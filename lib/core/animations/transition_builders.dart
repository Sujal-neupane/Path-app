import 'package:flutter/material.dart';

/// Custom transition builders for smooth navigation between screens

// ============================================================================
// SLIDE LEFT TRANSITION
// ============================================================================

class SlideLeftTransition extends PageRouteBuilder {
  final Widget page;

  SlideLeftTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// ============================================================================
// FADE TRANSITION
// ============================================================================

class FadeTransitionRoute extends PageRouteBuilder {
  final Widget page;

  FadeTransitionRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// ============================================================================
// SCALE + FADE TRANSITION
// ============================================================================

class ScaleAndFadeTransitionRoute extends PageRouteBuilder {
  final Widget page;

  ScaleAndFadeTransitionRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeOut;

            final scaleTween = Tween(begin: 0.85, end: 1.0)
                .chain(CurveTween(curve: curve));
            final fadeTween = Tween<double>(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// ============================================================================
// SLIDE UP TRANSITION (for modals)
// ============================================================================

class SlideUpTransition extends PageRouteBuilder {
  final Widget page;

  SlideUpTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;

            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// ============================================================================
// SHARED AXIS TRANSITION (Material Design 3)
// ============================================================================

class SharedAxisTransitionRoute extends PageRouteBuilder {
  final Widget page;
  final SharedAxisTransitionType type;

  SharedAxisTransitionRoute({
    required this.page,
    this.type = SharedAxisTransitionType.horizontal,
  })
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildSharedAxisTransition(
              animation,
              secondaryAnimation,
              child,
              type,
            );
          },
          transitionDuration: const Duration(milliseconds: 450),
        );

  static Widget _buildSharedAxisTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    SharedAxisTransitionType type,
  ) {
    switch (type) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: child,
        );
      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: child,
        );
      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
    }
  }
}

enum SharedAxisTransitionType { horizontal, vertical, scaled }

// ============================================================================
// CUSTOM MODAL BOTTOM SHEET WITH ANIMATION
// ============================================================================

Future<T?> showAnimatedBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool isScrollControlled = true,
  Duration transitionDuration = const Duration(milliseconds: 400),
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isDismissible: isDismissible,
    isScrollControlled: isScrollControlled,
    transitionAnimationController:
        AnimationController(vsync: Navigator.of(context, rootNavigator: true)),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
  );
}

// ============================================================================
// CUSTOM DIALOG WITH SCALE ANIMATION
// ============================================================================

Future<T?> showScaledDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Duration transitionDuration = const Duration(milliseconds: 300),
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) =>
        builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        ),
        child: child,
      );
    },
    transitionDuration: transitionDuration,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black54,
  );
}

// ============================================================================
// STAGGERED LIST ANIMATION
// ============================================================================

/// Animates list items with staggered entrance effect
class StaggeredListAnimation extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;
  final Duration staggerDuration;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final EdgeInsets padding;

  const StaggeredListAnimation({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 400),
    this.staggerDuration = const Duration(milliseconds: 100),
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      scrollDirection: scrollDirection,
      physics: physics,
      padding: padding,
      itemBuilder: (context, index) {
        return _AnimatedListItem(
          index: index,
          duration: duration,
          staggerDuration: staggerDuration,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Duration duration;
  final Duration staggerDuration;
  final Widget child;

  const _AnimatedListItem({
    required this.index,
    required this.duration,
    required this.staggerDuration,
    required this.child,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
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

    final delay = widget.staggerDuration * widget.index;

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
// PARALLAX SCROLL EFFECT
// ============================================================================

/// Creates parallax scroll effect for hero sections
class ParallaxScroll extends StatelessWidget {
  final ScrollController scrollController;
  final Widget child;
  final double parallaxMultiplier;

  const ParallaxScroll({
    super.key,
    required this.scrollController,
    required this.child,
    this.parallaxMultiplier = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        double offset = 0;
        if (scrollController.hasClients) {
          offset = scrollController.offset * parallaxMultiplier;
        }

        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
    );
  }
}

// ============================================================================
// HERO ANIMATION HELPER
// ============================================================================

/// Simplified hero animation wrapper
class AnimatedHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration transitionDuration;
  final Curve curve;

  const AnimatedHero({
    super.key,
    required this.tag,
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      child: child,
    );
  }
}
