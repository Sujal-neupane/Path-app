import 'package:flutter/material.dart';
import '../../../../core/theme/light_colors.dart';

class OnboardingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData; // Replaced with actual illustrations/svgs later

  const OnboardingItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Icon Placeholder
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: LightColors.forestPrimary.withOpacity(0.2), // Soft glow
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              size: 100,
              color: LightColors.logoWhite,
            ),
          ),
          const SizedBox(height: 64),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: LightColors.logoWhite, // White Logo theme text
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white70, // Slightly transparent
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100), // Space for bottom controls
        ],
      ),
    );
  }
}
