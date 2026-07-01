import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/app_theme.dart';

class PermitSuccessScreen extends ConsumerWidget {
  const PermitSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Pulse Icon
              Center(
                child: ClayContainer(
                  borderRadius: 99,
                  depth: 6,
                  spread: 4,
                  color: colors.surface,
                  padding: const EdgeInsets.all(24),
                  child: Icon(
                    Icons.security_rounded,
                    size: 72,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Checkout Initiated',
                style: AppTextStyles.h1.copyWith(
                  color: colors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A Stripe Checkout tab has been opened in your browser to complete payment. We are waiting to verify your permit.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Verification Timeline
              ClayContainer(
                borderRadius: 20,
                depth: 4,
                spread: 2,
                color: colors.surface,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _TimelineItem(
                      icon: Icons.check_circle_rounded,
                      title: '1. Session Created',
                      subtitle: 'Stripe transaction initialized.',
                      isDone: true,
                      colors: colors,
                    ),
                    _TimelineItem(
                      icon: Icons.open_in_browser_rounded,
                      title: '2. Complete Payment',
                      subtitle: 'Complete details on Stripe page.',
                      isDone: false,
                      isActive: true,
                      colors: colors,
                    ),
                    _TimelineItem(
                      icon: Icons.cloud_done_rounded,
                      title: '3. Webhook Verified',
                      subtitle: 'System signs permit automatically.',
                      isDone: false,
                      colors: colors,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Return Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.go('/dashboard');
                },
                child: ClayContainer(
                  borderRadius: 16,
                  depth: 4,
                  spread: 2,
                  color: colors.primary,
                  isDark: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Center(
                    child: Text(
                      'BACK TO DASHBOARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;
  final dynamic colors;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.isActive = false,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isDone
        ? colors.primary
        : isActive
            ? colors.accent
            : colors.textSecondary.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDone || isActive ? colors.textPrimary : colors.textSecondary,
                    fontWeight: isDone || isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
