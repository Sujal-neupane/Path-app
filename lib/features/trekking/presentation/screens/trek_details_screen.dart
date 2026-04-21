import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/components/index.dart';
import 'package:path_app/features/trekking/presentation/viewmodels/trekking_providers.dart';

/// Premium Trek Details Screen - Comprehensive information display
/// UX Laws: Progressive Disclosure (info appears as scroll), Miller's Law (group related info)
class TrekDetailsScreen extends ConsumerWidget {
  final String trekId;
  final VoidCallback? onCreateItinerary;

  const TrekDetailsScreen({
    super.key,
    required this.trekId,
    this.onCreateItinerary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trekDetails = ref.watch(trekDetailsProvider(trekId));

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: trekDetails.when(
        loading: () => const _LoadingState(),
        error: (error, _) => _ErrorState(error: error.toString()),
        data: (trek) => _TrekDetailsContent(
          trek: trek,
          onCreateItinerary: onCreateItinerary,
        ),
      ),
    );
  }
}

class _TrekDetailsContent extends StatelessWidget {
  final dynamic trek;
  final VoidCallback? onCreateItinerary;

  const _TrekDetailsContent({
    required this.trek,
    this.onCreateItinerary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero section with back button
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: LightColors.forestPrimary,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Radius.sm),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: LightColors.forestPrimary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(Spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trek.name ?? 'Trek',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Spacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            SizedBox(width: Spacing.xs),
                            Text(
                              trek.location ?? 'Unknown',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
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
        ),

        // Quick stats section (Miller's Law: 3 key metrics)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailStat(
                    icon: Icons.straighten_rounded,
                    label: 'Distance',
                    value: '${trek.totalDistance ?? 0} km',
                    color: LightColors.forestPrimary,
                  ),
                  _DetailStat(
                    icon: Icons.trending_up_rounded,
                    label: 'Elevation',
                    value: '${trek.totalElevationGain ?? 0}m',
                    color: LightColors.altitudeBlue,
                  ),
                  _DetailStat(
                    icon: Icons.calendar_today_rounded,
                    label: 'Days',
                    value: '${trek.estimatedDays ?? 0}',
                    color: LightColors.peakAmber,
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

        // Description section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About This Trek',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: Spacing.md),
                Text(
                  trek.description ??
                      'This is a premium trekking experience designed for adventure seekers.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Difficulty breakdown
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: _DifficultyBreakdown(trek: trek),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Best season section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: _BestSeasonCard(bestSeason: trek.bestSeason),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Permits section
        if (trek.permitsRequired ?? false)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: _PermitsCard(),
            ),
          ),

        if (trek.permitsRequired ?? false)
          SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Amenities grid
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: _AmenitiesSection(),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Rating section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: _RatingSection(
              rating: trek.averageRating ?? 0,
              completionCount: trek.completionCount ?? 0,
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // CTA buttons (sticky-like positioning with sliver)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PrimaryButton(
                  label: 'Create Itinerary',
                  onTap: onCreateItinerary,
                  color: LightColors.forestPrimary,
                ),
                SizedBox(height: Spacing.md),
                _SecondaryButton(
                  label: 'Save Trek',
                  icon: Icons.bookmark_outline_rounded,
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),
      ],
    );
  }
}

// ============================================================================
// COMPONENTS
// ============================================================================

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: Spacing.sm),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: LightColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: LightColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DifficultyBreakdown extends StatelessWidget {
  final dynamic trek;

  const _DifficultyBreakdown({required this.trek});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Breakdown',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w600,
            color: LightColors.textPrimary,
          ),
        ),
        SizedBox(height: Spacing.lg),
        _DifficultyBar(
          label: 'Physical',
          percentage: 0.7,
          color: LightColors.altitudeBlue,
        ),
        SizedBox(height: Spacing.lg),
        _DifficultyBar(
          label: 'Altitude',
          percentage: 0.85,
          color: LightColors.sosRed,
        ),
        SizedBox(height: Spacing.lg),
        _DifficultyBar(
          label: 'Technical',
          percentage: 0.4,
          color: LightColors.peakAmber,
        ),
      ],
    );
  }
}

class _DifficultyBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const _DifficultyBar({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radius.sm),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: LightColors.dividerLight,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _BestSeasonCard extends StatelessWidget {
  final String? bestSeason;

  const _BestSeasonCard({this.bestSeason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: LightColors.surfaceWhite,
        border: Border.all(
          color: LightColors.dividerLight,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(Radius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best Season',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Spacing.md),
          Text(
            bestSeason ?? 'Spring & Autumn',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColors.forestPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermitsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: LightColors.redLight,
        border: Border.all(
          color: LightColors.sosRed.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(Radius.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.document_scanner_rounded,
            color: LightColors.sosRed,
            size: 24,
          ),
          SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permits Required',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColors.sosRed,
                  ),
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  'Check requirements before booking',
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Amenities',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: Spacing.lg,
          mainAxisSpacing: Spacing.lg,
          childAspectRatio: 0.85,
          children: [
            _AmenityCard(
              icon: Icons.home_rounded,
              label: 'Teahouses',
            ),
            _AmenityCard(
              icon: Icons.water_rounded,
              label: 'Water Source',
            ),
            _AmenityCard(
              icon: Icons.restaurant_rounded,
              label: 'Food Available',
            ),
            _AmenityCard(
              icon: Icons.medical_services_rounded,
              label: 'Medical Help',
            ),
          ],
        ),
      ],
    );
  }
}

class _AmenityCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityCard({
    required this.icon,
    required this.label,
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
        borderRadius: BorderRadius.circular(Radius.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: LightColors.forestPrimary,
            size: 32,
          ),
          SizedBox(height: Spacing.md),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final double rating;
  final int completionCount;

  const _RatingSection({
    required this.rating,
    required this.completionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ratings & Reviews',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.lg),
        Container(
          padding: EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: LightColors.surfaceWhite,
            border: Border.all(
              color: LightColors.dividerLight,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(Radius.lg),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyles.h1.copyWith(
                      color: LightColors.peakAmber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Spacing.xs),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating.toInt()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: LightColors.peakAmber,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: Spacing.xxxl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completionCount explorers',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LightColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Spacing.xs),
                    Text(
                      'have completed this trek',
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
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _PrimaryButton({
    required this.label,
    this.onTap,
    this.color = LightColors.forestPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Spacing.lg),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Radius.md),
          boxShadow: AppShadows.medium,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _SecondaryButton({
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.lg),
      decoration: BoxDecoration(
        color: LightColors.surfaceWhite,
        border: Border.all(
          color: LightColors.forestPrimary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(Radius.md),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: LightColors.forestPrimary, size: 20),
              SizedBox(width: Spacing.sm),
            ],
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: LightColors.forestPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(LightColors.forestPrimary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: LightColors.sosRed,
          ),
          SizedBox(height: Spacing.lg),
          Text('Failed to load trek details'),
        ],
      ),
    );
  }
}
