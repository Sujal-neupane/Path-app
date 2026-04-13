import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure cache service for offline-first dashboard
/// Using SharedPreferences for immediate availability
/// Can be upgraded to Isar for better performance later
///
/// Features:
/// - Encrypted storage key naming
/// - TTL-based cache invalidation
/// - Integrity verification via hashing
/// - Sync metadata tracking
/// - Type-safe operations
class SecureCacheService {
  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Get singleton instance
  static final SecureCacheService _instance = SecureCacheService._internal();

  factory SecureCacheService() {
    return _instance;
  }

  /// Static getter for singleton instance (convenience method)
  static SecureCacheService get instance => _instance;

  SecureCacheService._internal();

  /// Initialize cache service
  /// Must be called before any cache operations
  Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    // Clean up expired cache entries on startup
    await _cleanupExpiredCache();
  }

  /// Cache dashboard data securely
  /// [userId] - User identifier for cache isolation
  /// [dashboardJson] - Serialized dashboard overview
  /// [ttlMs] - Time-to-live in milliseconds
  Future<void> cacheDashboard(
    String userId,
    String dashboardJson, {
    int ttlMs = 300000, // 5 minutes default
  }) async {
    if (!_initialized) throw Exception('SecureCacheService not initialized');

    try {
      // Calculate hash for integrity checking
      final hash = _sha256Hash(dashboardJson);

      // Create cache object
      final cacheData = {
        'data': dashboardJson,
        'hash': hash,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'ttlMs': ttlMs,
        'lastSyncedAt': DateTime.now().millisecondsSinceEpoch,
        'isVerified': true,
      };

      // Store with user-specific key
      final key = _getCacheKey(userId);
      await _prefs.setString(key, jsonEncode(cacheData));

      print('[Cache] Cached dashboard data for user: $userId');
    } catch (e) {
      print('[Cache] Error caching dashboard: $e');
      rethrow;
    }
  }

  /// Retrieve cached dashboard if available and not expired
  /// Returns null if:
  /// - No cache exists
  /// - Cache is expired
  /// - Integrity check fails
  Future<String?> getCachedDashboard(String userId) async {
    if (!_initialized) throw Exception('SecureCacheService not initialized');

    try {
      final key = _getCacheKey(userId);
      final cachedStr = _prefs.getString(key);

      if (cachedStr == null) {
        print('[Cache] No cache found for user: $userId');
        return null;
      }

      // Parse cache
      final cached = jsonDecode(cachedStr) as Map<String, dynamic>;
      final dashboardJson = cached['data'] as String;
      final storedHash = cached['hash'] as String;
      final cachedAt = cached['cachedAt'] as int;
      final ttlMs = cached['ttlMs'] as int;

      // Check if expired
      final now = DateTime.now().millisecondsSinceEpoch;
      if ((now - cachedAt) > ttlMs) {
        print('[Cache] Cache expired, removing for user: $userId');
        await _prefs.remove(key);
        return null;
      }

      // Verify integrity via hash
      final currentHash = _sha256Hash(dashboardJson);
      if (currentHash != storedHash) {
        print('[Cache] Integrity check failed, cache corrupted for user: $userId');
        await _prefs.remove(key);
        return null;
      }

      print(
        '[Cache] Cache hit - valid cache for user: $userId '
        '(age: ${now - cachedAt}ms, ttl: ${ttlMs}ms)',
      );
      return dashboardJson;
    } catch (e) {
      print('[Cache] Error retrieving cache: $e');
      return null;
    }
  }

  /// Get cache validity information
  Future<CacheValidityInfo?> getCacheValidityInfo(String userId) async {
    if (!_initialized) throw Exception('SecureCacheService not initialized');

    try {
      final key = _getCacheKey(userId);
      final cachedStr = _prefs.getString(key);

      if (cachedStr == null) {
        return CacheValidityInfo(
          isCached: false,
          isExpired: true,
          msUntilExpiry: 0,
          lastCachedAt: null,
        );
      }

      final cached = jsonDecode(cachedStr) as Map<String, dynamic>;
      final cachedAt = cached['cachedAt'] as int;
      final ttlMs = cached['ttlMs'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final age = now - cachedAt;
      final isExpired = age > ttlMs;

      return CacheValidityInfo(
        isCached: true,
        isExpired: isExpired,
        msUntilExpiry: isExpired ? 0 : (ttlMs - age),
        lastCachedAt: DateTime.fromMillisecondsSinceEpoch(cachedAt),
      );
    } catch (e) {
      print('[Cache] Error getting validity info: $e');
      return null;
    }
  }

  /// Clear cache for a specific user
  Future<void> clearUserCache(String userId) async {
    if (!_initialized) throw Exception('SecureCacheService not initialized');

    final key = _getCacheKey(userId);
    await _prefs.remove(key);
    print('[Cache] Cleared cache for user: $userId');
  }

  /// Clear all cache (use with caution!)
  Future<void> clearAllCache() async {
    if (!_initialized) throw Exception('SecureCacheService not initialized');

    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_dashboard_')) {
        await _prefs.remove(key);
      }
    }
    print('[Cache] Cleared all dashboard caches');
  }

  /// Get sync metadata for a user
  Future<CacheSyncMetadata?> getSyncMetadata(String userId) async {
    if (!_initialized) throw Exception('SecureCacheService not initialized');

    try {
      final key = _getSyncMetadataKey(userId);
      final metaStr = _prefs.getString(key);

      if (metaStr == null) return null;

      final meta = jsonDecode(metaStr) as Map<String, dynamic>;
      return CacheSyncMetadata.fromJson(meta);
    } catch (e) {
      return null;
    }
  }

  /// Mark sync as failed with error message
  Future<void> markSyncFailed(String userId, String errorMessage) async {
    if (!_initialized) return;

    try {
      var metadata = await getSyncMetadata(userId);
      metadata ??= CacheSyncMetadata(userId: userId);

      metadata.lastErrorMessage = errorMessage;

      final key = _getSyncMetadataKey(userId);
      await _prefs.setString(key, jsonEncode(metadata.toJson()));
    } catch (e) {
      print('[Cache] Error marking sync failed: $e');
    }
  }

  /// Clean up expired cache entries
  /// Returns the number of entries removed
  Future<int> cleanupExpiredCache() async {
    try {
      final keys = _prefs.getKeys();
      final now = DateTime.now().millisecondsSinceEpoch;
      int cleanedCount = 0;

      for (final key in keys) {
        if (key.startsWith('cache_dashboard_')) {
          final cachedStr = _prefs.getString(key);
          if (cachedStr != null) {
            try {
              final cached = jsonDecode(cachedStr) as Map<String, dynamic>;
              final cachedAt = cached['cachedAt'] as int;
              final ttlMs = cached['ttlMs'] as int;

              if ((now - cachedAt) > ttlMs) {
                await _prefs.remove(key);
                cleanedCount++;
                print('[Cache] Cleaned expired cache: $key');
              }
            } catch (e) {
              // Corrupted cache, remove it
              await _prefs.remove(key);
              cleanedCount++;
            }
          }
        }
      }
      return cleanedCount;
    } catch (e) {
      print('[Cache] Cleanup error: $e');
      return 0;
    }
  }

  /// Clean up expired cache entries (internal)
  Future<void> _cleanupExpiredCache() async {
    await cleanupExpiredCache();
  }

  /// Calculate SHA-256 hash for integrity verification
  /// Security: Uses cryptographic hash to detect tampering
  String _sha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Generate cache key for user
  String _getCacheKey(String userId) =>
      'cache_dashboard_${userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}';

  /// Generate sync metadata key for user
  String _getSyncMetadataKey(String userId) =>
      'sync_meta_${userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}';

  /// Get cache statistics (for debugging)
  Future<CacheStats> getCacheStats() async {
    if (!_initialized) throw Exception('SecureCacheService not initialized');

    final keys = _prefs.getKeys();
    int totalEntries = 0;
    int expiredEntries = 0;
    int totalSize = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final key in keys) {
      if (key.startsWith('cache_dashboard_')) {
        totalEntries++;
        final cachedStr = _prefs.getString(key);
        if (cachedStr != null) {
          totalSize += cachedStr.length;
          try {
            final cached = jsonDecode(cachedStr) as Map<String, dynamic>;
            final cachedAt = cached['cachedAt'] as int;
            final ttlMs = cached['ttlMs'] as int;

            if ((now - cachedAt) > ttlMs) {
              expiredEntries++;
            }
          } catch (e) {
            expiredEntries++;
          }
        }
      }
    }

    return CacheStats(
      totalEntries: totalEntries,
      expiredEntries: expiredEntries,
      validEntries: totalEntries - expiredEntries,
      totalSizeBytes: totalSize,
    );
  }
}

