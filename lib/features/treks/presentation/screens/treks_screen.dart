import 'package:flutter/material.dart';
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
class _TreksListView extends StatelessWidget {
  final List<TrekSummary> treks;

  const _TreksListView({required this.treks});

  @override
  Widget build(BuildContext context) {
    if (treks.isEmpty) {
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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
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
                  'Handpicked routes for your next mountain story.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: treks.length,
          itemBuilder: (context, index) {
            final trek = treks[index];
            return _TrekCard(
              trek: trek,
              onTap: () => context.push('/treks/${trek.id}'),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: ClayContainer(
          depth: 5,
          spread: 2.5,
          borderRadius: 22,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trek.name,
                      style: AppTextStyles.h3.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      trek.difficulty,
                      style: AppTextStyles.caption.copyWith(
                        color: difficultyColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                trek.shortDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(icon: Icons.landscape_rounded, text: trek.region),
                  _Pill(
                    icon: Icons.calendar_today_rounded,
                    text: '${trek.durationDays} days',
                  ),
                  _Pill(
                    icon: Icons.route_rounded,
                    text: '${trek.distanceKm} km',
                  ),
                  _Pill(
                    icon: Icons.terrain_rounded,
                    text: '${trek.maxAltitudeM} m',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: LightColors.peakAmber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trek.rating.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View details',
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.forestPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: LightColors.forestPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Pill Badge Widget
// ──────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LightColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: LightColors.forestPrimary),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.forestPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
