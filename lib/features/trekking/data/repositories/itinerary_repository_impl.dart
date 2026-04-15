import 'package:flutter/foundation.dart';
import 'package:path_app/core/errors/exceptions.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../datasources/itinerary_local_datasource.dart';
import '../datasources/itinerary_remote_datasource.dart';

/// Implementation of ItineraryRepository with offline-first pattern
///
/// Data flow:
///
/// READ operations (getFoo):
///   1. Try local cache first (fastest, instant UI update)
///   2. If expired/missing → hit remote API
///   3. Cache result immediately (fire-and-forget)
///   4. If network fails → return stale cache
///   5. If no cache → rethrow error
///
/// WRITE operations (createFoo, updateFoo, deleteFoo):
///   1. Hit remote API always (source of truth must be remote)
///   2. Update local cache after success
///   3. If network fails → fail (user must retry when online)
///   4. No offline writes to prevent conflicts
///
/// Cache TTL: 1 hour (configurable per method)
class ItineraryRepositoryImpl implements ItineraryRepository {
  final ItineraryRemoteDataSource _remoteDataSource;
  final ItineraryLocalDataSource _localDataSource;

  ItineraryRepositoryImpl({
    required ItineraryRemoteDataSource remoteDataSource,
    required ItineraryLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<Itinerary>> getUserItineraries() async {
    try {
      // Try cache first
      final cached = await _localDataSource.getCachedUserItineraries();
      final isCacheValid =
          cached.isNotEmpty && !await _localDataSource.isCacheExpired();

      if (cached.isNotEmpty && isCacheValid) {
        debugLog('Returning cached user itineraries: ${cached.length} items');
        return cached.map((m) => m.toDomain()).toList();
      }

      // Cache miss/expired → fetch remote
      final models = await _remoteDataSource.getUserItineraries();

      // Cache async (fire-and-forget)
      _localDataSource.cacheUserItineraries(models).catchError(
            (e) => debugLog('Cache write failed: $e'),
          );

      return models.map((m) => m.toDomain()).toList();
    } on NetworkException {
      // Network error → try stale cache
      try {
        final staleCache = await _localDataSource.getCachedUserItineraries();
        if (staleCache.isNotEmpty) {
          debugLog('Using stale cache, ${staleCache.length} itineraries');
          return staleCache.map((m) => m.toDomain()).toList();
        }
      } catch (e) {
        debugLog('Stale cache read failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Itinerary> getItineraryById(String itineraryId) async {
    try {
      // Try cache first
      final cached = await _localDataSource.getCachedItinerary(itineraryId);
      final isCacheValid = !await _localDataSource.isCacheExpired(key: itineraryId);

      if (cached != null && isCacheValid) {
        debugLog('Returning cached itinerary: $itineraryId');
        return cached.toDomain();
      }

      // Cache miss/expired → fetch remote
      final model = await _remoteDataSource.getItineraryById(itineraryId);

      // Cache async
      _localDataSource.cacheItinerary(model).catchError(
            (e) => debugLog('Cache write failed: $e'),
          );

      return model.toDomain();
    } on NetworkException {
      // Network error → try stale cache
      try {
        final staleCache =
            await _localDataSource.getCachedItinerary(itineraryId);
        if (staleCache != null) {
          debugLog('Using stale cache for itinerary: $itineraryId');
          return staleCache.toDomain();
        }
      } catch (e) {
        debugLog('Stale cache read failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Itinerary> createItinerary({
    required String trekId,
    required String acclimatizationPreference,
    DateTime? startDate,
  }) async {
    // Validate inputs
    if (trekId.isEmpty) {
      throw ValidationException(errors: ['Trek ID is required']);
    }

    try {
      // Write always goes to remote
      final model = await _remoteDataSource.createItinerary(
        trekId: trekId,
        acclimatizationPreference: acclimatizationPreference,
        startDate: startDate,
      );

      // Cache immediately
      await _localDataSource.cacheItinerary(model);

      return model.toDomain();
    } on NetworkException {
      // Network errors propagate - no offline support for writes
      rethrow;
    } catch (e) {
      throw ValidationException(errors: ['Failed to create itinerary: $e']);
    }
  }

  @override
  Future<Itinerary> updateItinerary({
    required String itineraryId,
    required Map<String, dynamic> updates,
  }) async {
    // Validate inputs
    if (itineraryId.isEmpty) {
      throw ValidationException(errors: ['Itinerary ID is required']);
    }
    if (updates.isEmpty) {
      throw ValidationException(errors: ['No updates provided']);
    }

    try {
      // Write always goes to remote
      final model = await _remoteDataSource.updateItinerary(
        itineraryId: itineraryId,
        updates: updates,
      );

      // Cache immediately
      await _localDataSource.cacheItinerary(model);

      return model.toDomain();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ValidationException(errors: ['Failed to update itinerary: $e']);
    }
  }

  @override
  Future<bool> deleteItinerary(String itineraryId) async {
    if (itineraryId.isEmpty) {
      throw ValidationException(errors: ['Itinerary ID is required']);
    }

    try {
      // Write always goes to remote
      final success = await _remoteDataSource.deleteItinerary(itineraryId);

      if (success) {
        // Clear from cache
        await _localDataSource.clearItineraryCache(itineraryId);
      }

      return success;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 500,
        message: 'Delete failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<Itinerary> setActiveItinerary(String itineraryId) async {
    if (itineraryId.isEmpty) {
      throw ValidationException(errors: ['Itinerary ID is required']);
    }

    try {
      // Activate on remote
      final model = await _remoteDataSource.setActiveItinerary(itineraryId);

      // Cache the itinerary and the active ID
      await Future.wait([
        _localDataSource.cacheItinerary(model),
        _localDataSource.cacheActiveItineraryId(itineraryId),
      ]);

      return model.toDomain();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 500,
        message: 'Failed to activate itinerary: ${e.toString()}',
      );
    }
  }

  @override
  Future<Itinerary?> getActiveItinerary() async {
    try {
      // Try remote first (active should always sync)
      final model = await _remoteDataSource.getActiveItinerary();

      if (model != null) {
        // Cache and ID
        await Future.wait([
          _localDataSource.cacheItinerary(model),
          _localDataSource.cacheActiveItineraryId(model.id),
        ]);
        return model.toDomain();
      }

      return null;
    } on NetworkException {
      // Network error → try stale cache
      try {
        final cachedId = await _localDataSource.getCachedActiveItineraryId();
        if (cachedId != null) {
          final staleCache =
              await _localDataSource.getCachedItinerary(cachedId);
          if (staleCache != null) {
            return staleCache.toDomain();
          }
        }
      } catch (e) {
        debugLog('Stale active itinerary fetch failed: $e');
      }
      return null;
    }
  }

  @override
  Future<DateTime?> getLastCompletedDayDate(String itineraryId) async {
    try {
      return await _remoteDataSource.getLastCompletedDayDate(itineraryId);
    } on NetworkException {
      // Try cache
      try {
        return await _localDataSource.getCachedDayCompletion(
          itineraryId: itineraryId,
          dayNumber: 1, // Get latest completion
        );
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<bool> completeDayInItinerary({
    required String itineraryId,
    required int dayNumber,
  }) async {
    try {
      final success = await _remoteDataSource.completeDayInItinerary(
        itineraryId: itineraryId,
        dayNumber: dayNumber,
      );

      if (success) {
        // Cache the completion
        await _localDataSource.cacheDayCompletion(
          itineraryId: itineraryId,
          dayNumber: dayNumber,
          completedAt: DateTime.now(),
        );
      }

      return success;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<List<Itinerary>> searchItineraries({
    String? query,
    String? difficultyFilter,
    DateTime? afterDate,
  }) async {
    try {
      // Search hits remote (always fresh)
      final models = await _remoteDataSource.searchItineraries(
        query: query,
        difficultyFilter: difficultyFilter,
        afterDate: afterDate,
      );

      // No caching for search results (transient)
      return models.map((m) => m.toDomain()).toList();
    } on NetworkException {
      // Search requires network - no fallback
      rethrow;
    }
  }

  @override
  Future<bool> cacheItineraryForOffline(String itineraryId) async {
    try {
      // Fetch full itinerary to ensure it's fresh
      final _ = await getItineraryById(itineraryId);
      
      // Convert to model and cache for offline
      final model = await _remoteDataSource.getItineraryById(itineraryId);
      await _localDataSource.saveOfflineItinerary(model);

      return true;
    } catch (e) {
      throw ServerException(
        statusCode: 500,
        message: 'Failed to cache for offline: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Itinerary>> getOfflineItineraries() async {
    try {
      final models = await _localDataSource.getOfflineItineraries();
      return models.map((m) => m.toDomain()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> clearOfflineItinerary(String itineraryId) async {
    try {
      await _localDataSource.removeOfflineItinerary(itineraryId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

void debugLog(String message) {
  if (kDebugMode) {
    print('[ItineraryRepo] $message');
  }
}
