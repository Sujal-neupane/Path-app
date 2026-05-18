import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/data/trek_seed_data.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

class TreksScreen extends StatelessWidget {
  const TreksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: CustomScrollView(
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
              itemCount: trekSeedData.length,
              itemBuilder: (context, index) {
                final trek = trekSeedData[index];
                return _TrekCard(
                  trek: trek,
                  onTap: () => context.push('/treks/${trek.id}'),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

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
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
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
                _Pill(icon: Icons.route_rounded, text: '${trek.distanceKm} km'),
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
    );
  }
}

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
