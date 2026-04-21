import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Beautiful skeleton loading component with shimmer effect
/// Used to show loading states instead of spinners
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final bool isCircular;
  final Duration animationDuration;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.isCircular = false,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseCol = widget.baseColor ?? LightColors.forestPrimary.withValues(alpha: 0.08);
    final highlightCol =
        widget.highlightColor ?? LightColors.forestPrimary.withValues(alpha: 0.2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - (_controller.value * 2), 0),
              end: Alignment(1.0 - (_controller.value * 2), 0),
              colors: [
                baseCol,
                highlightCol,
                baseCol,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseCol,
              borderRadius: widget.isCircular
                  ? BorderRadius.circular(widget.width)
                  : (widget.borderRadius ?? BorderRadius.circular(8)),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for trek card
class TrekCardSkeleton extends StatelessWidget {
  const TrekCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            color: LightColors.forestPrimary.withValues(alpha: 0.05),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 150,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 200,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SkeletonLoader(
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SkeletonLoader(
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for day card
class DayCardSkeleton extends StatelessWidget {
  const DayCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                width: 40,
                height: 40,
                isCircular: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 100,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    SkeletonLoader(
                      width: 150,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for stats grid
class StatsSkeleton extends StatelessWidget {
  final int columns;

  const StatsSkeleton({super.key, this.columns = 2});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        columns * 2,
        (index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: LightColors.forestPrimary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonLoader(
                width: 36,
                height: 36,
                isCircular: true,
              ),
              const SizedBox(height: 12),
              SkeletonLoader(
                width: 60,
                height: 14,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              SkeletonLoader(
                width: 80,
                height: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for hero section
class HeroSkeleton extends StatelessWidget {
  final double height;

  const HeroSkeleton({super.key, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LightColors.forestPrimary.withValues(alpha: 0.05),
            LightColors.forestPrimary.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for list of items
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final SkeletonType type;
  final double spacing;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.type = SkeletonType.card,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return switch (type) {
          SkeletonType.card => const TrekCardSkeleton(),
          SkeletonType.day => const DayCardSkeleton(),
          SkeletonType.line => SkeletonLoader(
              height: 16,
              borderRadius: BorderRadius.circular(4),
            ),
        };
      },
    );
  }
}

enum SkeletonType { card, day, line }

/// Full dashboard skeleton loading state
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Hero skeleton
        const HeroSkeleton(height: 280),
        const SizedBox(height: 32),

        // Stats section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoader(
                width: 120,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              const StatsSkeleton(columns: 3),
              const SizedBox(height: 40),

              // Featured section
              SkeletonLoader(
                width: 120,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              const TrekCardSkeleton(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}
