import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_typography.dart';

/// Full-bleed, image-forward hero — the signature surface of the redesign.
///
/// A trek/destination photo fills the card, a dark vertical scrim guarantees
/// text contrast, and editorial type sits at the bottom-left. Optional
/// `topTrailing` slot holds a glass status chip or actions.
class EditorialHero extends StatelessWidget {
  final String imageAsset;
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final Widget? topTrailing;
  final Widget? bottomExtra;
  final VoidCallback? onTap;

  const EditorialHero({
    super.key,
    required this.imageAsset,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.height = 260,
    this.borderRadius = AppRadii.hero,
    this.margin = EdgeInsets.zero,
    this.topTrailing,
    this.bottomExtra,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Padding(
      padding: margin,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo
                Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: const Color(0xFF1B3A2D),
                  ),
                ),
                // Scrim — stronger at the bottom for text legibility
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.45, 1.0],
                      colors: [
                        Color(0x33000000),
                        Color(0x00000000),
                        Color(0xD9000000),
                      ],
                    ),
                  ),
                ),
                if (topTrailing != null)
                  Positioned(top: 16, right: 16, child: topTrailing!),
                // Editorial text block
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null) ...[
                        Text(
                          eyebrow!.toUpperCase(),
                          style: AppType.eyebrow.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        title,
                        style: AppType.display.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: AppType.bodySm.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (bottomExtra != null) ...[
                        const SizedBox(height: 14),
                        bottomExtra!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
