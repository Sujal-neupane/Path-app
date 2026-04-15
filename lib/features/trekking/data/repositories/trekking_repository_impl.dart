import 'package:path_app/core/errors/exceptions.dart';
import '../../domain/entities/trek.dart';
import '../../domain/repositories/trekking_repository.dart';
import '../datasources/trekking_local_datasource.dart';
import '../datasources/trekking_remote_datasource.dart';


/// Implementation of TrekkingRepository with offline-first pattern
///
/// Data flow:
/// 1. READ operations:
///    - Check local cache first (fastest)
///    - If cache expired or empty → Remote API
///    - Update cache on successful remote fetch
///    - Graceful fallback to stale cache if network unavailable
///
/// 2. WRITE operations (create/update/delete):
///    - Hit remote API immediately (source of truth)
///    - Update local cache after successful write
///    - Throw exception if network unavailable
///
/// Benefits:
/// - Instant UX for repeated views (cache hit)
/// - Works offline for previously cached data
/// - Automatic refresh on network return
/// - No redundant API calls within cache TTL
class TrekkingRepositoryImpl implements TrekkingRepository {
  final TrekkingRemoteDataSource _remoteDataSource;
  final TrekkingLocalDataSource _localDataSource;

  /// Cache validity window (1 hour by default)
  /// After this duration, cached data is considered stale
  static const Duration cacheTtl = Duration(hours: 1);

