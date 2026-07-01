import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_typography.dart';

/// Frosted-glass surface for overlays, nav bars, sheets, and on-image controls.
///
/// Part of the "Editorial Alpine" system — glass is used for floating /
/// overlay surfaces, while photography carries the page and clay is an accent.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;
  final bool border;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 18.0,
    this.opacity = 0.6,
    this.borderRadius = AppRadii.card,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.tint,
    this.border = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTint =
        tint ?? (isDark ? const Color(0xFF0D2219) : Colors.white);
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseTint.withValues(alpha: opacity),
              borderRadius: radius,
              border: border
                  ? Border.all(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.08 : 0.55,
                      ),
                      width: 1,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
