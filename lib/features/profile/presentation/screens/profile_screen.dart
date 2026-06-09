import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';
import 'package:path_app/features/treks/domain/entities/waypoint.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(authSessionControllerProvider);
    final activeState = ref.watch(activeTrekProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: LightColors.forestPrimary),
          ),
          error: (err, stack) => _ProfileContent(
            name: 'Explorer',
            email: 'offline@hiker.com',
            activeState: activeState,
            ref: ref,
          ),
          data: (state) => _ProfileContent(
            name: state.user?.name ?? 'Explorer',
            email: state.user?.email ?? 'hiker@himalayas.com',
            activeState: activeState,
            ref: ref,
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String name;
  final String email;
  final ActiveTrekState activeState;
  final WidgetRef ref;

  const _ProfileContent({
    required this.name,
    required this.email,
    required this.activeState,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isTracking =
        activeState.region != null && activeState.region!.isNotEmpty;

    // 1. Calculate Real-Time Hiker Stats
    double activeDistance = activeState.distanceWalkedKm;
    double startAlt = 0.0;
    double currentAlt = 0.0;
    int currentGain = 0;

    if (isTracking) {
      final wps = getWaypointsForRegion(activeState.region!);
      if (wps.isNotEmpty) {
        startAlt = wps.first.alt;
        currentAlt = activeState.currentAltitude ?? startAlt;
        currentGain = (currentAlt - startAlt).clamp(0.0, 10000.0).round();
      }
    }

    final double totalDistance = 52.4 + activeDistance;
    final int totalElevation = 1450 + currentGain;
    final int completedTreks = 3 + (activeState.isFinished ? 1 : 0);

    // Dynamic Rank Title
    String rankTitle = 'Himalayan Explorer';
    if (totalDistance > 120) {
      rankTitle = 'Himalayan Legend';
    } else if (totalDistance > 75) {
      rankTitle = 'Alpine Guide';
    }

    // 2. Simulated Dynamic Vitals
    int heartRate = 68;
    int spo2 = 99;

    if (isTracking && currentAlt > startAlt) {
      // heart rate increases with altitude climbing
      final altDiff = currentAlt - startAlt;
      heartRate = (72 + (altDiff * 0.006)).round().clamp(60, 140);
      // oxygen saturation decreases slightly at altitude
      spo2 = (98 - (currentAlt / 1200)).round().clamp(84, 99);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        96,
      ), // Extra bottom padding for floating navigation shell
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
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LightColors.primaryLight,
                  border: Border.all(
                    color: LightColors.forestPrimary.withValues(alpha: 0.15),
                    width: 2.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: LightColors.forestPrimary,
                  size: 34,
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
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Rank Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: LightColors.forestPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rankTitle.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: LightColors.forestPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Live Expedition Shortcut Widget (Only visible when tracking is active)
        if (isTracking) ...[
          Text(
            'Live Tracker Session',
            style: AppTextStyles.h3.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ClayContainer(
            borderRadius: 20,
            depth: 6,
            spread: 3,
            color: LightColors.summitDark,
            isDark: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activeState.region!,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: LightColors.peakAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SIMULATING',
                        style: AppTextStyles.caption.copyWith(
                          color: LightColors.peakAmber,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Distance: ${activeDistance.toStringAsFixed(1)} km • Alt: ${currentAlt.round()} m',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push(
                            '/map-weather/navigator',
                            extra: activeState.region,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: LightColors.summitDark,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Resume',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(activeTrekProvider.notifier).clearTrek();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white24,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Stop',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 4. Real-time Hiker Statistics Grid
        Text(
          'Himalayan Hiker Stats',
          style: AppTextStyles.h3.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatGridCard(
                icon: Icons.directions_walk_rounded,
                value: '${totalDistance.toStringAsFixed(1)} km',
                label: 'Total Distance',
                accentColor: LightColors.forestPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatGridCard(
                icon: Icons.trending_up_rounded,
                value: '+$totalElevation m',
                label: 'Total Elevation',
                accentColor: LightColors.altitudeBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatGridCard(
                icon: Icons.terrain_rounded,
                value: '$completedTreks',
                label: 'Completed Trails',
                accentColor: LightColors.peakAmber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatGridCard(
                icon: Icons.favorite_rounded,
                value: '$heartRate bpm',
                label: 'Simulated Pulse',
                accentColor: LightColors.sosRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatGridCard(
                icon: Icons.thermostat_rounded,
                value: '$spo2%',
                label: 'Blood Oxygen (SpO2)',
                accentColor: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 5. Settings and Safety Actions
        Text(
          'Settings & Security',
          style: AppTextStyles.h3.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
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

        // Log Out Option
        const SizedBox(height: 16),
        _Tile(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          subtitle: 'Discard local sessions safely',
          iconColor: Colors.black54,
          onTap: () async {
            HapticFeedback.mediumImpact();
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            try {
              // Sign out from secure repository
              await ref.read(authSessionControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Log out failed: $e')),
              );
            }
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Claymorphic Grid Metric Tile
// ──────────────────────────────────────────────
class _StatGridCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  const _StatGridCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      depth: 4,
      spread: 2,
      borderRadius: 16,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Profile List Option Tile
// ──────────────────────────────────────────────
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
