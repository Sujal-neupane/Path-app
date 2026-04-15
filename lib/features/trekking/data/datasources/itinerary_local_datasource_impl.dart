import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/core/errors/exceptions.dart';
import '../models/itinerary_model.dart';
import 'itinerary_local_datasource.dart';

/// Implementation of ItineraryLocalDataSource using SharedPreferences
///
/// Caching strategy:
/// - TTL: 1 hour (configurable)
/// - Keys: "itinerary_{id}", "itineraries_list", "active_itinerary_id", etc.
/// - Timestamps: Track cache age for expiration
///
/// Fallback on corruption: Clear affected key and retry or return empty
class ItineraryLocalDataSourceImpl implements ItineraryLocalDataSource {
  final SharedPreferences _prefs;
  
  static const Duration _defaultTTL = Duration(hours: 1);
  static const String _keyUserItineraries = 'itinerary_user_list';
  static const String _keyActiveItineraryId = 'itinerary_active_id';
  static const String _keyOfflineItineraries = 'itinerary_offline_list';
  static const String _keyTimestamp = 'itinerary_timestamp';

  ItineraryLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<void> cacheUserItineraries(List<ItineraryModel> itineraries) async {
    try {
      final jsonList = itineraries.map((i) => i.toJson()).toList();
      final encodedList = jsonEncode(jsonList);
      
      await Future.wait([
        _prefs.setString(_keyUserItineraries, encodedList),
        _prefs.setInt(
          '${_keyTimestamp}_user_list',
          DateTime.now().millisecondsSinceEpoch,
        ),
      ]);
    } catch (e) {
      throw CacheCorruptedException(key: _keyUserItineraries);
    }
  }

  @override
  Future<List<ItineraryModel>> getCachedUserItineraries() async {
    try {
      final cached = _prefs.getString(_keyUserItineraries);
      
      if (cached == null || cached.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(cached) as List<dynamic>;
      return decoded
          .map((json) => ItineraryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await _prefs.remove(_keyUserItineraries);
      throw CacheCorruptedException(key: _keyUserItineraries);
    }
  }

  @override
  Future<void> cacheItinerary(ItineraryModel itinerary) async {
    try {
      final key = _generateItineraryKey(itinerary.id);
      final json = jsonEncode(itinerary.toJson());
      
      await Future.wait([
        _prefs.setString(key, json),
        _prefs.setInt(
          '${_keyTimestamp}_${itinerary.id}',
          DateTime.now().millisecondsSinceEpoch,
        ),
      ]);
    } catch (e) {
      throw CacheCorruptedException(key: itinerary.id);
    }
  }

  @override
  Future<ItineraryModel?> getCachedItinerary(String itineraryId) async {
    try {
      final key = _generateItineraryKey(itineraryId);
      final cached = _prefs.getString(key);
      
      if (cached == null || cached.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      return ItineraryModel.fromJson(decoded);
    } catch (e) {
      await _prefs.remove(_generateItineraryKey(itineraryId));
      throw CacheCorruptedException(key: itineraryId);
    }
  }

  @override
  Future<bool> isCacheExpired({String? key, Duration? customTTL}) async {
    try {
      final ttl = customTTL ?? _defaultTTL;
      final timestampKey = key != null ? '${_keyTimestamp}_$key' : _keyTimestamp;
      final cachedTimestamp = _prefs.getInt(timestampKey);
      
      if (cachedTimestamp == null) {
        return true; // No timestamp = treat as expired
      }

      final cacheAge = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(cachedTimestamp));
      
      return cacheAge.compareTo(ttl) > 0;
    } catch (e) {
      return true; // On error, treat as expired
    }
  }

  @override
  Future<void> clearAllItineraryCache() async {
    try {
      final keys = _prefs.getKeys();
      final itineraryKeys = keys
          .where((k) => k.toString().startsWith('itinerary_'))
          .toList();
      
      for (final key in itineraryKeys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw CacheCorruptedException(key: 'all_itineraries');
    }
  }

  @override
  Future<void> clearItineraryCache(String itineraryId) async {
    try {
      final key = _generateItineraryKey(itineraryId);
      await Future.wait([
        _prefs.remove(key),
        _prefs.remove('${_keyTimestamp}_$itineraryId'),
      ]);
    } catch (e) {
      throw CacheCorruptedException(key: itineraryId);
    }
  }

  @override
  Future<void> cacheActiveItineraryId(String itineraryId) async {
    try {
      await _prefs.setString(_keyActiveItineraryId, itineraryId);
    } catch (e) {
      throw CacheCorruptedException(key: _keyActiveItineraryId);
    }
  }

  @override
  Future<String?> getCachedActiveItineraryId() async {
    try {
      return _prefs.getString(_keyActiveItineraryId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveOfflineItinerary(ItineraryModel itinerary) async {
    try {
      // Store the itinerary
      await cacheItinerary(itinerary);

      // Add to offline list
      final offlineList = await getOfflineItineraries();
      if (!offlineList.any((i) => i.id == itinerary.id)) {
        offlineList.add(itinerary);
        final ids = offlineList.map((i) => i.id).toList();
        final encoded = jsonEncode(ids);
        await _prefs.setString(_keyOfflineItineraries, encoded);
      }
    } catch (e) {
      throw CacheCorruptedException(key: itinerary.id);
    }
  }

  @override
  Future<List<ItineraryModel>> getOfflineItineraries() async {
    try {
      final cached = _prefs.getString(_keyOfflineItineraries);
      
      if (cached == null || cached.isEmpty) {
        return [];
      }

      final List<dynamic> ids = jsonDecode(cached) as List<dynamic>;
      final List<ItineraryModel> result = [];

      for (final id in ids) {
        final itinerary = await getCachedItinerary(id.toString());
        if (itinerary != null) {
          result.add(itinerary);
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> removeOfflineItinerary(String itineraryId) async {
    try {
      // Remove from offline list
      final offlineList = await getOfflineItineraries();
      offlineList.removeWhere((i) => i.id == itineraryId);
      
      final ids = offlineList.map((i) => i.id).toList();
      if (ids.isEmpty) {
        await _prefs.remove(_keyOfflineItineraries);
      } else {
        final encoded = jsonEncode(ids);
        await _prefs.setString(_keyOfflineItineraries, encoded);
      }

      // Remove cache
      await clearItineraryCache(itineraryId);
    } catch (e) {
      throw CacheCorruptedException(key: itineraryId);
    }
  }

  @override
  Future<void> cacheDayCompletion({
    required String itineraryId,
    required int dayNumber,
    required DateTime completedAt,
  }) async {
    try {
      final key = '${_keyTimestamp}_day_completion_${itineraryId}_$dayNumber';
      await _prefs.setString(key, completedAt.toIso8601String());
    } catch (e) {
      throw CacheCorruptedException(key: itineraryId);
    }
  }

  @override
  Future<DateTime?> getCachedDayCompletion({
    required String itineraryId,
    required int dayNumber,
  }) async {
    try {
      final key = '${_keyTimestamp}_day_completion_${itineraryId}_$dayNumber';
      final cached = _prefs.getString(key);
      
      if (cached == null) return null;
      
      return DateTime.parse(cached);
    } catch (e) {
      return null;
    }
  }

  /// Generate cache key for specific itinerary
  String _generateItineraryKey(String itineraryId) => 'itinerary_$itineraryId';
}
