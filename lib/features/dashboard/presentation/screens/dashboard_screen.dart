import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/trekking/presentation/viewmodels/itinerary_providers.dart';


/// World-class dashboard: Minimal, aesthetic, user-centric
class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onExploreTreks;

  const DashboardScreen({
    super.key,
    this.onExploreTreks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItinerary = ref.watch(activeItineraryProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: activeItinerary.when(
          loading: () => _DashboardLoadingState(),
          error: (error, _) => _DashboardErrorState(error: error.toString()),
          data: (itinerary) {
            if (itinerary == null) {
              return _NoPlanDashboard(onExploreTreks: onExploreTreks);
            }
            return _ActivePlanDashboard(itinerary: itinerary);
          },
        ),
      ),
    );
  }
}

/// No active plan: Clean discovery surface using Hick's Law & aesthetic composition
class _NoPlanDashboard extends StatelessWidget {
  final VoidCallback? onExploreTreks;

  const _NoPlanDashboard({this.onExploreTreks});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimal greeting
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to explore?',
                  style: AppTextStyles.h1.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick a trek. Any pace.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Why PATH section (3 minimal cards showing UX laws)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why PATH',
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                _WhyCard(
                  number: '1',
                  title: 'Curated',
                  description: 'Hand-picked treks for your level',
                ),
                const SizedBox(height: 10),
                _WhyCard(
                  number: '2',
                  title: 'Safe',
                  description: 'One-tap SOS, real-time alerts',
                ),
                const SizedBox(height: 10),
                _WhyCard(
                  number: '3',
                  title: 'Progress',
                  description: 'Track every step of your journey',
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // CTA (Fitts's Law: Large touch target)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: onExploreTreks ?? () {},
                style: FilledButton.styleFrom(
                  backgroundColor: LightColors.forestPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Discover Treks',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Active trek: Minimalist progress tracker (Goal Gradient + Von Restorff)
class _ActivePlanDashboard extends StatelessWidget {
  final dynamic itinerary;

  const _ActivePlanDashboard({required this.itinerary});

  @override
  Widget build(BuildContext context) {
    // Calculate current day from startDate
    final startDate = DateTime.tryParse(itinerary.startDate ?? '') ?? DateTime.now();
    final today = DateTime.now();
    final dayIndex = (today.difference(startDate).inDays + 1)
        .clamp(1, itinerary.totalDays ?? 1);
    final totalDays = itinerary.totalDays ?? 1;
    final progress = (dayIndex / totalDays).clamp(0.0, 1.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trek name + day counter (minimal header)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itinerary.trekName ?? 'Your Trek',
                  style: AppTextStyles.h2.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Day $dayIndex of $totalDays',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Progress bar (visual feedback)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(
                      LightColors.forestPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% complete',
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Today's route (simple info card)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itinerary.currentSegmentName ?? 'Rest day',
                        style: AppTextStyles.h3.copyWith(
                          color: LightColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        itinerary.currentSegmentLocation ?? 'No specific location',
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

          const SizedBox(height: 40),

          // Action buttons (Fitts's Law: large, accessible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CompactActionButton(
                  icon: Icons.map_rounded,
                  label: 'Route',
                  onTap: () {},
                ),
                _CompactActionButton(
                  icon: Icons.list_rounded,
                  label: 'Details',
                  onTap: () {},
                ),
                _CompactActionButton(
                  icon: Icons.call_rounded,
                  label: 'SOS',
                  isEmergency: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Why card: Numbered composition with clear hierarchy
class _WhyCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _WhyCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: LightColors.forestPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Text(
              number,
              style: AppTextStyles.h3.copyWith(
                color: LightColors.forestPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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

/// Compact action button (minimal design)
class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEmergency;
  final VoidCallback onTap;

  const _CompactActionButton({
    required this.icon,
    required this.label,
    this.isEmergency = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isEmergency
              ? LightColors.sosRed
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEmergency ? Colors.white : LightColors.textPrimary,
              size: 16,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isEmergency ? Colors.white : LightColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: LightColors.forestPrimary,
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String error;

  const _DashboardErrorState({required this.error});

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
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