  TrekkingRepositoryImpl({
    required TrekkingRemoteDataSource remoteDataSource,
    required TrekkingLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<Trek>> getAllTreks({
    int page = 1,
    int pageSize = 10,
    String? locationFilter,
    String? difficultyFilter,
  }) async {
    // Pattern: Check cache first for instant UX
    try {
      // Try to get from local cache
      final cachedTreks = await _localDataSource.getCachedTreks(page);

      // If cache exists and not expired, return immediately
      if (cachedTreks.isNotEmpty && !await _localDataSource.isCacheExpired()) {
        return cachedTreks.map((model) => model.toDomain()).toList();
      }
    } catch (e) {
      // Cache corrupted? Continue to remote fetch
      debugLog('Cache read failed: $e, falling back to remote API');
    }

    // Cache miss or expired → Fetch from remote API
    try {
      final response = await _remoteDataSource.getAllTreks(
        page: page,
        pageSize: pageSize,
        locationFilter: locationFilter,
        difficultyFilter: difficultyFilter,
      );

      // Cache the fresh data immediately (fire-and-forget)
      _localDataSource
          .cacheTreks(response.data, page)
          .catchError((_) => debugLog('Cache write failed'));

      // Return domain entities
      return response.data.map((model) => model.toDomain()).toList();
    } on NetworkException {
      // Network unavailable - try stale cache as fallback
      final staleCachedTreks = await _localDataSource.getCachedTreks(page);
      if (staleCachedTreks.isNotEmpty) {
        debugLog(
          'Network unavailable, using stale cache (${staleCachedTreks.length} treks)',
        );
        return staleCachedTreks.map((model) => model.toDomain()).toList();
      }

      // No cache available - rethrow network error
      rethrow;

    }
  }

  @override
  Future<Trek> getTrekById(String trekId) async {
    // Check local cache first
    try {
      final cachedTrek = await _localDataSource.getCachedTrek(trekId);
      if (cachedTrek != null && !await _localDataSource.isCacheExpired()) {
        return cachedTrek.toDomain();
      }
    } catch (e) {
      debugLog('Cache lookup failed for trek $trekId: $e');
    }

    // Fetch from remote API
    try {
      final trekModel = await _remoteDataSource.getTrekById(trekId);

      // Cache immediately
      _localDataSource.cacheTrek(trekModel).catchError(
            (_) => debugLog('Failed to cache trek $trekId'),
          );

      return trekModel.toDomain();
    } on NetworkException {
      // Network down - try stale cache
      final staleTrek = await _localDataSource.getCachedTrek(trekId);
      if (staleTrek != null) {
        debugLog('Network unavailable for trek $trekId, using cache');
        return staleTrek.toDomain();
      }
      rethrow;
    }
  }

  @override
  Future<Trek> createTrek(Trek trek) async {
    // Writes ALWAYS go to remote first (source of truth)
    // Network must be available for creates
    if (trek.createdBy.isEmpty) {
      throw ValidationException(
        errors: ['Trek must have createdBy user ID'],
      );
    }

    final trekData = _trekToMap(trek);

    try {
      // Hit backend API
      final createdModel = await _remoteDataSource.createTrek(trekData);

      // Cache after successful create
      _localDataSource.cacheTrek(createdModel).catchError(
            (_) => debugLog('Failed to cache newly created trek'),
          );

      return createdModel.toDomain();
    } on ServerException catch (e) {
      // Validation errors from backend
      if (e.statusCode == 400) {
        throw ValidationException(
          errors: ['Trek validation error: ${e.message}'],
        );
      }
      rethrow;
    }
  }

  @override
  Future<Trek> updateTrek(String trekId, Map<String, dynamic> updates) async {
    // Writes go to remote first
    try {
      final updatedModel = await _remoteDataSource.updateTrek(trekId, updates);

      // Update cache
      _localDataSource.cacheTrek(updatedModel).catchError(
            (_) => debugLog('Failed to update trek cache'),
          );

      return updatedModel.toDomain();
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        throw GenericAppException(
          message: 'Trek not found',
        );
      }
      if (e.statusCode == 403) {
        throw GenericAppException(
          message: 'Not authorized to update this trek',
        );
      }
      rethrow;
    }
  }

  @override
  Future<bool> deleteTrek(String trekId) async {
    try {
      final success = await _remoteDataSource.deleteTrek(trekId);

      // Remove from cache
      if (success) {
        _localDataSource.removeOfflineTrek(trekId).catchError(
              (_) => debugLog('Failed to remove trek from cache'),
            );
      }

      return success;
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        throw GenericAppException(
          message: 'Trek not found',
        );
      }
      if (e.statusCode == 403) {
        throw GenericAppException(
          message: 'Not authorized to delete this trek',
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<Trek>> searchTreks(String query) async {
    if (query.isEmpty) {
      return [];
    }

    // Check cache first
    try {
      final cached = await _localDataSource.getCachedSearchResults(query);
      if (cached != null && !await _localDataSource.isCacheExpired()) {
        return cached.map((model) => model.toDomain()).toList();
      }
    } catch (e) {
      debugLog('Search cache lookup failed: $e');
    }

    // Fetch from remote
    try {
      final results = await _remoteDataSource.searchTreks(query);

      // Cache results
      _localDataSource.cacheSearchResults(
        query,
        results,
      ).catchError((_) => debugLog('Failed to cache search results'));

      return results.map((model) => model.toDomain()).toList();
    } on NetworkException {
      // Try cache
      final cached = await _localDataSource.getCachedSearchResults(query);
      if (cached != null) {
        debugLog('Network unavailable, using cached search results');
        return cached.map((model) => model.toDomain()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<Trek>> filterTreks({
    String? difficulty,
    int? maxDays,
    String? season,
  }) async {
    try {
      final results = await _remoteDataSource.filterTreks(
        difficulty: difficulty,
        maxDays: maxDays,
        season: season,
      );

      return results.map((model) => model.toDomain()).toList();
    } on NetworkException {
      // For filters, we can't meaningfully use stale cache
      // User is actively filtering, so they likely need fresh data
      debugLog('Network unavailable for filter operation');
      rethrow;
    }
  }

  @override
  Future<String> downloadTrekForOffline(String trekId) async {
    // First, ensure we have the trek data cached
    await getTrekById(trekId);

    try {
      // Download route data from backend
      final filePath = await _remoteDataSource.downloadTrekData(trekId);

      // Save for offline use
      final localPath = await _localDataSource.saveOfflineTrek(
        await _remoteDataSource.getTrekById(trekId),
        filePath,
      );

      return localPath;
    } on NetworkException {
      throw GenericAppException(
        message: 'Unable to download trek - network unavailable',
      );
    }
  }

  @override
  Future<List<Trek>> getOfflineTreks() async {
    try {
      final offlineTreks = await _localDataSource.getOfflineTreks();
      return offlineTreks.map((model) => model.toDomain()).toList();
    } catch (e) {
      debugLog('Failed to get offline treks: $e');
      return [];
    }
  }

  /// Convert domain Trek to API map for requests
  Map<String, dynamic> _trekToMap(Trek trek) {
    return {
      'name': trek.name,
      'location': trek.location,
      'description': trek.description,
      'totalDistance': trek.totalDistance,
      'totalElevationGain': trek.totalElevationGain,
      'maxAltitude': trek.maxAltitude,
      'estimatedDays': trek.estimatedDays,
      'difficultyRating': trek.difficultyRating,
      'bestSeason': trek.bestSeason,
      'routePoints': trek.routePoints
          .map((p) => {
                'name': p.name,
                'latitude': p.latitude,
                'longitude': p.longitude,
                'altitude': p.altitude,
                'distanceFromStart': p.distanceFromStart,
                'type': p.type,
                'estimatedHoursFromStart': p.estimatedHoursFromStart,
                'description': p.description,
                'difficultyLevel': p.difficultyLevel,
                'isHazardZone': p.isHazardZone,
                'hazardDescription': p.hazardDescription,
              })
          .toList(),
      'permitsRequired': trek.permitsRequired,
      'createdBy': trek.createdBy,
    };
  }

  /// Debug logging helper
  void debugLog(String message) {
    // In production, this could log to analytics/crash service
    // For now, just print in debug mode
    print('🔷 TrekkingRepository: $message');
  }
}
