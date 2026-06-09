import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Compact weather strip for the dashboard.
/// Shows current conditions at a glance without overwhelming.
/// (Miller's Law: 3 key weather metrics only)
class WeatherGlanceWidget extends StatelessWidget {
  final String temperature;
  final String condition;
  final String windSpeed;
  final String humidity;
  final String advisory;
  final VoidCallback? onTap;

  const WeatherGlanceWidget({
    super.key,
    this.temperature = '4°C',
    this.condition = 'Light Snow',
    this.windSpeed = '18 km/h',
    this.humidity = '64%',
    this.advisory = 'Pack thermal layers',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEBF3F9), Color(0xFFF5F9FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LightColors.altitudeBlue.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            // Weather icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: LightColors.altitudeBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.ac_unit_rounded,
                color: LightColors.altitudeBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Temperature + condition
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        temperature,
                        style: AppTextStyles.h3.copyWith(
                          color: LightColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: LightColors.altitudeBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          condition,
                          style: AppTextStyles.caption.copyWith(
                            color: LightColors.altitudeBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wind $windSpeed • Humidity $humidity',
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: LightColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
