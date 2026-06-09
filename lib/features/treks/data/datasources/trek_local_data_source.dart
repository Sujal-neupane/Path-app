import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

/// Cache key constants for trek data.
const String _treksCacheKey = 'cache_treks_catalog';
const String _treksCacheTimestampKey = 'cache_treks_catalog_ts';
const String _trekDetailCachePrefix = 'cache_trek_detail_';

/// Cache TTL — 30 minutes for trek catalog.
const int _cacheTtlMs = 30 * 60 * 1000;

/// Provider for the trek local data source.
final trekLocalDataSourceProvider = Provider<TrekLocalDataSource>((ref) {
  return TrekLocalDataSourceImpl();
});

/// Contract for local caching of trek data.
abstract class TrekLocalDataSource {
  /// Cache the full trek catalog list.
  Future<void> cacheTrekList(List<TrekSummary> treks);

  /// Retrieve cached trek list. Returns null if expired or absent.
  Future<List<TrekSummary>?> getCachedTrekList();

  /// Cache a single trek detail.
  Future<void> cacheTrekDetail(TrekSummary trek);

  /// Retrieve a cached trek detail by ID. Returns null if absent.
  Future<TrekSummary?> getCachedTrekDetail(String trekId);

  /// Clear all cached trek data.
  Future<void> clearCache();
}

/// Implementation using SharedPreferences for persistence.
class TrekLocalDataSourceImpl implements TrekLocalDataSource {
  @override
  Future<void> cacheTrekList(List<TrekSummary> treks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = treks.map((t) => t.toJson()).toList();
    await prefs.setString(_treksCacheKey, jsonEncode(jsonList));
    await prefs.setInt(
      _treksCacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<TrekSummary>?> getCachedTrekList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedStr = prefs.getString(_treksCacheKey);
    final timestamp = prefs.getInt(_treksCacheTimestampKey);

    if (cachedStr == null || timestamp == null) return null;

    // Check TTL expiry
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > _cacheTtlMs) {
      // Cache expired — remove stale data
      await prefs.remove(_treksCacheKey);
      await prefs.remove(_treksCacheTimestampKey);
      return null;
    }

    try {
      final decoded = jsonDecode(cachedStr) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((json) => TrekSummary.fromJson(json))
          .toList();
    } catch (e) {
      // Corrupted cache — clear it
      await prefs.remove(_treksCacheKey);
      await prefs.remove(_treksCacheTimestampKey);
      return null;
    }
  }

  @override
  Future<void> cacheTrekDetail(TrekSummary trek) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_trekDetailCachePrefix${trek.id}';
    await prefs.setString(key, jsonEncode(trek.toJson()));
  }

  @override
  Future<TrekSummary?> getCachedTrekDetail(String trekId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_trekDetailCachePrefix$trekId';
    final cachedStr = prefs.getString(key);

    if (cachedStr == null) return null;

    try {
      final json = jsonDecode(cachedStr) as Map<String, dynamic>;
      return TrekSummary.fromJson(json);
    } catch (e) {
      await prefs.remove(key);
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_treksCacheKey);
    await prefs.remove(_treksCacheTimestampKey);

    // Clear all trek detail caches
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_trekDetailCachePrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
