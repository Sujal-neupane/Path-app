import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Gamification Service - keeps users engaged with achievements and streaks
/// 
/// Features:
/// - Streak tracking (consecutive days of activity)
/// - Achievement system (badges for milestones)
/// - Points/rewards system
/// - User stats tracking
/// - Motivational messages based on progress
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();

  factory AchievementService() {
    return _instance;
  }

  AchievementService._internal();

  static AchievementService get instance => _instance;

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Storage keys
  static const String _streakKey = 'user_streak_data';
  static const String _achievementsKey = 'user_achievements';
  static const String _statsKey = 'user_stats';

  Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    // Migrate legacy data if needed
    await _checkAndUpdateStreakDaily();
  }

  /// Record a trek activity (automatically updates streak)
  Future<void> recordActivity(String activityType) async {
    if (!_initialized) throw Exception('AchievementService not initialized');

    try {
      // Update streak
      await _updateStreak();

      // Check for achievements
      await _checkAndUnlockAchievements(activityType);

      // Update stats
      await _incrementStat(activityType);
    } catch (e) {
      print('⚠️ Achievement tracking (non-critical): $e');
      // Non-blocking - don't crash if gamification fails
    }
  }

  /// Get current user stats
  Future<UserStats> getUserStats() async {
    if (!_initialized) throw Exception('AchievementService not initialized');

    try {
      final statsJson = _prefs.getString(_statsKey);
      if (statsJson != null) {
        final data = jsonDecode(statsJson) as Map<String, dynamic>;
        return UserStats.fromJson(data);
      }

      // First time user
      return UserStats();
    } catch (e) {
      print('⚠️ Failed to load user stats: $e');
      return UserStats();
    }
  }

  /// Get user's current streak
  Future<int> getCurrentStreak() async {
    if (!_initialized) throw Exception('AchievementService not initialized');

    try {
      final streakJson = _prefs.getString(_streakKey);
      if (streakJson != null) {
        final data = jsonDecode(streakJson) as Map<String, dynamic>;
        final streak = StreakData.fromJson(data);

        // Check if streak is still valid (consecutive days)
        final today = DateTime.now();
        final lastActivity = DateTime.parse(streak.lastActivityDate);
        final daysDiff = today.difference(lastActivity).inDays;

        if (daysDiff == 0) {
          // Same day - return current streak
          return streak.currentStreak;
        } else if (daysDiff == 1) {
          // Next day - streak continues
          return streak.currentStreak;
        } else {
          // Streak broken (2+ days passed)
          return 0;
        }
      }

      return 0;
    } catch (e) {
      print('⚠️ Failed to get current streak: $e');
      return 0;
    }
  }

  /// Get all unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    if (!_initialized) throw Exception('AchievementService not initialized');
    
    try {
      final achievementsJson = _prefs.getString(_achievementsKey);
      if (achievementsJson != null) {
        final data = jsonDecode(achievementsJson) as List<dynamic>;
        return data
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('⚠️ Failed to load achievements: $e');
      return [];
    }
  }

  /// Get motivational message based on progress
  Future<String> getMotivationalMessage() async {
    final streak = await getCurrentStreak();
    final stats = await getUserStats();

    if (streak >= 30) return '🔥 30-day streak! You\'re unstoppable!';
    if (streak >= 7) return '🚀 Week-long streak! Keep it up!';
    if (streak >= 3) return '⭐ 3-day streak! Building momentum!';
    if (stats.totalActivities == 1) return '🎉 Welcome! You\'re on your journey!';
    if (stats.totalActivities < 10) return '💪 ${stats.totalActivities} activities down. Keep going!';

    return 'Ready for your next adventure? 🏔️';
  }

  // ── Private Helpers ──

  Future<void> _updateStreak() async {
    try {
      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0]; // YYYY-MM-DD

      final streakJson = _prefs.getString(_streakKey);
      late StreakData streak;

      if (streakJson != null) {
        final data = jsonDecode(streakJson) as Map<String, dynamic>;
        streak = StreakData.fromJson(data);

        final lastActivity = DateTime.parse(streak.lastActivityDate);
        final daysDiff = now.difference(lastActivity).inDays;

        if (daysDiff == 0) {
          // Same day - no change
        } else if (daysDiff == 1) {
          // Next day - increment streak
          streak = streak.copyWith(
            currentStreak: streak.currentStreak + 1,
            lastActivityDate: today,
          );
        } else {
          // Streak broken - reset
          streak = StreakData(
            currentStreak: 1,
            longestStreak: streak.longestStreak,
            lastActivityDate: today,
          );
        }
      } else {
        // First activity
        streak = StreakData(
          currentStreak: 1,
          longestStreak: 1,
          lastActivityDate: today,
        );
      }

      // Update longest streak if current exceeds it
      if (streak.currentStreak > streak.longestStreak) {
        streak = streak.copyWith(longestStreak: streak.currentStreak);
      }

      await _prefs.setString(_streakKey, jsonEncode(streak.toJson()));
    } catch (e) {
      print('⚠️ Streak update failed: $e');
    }
  }

  Future<void> _checkAndUpdateStreakDaily() async {
    try {
      await _updateStreak();
    } catch (e) {
      print('⚠️ Daily streak check failed: $e');
    }
  }

  Future<void> _checkAndUnlockAchievements(String activityType) async {
    try {
      final stats = await getUserStats();
      final unlockedAchievements = await getUnlockedAchievements();
      final unlockedIds =
          unlockedAchievements.map((a) => a.id).toSet();

      final newAchievements = <Achievement>[];

      // Define achievement criteria
      final achievementCriteria = {
        'first_trek': (stats) => stats.totalActivities >= 1,
        'five_treks': (stats) => stats.totalActivities >= 5,
        'ten_treks': (stats) => stats.totalActivities >= 10,
        'altitude_seeker': (stats) =>
            stats.maxAltitudeReached >= 4000, // 4000m+
        'endurance_master': (stats) => stats.totalDistance >= 100, // 100km+
      };

      for (final entry in achievementCriteria.entries) {
        final achievementId = entry.key;
        final condition = entry.value;

        if (!unlockedIds.contains(achievementId) && condition(stats)) {
          newAchievements.add(
            Achievement(
              id: achievementId,
              title: _getTitleForAchievement(achievementId),
              description: _getDescriptionForAchievement(achievementId),
              unlockedAt: DateTime.now(),
            ),
          );
        }
      }

      if (newAchievements.isNotEmpty) {
        // Add to existing achievements
        final updated = [...unlockedAchievements, ...newAchievements];
        await _prefs.setString(
          _achievementsKey,
          jsonEncode(updated.map((a) => a.toJson()).toList()),
        );
      }
    } catch (e) {
      print('⚠️ Achievement unlock check failed: $e');
    }
  }

  Future<void> _incrementStat(String statType) async {
    try {
      final stats = await getUserStats();
      final updated = stats.copyWith(
        totalActivities: stats.totalActivities + 1,
      );

      await _prefs.setString(
        _statsKey,
        jsonEncode(updated.toJson()),
      );
    } catch (e) {
      print('⚠️ Stat increment failed: $e');
    }
  }

  String _getTitleForAchievement(String id) {
    return {
      'first_trek': 'First Steps',
      'five_treks': 'Trek Explorer',
      'ten_treks': 'Mountain Master',
      'altitude_seeker': 'Sky Chaser',
      'endurance_master': 'Iron Legs',
    }[id] ?? 'Unknown Achievement';
  }

  String _getDescriptionForAchievement(String id) {
    return {
      'first_trek': 'Completed your first trek',
      'five_treks': 'Completed 5 treks',
      'ten_treks': 'Completed 10 treks',
      'altitude_seeker': 'Reached 4000m altitude',
      'endurance_master': 'Walked 100km total',
    }[id] ?? 'Unknown';
  }
}

