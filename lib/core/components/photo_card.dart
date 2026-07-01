import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_app/core/theme/app_typography.dart';

/// Image-led card used across discovery surfaces (treks, destinations).
/// Replaces the old flat gradient cards with real photography + scrim.
///
/// Provide [meta] chips (e.g. duration / altitude) and an optional [badge]
/// (e.g. difficulty) shown top-left.
class PhotoCard extends StatefulWidget {
  final String imageAsset;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final List<PhotoCardMeta> meta;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const PhotoCard({
    super.key,
    required this.imageAsset,
    required this.title,
    this.subtitle,
    this.badge,
    this.meta = const [],
    this.width = 260,
    this.height = 320,
    this.onTap,
  });

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.card);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      Container(color: const Color(0xFF1B3A2D)),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                      colors: [Color(0x00000000), Color(0xE0000000)],
                    ),
                  ),
                ),
                if (widget.badge != null)
                  Positioned(top: 14, left: 14, child: widget.badge!),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppType.title.copyWith(
                          color: Colors.white,
                          fontSize: 19,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle!,
                          style: AppType.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (widget.meta.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (var i = 0; i < widget.meta.length; i++) ...[
                              if (i > 0) const SizedBox(width: 14),
                              _MetaItem(meta: widget.meta[i]),
                            ],
                          ],
                        ),
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

class PhotoCardMeta {
  final IconData icon;
  final String label;
  final Color? iconColor;
  const PhotoCardMeta(this.icon, this.label, {this.iconColor});
}

class _MetaItem extends StatelessWidget {
  final PhotoCardMeta meta;
  const _MetaItem({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          meta.icon,
          size: 14,
          color: meta.iconColor ?? Colors.white.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 5),
        Text(
          meta.label,
          style: AppType.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
