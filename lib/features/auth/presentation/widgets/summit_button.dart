import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// A premium CTA button with clean gradient, press scale + haptic,
/// and smooth loading/success state transitions.
class SummitButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSuccess;
  final bool enabled;

  const SummitButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
    this.enabled = true,
  });

  @override
  State<SummitButton> createState() => _SummitButtonState();
}

class _SummitButtonState extends State<SummitButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _loadingController;
  late Animation<double> _pressScale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isLoading) _loadingController.repeat();
  }

  @override
  void didUpdateWidget(SummitButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _loadingController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _loadingController.stop();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  bool get _isDisabled => !widget.enabled || widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (_isDisabled) return;
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressScale.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            // Clean dark gradient — not too green
            gradient: LinearGradient(
              colors: _isDisabled
                  ? [const Color(0xFFBBBBBB), const Color(0xFFAAAAAA)]
                  : widget.isSuccess
                      ? [const Color(0xFF2D6A4F), const Color(0xFF1B4332)]
                      : _isPressed
                          ? [const Color(0xFF163528), const Color(0xFF0D2219)]
                          : [const Color(0xFF1B4332), const Color(0xFF0D2219)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            // Subtle top highlight for depth
            border: Border.all(
              color: _isDisabled
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: _isPressed ? 0.0 : 0.06),
              width: 1,
            ),
            boxShadow: _isDisabled
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF1B4332)
                          .withValues(alpha: _isPressed ? 0.15 : 0.25),
                      blurRadius: _isPressed ? 8 : 16,
                      offset: Offset(0, _isPressed ? 2 : 6),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle top edge highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: _isPressed ? 0.0 : 0.08),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  child: widget.isLoading
                      ? _buildLoadingDots()
                      : widget.isSuccess
                          ? _buildSuccessContent()
                          : _buildLabelContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelContent() {
    return Row(
      key: const ValueKey('label'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.buttonText.copyWith(
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: 18,
        ),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      key: const ValueKey('loading'),
      animation: _loadingController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase =
                (_loadingController.value * 2 * math.pi + i * 1.0) %
                    (2 * math.pi);
            final bounce = ((math.sin(phase) + 1) / 2);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5 + bounce * 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSuccessContent() {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('success'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'DONE',
                style: AppTextStyles.buttonText.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
