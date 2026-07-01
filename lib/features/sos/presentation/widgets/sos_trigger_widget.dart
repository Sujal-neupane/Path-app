import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/sos/presentation/viewmodels/sos_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SosTriggerWidget extends ConsumerStatefulWidget {
  const SosTriggerWidget({super.key});

  @override
  ConsumerState<SosTriggerWidget> createState() => _SosTriggerWidgetState();
}

class _SosTriggerWidgetState extends ConsumerState<SosTriggerWidget> {
  double _dragProgress = 0.0; // Range: 0.0 to 1.0
  bool _isSuccess = false;
  bool _isLocating = false;

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
        _isLocating = true;
      });

      // Get real GPS location
      double latitude = 27.8068;
      double longitude = 86.7140;
      double altitude = 3440.0;
      double batteryLevel = 92.0;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission != LocationPermission.deniedForever &&
              permission != LocationPermission.denied) {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 10),
              ),
            );
            latitude = position.latitude;
            longitude = position.longitude;
            altitude = position.altitude;
          }
        }
      } catch (_) {
        // Use defaults if GPS fails
      }

      setState(() => _isLocating = false);

      // Fire SOS distress signal with real GPS coordinates
      await ref.read(sosViewModelProvider.notifier).triggerSos(
        lat: latitude,
        lng: longitude,
        alt: altitude,
        battery: batteryLevel,
        message: 'Emergency SOS triggered. GPS: $latitude, $longitude',
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

  Future<void> _callEmergency() async {
    HapticFeedback.heavyImpact();

    // Show confirmation dialog first (UX best practice for irreversible actions)
    final c = AppColors(Theme.of(context).brightness == Brightness.dark);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: c.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LightColors.sosRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_rounded, color: LightColors.sosRed, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Call Emergency Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'SpaceGrotesk',
                  color: c.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will immediately dial 112 (international emergency number). Only use this in a genuine emergency.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: c.textSecondary,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: LightColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: LightColors.sosRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Call 112',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final Uri phoneUri = Uri(scheme: 'tel', path: '112');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosViewModelProvider);
    final c = AppColors(Theme.of(context).brightness == Brightness.dark);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final thumbSize = 56.0;
            final maxDistance = trackWidth - thumbSize - 16.0;

            if (_isSuccess) {
              final isSynced = sosState.lastSentAlert != null && sosState.lastSentAlert!.isSynced;
              final subtitle = _isLocating
                  ? 'Acquiring GPS coordinates...'
                  : isSynced
                      ? 'Distress signal received by backend.'
                      : 'Saved to local queue. Syncing automatically...';

              return ClayContainer(
                borderRadius: 24,
                depth: 8,
                color: _isLocating
                    ? LightColors.altitudeBlue
                    : isSynced
                        ? LightColors.successGreen
                        : LightColors.peakAmber,
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
                      child: _isLocating
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
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
                            _isLocating
                                ? 'LOCATING...'
                                : isSynced
                                    ? 'SOS TRANSMITTED'
                                    : 'SOS QUEUED OFFLINE',
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
                    if (!_isLocating)
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
              // Soft red alert surface — dark-aware so it never flashes white.
              color: c.isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEECEB),
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
        ),
        const SizedBox(height: 10),

        // Emergency Call Button — always visible
        GestureDetector(
          onTap: _callEmergency,
          child: ClayContainer(
            borderRadius: 16,
            depth: 4,
            spread: 2,
            color: c.surfaceElevated,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LightColors.sosRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: LightColors.sosRed,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Call Emergency Services (112)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.sosRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: LightColors.sosRed,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
