import 'package:flutter/material.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// Premium hero section for dashboard
/// White background, minimal, premium feel
class DashboardHero extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final Widget? actionButton;
  final VoidCallback? onActionTap;

  const DashboardHero({
    super.key,
    this.greeting = 'Ready to Trek?',
    this.subtitle = 'Your next adventure awaits',
    this.actionButton,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Spacing.lg),
      margin: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: LightColors.forestPrimary,
        borderRadius: BorderRadius.circular(Radius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Spacing.md),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: Spacing.lg),
          ?actionButton,
        ],
      ),
    );
  }
}
