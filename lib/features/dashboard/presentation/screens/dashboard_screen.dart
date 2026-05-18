import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

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
              featuredTreks: treksData.value.take(3).toList(),
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

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: RefreshIndicator(
          color: LightColors.forestPrimary,
          onRefresh: () async {
            ref.invalidate(dashboardOverviewProvider);
            ref.invalidate(trekListProvider);
            await ref.read(dashboardOverviewProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              _DashboardHeader(
                dateLabel: overview.header.dateLabel.isNotEmpty
                    ? overview.header.dateLabel
                    : 'Today',
                greeting: overview.header.greeting.isNotEmpty
                    ? overview.header.greeting
                    : 'Journey Dashboard',
                onAvatarTap: () => context.go('/profile'),
              ),
              const SizedBox(height: 12),
              _ExpeditionHeroCard(
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.route_rounded,
                      value: overview.expedition.distance.isNotEmpty
                          ? overview.expedition.distance
                          : '11.2 km',
                      label: 'Distance',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.trending_up_rounded,
                      value: overview.expedition.ascent.isNotEmpty
                          ? overview.expedition.ascent
                          : '+780 m',
                      label: 'Ascent',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.schedule_rounded,
                      value: overview.expedition.eta.isNotEmpty
                          ? overview.expedition.eta
                          : '5h 20m',
                      label: 'ETA',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'Smart Actions',
                trailingText: 'Customize',
                onTap: () => context.go('/profile'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.terrain_rounded,
                      title: 'Explore Treks',
                      subtitle: 'Discover routes',
                      onTap: () => context.go('/treks'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.map_rounded,
                      title: 'Map + Weather',
                      subtitle: 'Trail conditions',
                      onTap: () => context.go('/map-weather'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'Featured Treks',
                trailingText: 'See all',
                onTap: () => context.go('/treks'),
              ),
              const SizedBox(height: 10),
              ...featuredTreks.map(
                (trek) => _FeaturedTrekTile(
                  trek: trek,
                  onTap: () => context.push('/treks/${trek.id}'),
                ),
              ),
              const SizedBox(height: 8),
              _SectionHeader(title: 'Today Focus'),
              const SizedBox(height: 10),
              _FocusChecklist(tasks: focusTasks),
              if (topInsight != null) ...[
                const SizedBox(height: 14),
                _InsightCard(insight: topInsight),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                greeting,
                style: AppTextStyles.h1.copyWith(
                  color: LightColors.textPrimary,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onAvatarTap,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: LightColors.primaryLight,
            ),
            child: const Icon(
              Icons.landscape_rounded,
              color: LightColors.forestPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF184A36), Color(0xFF2B6C50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
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
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressPercent / 100,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(LightColors.peakAmber),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onPlanTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: LightColors.summitDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Plan Next Move'),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: LightColors.forestPrimary),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LightColors.dividerLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: LightColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: LightColors.forestPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedTrekTile extends StatelessWidget {
  final TrekSummary trek;
  final VoidCallback onTap;

  const _FeaturedTrekTile({
    required this.trek,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LightColors.dividerLight),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: LightColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.landscape_rounded, color: LightColors.forestPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trek.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trek.durationDays} days • ${trek.region} • ${trek.rating.toStringAsFixed(1)}★',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }
}

class _FocusChecklist extends StatelessWidget {
  final List<DashboardTask> tasks;

  const _FocusChecklist({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LightColors.dividerLight),
        ),
        child: Text(
          'You are all set for today. Keep the momentum.',
          style: AppTextStyles.bodyMedium.copyWith(color: LightColors.textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightColors.dividerLight),
      ),
      child: Column(
        children: tasks
            .map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      task.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: task.done ? LightColors.successGreen : LightColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: LightColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (task.meta.isNotEmpty)
                            Text(
                              task.meta,
                              style: AppTextStyles.caption.copyWith(
                                color: LightColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final DashboardInsight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightColors.dividerLight),
      ),
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
          const SizedBox(height: 6),
          Text(
            insight.value,
            style: AppTextStyles.h3.copyWith(
              color: LightColors.forestPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

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
            ),
          ),
        ),
        if (trailingText != null && onTap != null)
          InkWell(
            onTap: onTap,
            child: Text(
              trailingText!,
              style: AppTextStyles.h3.copyWith(
                color: LightColors.forestPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

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
            const CircularProgressIndicator(color: LightColors.forestPrimary),
            const SizedBox(height: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 42, color: LightColors.sosRed),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: LightColors.textSecondary),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(backgroundColor: LightColors.forestPrimary),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
