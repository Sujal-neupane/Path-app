import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// A multi-layered mountain silhouette with animated contour lines,
/// floating amber sun, and drifting particle system.
///
/// Continues the visual language of the splash wave painter and
/// onboarding flow painter.
class MountainSilhouettePainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;

  MountainSilhouettePainter({
    this.animationValue = 0.0,
    this.scrollOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGradientSky(canvas, size);
    _drawStars(canvas, size);
    _drawAmberSun(canvas, size);
    _drawMountainLayerFar(canvas, size);
    _drawMountainLayerMid(canvas, size);
    _drawMountainLayerNear(canvas, size);
    _drawContourLines(canvas, size);
  }

  void _drawGradientSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0D2B1F), // Deep forest night
        LightColors.forestPrimary,
        const Color(0xFF3A7D5C), // Lighter at horizon
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  void _drawStars(Canvas canvas, Size size) {
    final rng = math.Random(42); // Deterministic seed for consistent stars
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.5;
      final radius = 0.5 + rng.nextDouble() * 1.2;

      // Stars twinkle based on animation value
      final twinklePhase = (animationValue * 2 * math.pi + i * 0.8) % (2 * math.pi);
      final alpha = 0.2 + 0.5 * ((math.sin(twinklePhase) + 1) / 2);

      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawAmberSun(Canvas canvas, Size size) {
    // Sun position — rises slightly with animation
    final sunX = size.width * 0.78;
    final sunY = size.height * 0.28 - (math.sin(animationValue * math.pi * 2) * 4);
    final sunRadius = size.width * 0.10;

    // Outer glow
    final glowPaint = Paint()
      ..color = LightColors.peakAmber.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(sunX, sunY), sunRadius * 2.2, glowPaint);

    // Mid glow
    final midGlow = Paint()
      ..color = LightColors.peakAmber.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset(sunX, sunY), sunRadius * 1.4, midGlow);

    // Core sun
    final sunPaint = Paint()
      ..color = LightColors.peakAmber.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(sunX, sunY), sunRadius, sunPaint);
  }

  void _drawMountainLayerFar(Canvas canvas, Size size) {
    // Farthest layer — subtle, lighter
    final parallax = scrollOffset * 0.1;
    final paint = Paint()
      ..color = const Color(0xFF1B4332).withValues(alpha: 0.5);

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.55 + parallax);
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.42 + parallax,
      size.width * 0.25, size.height * 0.50 + parallax,
    );
    path.quadraticBezierTo(
      size.width * 0.35, size.height * 0.58 + parallax,
      size.width * 0.45, size.height * 0.38 + parallax,
    );
    path.lineTo(size.width * 0.55, size.height * 0.30 + parallax);
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.45 + parallax,
      size.width * 0.80, size.height * 0.35 + parallax,
    );
    path.quadraticBezierTo(
      size.width * 0.90, size.height * 0.40 + parallax,
      size.width, size.height * 0.50 + parallax,
    );
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMountainLayerMid(Canvas canvas, Size size) {
    final parallax = scrollOffset * 0.2;
    final paint = Paint()
      ..color = const Color(0xFF163528).withValues(alpha: 0.7);

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.65 + parallax);
    path.quadraticBezierTo(
      size.width * 0.10, size.height * 0.55 + parallax,
      size.width * 0.20, size.height * 0.60 + parallax,
    );
    path.quadraticBezierTo(
      size.width * 0.30, size.height * 0.65 + parallax,
      size.width * 0.40, size.height * 0.48 + parallax,
    );
    path.lineTo(size.width * 0.48, size.height * 0.40 + parallax);
    path.quadraticBezierTo(
      size.width * 0.55, size.height * 0.50 + parallax,
      size.width * 0.65, size.height * 0.45 + parallax,
    );
    path.lineTo(size.width * 0.72, size.height * 0.38 + parallax);
    path.quadraticBezierTo(
      size.width * 0.82, size.height * 0.48 + parallax,
      size.width * 0.92, size.height * 0.55 + parallax,
    );
    path.lineTo(size.width, size.height * 0.52 + parallax);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMountainLayerNear(Canvas canvas, Size size) {
    // Nearest layer — darkest, most prominent
    final parallax = scrollOffset * 0.35;
    final paint = Paint()
      ..color = const Color(0xFF0D2219);

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.75 + parallax);
    path.quadraticBezierTo(
      size.width * 0.08, size.height * 0.68 + parallax,
      size.width * 0.18, size.height * 0.72 + parallax,
    );
    path.quadraticBezierTo(
      size.width * 0.28, size.height * 0.78 + parallax,
      size.width * 0.35, size.height * 0.62 + parallax,
    );
    path.lineTo(size.width * 0.42, size.height * 0.55 + parallax);
    path.quadraticBezierTo(
      size.width * 0.50, size.height * 0.68 + parallax,
      size.width * 0.60, size.height * 0.60 + parallax,
    );
    path.quadraticBezierTo(
      size.width * 0.70, size.height * 0.52 + parallax,
      size.width * 0.78, size.height * 0.65 + parallax,
    );
    path.quadraticBezierTo(
      size.width * 0.88, size.height * 0.72 + parallax,
      size.width, size.height * 0.68 + parallax,
    );
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawContourLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < 5; i++) {
      final alpha = 0.08 - (i * 0.012);
      if (alpha <= 0) continue;

      linePaint.color = Colors.white.withValues(alpha: alpha);
      final path = Path();
      final shift = i * 18.0 + (animationValue * 6);

      path.moveTo(0, size.height * 0.80 - shift);
      path.quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.65 - shift + math.sin(animationValue * math.pi * 2 + i) * 5,
        size.width * 0.50,
        size.height * 0.75 - shift,
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.85 - shift - math.cos(animationValue * math.pi * 2 + i) * 4,
        size.width,
        size.height * 0.70 - shift,
      );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MountainSilhouettePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}
