import 'package:flutter/material.dart';

/// Mixins for common animation patterns used throughout the app
/// Promotes code reuse and consistent animation behavior

// ============================================================================
// SHAKE ANIMATION MIXIN
// ============================================================================

mixin ShakeAnimationMixin on State {
  late AnimationController shakeController;

  @override
  void initState() {
    super.initState();
    shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this as TickerProvider,
    );
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
  }

  /// Trigger a shake animation (for error states)
  void triggerShake() {
    shakeController.forward().then((_) {
      shakeController.reverse();
    });
  }

  /// Get shake offset animation
  Animation<Offset> getShakeAnimation() {
    return Tween<Offset>(begin: Offset.zero, end: const Offset(0.02, 0))
        .animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );
  }
}

// ============================================================================
// PULSE ANIMATION MIXIN (Breathing effect)
// ============================================================================

mixin PulseAnimationMixin on State {
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this as TickerProvider,
    )..repeat(reverse: true);

    pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.05).animate(
          CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  /// Get pulse scale animation
  Animation<double> getPulseAnimation() => pulseAnimation;
}

// ============================================================================
// SLIDE IN ANIMATION MIXIN (Staggered entry)
// ============================================================================

mixin SlideInAnimationMixin on State {
  late AnimationController slideController;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this as TickerProvider,
    );
    slideController.forward();
  }

  @override
  void dispose() {
    slideController.dispose();
    super.dispose();
  }

  /// Get slide animation with optional interval for staggering
  Animation<Offset> getSlideAnimation({
    double begin = 0.3,
    Interval interval = const Interval(0.0, 1.0),
  }) {
    return Tween<Offset>(
      begin: Offset(0, begin),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: slideController,
        curve: interval,
      ),
    );
  }
}

// ============================================================================
// SCALE ANIMATION MIXIN
// ============================================================================

mixin ScaleAnimationMixin on State {
  late AnimationController scaleController;

  @override
  void initState() {
    super.initState();
    scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this as TickerProvider,
    );
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  /// Get scale animation
  Animation<double> getScaleAnimation({
    double begin = 0.0,
    Curve curve = Curves.elasticOut,
  }) {
    return Tween<double>(begin: begin, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: curve),
    );
  }

  /// Trigger scale animation
  void triggerScaleAnimation() {
    scaleController.forward().then((_) {
      scaleController.reverse();
    });
  }
}

// ============================================================================
// FADE ANIMATION MIXIN
// ============================================================================

mixin FadeAnimationMixin on State {
  late AnimationController fadeController;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this as TickerProvider,
    );
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }

  /// Get fade animation with optional interval
  Animation<double> getFadeAnimation({
    Interval interval = const Interval(0.0, 1.0),
  }) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: fadeController,
        curve: interval,
      ),
    );
  }

  /// Forward fade
  void fadeIn() {
    fadeController.forward();
  }

  /// Reverse fade
  void fadeOut() {
    fadeController.reverse();
  }
}

// ============================================================================
// ROTATION ANIMATION MIXIN
// ============================================================================

mixin RotationAnimationMixin on State {
  late AnimationController rotationController;

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this as TickerProvider,
    );
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  /// Get rotation animation (full 360 degree rotation)
  Animation<double> getRotationAnimation() {
    return Tween<double>(begin: 0, end: 1).animate(rotationController);
  }

  /// Start rotating
  void startRotation() {
    rotationController.repeat();
  }

  /// Stop rotating
  void stopRotation() {
    rotationController.stop();
  }

  /// Reset to zero
  void resetRotation() {
    rotationController.reset();
  }
}

// ============================================================================
// BOUNCE ANIMATION MIXIN
// ============================================================================

mixin BounceAnimationMixin on State {
  late AnimationController bounceController;

  @override
  void initState() {
    super.initState();
    bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this as TickerProvider,
    );
  }

  @override
  void dispose() {
    bounceController.dispose();
    super.dispose();
  }

  /// Get bounce animation
  Animation<double> getBounceAnimation() {
    return Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.elasticOut),
    );
  }

  /// Trigger bounce
  void triggerBounce() {
    bounceController.forward().then((_) {
      bounceController.reverse();
    });
  }
}

// ============================================================================
// COMPOSITE ANIMATION: SLIDE & FADE
// ============================================================================

/// Combines slide and fade animations for smooth entry effects
class SlideAndFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double slideBegin;
  final bool autoPlay;
  final VoidCallback? onComplete;

  const SlideAndFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.slideBegin = 0.3,
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<SlideAndFadeAnimation> createState() => _SlideAndFadeAnimationState();
}

class _SlideAndFadeAnimationState extends State<SlideAndFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideBegin),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.autoPlay) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// COMPOSITE ANIMATION: SCALE & FADE
// ============================================================================

/// Combines scale and fade animations for smooth entry effects
class ScaleAndFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleBegin;
  final Curve curve;
  final bool autoPlay;
  final VoidCallback? onComplete;

  const ScaleAndFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.scaleBegin = 0.85,
    this.curve = Curves.elasticOut,
    this.autoPlay = true,
    this.onComplete,
  });

  @override
  State<ScaleAndFadeAnimation> createState() => _ScaleAndFadeAnimationState();
}

class _ScaleAndFadeAnimationState extends State<ScaleAndFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: widget.scaleBegin, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.autoPlay) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