/// Data Models

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String lastActivityDate; // ISO format YYYY-MM-DD

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
  });

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastActivityDate,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActivityDate': lastActivityDate,
      };

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastActivityDate: json['lastActivityDate'] as String? ??
            DateTime.now().toIso8601String().split('T')[0],
      );
}

class UserStats {
  final int totalActivities;
  final double totalDistance; // in km
  final double maxAltitudeReached; // in meters
  final int achievementsUnlocked;
  final int totalAchievements;

  UserStats({
    this.totalActivities = 0,
    this.totalDistance = 0.0,
    this.maxAltitudeReached = 0.0,
    this.achievementsUnlocked = 0,
    this.totalAchievements = 5,
  });

  int get currentStreak => 0; // Calculated from StreakData

  UserStats copyWith({
    int? totalActivities,
    double? totalDistance,
    double? maxAltitudeReached,
    int? achievementsUnlocked,
  }) {
    return UserStats(
      totalActivities: totalActivities ?? this.totalActivities,
      totalDistance: totalDistance ?? this.totalDistance,
      maxAltitudeReached: maxAltitudeReached ?? this.maxAltitudeReached,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      totalAchievements: totalAchievements,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalActivities': totalActivities,
        'totalDistance': totalDistance,
        'maxAltitudeReached': maxAltitudeReached,
        'achievementsUnlocked': achievementsUnlocked,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalActivities: json['totalActivities'] as int? ?? 0,
        totalDistance: json['totalDistance'] as double? ?? 0.0,
        maxAltitudeReached: json['maxAltitudeReached'] as double? ?? 0.0,
        achievementsUnlocked: json['achievementsUnlocked'] as int? ?? 0,
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'unlockedAt': unlockedAt.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      );
}
