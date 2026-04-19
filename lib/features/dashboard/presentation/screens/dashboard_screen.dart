import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/trekking/domain/entities/itinerary.dart';
import 'package:path_app/features/trekking/presentation/screens/main_navigation_shell.dart';
import 'package:path_app/features/trekking/presentation/viewmodels/itinerary_providers.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onExploreTreks;

  const DashboardScreen({
    super.key,
    this.onExploreTreks,
  });

  void _openTreks(BuildContext context) {
    if (onExploreTreks != null) {
      onExploreTreks!();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationShell(initialTabIndex: 1),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItineraryAsync = ref.watch(activeItineraryProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: activeItineraryAsync.when(
          loading: () => const _DashboardLoadingState(),
          error: (error, _) => _DashboardErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(activeItineraryProvider),
          ),
          data: (itinerary) {
            if (itinerary == null) {
              return _NoPlanDashboard(
                onExploreTreks: () => _openTreks(context),
              );
            }

            return _ActivePlanDashboard(
              itinerary: itinerary,
              onExploreTreks: () => _openTreks(context),
            );
          },
        ),
      ),
    );
  }
}

class _NoPlanDashboard extends StatelessWidget {
  final VoidCallback onExploreTreks;

  const _NoPlanDashboard({
    required this.onExploreTreks,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateLabel = '${today.day}/${today.month}/${today.year}';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PATH Dashboard',
                  style: AppTextStyles.h2.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today • $dateLabel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [LightColors.summitDark, LightColors.forestPrimary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: LightColors.forestPrimary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find a trail that fits your pace',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose distance, elevation, and risk level. PATH will guide each day with safety-first recommendations.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: onExploreTreks,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: LightColors.summitDark,
                      ),
                      icon: const Icon(Icons.hiking_rounded),
                      label: const Text('Browse Treks'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Why This Home Is Simple',
              style: AppTextStyles.h3.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: const [
                Expanded(
                  child: _BenefitTile(
                    icon: Icons.filter_alt_rounded,
                    title: 'Lower Choices',
                    subtitle: 'Guided steps reduce decision fatigue.',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _BenefitTile(
                    icon: Icons.warning_amber_rounded,
                    title: 'Safety First',
                    subtitle: 'High-risk alerts are always visible.',
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          sliver: const SliverToBoxAdapter(
            child: _BenefitTile(
              icon: Icons.track_changes_rounded,
              title: 'Clear Progress',
              subtitle: 'Every screen highlights next best action.',
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivePlanDashboard extends StatelessWidget {
  final Itinerary itinerary;
  final VoidCallback onExploreTreks;

  const _ActivePlanDashboard({
    required this.itinerary,
    required this.onExploreTreks,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = itinerary.startDate;
    final totalDays = itinerary.totalDays > 0 ? itinerary.totalDays : 1;
    final dayIndex = startDate == null
        ? 1
        : (today.difference(DateTime(startDate.year, startDate.month, startDate.day)).inDays + 1)
            .clamp(1, totalDays);

    final progress = dayIndex / totalDays;
    final todayDay = itinerary.getDayByNumber(dayIndex) ?? (itinerary.days.isNotEmpty ? itinerary.days.first : null);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Active Trek',
              style: AppTextStyles.caption.copyWith(
                color: LightColors.forestPrimary,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              itinerary.name,
              style: AppTextStyles.h2.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MetricPill(label: 'Day', value: '$dayIndex/$totalDays'),
                      const SizedBox(width: 8),
                      _MetricPill(label: 'Distance', value: '${itinerary.totalDistanceKm.toStringAsFixed(1)} km'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    todayDay == null ? 'Next segment loading...' : todayDay.displayName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayDay == null
                        ? 'Keep your route data synced.'
                        : '${todayDay.startLocation} to ${todayDay.endLocation} • ${todayDay.estimatedHours.toStringAsFixed(1)}h',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: LightColors.meadowTint,
                      valueColor: const AlwaysStoppedAnimation(LightColors.forestPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.map_rounded,
                    label: 'Open Route',
                    color: LightColors.altitudeBlue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Route screen is in the Route tab.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.hiking_rounded,
                    label: 'Browse Treks',
                    color: LightColors.forestPrimary,
                    onTap: onExploreTreks,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
          sliver: SliverToBoxAdapter(
            child: _ActionButton(
              icon: Icons.emergency_rounded,
              label: 'Emergency SOS',
              color: LightColors.sosRed,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SOS demo action triggered.')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: LightColors.forestPrimary),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LightColors.meadowTint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.caption.copyWith(
          color: LightColors.summitDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: LightColors.forestPrimary,
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: LightColors.sosRed.withValues(alpha: 0.9),
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              'Dashboard unavailable right now',
              style: AppTextStyles.bodyLarge.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: LightColors.forestPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
