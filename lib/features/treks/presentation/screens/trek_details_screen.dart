import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/data/trek_seed_data.dart';

class TrekDetailsScreen extends StatelessWidget {
  final String trekId;

  const TrekDetailsScreen({super.key, required this.trekId});

  @override
  Widget build(BuildContext context) {
    final trek = findTrekById(trekId);
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
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: LightColors.summitDark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                trek.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B3A2D), Color(0xFF2D6A4F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -40,
                    top: -30,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 58,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${trek.region} • ${trek.bestSeason}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatTile(
                        label: 'Duration',
                        value: '${trek.durationDays} days',
                        icon: Icons.calendar_month_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatTile(
                        label: 'Distance',
                        value: '${trek.distanceKm} km',
                        icon: Icons.route_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatTile(
                        label: 'Elevation',
                        value: '${trek.elevationGainM} m',
                        icon: Icons.trending_up_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatTile(
                        label: 'Max Altitude',
                        value: '${trek.maxAltitudeM} m',
                        icon: Icons.terrain_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Overview',
                    style: AppTextStyles.h3.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trek.longDescription,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Highlights',
                    style: AppTextStyles.h3.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...trek.highlights.map(
                    (highlight) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: LightColors.successGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              highlight,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: LightColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Suggested Itinerary',
                    style: AppTextStyles.h3.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...trek.itinerary.map(
                    (dayPlan) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: LightColors.dividerLight),
                      ),
                      child: Text(
                        dayPlan,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: LightColors.forestPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.travel_explore_rounded),
                      label: const Text('Start Planning This Trek'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LightColors.dividerLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: LightColors.forestPrimary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
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
