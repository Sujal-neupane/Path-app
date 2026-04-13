import '../models/trek_api_model.dart';

/// Local trekking datasource interface
/// 
/// Handles caching and offline storage of trek data
/// Uses SharedPreferences or local SQLite DB
abstract class TrekkingLocalDataSource {
  /// Cache all treks locally
  /// 
  /// [treks]: Trek list to cache
  /// [page]: Page number (for pagination)
  /// Throws [CacheException] if cache write fails
  Future<void> cacheTreks(List<TrekApiModel> treks, int page);

  /// Get cached treks
  /// 
  /// [page]: Page number
  /// Returns cached trek list
  /// Throws [CacheException] if cache corrupted
  /// Returns empty list if no cache
  Future<List<TrekApiModel>> getCachedTreks(int page);

  /// Cache specific trek with full route data
  /// 
  /// [trek]: Trek to cache
  /// Throws [CacheException] if write fails
  Future<void> cacheTrek(TrekApiModel trek);

  /// Get single cached trek
  /// 
  /// [trekId]: Trek to retrieve
  /// Returns cached trek if exists
  /// Throws [CacheException] if corrupted
  /// Returns null if not cached
  Future<TrekApiModel?> getCachedTrek(String trekId);

  /// Get timestamp of last cached trek list
  /// 
  /// Returns null if never cached
  Future<DateTime?> getLastCacheTrek();

  /// Clear all trek cache
  Future<void> clearTrekCache();

  /// Check if cache is expired
  /// 
  /// Default TTL: 1 hour
  /// Returns true if cache should be refreshed
  Future<bool> isCacheExpired({Duration ttl = const Duration(hours: 1)});

  /// Get list of offline-available treks
  /// 
  /// Returns treks that have been downloaded with full route data
  Future<List<TrekApiModel>> getOfflineTreks();

  /// Save trek data for offline use
  /// 
  /// [trek]: Trek to save
  /// [gpxData]: GPS route data (for offline maps)
  /// Returns local file path
  Future<String> saveOfflineTrek(TrekApiModel trek, String gpxData);

  /// Remove trek from offline storage
  Future<void> removeOfflineTrek(String trekId);

  /// Get cached search results
  /// 
  /// [query]: Search query
  /// Returns previously cached search results if available
  Future<List<TrekApiModel>?> getCachedSearchResults(String query);

  /// Cache search results
  /// 
  /// [query]: Search term
  /// [results]: Search results to cache
  Future<void> cacheSearchResults(String query, List<TrekApiModel> results);
}
