import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import '../../domain/entities/trek.dart';

/// Reusable trek card widget for lists
///
/// Displays: Trek image, name, stats (distance/days/difficulty), offline indicator
/// Compact design, responsive width
/// Tap-friendly (Fitts's Law: 48dp minimum touch target)
///
/// Usage:
/// ```dart
/// TrekCard(
///   trek: trek,
///   onTap: () => Navigator.push(...),
///   isOffline: true,
/// )
/// ```
class TrekCard extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;
  final bool isOffline;
  final double? imageHeight;

  const TrekCard({
    required this.trek,
    required this.onTap,
    this.isOffline = false,
    this.imageHeight = 160,
    super.key,
  });

  /// Difficulty color coding (Von Restorff: high contrast)
  Color get difficultyColor {
    switch (trek.difficultyRating.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50); // Green
      case 'moderate':
        return LightColors.peakAmber; // Amber
      case 'expert':
      case 'challenging':
        return LightColors.sosRed; // Red
      default:
        return LightColors.forestPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = trek.routeDataPath;
    final hasNetworkImage = imageUrl != null && imageUrl.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: LightColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder with gradient overlay
              Stack(
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: hasNetworkImage
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: LightColors.forestPrimary.withValues(alpha: 0.1),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: LightColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: LightColors.forestPrimary.withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: LightColors.textSecondary,
                              ),
                            ),
                          ),
                  ),

                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Difficulty badge (top-right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trek.difficultyRating.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  // Offline indicator (bottom-left)
                  if (isOffline)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_done_rounded,
                              size: 14,
                              color: LightColors.forestPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Offline',
                              style: AppTextStyles.caption.copyWith(
                                color: LightColors.forestPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trek name
                    Text(
                      trek.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Stats row: distance / days / elevation
                    Row(
                      children: [
                        _StatItem(
                          icon: Icons.route_rounded,
                          label: '${trek.totalDistance.toStringAsFixed(1)}km',
                          color: LightColors.forestPrimary,
                        ),
                        const SizedBox(width: 12),
                        _StatItem(
                          icon: Icons.calendar_month_rounded,
                          label: '${trek.estimatedDays}d',
                          color: LightColors.altitudeBlue,
                        ),
                        const SizedBox(width: 12),
                        _StatItem(
                          icon: Icons.trending_up_rounded,
                          label: '${trek.totalElevationGain.toStringAsFixed(0)}m↑',
                          color: Colors.brown,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Location (best season)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: LightColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Best: ${trek.bestSeason}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: LightColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Explore button (Fitts's Law: 48dp min)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Explore'),
                    style: FilledButton.styleFrom(
                      backgroundColor: LightColors.forestPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small stat item: icon + label
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
