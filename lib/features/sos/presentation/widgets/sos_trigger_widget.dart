import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/sos/presentation/viewmodels/sos_viewmodel.dart';

class SosTriggerWidget extends ConsumerStatefulWidget {
  const SosTriggerWidget({super.key});

  @override
  ConsumerState<SosTriggerWidget> createState() => _SosTriggerWidgetState();
}

class _SosTriggerWidgetState extends ConsumerState<SosTriggerWidget> {
  double _dragProgress = 0.0; // Range: 0.0 to 1.0
  bool _isSuccess = false;

  void _onDragUpdate(DragUpdateDetails details, double maxDistance) {
    if (_isSuccess) return;
    setState(() {
      _dragProgress += details.primaryDelta! / maxDistance;
      _dragProgress = _dragProgress.clamp(0.0, 1.0);
    });
    // Haptic feedback tick as the user drags
    if (_dragProgress > 0.1 && _dragProgress < 0.9) {
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd() async {
    if (_isSuccess) return;
    if (_dragProgress > 0.90) {
      // Complete the trigger
      HapticFeedback.heavyImpact();
      setState(() {
        _dragProgress = 1.0;
        _isSuccess = true;
      });

      // Fire SOS distress signal via Riverpod notifier
      await ref.read(sosViewModelProvider.notifier).triggerSos(
        message: 'Manual SOS triggered via Smart Dashboard.',
      );
    } else {
      // Snap back to starting position
      setState(() {
        _dragProgress = 0.0;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _resetTrigger() {
    setState(() {
      _dragProgress = 0.0;
      _isSuccess = false;
    });
    ref.read(sosViewModelProvider.notifier).clearLocalQueue();
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final thumbSize = 56.0;
        final maxDistance = trackWidth - thumbSize - 16.0; // 8.0 padding on each side

        if (_isSuccess) {
          final isSynced = sosState.lastSentAlert != null && sosState.lastSentAlert!.isSynced;
          final subtitle = isSynced 
              ? 'Distress signal received by backend.' 
              : 'Saved to local queue. Syncing automatically...';

          return ClayContainer(
            borderRadius: 24,
            depth: 8,
            color: isSynced ? LightColors.successGreen : LightColors.peakAmber,
            isDark: true,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSynced ? 'SOS TRANSMITTED' : 'SOS QUEUED OFFLINE',
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _resetTrigger,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  tooltip: 'Cancel & Reset',
                )
              ],
            ),
          );
        }

        return ClayContainer(
          borderRadius: 24,
          depth: 8,
          color: const Color(0xFFFEECEB), // Soft clay warning background
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: SizedBox(
            height: 56,
            child: Stack(
              children: [
                // Inset Track label
                Center(
                  child: Opacity(
                    opacity: (1.0 - _dragProgress * 1.8).clamp(0.0, 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.keyboard_double_arrow_right_rounded,
                          color: LightColors.sosRed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SLIDE TO SEND SOS ALERT',
                          style: AppTextStyles.button.copyWith(
                            color: LightColors.sosRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sliding thumb button
                Positioned(
                  left: _dragProgress * maxDistance,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxDistance),
                    onHorizontalDragEnd: (_) => _onDragEnd(),
                    child: ClayContainer(
                      borderRadius: 18,
                      depth: 4,
                      color: LightColors.sosRed,
                      isDark: true,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        width: thumbSize,
                        height: thumbSize,
                        child: const Icon(
                          Icons.sos_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
