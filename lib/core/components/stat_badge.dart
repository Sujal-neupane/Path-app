import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Unified stat component for displaying icon + label + value
///
/// Replaces scattered _StatItem, _DayStat, _ProfileStat patterns
/// Used across dashboard, trek details, and itinerary screens
enum StatBadgeSize { small, medium, large }

class StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;
  final StatBadgeSize size;
  final bool showBackground;

  const StatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
    this.size = StatBadgeSize.medium,
    this.showBackground = true,
  });

  /// Dimensions based on size
  Map<String, double> get _dimensions {
    switch (size) {
      case StatBadgeSize.small:
        return {
          'iconSize': 16,
          'containerSize': 32,
          'spacing': 6,
          'padding': 8,
        };
      case StatBadgeSize.medium:
        return {
          'iconSize': 20,
          'containerSize': 40,
          'spacing': 8,
          'padding': 12,
        };
      case StatBadgeSize.large:
        return {
          'iconSize': 24,
          'containerSize': 48,
          'spacing': 12,
          'padding': 16,
        };
    }
  }

  /// Text styles based on size
  Map<String, TextStyle> get _textStyles {
    switch (size) {
      case StatBadgeSize.small:
        return {
          'value': AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          'label': AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: LightColors.textSecondary,
          ),
        };
      case StatBadgeSize.medium:
        return {
          'value': AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
          'label': AppTextStyles.caption.copyWith(
            fontSize: 12,
            color: LightColors.textSecondary,
          ),
        };
      case StatBadgeSize.large:
        return {
          'value': AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
          'label': AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            color: LightColors.textSecondary,
          ),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? LightColors.forestPrimary;
    final dims = _dimensions;
    final styles = _textStyles;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon container
        if (showBackground)
          Container(
            width: dims['containerSize']!,
            height: dims['containerSize']!,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(dims['containerSize']! / 3),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: dims['iconSize'],
              ),
            ),
          )
        else
          Icon(
            icon,
            color: color,
            size: dims['iconSize'],
          ),
        SizedBox(height: dims['spacing']),
        // Value
        Text(
          value,
          style: styles['value']!.copyWith(color: LightColors.textPrimary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        // Label
        Text(
          label,
          style: styles['label'],
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Compact horizontal stat display
/// Perfect for inline display in cards and headers
class CompactStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;

  const CompactStatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? LightColors.forestPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: LightColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
