import 'package:flutter/material.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'animated_stat_counter.dart';

/// Section showing key statistics with animated counters
class StatsOverviewSection extends StatelessWidget {
  final int totalTreks;
  final int totalElevationM;
  final int totalDays;
  final Duration? animationDuration;

  const StatsOverviewSection({
    super.key,
    required this.totalTreks,
    required this.totalElevationM,
    required this.totalDays,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Total Treks
          Expanded(
            child: Center(
              child: AnimatedStatCounter(
                finalValue: totalTreks,
                label: 'Treks',
                accentColor: LightColors.forestPrimary,
                duration: animationDuration ?? AnimationDuration.long,
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 60,
            color: LightColors.dividerLight,
            margin: EdgeInsets.symmetric(horizontal: Spacing.md),
          ),
          // Total Elevation
          Expanded(
            child: Center(
              child: AnimatedStatCounter(
                finalValue: totalElevationM,
                label: 'Elevation',
                suffix: 'm',
                accentColor: LightColors.altitudeBlue,
                duration: animationDuration ?? AnimationDuration.long,
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 60,
            color: LightColors.dividerLight,
            margin: EdgeInsets.symmetric(horizontal: Spacing.md),
          ),
          // Total Days
          Expanded(
            child: Center(
              child: AnimatedStatCounter(
                finalValue: totalDays,
                label: 'Days',
                accentColor: LightColors.peakAmber,
                duration: animationDuration ?? AnimationDuration.long,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card showing personal records
class PersonalRecordsCard extends StatelessWidget {
  final int? highestAltitude;
  final double? longestDistance;
  final int? fastestDayElevation;
  final VoidCallback? onViewAll;

  const PersonalRecordsCard({
    super.key,
    this.highestAltitude,
    this.longestDistance,
    this.fastestDayElevation,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Records',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColors.textPrimary,
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.forestPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: Spacing.lg),
          if (highestAltitude != null) ...[
            _RecordRow(
              icon: Icons.trending_up_rounded,
              label: 'Highest Altitude',
              value: '$highestAltitude m',
              color: LightColors.altitudeBlue,
            ),
            SizedBox(height: Spacing.md),
          ],
          if (longestDistance != null) ...[
            _RecordRow(
              icon: Icons.straighten_rounded,
              label: 'Longest Distance',
              value: '${longestDistance?.toStringAsFixed(1)} km',
              color: LightColors.forestPrimary,
            ),
            SizedBox(height: Spacing.md),
          ],
          if (fastestDayElevation != null) ...[
            _RecordRow(
              icon: Icons.flash_on_rounded,
              label: 'Most Elevation Climbed',
              value: '$fastestDayElevation m',
              color: LightColors.peakAmber,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radius.sm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: Spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
