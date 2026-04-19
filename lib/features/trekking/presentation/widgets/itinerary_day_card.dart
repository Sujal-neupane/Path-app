import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import '../../domain/entities/itinerary_day.dart';

/// Reusable itinerary day card for day-by-day editor
///
/// Displays: day number, locations, distance, elevation, AMS risk, difficulty
/// Tap-friendly for editing
/// Shows warning badges for high-altitude risk (Von Restorff)
///
/// Usage:
/// ```dart
/// ItineraryDayCard(
///   day: day,
///   dayNumber: 1,
///   onTap: () => showEditDialog(...),
/// )
/// ```
class ItineraryDayCard extends StatelessWidget {
  final ItineraryDay day;
  final int dayNumber;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool isDraggable;

  const ItineraryDayCard({
    required this.day,
    required this.dayNumber,
    this.onTap,
    this.onEdit,
    this.isDraggable = true,
    super.key,
  });

  /// AMS risk color (Von Restorff)
  Color get riskColor {
    switch (day.altitudeRiskLevel.toLowerCase()) {
      case 'high':
        return LightColors.sosRed;
      case 'moderate':
        return LightColors.peakAmber;
      case 'low':
      default:
        return Colors.green;
    }
  }

  /// Background tint for acclimatization days
  Color get dayBackgroundColor {
    if (day.isAcclimatizationDay) {
      return LightColors.forestPrimary.withValues(alpha: 0.06);
    }
    return LightColors.surfaceWhite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: dayBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: day.isAcclimatizationDay
                ? LightColors.forestPrimary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header: Day number + locations + drag handle
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  // Drag handle (if draggable)
                  if (isDraggable)
                    Icon(
                      Icons.drag_handle_rounded,
                      size: 20,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),

                  const SizedBox(width: 8),

                  // Day number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: LightColors.forestPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Day ${day.dayNumber}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Acclimatization badge
                  if (day.isAcclimatizationDay)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: LightColors.forestPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Rest Day',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: LightColors.forestPrimary,
                        ),
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Edit button (Fitts's Law: 40dp)
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: LightColors.forestPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Divider(
                height: 1,
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),

            // Content row: locations + stats
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route: Start → End
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: LightColors.forestPrimary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${day.startLocation} → ${day.endLocation}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: LightColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Stats row: distance / elevation / time
                  Row(
                    children: [
                      _DayStat(
                        icon: Icons.route_rounded,
                        value: '${day.distanceKm.toStringAsFixed(1)}km',
                        label: 'Distance',
                        color: LightColors.forestPrimary,
                      ),
                      const SizedBox(width: 10),
                      _DayStat(
                        icon: Icons.trending_up_rounded,
                        value: '+${day.elevationGainM}m',
                        label: 'Gain',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      _DayStat(
                        icon: Icons.schedule_rounded,
                        value: '${day.estimatedHours.toStringAsFixed(1)}h',
                        label: 'Time',
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Risk indicator + altitude info
                  Row(
                    children: [
                      // AMS risk badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: riskColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              size: 12,
                              color: riskColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AMS Risk: ${day.altitudeRiskLevel}',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: riskColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Altitude end
                      Text(
                        '${day.endAltitudeM}m',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: LightColors.altitudeBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single stat for day card
class _DayStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _DayStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                color: LightColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
