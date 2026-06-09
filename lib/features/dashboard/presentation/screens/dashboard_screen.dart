import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/animations/staggered_section.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:path_app/features/dashboard/presentation/widgets/featured_trek_carousel.dart';
import 'package:path_app/features/dashboard/presentation/widgets/weather_glance_widget.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
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
          (AsyncData<DashboardOverview> overviewData, AsyncData<List<TrekSummary>> treksData) =>
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

// ──────────────────────────────────────────────
// Dashboard Body — Main scrollable content
// ──────────────────────────────────────────────
class _DashboardBody extends ConsumerWidget {
  final DashboardOverview overview;
  final List<TrekSummary> featuredTreks;

  const _DashboardBody({
    required this.overview,
    required this.featuredTreks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressPercent = (overview.expedition.progress * 100).clamp(0, 100).toInt();
    final focusTasks = overview.tasks.take(3).toList();
    final topInsight = overview.insights.isNotEmpty ? overview.insights.first : null;

    final sosState = ref.watch(sosViewModelProvider);
    final queuedCount = sosState.queuedAlerts.length;

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: LightColors.forestPrimary,
          onRefresh: () async {
            ref.invalidate(dashboardOverviewProvider);
            ref.invalidate(trekListProvider);
            await ref.read(dashboardOverviewProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
            children: [
              // 0: Header
              StaggeredSection(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DashboardHeader(
                    dateLabel: overview.header.dateLabel.isNotEmpty
                        ? overview.header.dateLabel
                        : 'Today',
                    greeting: overview.header.greeting.isNotEmpty
                        ? overview.header.greeting
                        : 'Journey Dashboard',
                    onAvatarTap: () => context.go('/profile'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Offline SOS queue warning banner
              if (queuedCount > 0) ...[
                StaggeredSection(
                  index: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClayContainer(
                      color: LightColors.peakAmber,
                      borderRadius: 16,
                      depth: 4,
                      isDark: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Offline Cache: $queuedCount SOS alerts queued for transmission. Retrying automatically...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // SOS Emergency Slider
              StaggeredSection(
                index: 0,
                child: const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SosTriggerWidget(),
                ),
              ),
              const SizedBox(height: 16),

              // 1: Expedition Hero
              StaggeredSection(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ExpeditionHeroCard(
                    title: overview.expedition.title.isNotEmpty
                        ? overview.expedition.title
                        : 'Everest Base Camp',
                    subtitle: overview.expedition.subtitle.isNotEmpty
                        ? overview.expedition.subtitle
                        : 'Day 05 • Namche to Tengboche',
                    status: overview.expedition.statusTag.isNotEmpty
                        ? overview.expedition.statusTag
                        : 'SYNC OK',
                    progressPercent: progressPercent,
                    onPlanTap: () => context.go('/treks'),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2: Metric tiles
              StaggeredSection(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: _MetricTile(
                        icon: Icons.route_rounded,
                        value: overview.expedition.distance.isNotEmpty
                            ? overview.expedition.distance : '11.2 km',
                        label: 'Distance',
                        accentColor: LightColors.forestPrimary,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _MetricTile(
                        icon: Icons.trending_up_rounded,
                        value: overview.expedition.ascent.isNotEmpty
                            ? overview.expedition.ascent : '+780 m',
                        label: 'Ascent',
                        accentColor: LightColors.altitudeBlue,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _MetricTile(
                        icon: Icons.schedule_rounded,
                        value: overview.expedition.eta.isNotEmpty
                            ? overview.expedition.eta : '5h 20m',
                        label: 'ETA',
                        accentColor: LightColors.peakAmber,
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3: Smart Actions
              StaggeredSection(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Smart Actions',
                        trailingText: 'Customize',
                        onTap: () => context.go('/profile'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _ActionTile(
                            icon: Icons.terrain_rounded,
                            title: 'Explore Treks',
                            subtitle: 'Discover routes',
                            accentColor: LightColors.forestPrimary,
                            onTap: () => context.go('/treks'),
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _ActionTile(
                            icon: Icons.map_rounded,
                            title: 'Map + Weather',
                            subtitle: 'Trail conditions',
                            accentColor: LightColors.altitudeBlue,
                            onTap: () => context.go('/map-weather'),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 4: Featured Treks Carousel (full-bleed)
              StaggeredSection(
                index: 4,
                child: FeaturedTrekCarousel(
                  treks: featuredTreks,
                  onTrekTap: (trek) => context.push('/treks/${trek.id}'),
                  onSeeAll: () => context.go('/treks'),
                ),
              ),
              const SizedBox(height: 22),

              // 5: Weather Glance
              StaggeredSection(
                index: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WeatherGlanceWidget(
                    onTap: () => context.go('/map-weather'),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 6: Today Focus
              StaggeredSection(
                index: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Today Focus'),
                      const SizedBox(height: 12),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.textSecondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                greeting,
                style: AppTextStyles.h1.copyWith(
                  color: LightColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LightColors.primaryLight,
              border: Border.all(
                color: LightColors.forestPrimary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: LightColors.forestPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Expedition Hero Card
// ──────────────────────────────────────────────
class _ExpeditionHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final int progressPercent;
  final VoidCallback onPlanTap;

  const _ExpeditionHeroCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progressPercent,
    required this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      depth: 6,
      spread: 3,
      borderRadius: 22,
      color: LightColors.summitDark,
      isDark: true,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: LightColors.successGreen,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$progressPercent%',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progressPercent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(LightColors.peakAmber),
                ),
              ),
              const SizedBox(height: 16),
              // CTA
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPlanTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: LightColors.summitDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Plan Next Move',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: LightColors.summitDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Metric Tile
// ──────────────────────────────────────────────
class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor = LightColors.forestPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      depth: 4,
      spread: 2,
      borderRadius: 16,
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
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
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Action Tile
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
    return GestureDetector(
      onTap: onTap,
      child: ClayContainer(
        depth: 4,
        spread: 2,
        borderRadius: 18,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Section Header
// ──────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h2.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        if (trailingText != null && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              trailingText!,
              style: AppTextStyles.caption.copyWith(
                color: LightColors.forestPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
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
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LightColors.dividerLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: LightColors.successGreen, size: 20),
            const SizedBox(width: 10),
            Text(
              'You are all set for today. Keep the momentum.',
              style: AppTextStyles.bodyMedium.copyWith(color: LightColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightColors.dividerLight),
      ),
      child: Column(
        children: tasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                task.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: task.done ? LightColors.successGreen : LightColors.textTertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.meta.isNotEmpty)
                      Text(
                        task.meta,
                        style: AppTextStyles.caption.copyWith(
                          color: LightColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LightColors.forestPrimary.withValues(alpha: 0.06),
            LightColors.forestPrimary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: LightColors.forestPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: LightColors.forestPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.value,
                  style: AppTextStyles.h3.copyWith(
                    color: LightColors.forestPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (insight.hint.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    insight.hint,
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.textSecondary,
                      fontSize: 11,
                    ),
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
    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36, height: 36,
              child: CircularProgressIndicator(
                color: LightColors.forestPrimary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: LightColors.textSecondary),
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
    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: LightColors.redLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: LightColors.sosRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: LightColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: LightColors.forestPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
