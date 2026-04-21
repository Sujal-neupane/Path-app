import 'package:flutter/material.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// Animated counter that increments from 0 to final value
/// Creates the feeling of premium, living data
class AnimatedStatCounter extends StatefulWidget {
  final int finalValue;
  final String label;
  final String suffix;
  final Color accentColor;
  final Duration duration;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;

  const AnimatedStatCounter({
    Key? key,
    required this.finalValue,
    required this.label,
    this.suffix = '',
    this.accentColor = LightColors.forestPrimary,
    this.duration = const Duration(milliseconds: 1500),
    this.valueStyle,
    this.labelStyle,
  }) : super(key: key);

  @override
  State<AnimatedStatCounter> createState() => _AnimatedStatCounterState();
}

class _AnimatedStatCounterState extends State<AnimatedStatCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _countAnimation =
        IntTween(begin: 0, end: widget.finalValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedStatCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.finalValue != widget.finalValue) {
      _countAnimation = IntTween(begin: 0, end: widget.finalValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _countAnimation,
          builder: (context, child) {
            return Text(
              '${_countAnimation.value}${widget.suffix}',
              style: widget.valueStyle ??
                  AppTextStyles.h2.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
            );
          },
        ),
        SizedBox(height: Spacing.xs),
        Text(
          widget.label,
          style: widget.labelStyle ??
              AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
