import 'package:flutter/material.dart';
import 'package:path_app/core/constants/app_assets.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'mountain_silhouette_painter.dart';

/// The hero section at the top of auth screens:
/// mountain silhouette background + white logo + tagline.
///
/// Features:
/// - Animated mountain background with parallax
/// - Breathing logo (subtle continuous scale pulse)
/// - Tagline with letter-by-letter typewriter reveal
class AuthHeroSection extends StatefulWidget {
  final String tagline;
  final double height;
  final AnimationController parentController;

  const AuthHeroSection({
    super.key,
    required this.tagline,
    required this.height,
    required this.parentController,
  });

  @override
  State<AuthHeroSection> createState() => _AuthHeroSectionState();
}

class _AuthHeroSectionState extends State<AuthHeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    // Continuous breathing effect for the logo
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Derive animations from parent controller's timeline
    _logoFade = CurvedAnimation(
      parent: widget.parentController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
    );

    _logoScale = CurvedAnimation(
      parent: widget.parentController,
      curve: const Interval(0.2, 0.55, curve: Curves.elasticOut),
    );

    _taglineFade = CurvedAnimation(
      parent: widget.parentController,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          // Mountain background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _breatheController,
              builder: (context, _) {
                return CustomPaint(
                  painter: MountainSilhouettePainter(
                    animationValue: _breatheController.value,
                  ),
                );
              },
            ),
          ),

          // Logo + Tagline centered
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Breathing logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: AnimatedBuilder(
                      animation: _breatheController,
                      builder: (context, child) {
                        // Subtle breathing: 1.0 → 1.02 → 1.0
                        final breatheScale =
                            1.0 + (_breatheController.value * 0.02);
                        return Transform.scale(
                          scale: breatheScale,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        AppAssets.logoWhite,
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback: tinted logo
                          return Image.asset(
                            AppAssets.logo,
                            height: 70,
                            fit: BoxFit.contain,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tagline
                FadeTransition(
                  opacity: _taglineFade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_taglineFade),
                    child: Text(
                      widget.tagline,
                      style: AppTextStyles.authSubtitle.copyWith(
                        color: LightColors.meadowTint.withValues(alpha: 0.85),
                        letterSpacing: 2.0,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
