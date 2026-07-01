import 'package:flutter/material.dart';
import 'package:path_app/core/components/editorial_atoms.dart';
import 'package:path_app/core/components/photo_card.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

/// Image-led featured trek carousel (Editorial Alpine).
/// Real photography + scrim instead of flat gradient cards.
class FeaturedTrekCarousel extends StatelessWidget {
  final List<TrekSummary> treks;
  final ValueChanged<TrekSummary> onTrekTap;
  final VoidCallback? onSeeAll;

  const FeaturedTrekCarousel({
    super.key,
    required this.treks,
    required this.onTrekTap,
    this.onSeeAll,
  });

  static Color _difficultyColor(String difficulty) => switch (difficulty) {
    'Easy' => LightColors.successGreen,
    'Moderate' => LightColors.peakAmber,
    'Challenging' => LightColors.sosRed,
    _ => LightColors.difficultyExpert,
  };

  @override
  Widget build(BuildContext context) {
    if (treks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: EditorialSectionHeader(
            eyebrow: 'Curated for you',
            title: 'Featured treks',
            actionLabel: onSeeAll != null ? 'See all' : null,
            onAction: onSeeAll,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: treks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final trek = treks[index];
              return PhotoCard(
                imageAsset: trek.coverImageAsset,
                title: trek.name,
                subtitle: trek.region,
                width: 240,
                height: 300,
                onTap: () => onTrekTap(trek),
                badge: GlassChip(
                  label: trek.difficulty,
                  dotColor: _difficultyColor(trek.difficulty),
                ),
                meta: [
                  PhotoCardMeta(Icons.schedule_rounded, '${trek.durationDays}d'),
                  PhotoCardMeta(
                    Icons.terrain_rounded,
                    '${trek.maxAltitudeM}m',
                  ),
                  PhotoCardMeta(
                    Icons.star_rounded,
                    trek.rating.toStringAsFixed(1),
                    iconColor: LightColors.peakAmber,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
