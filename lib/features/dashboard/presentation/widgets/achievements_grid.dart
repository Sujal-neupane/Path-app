import 'package:flutter/material.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// Achievement card showing earned badges and streaks
class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const AchievementCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.accentColor = LightColors.forestPrimary,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: LightColors.surfaceWhite,
          border: Border.all(
            color: LightColors.dividerLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(Radius.lg),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radius.md),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            SizedBox(width: Spacing.lg),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Spacing.xs),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              color: LightColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid of achievement badges
class AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback? onViewAll;

  const AchievementsGrid({
    Key? key,
    required this.achievements,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.forestPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: Spacing.md),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: Spacing.md,
            mainAxisSpacing: Spacing.md,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _AchievementBadge(achievement: achievement);
          },
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: achievement.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radius.md),
              border: Border.all(
                color: achievement.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                achievement.icon,
                color: achievement.color,
                size: 28,
              ),
            ),
          ),
        ),
        SizedBox(height: Spacing.xs),
        Text(
          achievement.label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: LightColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class Achievement {
  final String label;
  final IconData icon;
  final Color color;
  final bool unlocked;

  Achievement({
    required this.label,
    required this.icon,
    required this.color,
    this.unlocked = false,
  });
}
