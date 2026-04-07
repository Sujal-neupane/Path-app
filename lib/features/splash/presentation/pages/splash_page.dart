import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/light_colors.dart';
import '../../../../core/constants/app_assets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();

    // Smooth transition to Onboarding
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.summitDark, // Keeps the white logo visible
      body: Stack(
        children: [
          // Seamless flowing wave background tying into the Onboarding design language
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SplashWavePainter(progress: _animController.value),
                );
              },
            ),
          ),
          
          // Pure, minimalist brand presentation
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.logo,
                      height: 120, // Proud and centered
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'P A T H',
                        style: TextStyle(
                          color: LightColors.logoWhite,
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 14.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _slideAnimation,
                      child: const Text(
                        'CONQUER EVERY ALTITUDE',
                        style: TextStyle(
                          color: LightColors.meadowTint,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.0, // Luxurious tracking
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  final double progress;

  _SplashWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left soft wave
    final paint1 = Paint()
      ..color = LightColors.trailGreen.withValues(alpha: 0.1 * progress)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(0, size.height * 0.3 * progress);
    path1.quadraticBezierTo(
      size.width * 0.3, size.height * 0.4 * progress,
      size.width * 0.6 * progress, 0
    );
    path1.close();
    canvas.drawPath(path1, paint1);

    // Bottom-right sweeping wave matching the onboarding curve style
    final paint2 = Paint()
      ..color = LightColors.forestPrimary.withValues(alpha: 0.3 * progress)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(size.width, size.height);
    path2.lineTo(size.width, size.height - (size.height * 0.4 * progress));
    path2.quadraticBezierTo(
      size.width * 0.5, size.height - (size.height * 0.3 * progress),
      size.width - (size.width * 0.8 * progress), size.height
    );
    path2.close();
    canvas.drawPath(path2, paint2);
    
    // Tiny subtle abstract sun rising slowly
    final sunPaint = Paint()
      ..color = LightColors.peakAmber.withValues(alpha: 0.4 * progress)
      ..style = PaintingStyle.fill;
      
    double sunX = size.width * 0.8;
    double sunY = size.height * 0.3 - (progress * 40); // Moves up slightly
    
    canvas.drawCircle(Offset(sunX, sunY), size.width * 0.15, sunPaint);
  }

  @override
  bool shouldRepaint(covariant _SplashWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
