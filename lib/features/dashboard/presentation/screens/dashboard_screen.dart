import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final overviewState = ref.watch(dashboardOverviewProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: Stack(
        children: [
          SafeArea(
            child: overviewState.when(
              loading: _buildLoading,
              error: (error, _) => _buildError(error.toString()),
              data: (overview) => RefreshIndicator(
                color: LightColors.forestPrimary,
                onRefresh: () async => ref.refresh(dashboardOverviewProvider.future),
                child: _buildContent(overview),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: LightColors.forestPrimary,
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: LightColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: LightColors.sosRed, size: 28),
              const SizedBox(height: 10),
              Text(
                'Unable to load dashboard',
                style: AppTextStyles.h3.copyWith(color: LightColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: LightColors.textSecondary),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => ref.invalidate(dashboardOverviewProvider),
                style: FilledButton.styleFrom(
                  backgroundColor: LightColors.forestPrimary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DashboardOverview overview) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildHeader(overview.header),
        _buildExpeditionHero(overview.expedition),
        _buildSectionTitle('Essential Actions', 'One tap access to what matters now'),
        _buildActionRow(),
        _buildSectionTitle('Live Overview', 'Real-time decisions for safer trekking'),
        _buildOverviewCards(overview.insights),
        _buildSectionTitle('Up Next', 'Your next checkpoint at a glance'),
        _buildNextCheckpointCard(overview.nextCheckpoint),
        _buildSectionTitle('Today Tasks', 'Focused execution with clear next steps'),
        _buildTaskList(overview.tasks),
        const SliverToBoxAdapter(child: SizedBox(height: 118)),
      ],
    );
  }

  Widget _buildHeader(DashboardHeader header) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header.dateLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.textSecondary,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    header.greeting,
                    style: AppTextStyles.h1.copyWith(
                      color: LightColors.textPrimary,
                      fontSize: 32,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    header.location,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: LightColors.surfaceWhite,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: const Icon(Icons.person_outline_rounded, color: LightColors.summitDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpeditionHero(ExpeditionSummary expedition) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: LightColors.surfaceWhite,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [LightColors.forestPrimary, LightColors.trailGreen],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE EXPEDITION',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    _heroBadge(expedition.statusTag),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expedition.title,
                      style: AppTextStyles.h2.copyWith(
                        color: LightColors.textPrimary,
                        fontSize: 29,
                      ),
                    ),
                    Text(
                      expedition.subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeroMetric(label: 'Distance', value: expedition.distance),
                        _HeroMetric(label: 'Ascent', value: expedition.ascent),
                        _HeroMetric(label: 'ETA', value: expedition.eta),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 9,
                        value: expedition.progress,
                        color: LightColors.forestPrimary,
                        backgroundColor: LightColors.meadowTint.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(expedition.progress * 100).round()}% completed today',
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.forestPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Continue Trek'),
                            style: FilledButton.styleFrom(
                              backgroundColor: LightColors.forestPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: LightColors.sosRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text('SOS', style: AppTextStyles.sosLabel.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textSecondary,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildActionRow() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(child: _actionCard('Offline Map', Icons.map_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _actionCard('Permits', Icons.assignment_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _actionCard('Trek Log', Icons.menu_book_outlined)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(String title, IconData icon) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: LightColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: LightColors.forestPrimary, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(List<DashboardInsight> insights) {
    final displayInsights = insights.take(2).toList();

    if (displayInsights.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverToBoxAdapter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 680;
            if (compact || displayInsights.length == 1) {
              return Column(
                children: [
                  for (int i = 0; i < displayInsights.length; i++) ...[
                    _overviewCard(displayInsights[i]),
                    if (i != displayInsights.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _overviewCard(displayInsights[0])),
                const SizedBox(width: 10),
                Expanded(child: _overviewCard(displayInsights[1])),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _overviewCard(DashboardInsight insight) {
    final color = insight.type == 'weather' ? LightColors.altitudeBlue : LightColors.forestPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  insight.type == 'weather' ? Icons.wb_cloudy_outlined : Icons.insights_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                insight.title,
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.value,
            style: AppTextStyles.h2.copyWith(
              color: LightColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            insight.hint,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextCheckpointCard(DashboardCheckpoint checkpoint) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LightColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColors.forestPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${checkpoint.order}',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkpoint.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      checkpoint.detail,
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: LightColors.textSecondary.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<DashboardTask> tasks) {
    if (tasks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LightColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              for (final task in tasks)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.done ? LightColors.forestPrimary : Colors.transparent,
                          border: Border.all(color: LightColors.forestPrimary.withValues(alpha: 0.45), width: 1.4),
                        ),
                        child: task.done
                            ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: LightColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      left: 22,
      right: 22,
      bottom: 24,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: LightColors.surfaceWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
            _buildNavItem(1, Icons.route_rounded, 'Route'),
            _buildNavItem(2, Icons.task_alt_rounded, 'Tasks'),
            _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? LightColors.forestPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 19,
              color: active ? Colors.white : LightColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: LightColors.textSecondary,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
