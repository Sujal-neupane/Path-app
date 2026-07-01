import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';

/// Small shared building blocks for the Editorial Alpine system.

/// Uppercase, wide-tracked label that sits above a headline.
class EyebrowLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const EyebrowLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text.toUpperCase(),
      style: AppType.eyebrow.copyWith(
        color: color ?? AppColors(isDark).primary,
      ),
    );
  }
}

/// Section header: an apex-ish title with an optional trailing action.
class EditorialSectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EditorialSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                EyebrowLabel(eyebrow!),
                const SizedBox(height: 6),
              ],
              Text(
                title,
                style: AppType.title.copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  actionLabel!,
                  style: AppType.caption.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 15, color: c.primary),
              ],
            ),
          ),
      ],
    );
  }
}

/// Compact translucent chip for use on top of photography (status, tags).
class GlassChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? dotColor;
  final Color background;
  final Color foreground;

  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.dotColor,
    this.background = const Color(0x33FFFFFF),
    this.foreground = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
          ],
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: AppType.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A quiet stat block (value + label) for neutral cards.
class StatBlock extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const StatBlock({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(height: 10),
        Text(value, style: AppType.stat.copyWith(color: c.textPrimary)),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: AppType.caption.copyWith(
            color: c.textSecondary,
            letterSpacing: 0.8,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
