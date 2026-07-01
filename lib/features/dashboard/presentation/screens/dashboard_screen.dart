import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/editorial_atoms.dart';
import 'package:path_app/core/components/editorial_hero.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_theme.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/animations/staggered_section.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:path_app/features/dashboard/presentation/widgets/featured_trek_carousel.dart';
import 'package:path_app/features/dashboard/presentation/widgets/weather_glance_widget.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/domain/entities/waypoint.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/features/sos/presentation/viewmodels/sos_viewmodel.dart';
import 'package:path_app/features/sos/presentation/widgets/sos_trigger_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(authSessionControllerProvider);

    return sessionAsync.when(
      loading: () => const _CenteredLoading(label: 'Preparing dashboard...'),
      error: (error, stackTrace) => _CenteredError(
        label: 'Unable to restore your session.',
        onRetry: () => ref.invalidate(authSessionControllerProvider),
      ),
      data: (session) {
        if (!session.isAuthenticated) {
          return _CenteredError(
            label: 'Please sign in to continue.',
            actionLabel: 'Go to Sign In',
            onRetry: () => context.go('/login'),
          );
        }

        final overviewAsync = ref.watch(dashboardOverviewProvider);
        final treksAsync = ref.watch(trekListProvider);

        return switch ((overviewAsync, treksAsync)) {
          (
            AsyncData<DashboardOverview> overviewData,
            AsyncData<List<TrekSummary>> treksData,
          ) =>
            _DashboardBody(
              overview: overviewData.value,
              featuredTreks: treksData.value.take(5).toList(),
            ),
          (AsyncError(), _) || (_, AsyncError()) => _CenteredError(
            label: 'Failed to load dashboard content.',
            onRetry: () {
              ref.invalidate(dashboardOverviewProvider);
              ref.invalidate(trekListProvider);
            },
          ),
          _ => const _CenteredLoading(label: 'Loading your expedition data...'),
        };
      },
    );
  }
}

/// Resolve a hero photo from a region/trek name.
String _heroImageForName(String name) {
  final n = name.toLowerCase();
  if (n.contains('everest')) return 'assets/images/everest_base_camp.png';
  if (n.contains('annapurna')) return 'assets/images/annapurna_circuit.png';
  if (n.contains('langtang')) return 'assets/images/langtang_valley.png';
  if (n.contains('poon') || n.contains('ghorepani')) {
    return 'assets/images/poon_hill.png';
  }
  return 'assets/images/everest_base_camp.png';
}

// ──────────────────────────────────────────────
// Dashboard Body — Main scrollable content
// ──────────────────────────────────────────────
class _DashboardBody extends ConsumerWidget {
  final DashboardOverview overview;
  final List<TrekSummary> featuredTreks;

