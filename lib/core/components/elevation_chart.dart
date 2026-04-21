import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Data point for elevation chart
class ElevationDataPoint {
  final String name;
  final double altitude;
  final double distanceKm;
  final double? effort; // Optional effort rating 0-1

  ElevationDataPoint({
    required this.name,
    required this.altitude,
    required this.distanceKm,
    this.effort,
  });
}

/// Beautiful elevation profile chart with gradient and waypoint markers
class ElevationChart extends StatelessWidget {
  final List<ElevationDataPoint> dataPoints;
  final double height;
  final Color? primaryColor;
  final bool showLabels;
  final bool showWaypoints;

  const ElevationChart({
    super.key,
    required this.dataPoints,
    this.height = 200,
    this.primaryColor,
    this.showLabels = true,
    this.showWaypoints = true,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: LightColors.forestPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No elevation data',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: LightColors.forestPrimary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: CustomPaint(
            painter: _ElevationChartPainter(
              dataPoints: dataPoints,
              primaryColor: primaryColor ?? LightColors.forestPrimary,
            ),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 12),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _ElevationStat(
                label: 'Start',
                value: '${dataPoints.first.altitude.toStringAsFixed(0)}m',
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ElevationStat(
                label: 'End',
                value: '${dataPoints.last.altitude.toStringAsFixed(0)}m',
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ElevationStat(
                label: 'Max',
                value:
                    '${_getMaxAltitude(dataPoints).toStringAsFixed(0)}m',
                icon: Icons.height_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ElevationStat(
                label: 'Distance',
                value: '${dataPoints.last.distanceKm.toStringAsFixed(1)}km',
                icon: Icons.route_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _getMaxAltitude(List<ElevationDataPoint> points) {
    return points.fold(0.0, (max, point) => point.altitude > max ? point.altitude : max);
  }
}

// ============================================================================
// CUSTOM PAINTER FOR ELEVATION CHART
// ============================================================================

class _ElevationChartPainter extends CustomPainter {
  final List<ElevationDataPoint> dataPoints;
  final Color primaryColor;

  _ElevationChartPainter({
    required this.dataPoints,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final padding = EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      bottom: 20,
    );
    final drawArea = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.left - padding.right,
      size.height - padding.top - padding.bottom,
    );

    // Calculate min and max altitude for scaling
    final minAlt = dataPoints.fold<double>(double.infinity,
        (min, point) => point.altitude < min ? point.altitude : min);
    final maxAlt = dataPoints.fold<double>(0.0,
        (max, point) => point.altitude > max ? point.altitude : max);
    final altRange = (maxAlt - minAlt).toDouble();

    // Draw grid lines and labels
    _drawGridLines(canvas, drawArea, minAlt, maxAlt);

    // Draw gradient fill
    _drawGradientFill(canvas, drawArea, dataPoints, minAlt, altRange);

    // Draw line path
    _drawLinePath(canvas, drawArea, dataPoints, minAlt, altRange);

    // Draw waypoint markers
    _drawWaypoints(canvas, drawArea, dataPoints, minAlt, altRange);
  }

  void _drawGridLines(
    Canvas canvas,
    Rect drawArea,
    double minAlt,
    double maxAlt,
  ) {
    final paint = Paint()
      ..color = LightColors.textSecondary.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Horizontal grid lines for altitude
    for (int i = 0; i <= 4; i++) {
      final altValue = minAlt + ((maxAlt - minAlt) / 4) * i;
      final y = drawArea.bottom - (drawArea.height / 4) * i;

      canvas.drawLine(
        Offset(drawArea.left, y),
        Offset(drawArea.right, y),
        paint,
      );

      // Alt label
      textPainter.text = TextSpan(
        text: '${altValue.toStringAsFixed(0)}m',
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          color: LightColors.textSecondary.withValues(alpha: 0.5),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(drawArea.left - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawGradientFill(
    Canvas canvas,
    Rect drawArea,
    List<ElevationDataPoint> dataPoints,
    double minAlt,
    double altRange,
  ) {
    final path = Path();

    // Build path
    for (int i = 0; i < dataPoints.length; i++) {
      final x = drawArea.left +
          (drawArea.width / (dataPoints.length - 1 > 0 ? dataPoints.length - 1 : 1)) *
              i;
      final normalizedAlt = (dataPoints[i].altitude - minAlt) / altRange;
      final y = drawArea.bottom - (normalizedAlt * drawArea.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Close path for fill
    path.lineTo(drawArea.right, drawArea.bottom);
    path.lineTo(drawArea.left, drawArea.bottom);
    path.close();

    // Gradient shader
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withValues(alpha: 0.2),
        primaryColor.withValues(alpha: 0.02),
      ],
    );

    final rect = path.getBounds();
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  void _drawLinePath(
    Canvas canvas,
    Rect drawArea,
    List<ElevationDataPoint> dataPoints,
    double minAlt,
    double altRange,
  ) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = drawArea.left +
          (drawArea.width / (dataPoints.length - 1 > 0 ? dataPoints.length - 1 : 1)) *
              i;
      final normalizedAlt = (dataPoints[i].altitude - minAlt) / altRange;
      final y = drawArea.bottom - (normalizedAlt * drawArea.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawWaypoints(
    Canvas canvas,
    Rect drawArea,
    List<ElevationDataPoint> dataPoints,
    double minAlt,
    double altRange,
  ) {
    for (int i = 0; i < dataPoints.length; i++) {
      final x = drawArea.left +
          (drawArea.width / (dataPoints.length - 1 > 0 ? dataPoints.length - 1 : 1)) *
              i;
      final normalizedAlt = (dataPoints[i].altitude - minAlt) / altRange;
      final y = drawArea.bottom - (normalizedAlt * drawArea.height);

      // Draw waypoint circle
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );

      canvas.drawCircle(
        Offset(x, y),
        3.5,
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ElevationChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.primaryColor != primaryColor;
  }
}

// ============================================================================
// ELEVATION STAT DISPLAY
// ============================================================================

class _ElevationStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ElevationStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColors.forestPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: LightColors.forestPrimary),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColors.textPrimary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    );
  }
}
