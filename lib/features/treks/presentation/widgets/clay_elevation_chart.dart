import 'package:flutter/material.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/dark_colors.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/domain/entities/itinerary_step.dart';

class ClayElevationChart extends StatelessWidget {
  final List<ItineraryStep> steps;

  const ClayElevationChart({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    final altitudes = steps.map((s) => s.altitudeM).toList();
    final maxAlt = altitudes.reduce((a, b) => a > b ? a : b);
    final minAlt = altitudes.reduce((a, b) => a < b ? a : b);
    final peakIndex = altitudes.indexOf(maxAlt);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? DarkColors.bioluminescent
        : LightColors.forestPrimary;
    final textPrimaryColor = isDark ? Colors.white : LightColors.summitDark;
    final textSecondaryColor = isDark
        ? Colors.white70
        : LightColors.textSecondary;
    final containerColor = isDark ? DarkColors.deepCanopy : Colors.white;

    return ClayContainer(
      depth: 6,
      spread: 3,
      borderRadius: 24,
      color: containerColor,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ELEVATION PROFILE',
                    style: AppTextStyles.caption.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Peak Altitude: $maxAlt m',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: LightColors.sosRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'High Altitude Zone',
                  style: TextStyle(
                    color: LightColors.sosRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _ElevationPainter(
                altitudes: altitudes,
                minAlt: minAlt,
                maxAlt: maxAlt,
                peakIndex: peakIndex,
                primaryColor: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final shouldPrint =
                  steps.length <= 6 ||
                  index == 0 ||
                  index == steps.length - 1 ||
                  index == peakIndex ||
                  (index % (steps.length ~/ 3) == 0);

              if (!shouldPrint) return const SizedBox.shrink();
              return Text(
                'Day ${index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: index == peakIndex
                      ? LightColors.sosRed
                      : textSecondaryColor,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ElevationPainter extends CustomPainter {
  final List<int> altitudes;
  final int minAlt;
  final int maxAlt;
  final int peakIndex;
  final Color primaryColor;

  _ElevationPainter({
    required this.altitudes,
    required this.minAlt,
    required this.maxAlt,
    required this.peakIndex,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (altitudes.isEmpty) return;

    final double widthStep = size.width / (altitudes.length - 1);
    final int altRange = (maxAlt - minAlt) == 0 ? 1 : (maxAlt - minAlt);
    const double padding = 20.0;
    final double drawableHeight = size.height - padding * 2;

    final points = <Offset>[];
    for (int i = 0; i < altitudes.length; i++) {
      final x = i * widthStep;
      final normalizedY = (altitudes[i] - minAlt) / altRange;
      final y = size.height - padding - (normalizedY * drawableHeight);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlX = p1.dx + (p2.dx - p1.dx) / 2;
      path.cubicTo(controlX, p1.dy, controlX, p2.dy, p2.dx, p2.dy);
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.25),
          primaryColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final peakPoint = points[peakIndex];
    final dottedPaint = Paint()
      ..color = LightColors.sosRed.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double startY = peakPoint.dy;
    double endY = size.height;
    const double dashHeight = 4.0;
    const double dashSpace = 4.0;

    while (startY < endY) {
      canvas.drawLine(
        Offset(peakPoint.dx, startY),
        Offset(peakPoint.dx, (startY + dashHeight).clamp(startY, endY)),
        dottedPaint,
      );
      startY += dashHeight + dashSpace;
    }

    final dotOuterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isPeak = i == peakIndex;

      final dotInnerPaint = Paint()
        ..color = isPeak ? LightColors.sosRed : LightColors.peakAmber
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p, 6, dotOuterPaint);
      canvas.drawCircle(p, 4.5, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ElevationPainter oldDelegate) {
    return oldDelegate.altitudes != altitudes ||
        oldDelegate.minAlt != minAlt ||
        oldDelegate.maxAlt != maxAlt ||
        oldDelegate.peakIndex != peakIndex ||
        oldDelegate.primaryColor != primaryColor;
  }
}
