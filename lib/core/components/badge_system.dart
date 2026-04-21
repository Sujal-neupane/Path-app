import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

// ============================================================================
// DIFFICULTY BADGE
// ============================================================================

enum DifficultyLevel { easy, moderate, expert }

class DifficultyBadge extends StatelessWidget {
  final DifficultyLevel level;
  final bool isCompact;

  const DifficultyBadge({
    super.key,
    required this.level,
    this.isCompact = false,
  });

  (Color bgColor, Color textColor, String label, IconData icon)
      get _levelConfig {
    switch (level) {
      case DifficultyLevel.easy:
        return (
          const Color(0xFF2ECC71).withValues(alpha: 0.1),
          const Color(0xFF27AE60),
          'Easy',
          Icons.trending_down_rounded,
        );
      case DifficultyLevel.moderate:
        return (
          LightColors.peakAmber.withValues(alpha: 0.1),
          LightColors.peakAmber,
          'Moderate',
          Icons.trending_up_rounded,
        );
      case DifficultyLevel.expert:
        return (
          LightColors.sosRed.withValues(alpha: 0.1),
          LightColors.sosRed,
          'Expert',
          Icons.trending_up_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label, icon) = _levelConfig;

    if (isCompact) {
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

enum StatusType { active, completed, offline, available, pending }

class StatusBadge extends StatelessWidget {
  final StatusType status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  (Color bgColor, Color textColor, String label, IconData icon)
      get _statusConfig {
    switch (status) {
      case StatusType.active:
        return (
          LightColors.trailGreen.withValues(alpha: 0.1),
          LightColors.trailGreen,
          'Active',
          Icons.play_circle_rounded,
        );
      case StatusType.completed:
        return (
          const Color(0xFF2ECC71).withValues(alpha: 0.1),
          const Color(0xFF27AE60),
          'Completed',
          Icons.check_circle_rounded,
        );
      case StatusType.offline:
        return (
          LightColors.textSecondary.withValues(alpha: 0.1),
          LightColors.textSecondary,
          'Offline',
          Icons.cloud_off_rounded,
        );
      case StatusType.available:
        return (
          LightColors.altitudeBlue.withValues(alpha: 0.1),
          LightColors.altitudeBlue,
          'Available',
          Icons.check_rounded,
        );
      case StatusType.pending:
        return (
          LightColors.peakAmber.withValues(alpha: 0.1),
          LightColors.peakAmber,
          'Pending',
          Icons.schedule_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label, icon) = _statusConfig;

    if (isCompact) {
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RISK BADGE (AMS RISK)
// ============================================================================

enum RiskLevel { low, medium, high }

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final String? customLabel;
  final bool isCompact;

  const RiskBadge({
    super.key,
    required this.level,
    this.customLabel,
    this.isCompact = false,
  });

  (Color bgColor, Color textColor, String label, IconData icon) get _riskConfig {
    switch (level) {
      case RiskLevel.low:
        return (
          const Color(0xFF2ECC71).withValues(alpha: 0.1),
          const Color(0xFF27AE60),
          customLabel ?? 'Low Risk',
          Icons.check_circle_rounded,
        );
      case RiskLevel.medium:
        return (
          LightColors.peakAmber.withValues(alpha: 0.1),
          LightColors.peakAmber,
          customLabel ?? 'Medium Risk',
          Icons.warning_rounded,
        );
      case RiskLevel.high:
        return (
          LightColors.sosRed.withValues(alpha: 0.1),
          LightColors.sosRed,
          customLabel ?? 'High Risk',
          Icons.error_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label, icon) = _riskConfig;

    if (isCompact) {
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GENERIC BADGE HELPER
// ============================================================================

class GenericBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets padding;
  final bool isCompact;

  const GenericBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? LightColors.forestPrimary.withValues(alpha: 0.1);
    final tColor = textColor ?? LightColors.forestPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
        border: Border.all(
          color: tColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isCompact ? 12 : 14, color: tColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: (isCompact ? AppTextStyles.caption : AppTextStyles.bodyMedium)
                .copyWith(
              color: tColor,
              fontWeight: FontWeight.w700,
              fontSize: isCompact ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }
}
