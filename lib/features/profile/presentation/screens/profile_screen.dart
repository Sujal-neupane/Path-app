import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              _ProfileContent(name: 'Explorer', email: 'Not available'),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          'Profile',
          style: AppTextStyles.h1.copyWith(
            color: LightColors.textPrimary,
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LightColors.dividerLight),
          ),
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
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h3.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Tile(
          icon: Icons.emoji_events_rounded,
          title: 'Achievements',
          subtitle: '7 badges unlocked',
        ),
        _Tile(
          icon: Icons.hiking_rounded,
          title: 'Trek History',
          subtitle: '12 completed expeditions',
        ),
        _Tile(
          icon: Icons.download_rounded,
          title: 'Offline Maps',
          subtitle: '4 regions downloaded',
        ),
        _Tile(
          icon: Icons.settings_rounded,
          title: 'Preferences',
          subtitle: 'Theme, notifications, and privacy',
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LightColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: LightColors.forestPrimary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        ],
      ),
    );
  }
}
