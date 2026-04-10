import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// An altitude-themed password strength meter.
///
/// Visual metaphor: a mountain cross-section showing "altitude gained".
/// 4 levels: Base Camp (weak) → Trail Head → Ridge Line → Summit (very strong).
class PasswordStrengthIndicator extends StatelessWidget {
  /// Password strength from 0.0 (empty) to 1.0 (very strong).
  final double strength;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    if (strength <= 0) return const SizedBox.shrink();

    final level = _getLevel(strength);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Altitude bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        // Background track
                        Container(
                          decoration: BoxDecoration(
                            color: LightColors.forestPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Filled portion
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          widthFactor: strength.clamp(0.0, 1.0),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  level.color.withValues(alpha: 0.7),
                                  level.color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: level.color.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Altitude label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey(level.label),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(level.icon, size: 12, color: level.color),
                    const SizedBox(width: 4),
                    Text(
                      level.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: level.color,
                        letterSpacing: 0.5,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StrengthLevel _getLevel(double s) {
    if (s < 0.25) {
      return _StrengthLevel(
        label: 'BASE CAMP',
        color: LightColors.sosRed,
        icon: Icons.warning_amber_rounded,
      );
    } else if (s < 0.50) {
      return _StrengthLevel(
        label: 'TRAIL HEAD',
        color: LightColors.peakAmber,
        icon: Icons.trending_up,
      );
    } else if (s < 0.75) {
      return _StrengthLevel(
        label: 'RIDGE LINE',
        color: LightColors.trailGreen,
        icon: Icons.terrain,
      );
    } else {
      return _StrengthLevel(
        label: 'SUMMIT',
        color: LightColors.forestPrimary,
        icon: Icons.landscape,
      );
    }
  }
}

class _StrengthLevel {
  final String label;
  final Color color;
  final IconData icon;

  _StrengthLevel({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// A FractionallySizedBox that animates its widthFactor.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final AlignmentGeometry alignment;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.alignment,
    required this.child,
    required super.duration,
    super.curve,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}
