import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

/// Horizontal scrolling featured trek cards.
/// Designed as a discovery surface following Aesthetic-Usability effect.
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

  @override
  Widget build(BuildContext context) {
    if (treks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Featured Treks',
                  style: AppTextStyles.h2.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Row(
                    children: [
                      Text(
                        'See all',
                        style: AppTextStyles.caption.copyWith(
                          color: LightColors.forestPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: LightColors.forestPrimary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal scroll
        SizedBox(
          height: 166,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: treks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _FeaturedTrekCard(
                trek: treks[index],
                onTap: () => onTrekTap(treks[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedTrekCard extends StatelessWidget {
  final TrekSummary trek;
  final VoidCallback onTap;

  const _FeaturedTrekCard({required this.trek, required this.onTap});

  Color get _difficultyColor => switch (trek.difficulty) {
    'Easy' => LightColors.successGreen,
    'Moderate' => LightColors.peakAmber,
    _ => LightColors.sosRed,
  };

  LinearGradient get _cardGradient => switch (trek.difficulty) {
    'Easy' => const LinearGradient(
      colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Moderate' => const LinearGradient(
      colors: [Color(0xFF3A2D1B), Color(0xFF6A4F2D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    _ => const LinearGradient(
      colors: [Color(0xFF3A1B1B), Color(0xFF6A2D2D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Difficulty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trek.difficulty,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Trek name
                Text(
                  trek.name,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Bottom info row
                Row(
                  children: [
                    _MiniStat(
                      icon: Icons.schedule_rounded,
                      text: '${trek.durationDays}d',
                    ),
                    const SizedBox(width: 12),
                    _MiniStat(
                      icon: Icons.terrain_rounded,
                      text: '${trek.maxAltitudeM}m',
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: LightColors.peakAmber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trek.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniStat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
