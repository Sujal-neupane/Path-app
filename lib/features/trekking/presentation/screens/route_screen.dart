import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/trekking/presentation/viewmodels/itinerary_providers.dart';


/// Active trek route/navigation screen (Route tab)
///
/// Shows:
/// - Map with active trek (OCM - OpenCycleMap placeholder)
/// - Current location dot
/// - Trail overlay with waypoints
/// - Next 3 waypoints in bottom sheet
/// - Large red SOS button (Fitts's Law)
///
/// Minimal UI - focus on map and safety
class RouteScreen extends ConsumerWidget {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItinerary = ref.watch(activeItineraryProvider);

    return Scaffold(
      body: activeItinerary.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: LightColors.forestPrimary,
          ),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: LightColors.sosRed,
              ),
              const SizedBox(height: 12),
              Text(
                'No active trek',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        data: (activeItinerary) {
          if (activeItinerary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: 48,
                    color: LightColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active trek',
                    style: AppTextStyles.h3.copyWith(
                      color: LightColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a trek to start navigating',
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

          return Stack(
            children: [
              // Map placeholder (Phase 4: integrate OCM)
              Container(
                color: LightColors.forestPrimary.withValues(alpha: 0.05),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_rounded,
                        size: 64,
                        color: LightColors.forestPrimary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Map view coming soon',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Safe area header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Active',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeItinerary.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: LightColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Day ${activeItinerary.days.length} of ${activeItinerary.totalDays}',
                              style: AppTextStyles.caption.copyWith(
                                color: LightColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: LightColors.forestPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom sheet: next waypoints
              DraggableScrollableSheet(
                initialChildSize: 0.25,
                minChildSize: 0.1,
                maxChildSize: 0.6,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // Drag handle
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Waypoints',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: LightColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...activeItinerary.days.take(3).map((day) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: LightColors.forestPrimary
                                          .withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: LightColors.forestPrimary
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.place_rounded,
                                          size: 16,
                                          color: LightColors.forestPrimary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                day.endLocation,
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '${day.distanceKm}km • +${day.elevationGainM}m',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  fontSize: 10,
                                                  color:
                                                      LightColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // SOS Button (Fitts's Law: large, red, accessible)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: SizedBox(
                  height: 56,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Emergency SOS'),
                          content: const Text(
                            'Send location and alert to emergency contacts?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Emergency alert sent (demo)'),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: LightColors.sosRed,
                              ),
                              child: const Text('Send SOS'),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: LightColors.sosRed,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    label: const Text(
                      'SOS Emergency',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    icon: const Icon(Icons.emergency_rounded),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
