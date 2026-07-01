import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/app_theme.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';
import 'package:path_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

class HapticsNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
  void set(bool val) => state = val;
}

final hapticsEnabledProvider = NotifierProvider<HapticsNotifier, bool>(
  () => HapticsNotifier(),
);

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
  void set(bool val) => state = val;
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsNotifier, bool>(
      () => NotificationsNotifier(),
    );

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(authSessionControllerProvider);
    final activeState = ref.watch(activeTrekProvider);
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;
    // Real-time profile stats (XP, level, distance, elevation, badges).
    final stats = ref.watch(profileStatsProvider).asData?.value;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () => ref.refresh(profileStatsProvider.future),
          child: sessionAsync.when(
            loading: () =>
                Center(child: CircularProgressIndicator(color: colors.primary)),
            error: (err, stack) => _ProfileContent(
              name: 'Explorer',
              email: 'offline@hiker.com',
              activeState: activeState,
              stats: stats,
              ref: ref,
              colors: colors,
            ),
            data: (state) => _ProfileContent(
              name: state.user?.name ?? 'Explorer',
              email: state.user?.email ?? 'hiker@himalayas.com',
              activeState: activeState,
              stats: stats,
              ref: ref,
              colors: colors,
            ),
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
  final ProfileStats? stats;
  final WidgetRef ref;
  final dynamic colors;

  const _ProfileContent({
    required this.name,
    required this.email,
    required this.activeState,
    required this.stats,
    required this.ref,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTracking =
        activeState.region != null && activeState.region!.isNotEmpty;

    // 1. Calculate Real-Time Hiker Stats
    double activeDistance = activeState.distanceWalkedKm;
    double currentAlt = 0.0;
    int currentGain = 0;

    if (isTracking) {
      currentAlt = activeState.currentAltitude ?? 0.0;
      currentGain = currentAlt.clamp(0.0, 10000.0).round();
    }

    // Real backend stats + any live tracking gains layered on top.
    final double totalDistance = (stats?.distanceKm ?? 0) + activeDistance;
    final int totalElevation = (stats?.elevationM ?? 0) + currentGain;
    final int completedTreks =
        (stats?.treksCompleted ?? 0) + (activeState.isFinished ? 1 : 0);
    final int totalXp = stats?.xp ?? 0;
    final int badgeCount = stats?.badgeCount ?? 0;

    // Real rank/level from the backend XP system.
    final String rankTitle = stats?.levelLabel ?? 'Himalayan Explorer';

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
            color: colors.textPrimary,
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 16),

        // Claymorphic User Header Card
        ClayContainer(
          borderRadius: 22,
          depth: 6,
          spread: 3,
          color: colors.surface,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.15),
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: colors.primary,
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
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
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
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rankTitle.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    if (stats != null && stats!.nextLevelXp != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: stats!.levelProgress,
                          minHeight: 6,
                          backgroundColor: colors.primary.withValues(alpha: 0.12),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats!.xp} / ${stats!.nextLevelXp} XP → ${stats!.nextLevelLabel}',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
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
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ClayContainer(
            borderRadius: 20,
            depth: 6,
            spread: 3,
            color: isDark ? colors.surface : LightColors.summitDark,
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
                        color: colors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TRACKING',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.accent,
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
                          foregroundColor: isDark ? colors.surface : LightColors.summitDark,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Resume',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? colors.primary : LightColors.summitDark,
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
            color: colors.textPrimary,
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
                accentColor: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatGridCard(
                icon: Icons.trending_up_rounded,
                value: '+$totalElevation m',
                label: 'Total Elevation',
                accentColor: colors.info,
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
                accentColor: colors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatGridCard(
                icon: Icons.bolt_rounded,
                value: '$totalXp',
                label: 'Experience (XP)',
                accentColor: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatGridCard(
                icon: Icons.workspace_premium_rounded,
                value: '$badgeCount',
                label: 'Badges Earned',
                accentColor: colors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatGridCard(
                icon: Icons.flag_rounded,
                value: '${stats?.checkpointsReached ?? 0}',
                label: 'Checkpoints',
                accentColor: colors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 5. Settings and Safety Actions
        Text(
          'Settings & Security',
          style: AppTextStyles.h3.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _Tile(
          icon: Icons.emergency_share_rounded,
          title: 'Emergency Logs',
          subtitle: 'Track safety distress signals',
          iconColor: colors.error,
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/sos-history');
          },
        ),
        _Tile(
          icon: Icons.emoji_events_rounded,
          title: 'Achievements',
          subtitle: '5 badges unlocked',
          iconColor: colors.accent,
          onTap: () {
            HapticFeedback.lightImpact();
            _showAchievementsDialog(context, ref);
          },
        ),
        _Tile(
          icon: Icons.download_rounded,
          title: 'Offline Maps',
          subtitle: 'Manage cached trail regions',
          iconColor: colors.info,
          onTap: () {
            HapticFeedback.lightImpact();
            _showOfflineMapsDialog(context, ref);
          },
        ),
        _Tile(
          icon: Icons.settings_rounded,
          title: 'Preferences',
          subtitle: 'Theme, alerts, and settings',
          iconColor: colors.textSecondary,
          onTap: () {
            HapticFeedback.lightImpact();
            _showPreferencesDialog(context, ref);
          },
        ),

        // Log Out Option
        const SizedBox(height: 16),
        _Tile(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          subtitle: 'Discard local sessions safely',
          iconColor: colors.textSecondary,
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
// Settings Modal Dialog Creators
// ──────────────────────────────────────────────

void _showAchievementsDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final colors = ref.watch(appThemeProvider).colors;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClayContainer(
              borderRadius: 24,
              depth: 8,
              spread: 3,
              color: colors.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unlocked Badges',
                        style: AppTextStyles.h2.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _BadgeItem(
                          icon: '🏔️',
                          title: 'EBC Trailblazer',
                          subtitle: 'Completed Sagarmatha route',
                          xp: '+500 XP',
                          unlocked: true,
                          colors: colors,
                        ),
                        _BadgeItem(
                          icon: '🦵',
                          title: 'Annapurna Walker',
                          subtitle: 'Hiked over 50 km',
                          xp: '+200 XP',
                          unlocked: true,
                          colors: colors,
                        ),
                        _BadgeItem(
                          icon: '🤝',
                          title: 'Social Sherpa',
                          subtitle: 'Shared community insights',
                          xp: '+100 XP',
                          unlocked: true,
                          colors: colors,
                        ),
                        _BadgeItem(
                          icon: '💳',
                          title: 'Permitted Hiker',
                          subtitle: 'Booked Stripe permit fee',
                          xp: '+150 XP',
                          unlocked: true,
                          colors: colors,
                        ),
                        _BadgeItem(
                          icon: '🎒',
                          title: 'Gear Master',
                          subtitle: 'Packed correct trek gear',
                          xp: '+100 XP',
                          unlocked: true,
                          colors: colors,
                        ),
                        _BadgeItem(
                          icon: '⬆️',
                          title: 'Altitude Pioneer',
                          subtitle: 'Climbed above 5,000m',
                          xp: '+300 XP',
                          unlocked: false,
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
}

class _BadgeItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String xp;
  final bool unlocked;
  final dynamic colors;

  const _BadgeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.unlocked,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClayContainer(
        borderRadius: 16,
        depth: unlocked ? 4 : 1,
        spread: 1.5,
        color: colors.surface,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: unlocked
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.textSecondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: unlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: unlocked
                          ? colors.textPrimary
                          : colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  xp,
                  style: TextStyle(
                    color: unlocked ? colors.primary : colors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
                Icon(
                  unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                  size: 14,
                  color: unlocked ? colors.primary : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showOfflineMapsDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final colors = ref.watch(appThemeProvider).colors;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClayContainer(
              borderRadius: 24,
              depth: 8,
              spread: 3,
              color: colors.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offline Regions',
                        style: AppTextStyles.h2.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download topographic GIS vector tiles for offline trail routing.',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: const [
                        _OfflineMapDownloader(
                          region: 'Everest Region',
                          size: '42 MB',
                        ),
                        _OfflineMapDownloader(
                          region: 'Annapurna Conservation',
                          size: '65 MB',
                        ),
                        _OfflineMapDownloader(
                          region: 'Langtang Valley',
                          size: '28 MB',
                        ),
                        _OfflineMapDownloader(
                          region: 'Ghorepani Poon Hill',
                          size: '15 MB',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
}

class _OfflineMapDownloader extends ConsumerStatefulWidget {
  final String region;
  final String size;

  const _OfflineMapDownloader({
    required this.region,
    required this.size,
  });

  @override
  ConsumerState<_OfflineMapDownloader> createState() =>
      _OfflineMapDownloaderState();
}

class _OfflineMapDownloaderState extends ConsumerState<_OfflineMapDownloader> {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadDownloadState();
  }

  Future<void> _loadDownloadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isDownloaded = prefs.getBool('offline_map_${widget.region}') ?? false;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDownload() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.05;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _isDownloading = false;
          _isDownloaded = true;
          _timer?.cancel();
          HapticFeedback.mediumImpact();
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool('offline_map_${widget.region}', true);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appThemeProvider).colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClayContainer(
        borderRadius: 16,
        depth: 4,
        spread: 1.5,
        color: colors.surface,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.region,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.size,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _isDownloading || _isDownloaded
                      ? null
                      : _startDownload,
                  child: ClayContainer(
                    borderRadius: 10,
                    depth: _isDownloaded ? 1 : 4,
                    spread: 1,
                    color: _isDownloaded ? colors.primary : colors.surface,
                    isDark: _isDownloaded,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: _isDownloaded
                        ? const Icon(
                            Icons.cloud_done_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : _isDownloading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : Icon(
                            Icons.cloud_download_rounded,
                            color: colors.primary,
                            size: 16,
                          ),
                  ),
                ),
              ],
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: colors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Downloading Vector tiles...',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void _showPreferencesDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final isDark = ref.watch(themeModeProvider);
          final colors = ref.watch(appThemeProvider).colors;
          final haptics = ref.watch(hapticsEnabledProvider);
          final notifications = ref.watch(notificationsEnabledProvider);

          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClayContainer(
              borderRadius: 24,
              depth: 8,
              spread: 3,
              color: colors.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preferences',
                        style: AppTextStyles.h2.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Theme Mode Option
                  _PreferenceToggle(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Theme Mode',
                    subtitle: 'Optimized high-contrast night mapping',
                    value: isDark,
                    colors: colors,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),

                  // Haptics Option
                  _PreferenceToggle(
                    icon: Icons.vibration_rounded,
                    title: 'Tactile Haptic Feedback',
                    subtitle: 'Feel menu selections physically',
                    value: haptics,
                    colors: colors,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      ref.read(hapticsEnabledProvider.notifier).set(val);
                    },
                  ),

                  // Push notifications
                  _PreferenceToggle(
                    icon: Icons.notifications_active_rounded,
                    title: 'Safety Warning Alerts',
                    subtitle: 'Receive storm & altitude warnings',
                    value: notifications,
                    colors: colors,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      ref.read(notificationsEnabledProvider.notifier).set(val);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _PreferenceToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final dynamic colors;
  final ValueChanged<bool> onChanged;

  const _PreferenceToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeColor: colors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Claymorphic Grid Metric Tile
// ──────────────────────────────────────────────
class _StatGridCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appThemeProvider).colors;

    return ClayContainer(
      depth: 4,
      spread: 2,
      borderRadius: 16,
      color: colors.surface,
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
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colors.textSecondary,
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
class _Tile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appThemeProvider).colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: ClayContainer(
          borderRadius: 16,
          depth: 6,
          spread: 2,
          color: colors.surface,
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
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.textPrimary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
