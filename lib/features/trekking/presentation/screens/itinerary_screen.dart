import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import '../viewmodels/itinerary_providers.dart';
import '../widgets/itinerary_day_card.dart';

/// Editable custom itinerary screen (Itinerary tab)
///
/// Shows:
/// - Custom day-by-day plan for active trek
/// - Total metrics (days, distance, elevation, risk assessment)
/// - Editable day cards (currently editing preview only)
/// - "Start Trek" primary action (green - Fitts's Law)
///
/// Drag-to-reorder (Phase 4 feature)
/// Tap day to edit acclimatization/notes
class ItineraryScreen extends ConsumerWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItinerary = ref.watch(activeItineraryProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: activeItinerary.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: LightColors.forestPrimary,
          ),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err'),
        ),
        data: (activeItinerary) {
          if (activeItinerary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 48,
                    color: LightColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active itinerary',
                    style: AppTextStyles.h3.copyWith(
                      color: LightColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create a custom itinerary for a trek',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      // TODO: Navigate to TrekListScreen
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: LightColors.forestPrimary,
                    ),
                    child: const Text('Browse Treks'),
                  ),
                ],
              ),
            );
          }

          // Calculate summary stats
          final riskCount = activeItinerary.highAltitudeRiskDays.length;
          final acclimatizationDays = activeItinerary.acclimatizationDaysCount;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                backgroundColor: Colors.white,
                foregroundColor: LightColors.textPrimary,
                elevation: 0.5,
                title: Text(
                  'Your Itinerary',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Summary cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Main trek info card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              LightColors.forestPrimary,
                              LightColors.forestPrimary.withValues(
                                alpha: 0.85,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: LightColors.forestPrimary
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Custom Plan',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Editable',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              activeItinerary.name,
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _StatBadge(
                                  icon: Icons.calendar_today_rounded,
                                  label: '${activeItinerary.totalDays} days',
                                  isDark: true,
                                ),
                                const SizedBox(width: 10),
                                _StatBadge(
                                  icon: Icons.route_rounded,
                                  label:
                                      '${activeItinerary.totalDistanceKm.toStringAsFixed(0)}km',
                                  isDark: true,
                                ),
                                const SizedBox(width: 10),
                                _StatBadge(
                                  icon: Icons.trending_up_rounded,
                                  label:
                                      '${activeItinerary.totalElevationGainM}m',
                                  isDark: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Risk/Accl badges
                      Row(
                        children: [
                          if (acclimatizationDays > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$acclimatizationDays accl. days',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          if (riskCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: LightColors.sosRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      LightColors.sosRed.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.warning_rounded,
                                    size: 14,
                                    color: LightColors.sosRed,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$riskCount high-risk days',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: LightColors.sosRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Days list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final day = activeItinerary.days[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ItineraryDayCard(
                          day: day,
                          dayNumber: index + 1,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Editing Day ${day.dayNumber}'),
                              ),
                            );
                          },
                          onEdit: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Edit dialog for Day ${day.dayNumber}'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: activeItinerary.days.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Starting trek...')),
          );
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text(
          'Start Trek',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Small stat badge
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatBadge({
    required this.icon,
    required this.label,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : LightColors.forestPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? Colors.white : LightColors.forestPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LightColors.forestPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
