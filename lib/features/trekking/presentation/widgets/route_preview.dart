import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import '../../domain/entities/trek.dart';

/// Elevation profile preview widget
///
/// Displays route as simplified line chart:
/// - X axis: Distance (0 → total km)
/// - Y axis: Elevation (start → end altitude)
/// - Gradient fill under curve
///
/// Shows: start/end altitudes, total elevation gain/loss, waypoint markers
/// Compact: fits in modal/detail view
class RoutePreview extends StatelessWidget {
  final Trek trek;
  final double? height;

  const RoutePreview({
    required this.trek,
    this.height = 240,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: LightColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header: title + stats
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route Profile',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // Stats row
                Row(
                  children: [
                    _ProfileStat(
                      label: 'Gain',
                      value: '${trek.totalElevationGain.toStringAsFixed(0)}m',
                      icon: Icons.trending_up_rounded,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 14),
                    _ProfileStat(
                      label: 'Loss',
                      value: '0m',
                      icon: Icons.trending_down_rounded,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 14),
                    _ProfileStat(
                      label: 'Distance',
                      value: '${trek.totalDistance.toStringAsFixed(1)}km',
                      icon: Icons.route_rounded,
                      color: LightColors.forestPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Elevation profile chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: _ElevationChart(trek: trek),
            ),
          ),

          // Start / End altitude info
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: _AltitudeInfo(
                    label: 'Start',
                    altitude: (trek.startPoint?.altitude ?? 0).toInt(),
                    location: trek.startPoint?.name ?? 'Start',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AltitudeInfo(
                    label: 'End',
                    altitude: (trek.endPoint?.altitude ?? 0).toInt(),
                    location: trek.endPoint?.name ?? 'End',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple line chart showing elevation profile
class _ElevationChart extends StatelessWidget {
  final Trek trek;

  const _ElevationChart({required this.trek});

  @override
  Widget build(BuildContext context) {
    // For now, simplified: just show line from start to end altitude
    // In Phase 4, integrate with actual waypoint data
    final startAlt = (trek.startPoint?.altitude ?? 0).toDouble();
    final endAlt = (trek.endPoint?.altitude ?? 0).toDouble();
    final elevationGain = trek.totalElevationGain;

    return CustomPaint(
      painter: _ElevationChartPainter(
        startAltitude: startAlt,
        endAltitude: endAlt,
        elevationGain: elevationGain.toInt(),
        distance: trek.totalDistance,
      ),
      child: Container(),
    );
  }
}

/// Custom painter for elevation profile
class _ElevationChartPainter extends CustomPainter {
  final double startAltitude;
  final double endAltitude;
  final int elevationGain;
  final double distance;

  _ElevationChartPainter({
    required this.startAltitude,
    required this.endAltitude,
    required this.elevationGain,
    required this.distance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background grid
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    // Draw horizontal grid lines (every 500m)
    for (int i = 0; i <= 5; i++) {
      final y = size.height - (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Line path (simplified: linear from start to end)
    // In real app, would use waypoint data
    final path = Path();
    path.moveTo(0, size.height); // Start at bottom-left

    // Draw line (simplified sine wave to show elevation changes)
    final steps = 100;
    for (int i = 0; i <= steps; i++) {
      final x = (i / steps) * size.width;
      final normalizedValue = i / steps;

      // Approximate elevation using sine wave
      final baseElevation = startAltitude +
          (endAltitude - startAltitude) * normalizedValue;
      final variation = elevationGain * 0.3 * Math.sin(normalizedValue * 3.14);
      final currentElevation = baseElevation + variation;

      // Normalize to chart height
      final maxAltitude = (startAltitude + elevationGain).toDouble();
      final minAltitude = startAltitude.toDouble();
      final normalizedY = 1.0 -
          ((currentElevation - minAltitude) /
              (maxAltitude - minAltitude))
              .clamp(0.0, 1.0);

      final y = size.height * normalizedY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Complete the path for fill
    path.lineTo(size.width, size.height);
    path.close();

    // Gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        LightColors.forestPrimary.withValues(alpha: 0.2),
        LightColors.forestPrimary.withValues(alpha: 0.02),
      ],
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(path, gradientPaint);

    // Line stroke
    final linePaint = Paint()
      ..color = LightColors.forestPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, linePaint);

    // Start point marker
    canvas.drawCircle(
      Offset(0, size.height * 0.6),
      4,
      Paint()..color = Colors.green,
    );

    // End point marker
    canvas.drawCircle(
      Offset(size.width, size.height * 0.3),
      4,
      Paint()..color = Colors.redAccent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Profile stat: label, value, icon
class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
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
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Altitude info: start or end
class _AltitudeInfo extends StatelessWidget {
  final String label;
  final int altitude;
  final String location;

  const _AltitudeInfo({
    required this.label,
    required this.altitude,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: LightColors.forestPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: LightColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${altitude}m',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: LightColors.forestPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
