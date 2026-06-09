  import 'package:flutter/material.dart';
  import 'package:path_app/core/theme/app_text_styles.dart';
  import 'package:path_app/core/theme/light_colors.dart';

  /// Generic info container used across dashboard, trek details, itinerary
  /// Perfect for altitude info, risk indicators, weather data
  class InfoCard extends StatelessWidget {
    final String title;
    final String value;
    final IconData? icon;
    final Color? accentColor;
    final Color? backgroundColor;
    final VoidCallback? onTap;
    final bool isHighlight;
    final String? subtitle;

    const InfoCard({
      super.key,
      required this.title,
      required this.value,
      this.icon,
      this.accentColor,
      this.backgroundColor,
      this.onTap,
      this.isHighlight = false,
      this.subtitle,
    });

    @override
    Widget build(BuildContext context) {
      final accentCol = accentColor ?? LightColors.forestPrimary;
      final bgCol = backgroundColor ?? accentCol.withValues(alpha: 0.06);

      return Material(
        color: bgCol,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isHighlight
                    ? accentCol.withValues(alpha: 0.3)
                    : Colors.transparent,
                width: isHighlight ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon on left
                if (icon != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentCol.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: accentCol,
                        size: 20,
                      ),
                    ),
                  ),
                if (icon != null) const SizedBox(width: 12),

                // Content on right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.caption.copyWith(
                          color: LightColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: AppTextStyles.h3.copyWith(
                          color: LightColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: LightColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Optional trailing icon for interactive cards
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: accentCol.withValues(alpha: 0.4),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Compact inline info display
  /// Used for quick stats in headers and ribbons
  class CompactInfoBadge extends StatelessWidget {
    final String label;
    final String value;
    final IconData? icon;
    final Color? accentColor;

    const CompactInfoBadge({
      super.key,
      required this.label,
      required this.value,
      this.icon,
      this.accentColor,
    });

    @override
    Widget build(BuildContext context) {
      final color = accentColor ?? LightColors.forestPrimary;

      return Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: LightColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
