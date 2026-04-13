import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/gamification/achievement_service.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Gamification widgets to enhance user engagement and motivation
/// Shows streaks, achievements, and motivational messages

/// Provider for user achievements  
final userAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = AchievementService.instance;
  return service.getUnlockedAchievements();
});

/// Provider for user streak
final userStreakProvider = FutureProvider<int>((ref) async {
  final service = AchievementService.instance;
  return service.getCurrentStreak();
});

/// Provider for user stats
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final service = AchievementService.instance;
  return service.getUserStats();
});

/// Provider for motivational message
final motivationalMessageProvider = FutureProvider<String>((ref) async {
  final service = AchievementService.instance;
  return service.getMotivationalMessage();
});

/// Streak indicator widget - Shows current streak with fire emoji
class StreakIndicator extends ConsumerWidget {
  const StreakIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(userStreakProvider);

    return streakAsync.when(
      loading: () => _buildSkeletonStreak(),
      error: (_, __) => const SizedBox.shrink(), // Gracefully hide on error
      data: (streak) {
        if (streak == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            // Show streak details modal
            _showStreakDialog(context, streak);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B6B),
                  const Color(0xFFFF8E72),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$streak days',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper to show streak dialog
  void _showStreakDialog(BuildContext context, int streak) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          '🔥 On Fire!',
          style: AppTextStyles.h3.copyWith(
            color: const Color(0xFFFF6B6B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have a $streak day streak!',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Keep up the momentum 🚀',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonStreak() {
    return Container(
      width: 90,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

/// Achievements grid - Shows unlocked achievements as badges
class AchievementsGrid extends ConsumerWidget {
  final int maxDisplay;

  const AchievementsGrid({
    super.key,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(userAchievementsProvider);

    return achievementsAsync.when(
      loading: () => _buildSkeletonGrid(),
      error: (_, __) => const SizedBox.shrink(),
      data: (achievements) {
        if (achievements.isEmpty) return const SizedBox.shrink();

        final displayed = achievements.take(maxDisplay).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: AppTextStyles.caption.copyWith(
                color: LightColors.forestPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...displayed.map((achievement) => _buildAchievementBadge(achievement, context)),
                if (achievements.length > maxDisplay) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: LightColors.stoneWhite,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '+${achievements.length - maxDisplay}',
                        style: AppTextStyles.caption.copyWith(
                          color: LightColors.forestPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementBadge(Achievement achievement, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showAchievementDialog(context, achievement);
      },
      child: Tooltip(
        message: achievement.title,
        child: Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LightColors.forestPrimary,
                LightColors.forestPrimary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: LightColors.forestPrimary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(_getEmojiForAchievement(achievement.id), style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }

  /// Helper to show achievement dialog
  void _showAchievementDialog(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Text(
            _getEmojiForAchievement(achievement.id),
            style: const TextStyle(fontSize: 48),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.title,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return Row(
      children: [
        for (int i = 0; i < maxDisplay; i++) ...[
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ],
    );
  }

  String _getEmojiForAchievement(String id) {
    return {
      'first_trek': '🥾',
      'five_treks': '🌄',
      'ten_treks': '⛰️',
      'altitude_seeker': '🚁',
      'endurance_master': '💪',
    }[id] ?? '⭐';
  }
}

/// Motivational message widget - Shows personalized motivation
class MotivationalMessage extends ConsumerWidget {
  const MotivationalMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(motivationalMessageProvider);

    return messageAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (message) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LightColors.forestPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: LightColors.forestPrimary.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            message,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.forestPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
