import 'dart:convert';
import 'package:path_app/core/errors/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trek_api_model.dart';
import 'trekking_local_datasource.dart';

/// Implementation of TrekkingLocalDataSource using SharedPreferences
///
/// Caches trek data locally for:
/// - Instant UX on repeated views
/// - Offline fallback when network unavailable
/// - Reduced API calls within TTL window
///
/// Cache structure:
/// - Key: 'treks_page_$page' → JSON list of treks
/// - Key: 'trek_$trekId' → JSON trek with route points
/// - Key: 'trek_${trekId}_timestamp' → Last update timestamp
/// - Key: 'trek_search_$query' → JSON search results
/// - Key: 'offline_treks' → JSON list of trek IDs with route data
class TrekkingLocalDataSourceImpl implements TrekkingLocalDataSource {
  final SharedPreferences _prefs;

  // Cache key constants
  static const String _trekkingCachePrefix = 'trekking_';
  static const String _trek = '${_trekkingCachePrefix}trek_';
  static const String _trekList = '${_trekkingCachePrefix}treks_page_';
  static const String _trekTimestamp = '${_trekkingCachePrefix}trek_timestamp_';
  static const String _searchResults = '${_trekkingCachePrefix}search_';
  static const String _offlineTreksKey = '${_trekkingCachePrefix}offline_treks';
  static const String _lastCacheTimeKey = '${_trekkingCachePrefix}last_cache';

  TrekkingLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<void> cacheTreks(List<TrekApiModel> treks, int page) async {
    try {
      final jsonList = treks.map((t) => jsonEncode(t.toJson())).toList();
      await _prefs.setStringList('$_trekList$page', jsonList);
      await _prefs.setInt(_lastCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw CacheCorruptedException(
        key: 'treks_page_$page',
      );
    }
  }

  @override
  Future<List<TrekApiModel>> getCachedTreks(int page) async {
    try {
      final cached = _prefs.getStringList('$_trekList$page');
      if (cached == null || cached.isEmpty) {
        return [];
      }

      return cached
          .map((jsonStr) =>
              TrekApiModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheCorruptedException(
        key: 'treks_page_$page',
      );
    }
  }

  @override
  Future<void> cacheTrek(TrekApiModel trek) async {
    try {
      await _prefs.setString(
        '$_trek${trek.id}',
        jsonEncode(trek.toJson()),
      );
      await _prefs.setInt(
        '$_trekTimestamp${trek.id}',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheCorruptedException(
        key: trek.id,
      );
    }
  }

  @override
  Future<TrekApiModel?> getCachedTrek(String trekId) async {
    try {
      final cached = _prefs.getString('$_trek$trekId');
      if (cached == null) {
        return null;
      }

      return TrekApiModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    } catch (e) {
      throw CacheCorruptedException(
        key: trekId,
      );
    }
  }

  @override
  Future<DateTime?> getLastCacheTrek() async {
    final timestamp = _prefs.getInt(_lastCacheTimeKey);
    if (timestamp == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<void> clearTrekCache() async {
    try {
      final keys = _prefs.getKeys();
      final trekkingKeys = keys.where((key) => key.startsWith(_trekkingCachePrefix));

      for (final key in trekkingKeys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw CacheCorruptedException(
        key: 'all_treks',
      );
    }
  }

  @override
  Future<bool> isCacheExpired({Duration ttl = const Duration(hours: 1)}) async {
    final lastCache = await getLastCacheTrek();
    if (lastCache == null) {
      return true; // No cache yet
    }

    final now = DateTime.now();
    return now.difference(lastCache).compareTo(ttl) > 0;
  }

  @override
  Future<List<TrekApiModel>> getOfflineTreks() async {
    try {
      final offlineJsonList = _prefs.getStringList(_offlineTreksKey);
      if (offlineJsonList == null || offlineJsonList.isEmpty) {
        return [];
      }

      final offlineTreks = <TrekApiModel>[];
      for (final jsonStr in offlineJsonList) {
        try {
          final trek = TrekApiModel.fromJson(
            jsonDecode(jsonStr) as Map<String, dynamic>,
          );
          offlineTreks.add(trek);
        } catch (e) {
          // Skip corrupted entries
          continue;
        }
      }

      return offlineTreks;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> saveOfflineTrek(TrekApiModel trek, String gpxData) async {
    try {
      // Save trek data
      await cacheTrek(trek);

      // Add to offline list
      final offline = await getOfflineTreks();
      if (!offline.any((t) => t.id == trek.id)) {
        offline.add(trek);
        final jsonList = offline.map((t) => jsonEncode(t.toJson())).toList();
        await _prefs.setStringList(_offlineTreksKey, jsonList);
      }

      // In real implementation, save GPX file to device storage
      // For now, just return a cache key path
      final cacheKey = 'offline_trek_${trek.id}_data';
      await _prefs.setString(cacheKey, gpxData);

      return cacheKey;
    } catch (e) {
      throw CacheCorruptedException(
        key: trek.id,
      );
    }
  }

  @override
  Future<void> removeOfflineTrek(String trekId) async {
    try {
      final offline = await getOfflineTreks();
      offline.removeWhere((t) => t.id == trekId);

      if (offline.isEmpty) {
        await _prefs.remove(_offlineTreksKey);
      } else {
        final jsonList = offline.map((t) => jsonEncode(t.toJson())).toList();
        await _prefs.setStringList(_offlineTreksKey, jsonList);
      }

      // Clear trek data
      await _prefs.remove('$_trek$trekId');
      await _prefs.remove('$_trekTimestamp$trekId');
      await _prefs.remove('offline_trek_${trekId}_data');
    } catch (e) {
      throw CacheCorruptedException(
        key: trekId,
      );
    }
  }

  @override
  Future<List<TrekApiModel>?> getCachedSearchResults(String query) async {
    try {
      final cached = _prefs.getString('$_searchResults$query');
      if (cached == null) {
        return null;
      }

      final list = (jsonDecode(cached) as List)
          .cast<Map<String, dynamic>>()
          .map((item) => TrekApiModel.fromJson(item))
          .toList();

      return list;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheSearchResults(
    String query,
    List<TrekApiModel> results,
  ) async {
    try {
      final jsonList = jsonEncode(
        results.map((r) => r.toJson()).toList(),
      );
      await _prefs.setString('$_searchResults$query', jsonList);
    } catch (e) {
      // Search cache failures are non-critical
      print('Failed to cache search results: $e');
    }
  }
}
