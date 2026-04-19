import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import '../viewmodels/trekking_providers.dart';
import '../widgets/route_preview.dart';

/// Trek detail view (modal from list)
///
/// Shows: Full description, route preview (RoutePreview widget),
/// location intel, permits, safety info
/// Actions: "Create Itinerary" (primary - green), "Download Offline" (secondary)
///
/// Scrollable modal with sticky header
class TrekDetailsScreen extends ConsumerWidget {
  final String trekId;

  const TrekDetailsScreen({
    required this.trekId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trekState = ref.watch(trekDetailsProvider(trekId));

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: trekState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: LightColors.forestPrimary,
          ),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err'),
        ),
        data: (trek) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with close button
              SliverAppBar(
                backgroundColor: Colors.white,
                foregroundColor: LightColors.textPrimary,
                elevation: 0.5,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: LightColors.forestPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: LightColors.forestPrimary,
                      size: 20,
                    ),
                  ),
                ),
                centerTitle: true,
                title: Text(
                  trek.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Description
                    Text(
                      'About',
                      style: AppTextStyles.h3.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trek.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textSecondary,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Route preview
                    Text(
                      'Elevation Profile',
                      style: AppTextStyles.h3.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoutePreview(trek: trek, height: 220),

                    const SizedBox(height: 24),

                    // Key Info Grid
                    Text(
                      'Trek Details',
                      style: AppTextStyles.h3.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _InfoBox(
                          icon: Icons.calendar_month_rounded,
                          label: 'Duration',
                          value: '${trek.estimatedDays} days',
                          color: LightColors.altitudeBlue,
                        ),
                        _InfoBox(
                          icon: Icons.trending_up_rounded,
                          label: 'Max Altitude',
                          value: '${trek.maxAltitude.toStringAsFixed(0)}m',
                          color: Colors.orange,
                        ),
                        _InfoBox(
                          icon: Icons.people_rounded,
                          label: 'Difficulty',
                          value: trek.difficultyRating,
                          color: LightColors.forestPrimary,
                        ),
                        _InfoBox(
                          icon: Icons.wb_sunny_rounded,
                          label: 'Best Season',
                          value: trek.bestSeason,
                          color: Colors.amber,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Permits
                    Text(
                      'Permits Required',
                      style: AppTextStyles.h3.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (trek.permitsRequired != null && trek.permitsRequired!.isNotEmpty)
                      ...trek.permitsRequired!.split(',').map((permit) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            permit,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: LightColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 24),

                    // Safety alerts
                    if (trek.maxAltitude > 4000)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: LightColors.sosRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: LightColors.sosRed.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: LightColors.sosRed,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'High altitude sections - acclimatization critical',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: LightColors.sosRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          // TODO: Navigate to create itinerary
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Create itinerary'),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Create Itinerary',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Download offline
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Downloading offline...'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: LightColors.forestPrimary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.download_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Download Offline',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: LightColors.forestPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Info box for trek details grid
class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: LightColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
