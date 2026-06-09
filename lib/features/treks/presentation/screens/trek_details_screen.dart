import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/domain/entities/itinerary_step.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';
import 'package:path_app/features/treks/presentation/widgets/clay_elevation_chart.dart';

class TrekDetailsScreen extends ConsumerStatefulWidget {
  final String trekId;

  const TrekDetailsScreen({super.key, required this.trekId});

  @override
  ConsumerState<TrekDetailsScreen> createState() => _TrekDetailsScreenState();
}

class _TrekDetailsScreenState extends ConsumerState<TrekDetailsScreen> {
  bool _isTracking = false;
  int _activeTab = 0; // 0 = Route, 1 = Itinerary
  int _activeDayIndex = 0;
  late final PageController _dayPageController = PageController();

  @override
  void dispose() {
    _dayPageController.dispose();
    super.dispose();
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTracking
              ? 'Route Navigation Active: GPS cache lock engaged.'
              : 'Navigation tracking paused.',
        ),
        backgroundColor: _isTracking
            ? LightColors.successGreen
            : LightColors.summitDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trekAsync = ref.watch(trekDetailsProvider(widget.trekId));

    return trekAsync.when(
      loading: () => Scaffold(
        backgroundColor: LightColors.stoneWhite,
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: LightColors.summitDark,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: LightColors.forestPrimary),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: LightColors.stoneWhite,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: LightColors.summitDark,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: LightColors.sosRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load trek details',
                  style: AppTextStyles.h3.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.invalidate(trekDetailsProvider(widget.trekId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LightColors.forestPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (trek) {
        if (trek == null) {
          return Scaffold(
            backgroundColor: LightColors.stoneWhite,
            appBar: AppBar(title: const Text('Trek Details')),
            body: Center(
              child: Text(
                'Trek not found.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: LightColors.stoneWhite,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Claymorphic Header Banner ──
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: LightColors.summitDark,
                leading: BackButton(
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    trek.name,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(trek.coverImageAsset, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${trek.region} Region • Best Season: ${trek.bestSeason}',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Detailed Info Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Claymorphic Tab Switcher
                      _buildTabSwitcher(),
                      const SizedBox(height: 18),

                      // Animated cross switcher for tabs
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.08, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _activeTab == 0
                            ? _buildRouteProfileTab(trek)
                            : _buildItineraryTab(trek),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabSwitcher() {
    return ClayContainer(
      depth: 4,
      spread: 2,
      borderRadius: 20,
      color: LightColors.stoneWhite,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTab = 0;
                });
              },
              child: ClayContainer(
                depth: _activeTab == 0 ? 4 : 0,
                spread: _activeTab == 0 ? 2 : 0,
                borderRadius: 16,
                isFlat: _activeTab != 0,
                color: _activeTab == 0 ? Colors.white : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Route Profile',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _activeTab == 0
                          ? LightColors.forestPrimary
                          : LightColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTab = 1;
                });
              },
              child: ClayContainer(
                depth: _activeTab == 1 ? 4 : 0,
                spread: _activeTab == 1 ? 2 : 0,
                borderRadius: 16,
                isFlat: _activeTab != 1,
                color: _activeTab == 1 ? Colors.white : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Itinerary & Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _activeTab == 1
                          ? LightColors.forestPrimary
                          : LightColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteProfileTab(TrekSummary trek) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3D Stat Grid using ClayContainers
        Row(
          children: [
            _StatTile(
              label: 'Duration',
              value: '${trek.durationDays} days',
              icon: Icons.calendar_month_rounded,
              accentColor: LightColors.forestPrimary,
            ),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Distance',
              value: '${trek.distanceKm} km',
              icon: Icons.route_rounded,
              accentColor: LightColors.altitudeBlue,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatTile(
              label: 'Ascent',
              value: '+${trek.elevationGainM} m',
              icon: Icons.trending_up_rounded,
              accentColor: LightColors.peakAmber,
            ),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Max Altitude',
              value: '${trek.maxAltitudeM} m',
              icon: Icons.terrain_rounded,
              accentColor: LightColors.sosRed,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Elevation Profile Chart
        if (trek.detailedItinerary.isNotEmpty) ...[
          ClayElevationChart(steps: trek.detailedItinerary),
          const SizedBox(height: 24),
        ],

        // Route Map Card (Tactile Clay)
        ClayContainer(
          depth: 6,
          spread: 3,
          borderRadius: 22,
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: LightColors.forestPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'LIVE TRAIL MAP & PLANNER',
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.forestPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Offline GIS route maps are locked for ${trek.region} region. Track checkpoints and elevation metrics without cellular coverage.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isTracking
                          ? 'GPS Navigation Active'
                          : 'GPS Offline Idle',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isTracking
                            ? LightColors.successGreen
                            : LightColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _toggleTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking
                          ? LightColors.successGreen
                          : LightColors.forestPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: Icon(
                      _isTracking
                          ? Icons.gps_fixed_rounded
                          : Icons.gps_not_fixed_rounded,
                      size: 16,
                    ),
                    label: Text(_isTracking ? 'TRACKING' : 'START PLAN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryTab(TrekSummary trek) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview Section
        Text(
          'Overview',
          style: AppTextStyles.h2.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          trek.longDescription,
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Highlights
        Text(
          'Highlights',
          style: AppTextStyles.h2.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        ...trek.highlights.map(
          (highlight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClayContainer(
              depth: 3,
              spread: 1.5,
              borderRadius: 14,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 18,
                    color: LightColors.forestPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      highlight,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Horizontal Day-by-Day Itinerary Carousel
        Text(
          'Day-by-Day Itinerary',
          style: AppTextStyles.h2.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Slide cards or tap nodes to navigate structured checkpoints.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Day Selector (nodes row connected by path line)
        if (trek.detailedItinerary.isNotEmpty) ...[
          _buildDayStepperNodes(trek.detailedItinerary),
          const SizedBox(height: 14),
          _buildItineraryCarousel(trek.detailedItinerary),
        ],
      ],
    );
  }

  Widget _buildDayStepperNodes(List<ItineraryStep> steps) {
    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connecting trail line
          Positioned(
            left: 28,
            right: 28,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: LightColors.forestPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Scrollable Nodes Row
          ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: steps.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final isActive = index == _activeDayIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeDayIndex = index;
                      });
                      _dayPageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: ClayContainer(
                        depth: isActive ? 6 : 2,
                        spread: isActive ? 2.5 : 1,
                        borderRadius: 99,
                        color: isActive
                            ? LightColors.forestPrimary
                            : Colors.white,
                        padding: EdgeInsets.zero,
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Center(
                            child: Text(
                              'D${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : LightColors.forestPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryCarousel(List<ItineraryStep> steps) {
    return SizedBox(
      height: 310,
      child: PageView.builder(
        controller: _dayPageController,
        itemCount: steps.length,
        onPageChanged: (index) {
          setState(() {
            _activeDayIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final step = steps[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ClayContainer(
              depth: 4,
              spread: 2,
              borderRadius: 22,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Title & Day Label
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              style: AppTextStyles.h3.copyWith(
                                color: LightColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: LightColors.forestPrimary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Day ${index + 1}',
                              style: AppTextStyles.caption.copyWith(
                                color: LightColors.forestPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Step Description
                      Text(
                        step.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightColors.textSecondary,
                          height: 1.45,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Metric Badge Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _MetricBadge(
                            icon: Icons.terrain_rounded,
                            label: '${step.altitudeM} m',
                            color: LightColors.altitudeBlue,
                          ),
                          _MetricBadge(
                            icon: Icons.schedule_rounded,
                            label: step.hikingTime,
                            color: LightColors.peakAmber,
                            key: ValueKey('time_${step.hikingTime}'),
                          ),
                          _MetricBadge(
                            icon: Icons.speed_rounded,
                            label: step.difficulty,
                            color: step.difficulty == 'Easy'
                                ? LightColors.successGreen
                                : step.difficulty == 'Moderate'
                                ? LightColors.peakAmber
                                : LightColors.sosRed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Recommended Stays / Hotels Box
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: LightColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.hotel_rounded,
                              size: 16,
                              color: LightColors.forestPrimary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RECOMMENDED STAYS:',
                                    style: AppTextStyles.caption.copyWith(
                                      color: LightColors.forestPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step.stays.join(', '),
                                    style: AppTextStyles.caption.copyWith(
                                      color: LightColors.summitDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // GIS Location status
                      if (step.latitude != null && step.longitude != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: LightColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'GIS Location: ${step.latitude!.toStringAsFixed(4)}, ${step.longitude!.toStringAsFixed(4)} (Cached)',
                              style: const TextStyle(
                                fontSize: 10,
                                color: LightColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SpaceGrotesk',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Claymorphic Stat Card Widget
// ──────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClayContainer(
        depth: 4,
        spread: 2,
        borderRadius: 18,
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
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
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Metric Badge Widget
// ──────────────────────────────────────────────
class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
