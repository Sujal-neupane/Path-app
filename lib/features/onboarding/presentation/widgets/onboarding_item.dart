import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/light_colors.dart';
import 'dart:math' as math;

class OnboardingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String lottieAsset;
  final IconData fallbackIcon;
  final double pageOffset;

  const OnboardingItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.fallbackIcon,
    required this.pageOffset,
  });

  @override
  Widget build(BuildContext context) {
    // Parallax & Fade calculations
    final double opacity = math.max(0.0, 1.0 - pageOffset.abs() * 1.5).clamp(0.0, 1.0);
    final double textTranslateX = pageOffset * 100.0;
    final double imageTranslateX = pageOffset * -50.0; // Image moves opposite to text

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ==============================
          // Animated Vector Character (.lottie)
          // ==============================
          Expanded(
            flex: 5,
            child: Transform.translate(
              offset: Offset(imageTranslateX, 0),
              child: Opacity(
                opacity: opacity,
                child: Center(
                  child: Hero(
                    tag: 'onboarding_lottie_${title.hashCode}',
                    child: Lottie.asset(
                      lottieAsset,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.85,
                      // Fallback in case asset fails
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Lottie load error for $lottieAsset: $error');
                        return _buildVectorFallback();
                      },
                      frameBuilder: (context, child, composition) {
                        if (composition == null) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: LightColors.forestPrimary,
                            ),
                          );
                        }
                        return child;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // ==============================
          // Typography with Depth Parallax
          // ==============================
          Expanded(
            flex: 3,
            child: Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(textTranslateX, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: LightColors.textPrimary, // Clean dark text on white
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: LightColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Elegant fallback that mimics a minimal vector illustration if internet is down
  Widget _buildVectorFallback() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 250,
            height: 250,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: LightColors.forestPrimary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              fallbackIcon,
              size: 120,
              color: LightColors.forestPrimary,
            ),
          ),
        );
      },
    );
  }
}
