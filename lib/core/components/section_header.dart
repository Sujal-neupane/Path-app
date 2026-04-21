import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Reusable section header component with title, subtitle, and optional action
/// Replaces _SectionHeader pattern used throughout dashboard, trek details, itinerary
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;
  final bool showDivider;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel = 'See all',
    this.actionIcon = Icons.arrow_forward_rounded,
    this.showDivider = false,
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, 12),
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle ??
                        AppTextStyles.h2.copyWith(
                          color: LightColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: subtitleStyle ??
                          AppTextStyles.caption.copyWith(
                            color: LightColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (onAction != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: LightColors.forestPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          actionIcon,
                          color: LightColors.forestPrimary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: LightColors.forestPrimary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
        ] else
          SizedBox(height: padding.bottom),
      ],
    );
  }
}

/// Compact section header for inline use
class CompactSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool showDivider;

  const CompactSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel = 'View',
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (onAction != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      actionLabel!,
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.forestPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: LightColors.forestPrimary.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }
}

/// Section with header and optional content
class Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets childPadding;
  final VoidCallback? onAction;
  final String? actionLabel;

  const Section({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.childPadding = const EdgeInsets.fromLTRB(0, 12, 0, 0),
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          onAction: onAction,
          actionLabel: actionLabel,
          padding: EdgeInsets.zero,
        ),
        Padding(
          padding: childPadding,
          child: child,
        ),
      ],
    );
  }
}
