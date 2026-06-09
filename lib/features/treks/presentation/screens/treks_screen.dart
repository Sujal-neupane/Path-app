import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

class TreksScreen extends ConsumerWidget {
  const TreksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treksAsync = ref.watch(trekListProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: treksAsync.when(
          loading: () => const _TreksLoadingShimmer(),
          error: (error, stack) => _TreksErrorView(
            error: error.toString(),
            onRetry: () => ref.invalidate(trekListProvider),
          ),
          data: (treks) => _TreksListView(treks: treks),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Trek List (Data loaded successfully)
// ──────────────────────────────────────────────
class _TreksListView extends StatefulWidget {
  final List<TrekSummary> treks;

  const _TreksListView({required this.treks});

  @override
  State<_TreksListView> createState() => _TreksListViewState();
}

class _TreksListViewState extends State<_TreksListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDifficulty = 'All';

  final List<String> _difficulties = ['All', 'Easy', 'Moderate', 'Challenging', 'Extreme'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TrekSummary> get _filteredTreks {
    return widget.treks.where((trek) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          trek.name.toLowerCase().contains(query) ||
          trek.region.toLowerCase().contains(query) ||
          trek.shortDescription.toLowerCase().contains(query);

      // Matches mapped labels like 'Easy', 'Moderate', 'Challenging', 'Extreme'
      final matchesDifficulty = _selectedDifficulty == 'All' ||
          trek.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase();

      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedDifficulty = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.treks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hiking_rounded,
              size: 64,
              color: LightColors.textTertiary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No treks available yet',
              style: AppTextStyles.h3.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Official treks will appear here once published.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredTreks;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Treks',
                  style: AppTextStyles.h1.copyWith(
                    color: LightColors.textPrimary,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Handpicked routes for your next mountain story.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Claymorphic Search Bar
                ClayContainer(
                  borderRadius: 16,
                  depth: 4,
                  spread: 2,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: LightColors.forestPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: LightColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by name, region...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: LightColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: const Icon(
                            Icons.close_rounded,
                            color: LightColors.textSecondary,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Difficulty Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _difficulties.map((diff) {
                      final isSelected = _selectedDifficulty == diff;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 6, top: 4),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedDifficulty = diff;
                            });
                          },
                          child: ClayContainer(
                            borderRadius: 12,
                            depth: isSelected ? 2 : 5,
                            spread: isSelected ? 1 : 2,
                            isFlat: isSelected,
                            color: isSelected ? LightColors.meadowTint : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Text(
                              diff,
                              style: AppTextStyles.button.copyWith(
                                color: isSelected
                                    ? LightColors.primaryFocus
                                    : LightColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_list_off_rounded,
                    size: 56,
                    color: LightColors.textTertiary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Matching Trails',
                    style: AppTextStyles.h3.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search query or selecting a different difficulty level.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _resetFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightColors.forestPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reset Filters'),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final trek = filtered[index];
              return _TrekCard(
                trek: trek,
                onTap: () => context.push('/treks/${trek.id}'),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Claymorphic Trek Card
// ──────────────────────────────────────────────
class _TrekCard extends StatelessWidget {
  final TrekSummary trek;
  final VoidCallback onTap;

  const _TrekCard({required this.trek, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final difficultyColor = switch (trek.difficulty) {
      'Easy' => LightColors.successGreen,
      'Moderate' => LightColors.peakAmber,
      _ => LightColors.sosRed,
    };

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: ClayContainer(
          depth: 6,
          spread: 3,
          borderRadius: 24,
          color: Colors.white,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Cover Image Banner with Overlays
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Image.asset(
                        trek.coverImageAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay for visual depth and contrast protection
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                    // Glassmorphic/Claymorphic Rating Badge
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: LightColors.peakAmber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trek.rating.toStringAsFixed(1),
                              style: AppTextStyles.caption.copyWith(
                                color: LightColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Glassmorphic/Claymorphic Difficulty Badge
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          trek.difficulty.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details section with generous spacing and strong scannability
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      trek.name,
                      style: AppTextStyles.h2.copyWith(
                        color: LightColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Region Sub-header
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: LightColors.forestPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trek.region} Region',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: LightColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Short Description
                    Text(
                      trek.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Divider
                    Container(
                      height: 1.5,
                      color: LightColors.dividerLight.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    // Row of stats & clean view detail arrow
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _CardMetric(
                                icon: Icons.calendar_today_rounded,
                                value: '${trek.durationDays} days',
                                label: 'Duration',
                              ),
                              _CardMetric(
                                icon: Icons.route_rounded,
                                value: '${trek.distanceKm} km',
                                label: 'Distance',
                              ),
                              _CardMetric(
                                icon: Icons.terrain_rounded,
                                value: '${trek.maxAltitudeM} m',
                                label: 'Altitude',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: LightColors.primaryLight,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: LightColors.forestPrimary.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: LightColors.forestPrimary,
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
}

// ──────────────────────────────────────────────
// Card Metric Column Widget
// ──────────────────────────────────────────────
class _CardMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _CardMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: LightColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 13, color: LightColors.forestPrimary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Loading Shimmer State
// ──────────────────────────────────────────────
class _TreksLoadingShimmer extends StatelessWidget {
  const _TreksLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Treks',
            style: AppTextStyles.h1.copyWith(
              color: LightColors.textPrimary,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading curated routes...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ClayContainer(
                depth: 3,
                spread: 1.5,
                borderRadius: 22,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 18,
                      decoration: BoxDecoration(
                        color: LightColors.dividerLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: LightColors.dividerLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 14,
                      decoration: BoxDecoration(
                        color: LightColors.dividerLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Error View with Retry
// ──────────────────────────────────────────────
class _TreksErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _TreksErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: LightColors.sosRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load treks',
              style: AppTextStyles.h3.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: LightColors.forestPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
