import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/gamification/gamification_widgets.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';

/// Premium Dashboard Screen with:
/// - Glassmorphism effects & visual depth
/// - Animated card entrances
/// - Multiple sections (routes, tasks from server)
/// - Better color harmony and typography
/// - Smooth micro-interactions
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

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
              data: (overview) {
                // Trigger animations on load
                _fadeController.forward(from: 0);
                _slideController.forward(from: 0);

                return RefreshIndicator(
                  color: LightColors.forestPrimary,
                  strokeWidth: 2.8,
                  backgroundColor: Colors.white,
                  onRefresh: () async =>
                      ref.refresh(dashboardOverviewProvider.future),
                  child: _buildContent(overview),
                );
              },
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LightColors.forestPrimary.withValues(alpha: 0.08),
              border: Border.all(
                color: LightColors.forestPrimary.withValues(alpha: 0.15),
              ),
            ),
            child: const CircularProgressIndicator(
              color: LightColors.forestPrimary,
              strokeWidth: 2.8,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your journey...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.forestPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: LightColors.surfaceWhite,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LightColors.sosRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: LightColors.sosRed.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: LightColors.sosRed,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Connection Issue',
                style: AppTextStyles.h3.copyWith(
                  color: LightColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message.length > 100
                    ? 'Unable to load your dashboard. Check your internet connection and try again.'
                    : message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.invalidate(dashboardOverviewProvider),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: LightColors.forestPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DashboardOverview overview) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(_fadeController),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(overview.header),
          _buildStreakAndMotivationSection(),
          _buildExpeditionHero(overview.expedition),
          _buildAchievementsShowcase(),
          _buildLiveStatusIndicator(),
          _buildQuickActionsSection(),
          _buildSectionDivider(),
          _buildSectionTitle('Essential Metrics', 'Your trek at a glance'),
          _buildInsightsGrid(overview.insights),
          _buildSectionTitle('What\'s Next', 'Stay on track'),
          _buildNextCheckpointCard(overview.nextCheckpoint),
          _buildSectionTitle('Today\'s Focus', 'Execute with clarity'),
          _buildTasksWidget(overview.tasks),
          _buildSectionTitle('Upcoming Routes', 'Your roadmap ahead'),
          _buildRoutesSection(),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 140),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(DashboardHeader header) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header.dateLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.forestPrimary,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Gradient text effect for greeting
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        LightColors.textPrimary,
                        LightColors.forestPrimary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      header.greeting,
                      style: AppTextStyles.h1.copyWith(
                        color: LightColors.textPrimary,
                        fontSize: 38,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: LightColors.altitudeBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        header.location,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildProfileAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LightColors.forestPrimary.withValues(alpha: 0.2),
            LightColors.meadowTint.withValues(alpha: 0.15),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.25),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: LightColors.forestPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: LightColors.forestPrimary,
        size: 30,
      ),
    );
  }

  /// Gamification section: Shows streak badge + motivational message
  Widget _buildStreakAndMotivationSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak indicator with shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const StreakIndicator(),
            ),
            const SizedBox(height: 12),
            // Motivational message from gamification service
            const MotivationalMessage(),
          ],
        ),
      ),
    );
  }

  /// Achievements showcase section: Grid of unlocked badges
  Widget _buildAchievementsShowcase() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      sliver: SliverToBoxAdapter(
        child: const AchievementsGrid(maxDisplay: 4),
      ),
    );
  }

  Widget _buildExpeditionHero(ExpeditionSummary expedition) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      sliver: SliverToBoxAdapter(
        child: _buildGlassmorphicCard(
          child: Column(
            children: [
              // Premium gradient header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LightColors.forestPrimary,
                      LightColors.summitDark.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: LightColors.forestPrimary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child:
                          const Icon(Icons.route_rounded, color: Colors.white, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ACTIVE EXPEDITION',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _buildStatusBadge(expedition.statusTag),
                  ],
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expedition.title,
                      style: AppTextStyles.h2.copyWith(
                        color: LightColors.textPrimary,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      expedition.subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildMetricsRow(expedition),
                    const SizedBox(height: 20),
                    _buildProgressBar(expedition.progress),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow_rounded, size: 20),
                            label: const Text('Continue'),
                            style: FilledButton.styleFrom(
                              backgroundColor: LightColors.forestPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: LightColors.sosRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'SOS',
                            style: AppTextStyles.sosLabel.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
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

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMetricsRow(ExpeditionSummary expedition) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricPill('Distance', expedition.distance),
        _buildMetricPill('Ascent', expedition.ascent),
        _buildMetricPill('ETA', expedition.eta),
      ],
    );
  }

  Widget _buildMetricPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: LightColors.meadowTint.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: LightColors.forestPrimary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Progress',
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.caption.copyWith(
                color: LightColors.forestPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 11,
            value: progress,
            color: LightColors.forestPrimary,
            backgroundColor: LightColors.meadowTint.withValues(alpha: 0.25),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStatusIndicator() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: LightColors.altitudeBlue.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: LightColors.altitudeBlue.withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: LightColors.altitudeBlue.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: LightColors.altitudeBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                'Live tracking • Connected',
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.altitudeBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.map_outlined,
                label: 'Map',
                color: LightColors.altitudeBlue,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.assignment_outlined,
                label: 'Permits',
                color: LightColors.peakAmber,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.menu_book_outlined,
                label: 'Trek Log',
                color: LightColors.trailGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 7),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: LightColors.forestPrimary,
                letterSpacing: 1.9,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
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

  Widget _buildInsightsGrid(List<DashboardInsight> insights) {
    if (insights.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final displayInsights = insights.take(2).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: List.generate(
            displayInsights.length,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == displayInsights.length - 1 ? 0 : 10),
                child: _buildInsightCard(displayInsights[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(DashboardInsight insight) {
    final isWeather = insight.type == 'weather';
    final color = isWeather ? LightColors.altitudeBlue : LightColors.peakAmber;

    return _buildGlassmorphicCard(
      borderColor: color.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  isWeather ? Icons.cloud_outlined : Icons.trending_up,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  insight.title,
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            insight.value,
            style: AppTextStyles.h2.copyWith(
              color: LightColors.textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            insight.hint,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextCheckpointCard(DashboardCheckpoint checkpoint) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: _buildGlassmorphicCard(
          borderColor: LightColors.forestPrimary.withValues(alpha: 0.16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LightColors.forestPrimary,
                      LightColors.trailGreen,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: LightColors.forestPrimary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '${checkpoint.order}',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkpoint.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      checkpoint.detail,
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: LightColors.textSecondary.withValues(alpha: 0.4),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksWidget(List<DashboardTask> tasks) {
    if (tasks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: _buildGlassmorphicCard(
          child: Column(
            children: [
              for (int i = 0; i < tasks.length; i++) ...[
                _buildTaskItem(tasks[i]),
                if (i < tasks.length - 1)
                  Divider(
                    height: 14,
                    thickness: 1,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(DashboardTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.done
                  ? LightColors.forestPrimary
                  : Colors.transparent,
              border: Border.all(
                color: task.done
                    ? LightColors.forestPrimary
                    : LightColors.forestPrimary.withValues(alpha: 0.35),
                width: 1.6,
              ),
              boxShadow: task.done
                  ? [
                      BoxShadow(
                        color:
                            LightColors.forestPrimary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: task.done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
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
    );
  }

  Widget _buildRoutesSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            _buildRouteCard(
              title: 'Manali-Leh Highway',
              distance: '473 km',
              difficulty: 'Expert',
              estimatedDays: '10–12 days',
              icon: Icons.directions_walk_rounded,
              color: LightColors.sosRed,
            ),
            const SizedBox(height: 11),
            _buildRouteCard(
              title: 'Everest Base Camp',
              distance: '65 km',
              difficulty: 'Advanced',
              estimatedDays: '12–14 days',
              icon: Icons.terrain_rounded,
              color: LightColors.peakAmber,
            ),
            const SizedBox(height: 11),
            _buildRouteCard(
              title: 'Annapurna Circuit',
              distance: '160 km',
              difficulty: 'Intermediate',
              estimatedDays: '7–8 days',
              icon: Icons.landscape_rounded,
              color: LightColors.trailGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard({
    required String title,
    required String distance,
    required String difficulty,
    required String estimatedDays,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        splashColor: color.withValues(alpha: 0.08),
        child: _buildGlassmorphicCard(
          borderColor: color.withValues(alpha: 0.18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          distance,
                          style: AppTextStyles.caption.copyWith(
                            color: LightColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: AppTextStyles.caption.copyWith(
                            color: LightColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            difficulty,
                            style: AppTextStyles.caption.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    estimatedDays,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Duration',
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: color.withValues(alpha: 0.4),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable glassmorphic card builder
  /// Creates cards with:
  /// - Soft shadows and borders
  /// - Optional custom border color
  /// - Consistent padding and spacing
  Widget _buildGlassmorphicCard({
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LightColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor ?? Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: LightColors.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? LightColors.forestPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: LightColors.forestPrimary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: active ? Colors.white : LightColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