  const _DashboardBody({required this.overview, required this.featuredTreks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;

    final activeState = ref.watch(activeTrekProvider);
    final isTracking =
        activeState.region != null && activeState.region!.isNotEmpty;

    final focusTasks = overview.tasks.take(3).toList();
    final topInsight = overview.insights.isNotEmpty
        ? overview.insights.first
        : null;

    final sosState = ref.watch(sosViewModelProvider);
    final queuedCount = sosState.queuedAlerts.length;

    // Resolve hero details
    String heroEyebrow = 'No active expedition';
    String heroTitle = 'Find your next summit';
    String heroSubtitle = 'Discover handpicked trails and start your journey.';
    String heroStatus = 'INACTIVE';
    Color heroStatusDot = LightColors.textTertiary;
    int progressPercent = 0;
    String heroImage = featuredTreks.isNotEmpty
        ? featuredTreks.first.coverImageAsset
        : 'assets/images/everest_base_camp.png';
    VoidCallback onHeroTap = () => context.go('/treks');
    VoidCallback? onHeroSecondaryTap;
    String heroButtonLabel = 'Explore treks';
    String? heroSecondaryButtonLabel;

    String distanceValue = '0.0 km';
    String ascentValue = '+0 m';
    String etaValue = '--';

    if (isTracking) {
      heroTitle = activeState.region!;
      heroImage = _heroImageForName(activeState.region!);
      heroStatus = activeState.isFinished ? 'COMPLETED' : 'LIVE';
      heroStatusDot = activeState.isFinished
          ? LightColors.successGreen
          : LightColors.peakAmber;
      heroEyebrow = 'Active expedition';

      final waypoints = getWaypointsForRegion(activeState.region!);
      final totalWps = activeState.totalCheckpoints > 0
          ? activeState.totalCheckpoints
          : waypoints.length;
      final curIdx = activeState.currentCheckpointIndex;

      progressPercent = (totalWps > 1)
          ? (curIdx / (totalWps - 1) * 100).clamp(0, 100).toInt()
          : 0;

      if (waypoints.isNotEmpty) {
        if (curIdx < waypoints.length - 1) {
          heroSubtitle =
              'Day ${curIdx + 1} • ${waypoints[curIdx].name} → ${waypoints[curIdx + 1].name}';
        } else {
          heroSubtitle =
              'Day ${curIdx + 1} • Destination reached at ${waypoints.last.name}';
        }

        if (activeState.currentAltitude != null) {
          final startAlt = waypoints.first.alt;
          final diff = (activeState.currentAltitude! - startAlt)
              .clamp(0.0, 10000.0)
              .round();
          ascentValue = '+$diff m';
        }
      } else {
        heroSubtitle = 'Day ${curIdx + 1} • Tracking coordinates live';
      }

      distanceValue = '${activeState.distanceWalkedKm.toStringAsFixed(1)} km';
      etaValue = activeState.isFinished
          ? 'Finished'
          : 'Day ${curIdx + 1}';
      heroButtonLabel = 'Resume tracker';
      onHeroTap = () =>
          context.push('/map-weather/navigator', extra: activeState.region);

      heroSecondaryButtonLabel = 'Stop';
      onHeroSecondaryTap = () {
        HapticFeedback.mediumImpact();
        ref.read(activeTrekProvider.notifier).clearTrek();
      };
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            ref.invalidate(dashboardOverviewProvider);
            ref.invalidate(trekListProvider);
            await ref.read(dashboardOverviewProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 110),
            children: [
              // Header
              StaggeredSection(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _DashboardHeader(
                    dateLabel: overview.header.dateLabel.isNotEmpty
                        ? overview.header.dateLabel
                        : 'Today',
                    greeting: overview.header.greeting.isNotEmpty
                        ? overview.header.greeting
                        : 'Welcome back',
                    onAvatarTap: () => context.go('/profile'),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Offline SOS queue warning banner
              if (queuedCount > 0) ...[
                StaggeredSection(
                  index: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClayContainer(
                      color: LightColors.peakAmber,
                      borderRadius: 16,
                      depth: 4,
                      isDark: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Offline: $queuedCount SOS alerts queued. Retrying automatically…',
                              style: AppType.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // SOS Emergency Slider
              StaggeredSection(
                index: 0,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SosTriggerWidget(),
                ),
              ),
              const SizedBox(height: 18),

              // Editorial expedition hero
              StaggeredSection(
                index: 1,
                child: EditorialHero(
                  imageAsset: heroImage,
                  eyebrow: heroEyebrow,
                  title: heroTitle,
                  subtitle: heroSubtitle,
                  height: 320,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  onTap: onHeroTap,
                  topTrailing: GlassChip(
                    label: heroStatus,
                    dotColor: heroStatusDot,
                  ),
                  bottomExtra: _HeroFooter(
                    progressPercent: progressPercent,
                    showProgress: isTracking,
                    buttonLabel: heroButtonLabel,
                    onTap: onHeroTap,
                    secondaryLabel: heroSecondaryButtonLabel,
                    onSecondaryTap: onHeroSecondaryTap,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Live metric strip (single neutral card, quiet stats)
              StaggeredSection(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _MetricStrip(
                    distance: distanceValue,
                    ascent: ascentValue,
                    eta: etaValue,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Smart Actions
              StaggeredSection(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditorialSectionHeader(
                        eyebrow: 'Jump back in',
                        title: 'Quick actions',
                        actionLabel: 'Rankings',
                        onAction: () => context.push('/leaderboard'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.terrain_rounded,
                              title: 'Explore treks',
                              subtitle: 'Discover routes',
                              accentColor: LightColors.forestPrimary,
                              onTap: () => context.go('/treks'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.auto_awesome_rounded,
                              title: 'AI guide',
                              subtitle: 'Ask anything',
                              accentColor: LightColors.peakAmber,
                              onTap: () => context.push('/ai-guide'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.map_rounded,
                              title: 'Map + weather',
                              subtitle: 'Trail conditions',
                              accentColor: LightColors.altitudeBlue,
                              onTap: () => context.go('/map-weather'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.monitor_heart_rounded,
                              title: 'AMS check',
                              subtitle: 'Altitude safety',
                              accentColor: LightColors.sosRed,
                              onTap: () => context.push('/ams-tracker'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Featured Treks Carousel (full-bleed)
              StaggeredSection(
                index: 4,
                child: FeaturedTrekCarousel(
                  treks: featuredTreks,
                  onTrekTap: (trek) => context.push('/treks/${trek.id}'),
                  onSeeAll: () => context.go('/treks'),
                ),
              ),
              const SizedBox(height: 30),

              // Weather Glance
              StaggeredSection(
                index: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditorialSectionHeader(
                        eyebrow: 'On the mountain',
                        title: 'Conditions',
                      ),
                      const SizedBox(height: 16),
                      WeatherGlanceWidget(
                        onTap: () => context.go('/map-weather'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Today Focus
              StaggeredSection(
                index: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditorialSectionHeader(
                        eyebrow: 'Stay on track',
                        title: 'Today’s focus',
                      ),
                      const SizedBox(height: 16),
                      _FocusChecklist(tasks: focusTasks),
                      if (topInsight != null) ...[
                        const SizedBox(height: 12),
                        _InsightCard(insight: topInsight),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Dashboard Header
// ──────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final String dateLabel;
  final String greeting;
  final VoidCallback onAvatarTap;

  const _DashboardHeader({
    required this.dateLabel,
    required this.greeting,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EyebrowLabel(dateLabel, color: c.textTertiary),
              const SizedBox(height: 8),
              Text(
                greeting,
                style: AppType.displayXL.copyWith(color: c.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.surfaceElevated,
              border: Border.all(color: c.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.person_rounded, color: c.primary, size: 24),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Hero footer — progress + CTAs over the photo
// ──────────────────────────────────────────────
class _HeroFooter extends StatelessWidget {
  final int progressPercent;
  final bool showProgress;
  final String buttonLabel;
  final VoidCallback onTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  const _HeroFooter({
    required this.progressPercent,
    required this.showProgress,
    required this.buttonLabel,
    required this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showProgress) ...[
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      LightColors.peakAmber,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progressPercent%',
                style: AppType.titleSm.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LightColors.summitDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: AppType.button.copyWith(
                    color: LightColors.summitDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (secondaryLabel != null && onSecondaryTap != null) ...[
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: onSecondaryTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    secondaryLabel!,
                    style: AppType.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Metric Strip — one neutral card, three quiet stats
// ──────────────────────────────────────────────
class _MetricStrip extends StatelessWidget {
  final String distance;
  final String ascent;
  final String eta;

  const _MetricStrip({
    required this.distance,
    required this.ascent,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: StatBlock(
              icon: Icons.route_rounded,
              value: distance,
              label: 'Distance',
              accent: LightColors.forestPrimary,
            ),
          ),
          _divider(c),
          Expanded(
            child: StatBlock(
              icon: Icons.trending_up_rounded,
              value: ascent,
              label: 'Ascent',
              accent: LightColors.altitudeBlue,
            ),
          ),
          _divider(c),
          Expanded(
            child: StatBlock(
              icon: Icons.schedule_rounded,
              value: eta,
              label: 'ETA',
              accent: LightColors.peakAmber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(AppColors c) => Container(
    width: 1,
    height: 42,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: c.border,
  );
}

// ──────────────────────────────────────────────
// Action Tile (neutral card with accent icon)
// ──────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppType.titleSm.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppType.caption.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Focus Checklist
// ──────────────────────────────────────────────
class _FocusChecklist extends StatelessWidget {
  final List<DashboardTask> tasks;

  const _FocusChecklist({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: LightColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'You are all set for today. Keep the momentum.',
                style: AppType.bodySm.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _FocusRow(task: tasks[i]),
          ],
        ],
      ),
    );
  }
}

class _FocusRow extends StatelessWidget {
  final DashboardTask task;
  const _FocusRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          task.done
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 20,
          color: task.done ? LightColors.successGreen : c.textTertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: AppType.bodySm.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                  decoration:
                      task.done ? TextDecoration.lineThrough : null,
                ),
              ),
              if (task.meta.isNotEmpty)
                Text(
                  task.meta,
                  style: AppType.caption.copyWith(color: c.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Insight Card
// ──────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final DashboardInsight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: c.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AppType.caption.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  insight.value,
                  style: AppType.titleSm.copyWith(color: c.primary),
                ),
                if (insight.hint.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    insight.hint,
                    style: AppType.caption.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Loading & Error states
// ──────────────────────────────────────────────
class _CenteredLoading extends StatelessWidget {
  final String label;

  const _CenteredLoading({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Scaffold(
      backgroundColor: c.canvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                color: c.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppType.bodySm.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredError extends StatelessWidget {
  final String label;
  final String actionLabel;
  final VoidCallback onRetry;

  const _CenteredError({
    required this.label,
    required this.onRetry,
    this.actionLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Scaffold(
      backgroundColor: c.canvas,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B1B1B)
                      : LightColors.redLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: c.error,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppType.title.copyWith(
                  color: c.textPrimary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(actionLabel, style: AppType.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