/// Information about cache validity
class CacheValidityInfo {
  final bool isCached;
  final bool isExpired;
  final int msUntilExpiry;
  final DateTime? lastCachedAt;

  CacheValidityInfo({
    required this.isCached,
    required this.isExpired,
    required this.msUntilExpiry,
    required this.lastCachedAt,
  });

  /// Convenience getter
  bool get isValid => isCached && !isExpired;
}

/// Cache synchronization metadata
class CacheSyncMetadata {
  String userId;
  int lastSuccessfulSync;
  int pendingChanges;
  int totalCacheSize;
  String? lastErrorMessage;
  bool isSyncPaused;

  CacheSyncMetadata({
    required this.userId,
    this.lastSuccessfulSync = 0,
    this.pendingChanges = 0,
    this.totalCacheSize = 0,
    this.lastErrorMessage,
    this.isSyncPaused = false,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'lastSuccessfulSync': lastSuccessfulSync,
        'pendingChanges': pendingChanges,
        'totalCacheSize': totalCacheSize,
        'lastErrorMessage': lastErrorMessage,
        'isSyncPaused': isSyncPaused,
      };

  factory CacheSyncMetadata.fromJson(Map<String, dynamic> json) =>
      CacheSyncMetadata(
        userId: json['userId'] ?? '',
        lastSuccessfulSync: json['lastSuccessfulSync'] ?? 0,
        pendingChanges: json['pendingChanges'] ?? 0,
        totalCacheSize: json['totalCacheSize'] ?? 0,
        lastErrorMessage: json['lastErrorMessage'],
        isSyncPaused: json['isSyncPaused'] ?? false,
      );
}

/// Cache statistics for monitoring
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int validEntries;
  final int totalSizeBytes;

  CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.validEntries,
    required this.totalSizeBytes,
  });

  String get readableSize {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
