import 'package:flutter/material.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// Quick action card for common dashboard actions
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: LightColors.surfaceWhite,
          border: Border.all(color: LightColors.dividerLight, width: 1),
          borderRadius: BorderRadius.circular(Radius.lg),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radius.md),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            SizedBox(height: Spacing.md),
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
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid of quick action cards
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onExploreTreks;
  final VoidCallback onViewSaved;
  final VoidCallback onCreateItinerary;
  final VoidCallback onViewProfile;

  const QuickActionsGrid({
    super.key,
    required this.onExploreTreks,
    required this.onViewSaved,
    required this.onCreateItinerary,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w600,
            color: LightColors.textPrimary,
          ),
        ),
        SizedBox(height: Spacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: Spacing.lg,
          mainAxisSpacing: Spacing.lg,
          childAspectRatio: 0.95,
          children: [
            QuickActionCard(
              icon: Icons.explore_rounded,
              title: 'Explore Treks',
              description: 'Discover new adventures',
              accentColor: LightColors.forestPrimary,
              onTap: onExploreTreks,
            ),
            QuickActionCard(
              icon: Icons.bookmark_rounded,
              title: 'Saved Treks',
              description: 'Your bookmarks',
              accentColor: LightColors.peakAmber,
              onTap: onViewSaved,
            ),
            QuickActionCard(
              icon: Icons.calendar_month_rounded,
              title: 'Create Plan',
              description: 'Build an itinerary',
              accentColor: LightColors.altitudeBlue,
              onTap: onCreateItinerary,
            ),
            QuickActionCard(
              icon: Icons.person_rounded,
              title: 'Profile',
              description: 'View your stats',
              accentColor: LightColors.sosRed,
              onTap: onViewProfile,
            ),
          ],
        ),
      ],
    );
  }
}
