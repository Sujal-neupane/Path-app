import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Beautiful day-by-day progress visualization with milestone markers
class ProgressHero extends StatefulWidget {
  final int currentDay;
  final int totalDays;
  final String? location;
  final String? routeInfo;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool animated;

  const ProgressHero({
    super.key,
    required this.currentDay,
    required this.totalDays,
    this.location,
    this.routeInfo,
    this.backgroundColor,
    this.progressColor,
    this.animated = true,
  });

  @override
  State<ProgressHero> createState() => _ProgressHeroState();
}

class _ProgressHeroState extends State<ProgressHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      _progressAnimation = Tween<double>(
        begin: 0,
        end: widget.currentDay / widget.totalDays,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay && widget.animated) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.currentDay / oldWidget.totalDays,
        end: widget.currentDay / widget.totalDays,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? LightColors.forestPrimary;
    final progressCol = widget.progressColor ?? Colors.white;
    final progressValue = widget.animated
        ? _progressAnimation.value
        : widget.currentDay / widget.totalDays;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withValues(alpha: 0.85),
            bgColor,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day counter with emoji motivation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${widget.currentDay} of ${widget.totalDays}',
                    style: AppTextStyles.caption.copyWith(
                      color: progressCol.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMotivationalMessage(widget.currentDay, widget.totalDays),
                    style: AppTextStyles.h2.copyWith(
                      color: progressCol,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              _getMotivatinalEmoji(widget.currentDay, widget.totalDays),
            ],
          ),
          const SizedBox(height: 20),

          // Route info if provided
          if (widget.location != null || widget.routeInfo != null) ...[
            Container(
              decoration: BoxDecoration(
                color: progressCol.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: progressCol,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.routeInfo ??
                          widget.location ??
                          'On the trek',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: progressCol.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Progress bar with labels
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 8,
                  backgroundColor: progressCol.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(progressCol.withValues(alpha: 0.95)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progressValue * 100).toStringAsFixed(0)}% Complete',
                    style: AppTextStyles.caption.copyWith(
                      color: progressCol.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.totalDays - widget.currentDay} days left',
                    style: AppTextStyles.caption.copyWith(
                      color: progressCol.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int current, int total) {
    final percentage = (current / total) * 100;

    if (current == 1) {
      return 'Great Start! 🏔️';
    } else if (percentage < 30) {
      return 'Building Momentum 💪';
    } else if (percentage < 50) {
      return 'Halfway There! 🏅';
    } else if (percentage < 75) {
      return 'Pushing Forward 🔥';
    } else if (percentage < 95) {
      return 'Almost There! 🎯';
    } else {
      return 'The Summit Awaits! ⛰️';
    }
  }

  Widget _getMotivatinalEmoji(int current, int total) {
    final percentage = (current / total) * 100;

    return Text(
      percentage < 30
          ? '🚶'
          : percentage < 50
              ? '🥾'
              : percentage < 75
                  ? '⛰️'
                  : percentage < 95
                      ? '🏔️'
                      : '🏁',
      style: const TextStyle(fontSize: 32),
    );
  }
}

/// Compact progress bar variant
class CompactProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final Color? color;
  final bool showLabel;
  final bool showPercentage;

  const CompactProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.color,
    this.showLabel = true,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final progressCol = color ?? LightColors.forestPrimary;
    final progress = current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColors.textPrimary,
                ),
              ),
              if (showPercentage)
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: progressCol,
                  ),
                ),
            ],
          ),
        if (showLabel) const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: progressCol.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(progressCol),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Text(
            'Day $current of $total',
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

/// Multi-stage progress indicator (for different phases)
class MultiStageProgress extends StatelessWidget {
  final int currentStage;
  final List<String> stages;
  final List<Color>? stageColors;

  const MultiStageProgress({
    super.key,
    required this.currentStage,
    required this.stages,
    this.stageColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stages.length, (index) {
        final isCompleted = index < currentStage;
        final isCurrent = index == currentStage;
        final color = stageColors?[index] ?? LightColors.forestPrimary;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  // Circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent
                          ? color
                          : color.withValues(alpha: 0.1),
                      border: isCurrent
                          ? Border.all(
                              color: color,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isCompleted || isCurrent ? Colors.white : color,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // Connector line
                  if (index < stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted ? color : color.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stages[index],
                style: AppTextStyles.caption.copyWith(
                  color: isCurrent ? color : LightColors.textSecondary,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }
}
