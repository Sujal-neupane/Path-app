import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/core/cache/secure_cache_service.dart';
import 'package:path_app/core/gamification/achievement_service.dart';

/// Application initialization service
/// Runs on app startup to setup all core services
class AppSetup {
  /// Store SharedPreferences instance for access by providers
  static SharedPreferences? _sharedPreferences;

  /// Get the initialized SharedPreferences instance
  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw UnimplementedError('SharedPreferences not yet initialized');
    }
    return _sharedPreferences!;
  }
  /// Initialize all core services
  ///
  /// Runs once at app startup and sets up:
  /// - SharedPreferences (local storage)
  /// - Cache layer (offline-first)
  /// - Gamification (achievements, streaks)  
  /// - Analytics (optional)
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      debugPrint('▶️ Starting app initialization...');

      // 0. Initialize SharedPreferences
      await _initializeSharedPreferences();
      debugPrint('✅ SharedPreferences initialized');

      // 1. Initialize cache service
      await _initializeCacheService();
      debugPrint('✅ Cache service initialized');

      // 2. Initialize gamification (depends on cache)
      await _initializeGamification();
      debugPrint('✅ Gamification service initialized');

      debugPrint('🚀 App initialization complete - all systems ready');
    } catch (e) {
      debugPrint('❌ Initialization error: $e');
      // Gracefully degrade - app still works with limited features
      rethrow;
    }
  }

  /// Initialize SharedPreferences for persistent local storage
  static Future<void> _initializeSharedPreferences() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      debugPrint('✔️ SharedPreferences ready');
    } catch (e) {
      debugPrint('❌ SharedPreferences initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize cache service with automatic cleanup
  static Future<void> _initializeCacheService() async {
    try {
      final cacheService = SecureCacheService.instance;
      await cacheService.initialize();

      // Auto-cleanup expired cache
      final cleanedCount = await cacheService.cleanupExpiredCache();
      if (cleanedCount > 0) {
        debugPrint('🗑️ Cleaned $cleanedCount expired cache entries');
      }

      debugPrint('✔️ Cache service ready');
    } catch (e) {
      debugPrint('❌ Cache initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize gamification service
  static Future<void> _initializeGamification() async {
    try {
      final achievementService = AchievementService.instance;
      await achievementService.initialize();

      // Load user stats
      final stats = await achievementService.getUserStats();
      debugPrint('📊 User streak: ${stats.currentStreak} days');
      debugPrint('🏆 Achievements unlocked: ${stats.achievementsUnlocked}/${stats.totalAchievements}');

      debugPrint('✔️ Gamification service ready');
    } catch (e) {
      debugPrint('⚠️ Gamification initialization (non-critical): $e');
      // Don't fail - gamification is optional
    }
  }
}
