import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/components/index.dart';
import 'package:path_app/features/trekking/presentation/viewmodels/itinerary_providers.dart';
import '../widgets/animated_stat_counter.dart';
import '../widgets/dashboard_hero.dart';
import '../widgets/achievements_grid.dart';
import '../widgets/motivational_card.dart';
import '../widgets/stats_overview_section.dart';
import '../widgets/quick_action_cards.dart';

/// Premium Dashboard - Clean, Minimal, User-Centric
/// UX Laws: Hick's, Fitts's, Jakob's, Miller's, Zeigarnik, Peak-End
/// Design: White background, app colors only, no gradients
class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onExploreTreks;
  final VoidCallback? onViewProfile;

  const DashboardScreen({
    super.key,
    this.onExploreTreks,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItinerary = ref.watch(activeItineraryProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: activeItinerary.when(
        loading: () => const _LoadingState(),
        error: (error, _) => _ErrorState(error: error.toString()),
        data: (itinerary) {
          if (itinerary == null) {
            return _DiscoveryDashboard(onExploreTreks: onExploreTreks);
          }
          return _ActiveTrekDashboard(
            itinerary: itinerary,
            onViewProfile: onViewProfile,
          );
        },
      ),
    );
  }
}

// ============================================================================
// DISCOVERY STATE - No active trek
// ============================================================================

class _DiscoveryDashboard extends StatelessWidget {
  final VoidCallback? onExploreTreks;

  const _DiscoveryDashboard({this.onExploreTreks});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: DashboardHero(
              greeting: 'Ready to Trek?',
              subtitle: 'Start your adventure and explore the world one step at a time.',
              actionButton: _PrimaryButton(
                label: 'Explore Treks',
                onTap: onExploreTreks,
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

        // Quick actions grid (Hick's Law: 4 main actions only)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: QuickActionsGrid(
              onExploreTreks: onExploreTreks ?? () {},
              onViewSaved: () {},
              onCreateItinerary: () {},
              onViewProfile: () {},
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Why trek section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why Trek?',
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: Spacing.lg),
                _ValuePropCard(
                  icon: Icons.landscape_rounded,
                  title: 'Discover Nature',
                  description: 'Experience breathtaking landscapes and untouched wilderness',
                  color: LightColors.forestPrimary,
                ),
                SizedBox(height: Spacing.lg),
                _ValuePropCard(
                  icon: Icons.favorite_rounded,
                  title: 'Wellness',
                  description: 'Improve fitness and mental health through adventure',
                  color: LightColors.altitudeBlue,
                ),
                SizedBox(height: Spacing.lg),
                _ValuePropCard(
                  icon: Icons.people_rounded,
                  title: 'Community',
                  description: 'Connect with fellow trekkers and share experiences',
                  color: LightColors.peakAmber,
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),
      ],
    );
  }
}

// ============================================================================
// ACTIVE TREK STATE
// ============================================================================

class _ActiveTrekDashboard extends StatelessWidget {
  final dynamic itinerary;
  final VoidCallback? onViewProfile;

  const _ActiveTrekDashboard({
    required this.itinerary,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Active trek hero (Zeigarnik Effect: highlight active progress)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: _ActiveTrekCard(itinerary: itinerary),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

        // Progress section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: Spacing.lg),
                _ProgressBar(
                  daysCompleted: 3,
                  totalDays: itinerary.totalDays ?? 12,
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Quick stats (Miller's Law: 3 items)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: StatsOverviewSection(
              totalTreks: 1,
              totalElevationM: itinerary.totalElevationGainM ?? 0,
              totalDays: itinerary.totalDays ?? 0,
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Next checkpoint
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: _NextCheckpointCard(),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),

        // Motivational message (Peak-End rule: end with motivation)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: MotivationalCard.forEvening(),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),
      ],
    );
  }
}

// ============================================================================
// SUB-COMPONENTS
// ============================================================================

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: Spacing.lg),
        decoration: BoxDecoration(
          color: LightColors.forestPrimary,
          borderRadius: BorderRadius.circular(Radius.md),
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

class _ValuePropCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _ValuePropCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

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
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
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

class _ActiveTrekCard extends StatelessWidget {
  final dynamic itinerary;

  const _ActiveTrekCard({required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: LightColors.forestPrimary,
        borderRadius: BorderRadius.circular(Radius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Trek',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: Spacing.sm),
          Text(
            itinerary.name ?? 'Your Trek',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Spacing.md),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
              SizedBox(width: Spacing.xs),
              Text(
                'Days: ${itinerary.totalDays ?? 0}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int daysCompleted;
  final int totalDays;

  const _ProgressBar({
    required this.daysCompleted,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final progress = daysCompleted / totalDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Day $daysCompleted of $totalDays',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.forestPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radius.sm),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: LightColors.dividerLight,
            valueColor: AlwaysStoppedAnimation(LightColors.forestPrimary),
          ),
        ),
      ],
    );
  }
}

class _NextCheckpointCard extends StatelessWidget {
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
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Checkpoint',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColors.textPrimary,
            ),
          ),
          SizedBox(height: Spacing.lg),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LightColors.altitudeBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Radius.md),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: LightColors.altitudeBlue,
                  size: 22,
                ),
              ),
              SizedBox(width: Spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Namche Bazaar',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LightColors.textPrimary,
                      ),
                    ),
                    Text(
                      '12 km away • 3,440 m altitude',
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOADING & ERROR STATES
// ============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(LightColors.forestPrimary),
          ),
          SizedBox(height: Spacing.lg),
          Text(
            'Loading your adventure...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
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
          Text(
            'Something went wrong',
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
    );
  }
}
