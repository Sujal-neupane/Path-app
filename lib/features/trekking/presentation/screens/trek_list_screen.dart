import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/components/index.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/trekking/presentation/viewmodels/trekking_providers.dart';

/// Premium Trek List Screen - Clean discovery experience
/// UX Laws: Hick's (limited filters), Miller's (group by difficulty), Jakob's (familiar patterns)
class TrekListScreen extends ConsumerStatefulWidget {
  final VoidCallback? onTrekSelected;

  const TrekListScreen({
    super.key,
    this.onTrekSelected,
  });

  @override
  ConsumerState<TrekListScreen> createState() => _TrekListScreenState();
}

class _TrekListScreenState extends ConsumerState<TrekListScreen> {
  final _searchController = TextEditingController();
  String _selectedDifficulty = 'all'; // all, easy, moderate, hard

  @override
  void initState() {
    super.initState();
    // Fetch treks on mount
    Future.microtask(() {
      ref.read(trekListProvider.notifier).fetchTreks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trekListState = ref.watch(trekListProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            backgroundColor: LightColors.surfaceWhite,
            elevation: 0,
            title: Text(
              'Explore Treks',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColors.textPrimary,
              ),
            ),
          ),

          // Search bar (Fitts's Law: large touch targets)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Spacing.lg),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),

          // Difficulty filter (Hick's Law: 4 choices only)
          SliverToBoxAdapter(
            child: _DifficultyFilter(
              selectedDifficulty: _selectedDifficulty,
              onChanged: (difficulty) {
                setState(() => _selectedDifficulty = difficulty);
              },
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: Spacing.md)),

          // Trek list content
          if (trekListState.isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.xxxl),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(LightColors.forestPrimary),
                  ),
                ),
              ),
            )
          else if (trekListState.error != null)
            SliverToBoxAdapter(
              child: _ErrorWidget(error: trekListState.error ?? 'Unknown error'),
            )
          else if (trekListState.treks.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Spacing.lg),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hiking_rounded,
                        size: 64,
                        color: LightColors.textSecondary.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: Spacing.lg),
                      Text(
                        'No Treks Found',
                        style: AppTextStyles.h3.copyWith(
                          color: LightColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: Spacing.md),
                      Text(
                        'Try adjusting your filters',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final trek = trekListState.treks[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: Spacing.lg),
                      child: _TrekListCard(
                        trek: trek,
                        onTap: () {
                          // Navigate to trek details
                          context.push('/trek-details/${trek.id}');
                        },
                      ),
                    );
                  },
                  childCount: trekListState.treks.length,
                ),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPONENTS
// ============================================================================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _SearchBar({
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColors.surfaceWhite,
        border: Border.all(
          color: LightColors.dividerLight,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(Radius.md),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium.copyWith(
          color: LightColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search treks...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: LightColors.textSecondary,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: LightColors.textSecondary,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: LightColors.textSecondary,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.md,
          ),
        ),
      ),
    );
  }
}

class _DifficultyFilter extends StatelessWidget {
  final String selectedDifficulty;
  final ValueChanged<String>? onChanged;

  const _DifficultyFilter({
    required this.selectedDifficulty,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const difficulties = ['all', 'easy', 'moderate', 'hard'];
    const labels = ['All', 'Easy', 'Moderate', 'Hard'];
    final colors = [
      LightColors.textPrimary,
      LightColors.difficultyEasy,
      LightColors.difficultyModerate,
      LightColors.difficultyHard,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        children: List.generate(
          difficulties.length,
          (index) {
            final isSelected = selectedDifficulty == difficulties[index];
            return Padding(
              padding: EdgeInsets.only(right: Spacing.md),
              child: GestureDetector(
                onTap: () => onChanged?.call(difficulties[index]),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors[index].withValues(alpha: 0.1)
                        : LightColors.surfaceWhite,
                    border: Border.all(
                      color: isSelected
                          ? colors[index]
                          : LightColors.dividerLight,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(Radius.md),
                  ),
                  child: Text(
                    labels[index],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? colors[index]
                          : LightColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrekListCard extends StatelessWidget {
  final dynamic trek;
  final VoidCallback? onTap;

  const _TrekListCard({
    required this.trek,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: LightColors.surfaceWhite,
          border: Border.all(
            color: LightColors.dividerLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(Radius.lg),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Difficulty badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trek.name ?? 'Unknown Trek',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: Spacing.md),
                _DifficultyBadge(
                  difficulty: trek.difficultyRating ?? 'moderate',
                ),
              ],
            ),

            SizedBox(height: Spacing.md),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: LightColors.textSecondary,
                ),
                SizedBox(width: Spacing.xs),
                Text(
                  trek.location ?? 'Unknown',
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: Spacing.lg),

            // Stats row (Miller's Law: 3 key stats)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TrekStat(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: '${trek.totalDistance ?? 0} km',
                ),
                _TrekStat(
                  icon: Icons.trending_up_rounded,
                  label: 'Elevation',
                  value: '${trek.totalElevationGain ?? 0}m',
                ),
                _TrekStat(
                  icon: Icons.calendar_today_rounded,
                  label: 'Duration',
                  value: '${trek.estimatedDays ?? 0} days',
                ),
              ],
            ),

            SizedBox(height: Spacing.lg),

            // Rating + explorers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: LightColors.peakAmber,
                    ),
                    SizedBox(width: Spacing.xs),
                    Text(
                      '${trek.averageRating ?? 0}/5',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: LightColors.forestPrimary,
                      borderRadius: BorderRadius.circular(Radius.sm),
                    ),
                    child: Text(
                      'Explore',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (difficulty.toLowerCase()) {
      'easy' => (LightColors.difficultyEasy, 'Easy'),
      'moderate' => (LightColors.difficultyModerate, 'Moderate'),
      'hard' || 'expert' => (LightColors.difficultyHard, 'Hard'),
      _ => (LightColors.textSecondary, 'Unknown'),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(Radius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _TrekStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TrekStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: LightColors.forestPrimary,
          ),
          SizedBox(height: Spacing.xs),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: LightColors.sosRed,
            ),
            SizedBox(height: Spacing.lg),
            Text(
              'Failed to load treks',
              style: AppTextStyles.h3.copyWith(
                color: LightColors.textPrimary,
              ),
            ),
            SizedBox(height: Spacing.sm),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
