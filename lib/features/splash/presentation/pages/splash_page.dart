import 'package:flutter/material.dart';
import '../../../../core/theme/light_colors.dart';
import '../../../../core/constants/app_assets.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // 500ms animation per UX 15 laws guidelines
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Smooth subtle fade
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Elegant subtle float up
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate to Onboarding after splash completes (3.5 sec total, feels natural)
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        context.go('/onboarding');
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
    return Scaffold(
      backgroundColor: LightColors.summitDark, // Using the deep brand color
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Real Logo image with a fallback representation
                Image.asset(
                  AppAssets.logo,
                  width: 250, // Slightly bigger since it's a text-heavy logo
                  // errorBuilder acts as a placeholder if logo.png is missing
                  errorBuilder: (context, error, stackTrace) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'P',
                        style: TextStyle(
                          color: LightColors.logoWhite,
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      // Custom Mountain Icon as 'A'
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.landscape_rounded, // Mountain peak
                          size: 72,
                          color: LightColors.logoWhite,
                        ),
                      ),
                      const Text(
                        'TH',
                        style: TextStyle(
                          color: LightColors.logoWhite,
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
