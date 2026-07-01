import 'package:flutter/material.dart';

/// Claymorphic container — soft, rounded, matte 3D appearance.
///
/// Achieves clay effect through:
/// - Subtle dual shadow system (no harsh edges)
/// - Soft internal gradient (no glossy shine)
/// - NO border highlight (pure matte clay)
class ClayContainer extends StatelessWidget {
  final Widget child;
  final double depth;
  final double spread;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final bool isDark;
  final bool isFlat;
  final bool isInset;
  final BorderRadiusGeometry? customBorderRadius;

  const ClayContainer({
    super.key,
    required this.child,
    this.depth = 6.0,
    this.spread = 2.0,
    this.borderRadius = 20.0,
    this.color,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.border,
    this.isDark = false,
    this.isFlat = false,
    this.isInset = false,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIsDark = isDark || isThemeDark;
    
    final baseColor = color ?? (effectiveIsDark ? const Color(0xFF0D2219) : Colors.white);

    final resolvedBorderRadius =
        customBorderRadius ?? BorderRadius.circular(borderRadius);

    if (isFlat) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: resolvedBorderRadius,
          border: border,
        ),
        child: child,
      );
    }

    // Subtle clay gradient — top slightly lighter, bottom slightly darker
    final lightColor = _adjustLightness(baseColor, effectiveIsDark ? 0.02 : 0.04);
    final darkColor = _adjustLightness(baseColor, effectiveIsDark ? -0.01 : -0.03);

    final gradient = LinearGradient(
      colors: [lightColor, darkColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Soft clay shadows — no harsh white glow
    final shadows = isInset
        ? <BoxShadow>[]
        : [
            // Bottom-right soft shadow
            BoxShadow(
              color: effectiveIsDark
                  ? const Color(0xFF020906).withValues(alpha: 0.5)
                  : const Color(0xFFB8C0BA).withValues(alpha: 0.45),
              offset: Offset(depth * 0.6, depth * 0.6),
              blurRadius: depth * 1.5,
              spreadRadius: spread * 0.2,
            ),
            // Top-left ambient lift (very subtle, no white shine)
            BoxShadow(
              color: effectiveIsDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white.withValues(alpha: 0.7),
              offset: Offset(-depth * 0.4, -depth * 0.4),
              blurRadius: depth * 1.2,
              spreadRadius: spread * 0.1,
            ),
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: resolvedBorderRadius,
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );
  }

  Color _adjustLightness(Color color, double amount) {
    if (color == Colors.white && amount > 0) return color;
    if (color == Colors.white && amount < 0) return const Color(0xFFF5F5F3);

    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
