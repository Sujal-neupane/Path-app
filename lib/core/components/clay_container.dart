import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';

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
  final BorderRadiusGeometry? customBorderRadius;

  const ClayContainer({
    super.key,
    required this.child,
    this.depth = 8.0,
    this.spread = 4.0,
    this.borderRadius = 24.0,
    this.color,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.border,
    this.isDark = false,
    this.isFlat = false,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? (isDark ? LightColors.summitDark : Colors.white);
    
    // Calculate light and dark tones for the inner gradient and outer shadows
    final lightColor = _getLightColor(baseColor);
    final darkColor = _getDarkColor(baseColor);

    // Claymorphism lighting gradient
    final gradient = LinearGradient(
      colors: isFlat 
        ? [baseColor, baseColor]
        : [lightColor, darkColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Claymorphic double outer shadow system
    final shadows = [
      // Dark bottom-right shadow (recess depth)
      BoxShadow(
        color: isDark 
          ? const Color(0xFF08140E).withValues(alpha: 0.5)
          : const Color(0xFFC0C9C3).withValues(alpha: 0.6),
        offset: Offset(depth, depth),
        blurRadius: depth * 2,
        spreadRadius: spread * 0.5,
      ),
      // Light top-left shadow (ambient glow)
      BoxShadow(
        color: isDark 
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white,
        offset: Offset(-depth, -depth),
        blurRadius: depth * 2,
        spreadRadius: spread * 0.5,
      ),
    ];

    // Top-left highlight border simulating 3D highlight edge
    final defaultBorder = Border.all(
      color: isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.8),
      width: 2.0,
    );

    final resolvedBorderRadius = customBorderRadius ?? BorderRadius.circular(borderRadius);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: resolvedBorderRadius,
        border: border ?? defaultBorder,
        boxShadow: shadows,
      ),
      child: child,
    );
  }

  Color _getLightColor(Color color) {
    if (color == Colors.white) return color;
    
    // Tint color towards white to create top-left highlight source
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.06).clamp(0.0, 1.0)).toColor();
  }

  Color _getDarkColor(Color color) {
    if (color == Colors.white) return const Color(0xFFECEFF1);
    
    // Shade color slightly to create bottom-right shadow sink
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0)).toColor();
  }
}
