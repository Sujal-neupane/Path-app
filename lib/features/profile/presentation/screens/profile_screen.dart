import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionControllerProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: session.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: LightColors.forestPrimary),
          ),
          error: (_, __) => const _ProfileContent(name: 'Explorer', email: 'Not available'),
          data: (state) => _ProfileContent(
            name: state.user?.name ?? 'Explorer',
            email: state.user?.email ?? 'Not available',
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileContent({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 96), // Bottom padding for bottom nav shell
      children: [
        Text(
          'Profile',
          style: AppTextStyles.h1.copyWith(
            color: LightColors.textPrimary,
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 16),

        // Claymorphic User Header Card
        ClayContainer(
          borderRadius: 22,
          depth: 6,
          spread: 3,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: LightColors.primaryLight,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: LightColors.forestPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h2.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Profile Option Tiles
        _Tile(
          icon: Icons.emergency_share_rounded,
          title: 'Emergency Logs',
          subtitle: 'Track safety distress signals',
          iconColor: LightColors.sosRed,
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/sos-history');
          },
        ),
        _Tile(
          icon: Icons.emoji_events_rounded,
          title: 'Achievements',
          subtitle: '7 badges unlocked',
          iconColor: LightColors.peakAmber,
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        _Tile(
          icon: Icons.hiking_rounded,
          title: 'Trek History',
          subtitle: '12 completed expeditions',
          iconColor: LightColors.forestPrimary,
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        _Tile(
          icon: Icons.download_rounded,
          title: 'Offline Maps',
          subtitle: '4 regions downloaded',
          iconColor: LightColors.altitudeBlue,
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        _Tile(
          icon: Icons.settings_rounded,
          title: 'Preferences',
          subtitle: 'Theme, alerts, and settings',
          iconColor: LightColors.textSecondary,
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: ClayContainer(
          borderRadius: 16,
          depth: 6,
          spread: 2,
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: LightColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
