import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/domain/entities/waypoint.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

class TrailNavigatorScreen extends ConsumerStatefulWidget {
  final String region;

  const TrailNavigatorScreen({super.key, required this.region});

  @override
  ConsumerState<TrailNavigatorScreen> createState() => _TrailNavigatorScreenState();
}

class _TrailNavigatorScreenState extends ConsumerState<TrailNavigatorScreen> {
  late List<Waypoint> _waypoints;
  int _currentIndex = 0;
  double _lerpProgress = 0.0; // From 0.0 to 1.0 between current and next waypoint
  bool _isPlaying = false;
  int _simulationSpeed = 1; // 1 = 1s, 2 = 500ms, 5 = 200ms
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadWaypoints();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeTrekProvider.notifier).startTrek(
        widget.region,
        totalCheckpoints: _waypoints.length,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadWaypoints() {
    _waypoints = getWaypointsForRegion(widget.region);
  }


  void _toggleSimulation() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final intervalMs = (1000 / _simulationSpeed).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentIndex < _waypoints.length - 1) {
          _lerpProgress += 0.1;
          if (_lerpProgress >= 1.0) {
            _currentIndex++;
            _lerpProgress = 0.0;
            HapticFeedback.lightImpact();
          }
        } else {
          // Finished route!
          _isPlaying = false;
          _timer?.cancel();
          HapticFeedback.heavyImpact();
          _showRouteFinishedDialog();
        }
      });
      ref.read(activeTrekProvider.notifier).updateProgress(
        region: widget.region,
        currentIndex: _currentIndex,
        distanceWalkedKm: _currentDistanceKm,
        isFinished: _currentIndex >= _waypoints.length - 1,
        latitude: _currentLat,
        longitude: _currentLng,
        altitude: _currentAlt,
        totalCheckpoints: _waypoints.length,
      );
    });
  }

  void _changeSpeed(int speed) {
    HapticFeedback.selectionClick();
    setState(() {
      _simulationSpeed = speed;
    });
    if (_isPlaying) {
      _startTimer();
    }
  }

  void _resetSimulation() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _currentIndex = 0;
      _lerpProgress = 0.0;
      _isPlaying = false;
    });
    ref.read(activeTrekProvider.notifier).updateProgress(
      region: widget.region,
      currentIndex: 0,
      distanceWalkedKm: 0.0,
      isFinished: false,
      latitude: _waypoints.isNotEmpty ? _waypoints.first.lat : null,
      longitude: _waypoints.isNotEmpty ? _waypoints.first.lng : null,
      altitude: _waypoints.isNotEmpty ? _waypoints.first.alt : null,
      totalCheckpoints: _waypoints.length,
    );
  }

  void _showRouteFinishedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LightColors.stoneWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: LightColors.peakAmber,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Route Completed!',
              style: AppTextStyles.h2.copyWith(color: LightColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'You have successfully simulated the complete trail route for ${widget.region}. GPS coordinates and offline trackers synced successfully.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetSimulation();
            },
            child: Text(
              'Reset',
              style: AppTextStyles.button.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: LightColors.forestPrimary,
            ),
            child: const Text('Great'),
          ),
        ],
      ),
    );
  }

  double get _currentLat {
    if (_currentIndex >= _waypoints.length - 1) {
      return _waypoints.last.lat;
    }
    final current = _waypoints[_currentIndex];
    final next = _waypoints[_currentIndex + 1];
    return current.lat + (next.lat - current.lat) * _lerpProgress;
  }

  double get _currentLng {
    if (_currentIndex >= _waypoints.length - 1) {
      return _waypoints.last.lng;
    }
    final current = _waypoints[_currentIndex];
    final next = _waypoints[_currentIndex + 1];
    return current.lng + (next.lng - current.lng) * _lerpProgress;
  }

  double get _currentAlt {
    if (_currentIndex >= _waypoints.length - 1) {
      return _waypoints.last.alt;
    }
    final current = _waypoints[_currentIndex];
    final next = _waypoints[_currentIndex + 1];
    return current.alt + (next.alt - current.alt) * _lerpProgress;
  }

  double get _currentDistanceKm {
    if (_waypoints.isEmpty) return 0.0;
    if (_currentIndex >= _waypoints.length - 1) {
      return _parseDistance(_waypoints.last.distance);
    }
    final currentDist = _parseDistance(_waypoints[_currentIndex].distance);
    final nextDist = _parseDistance(_waypoints[_currentIndex + 1].distance);
    return currentDist + (nextDist - currentDist) * _lerpProgress;
  }

  double _parseDistance(String distStr) {
    final clean = distStr.replaceAll(' km', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: LightColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'GPX Trail Navigator',
          style: AppTextStyles.h2.copyWith(color: LightColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Coordinate Display Card
          ClayContainer(
            borderRadius: 22,
            depth: 6,
            spread: 3,
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.region.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.forestPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isPlaying
                            ? LightColors.successLight
                            : LightColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isPlaying ? 'SIMULATING' : 'PAUSED',
                        style: AppTextStyles.caption.copyWith(
                          color: _isPlaying
                              ? LightColors.successGreen
                              : LightColors.forestPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatBlock(
                        title: 'LATITUDE',
                        value: _currentLat.toStringAsFixed(5),
                      ),
                    ),
                    Expanded(
                      child: _StatBlock(
                        title: 'LONGITUDE',
                        value: _currentLng.toStringAsFixed(5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatBlock(
                        title: 'ALTITUDE',
                        value: '${_currentAlt.round()} m',
                        valueColor: LightColors.altitudeBlue,
                      ),
                    ),
                    Expanded(
                      child: _StatBlock(
                        title: 'DISTANCE WALKED',
                        value: '${_currentDistanceKm.toStringAsFixed(2)} km',
                        valueColor: LightColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: LightColors.dividerLight),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_city_rounded,
                      color: LightColors.forestPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Next Stop: ',
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _currentIndex < _waypoints.length - 1
                            ? _waypoints[_currentIndex + 1].name
                            : 'Destination Reached',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Custom Painted Route Visualizer Map
          ClayContainer(
            borderRadius: 22,
            depth: 6,
            spread: 3,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPX Hiker Trail Trace',
                  style: AppTextStyles.h3.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: LightColors.stoneWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: _TrailMapPainter(
                        waypoints: _waypoints,
                        currentIndex: _currentIndex,
                        lerpProgress: _lerpProgress,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Timeline steps
          ClayContainer(
            borderRadius: 22,
            depth: 6,
            spread: 3,
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waypoint Progress',
                  style: AppTextStyles.h3.copyWith(
                    color: LightColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _waypoints.length,
                  itemBuilder: (context, index) {
                    final wp = _waypoints[index];
                    final isPassed = index < _currentIndex;
                    final isActive = index == _currentIndex;

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? LightColors.successGreen
                                      : isActive
                                      ? LightColors.forestPrimary
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isPassed || isActive
                                        ? Colors.transparent
                                        : LightColors.dividerStrong,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: isPassed
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 12,
                                        )
                                      : isActive
                                      ? const Icon(
                                          Icons.hiking_rounded,
                                          color: Colors.white,
                                          size: 11,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: AppTextStyles.caption.copyWith(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: LightColors.textTertiary,
                                          ),
                                        ),
                                ),
                              ),
                              if (index < _waypoints.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isPassed
                                        ? LightColors.successGreen
                                        : LightColors.divider,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wp.name,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: isActive
                                                  ? LightColors.textPrimary
                                                  : LightColors.textSecondary,
                                              fontWeight: isActive
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Altitude: ${wp.alt} m • ${wp.distance}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: LightColors.textTertiary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: LightColors.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ACTIVE',
                                        style: AppTextStyles.caption.copyWith(
                                          color: LightColors.forestPrimary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Simulation Controls Card
          ClayContainer(
            borderRadius: 22,
            depth: 8,
            color: LightColors.summitDark,
            isDark: true,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton.filled(
                  onPressed: _resetSimulation,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.replay_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _toggleSimulation,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: LightColors.summitDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _isPlaying ? 'Pause Tracker' : 'Start Simulation',
                      style: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColors.summitDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<int>(
                  color: LightColors.summitDark,
                  offset: const Offset(0, -110),
                  onSelected: _changeSpeed,
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_simulationSpeed}x',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text(
                        'Normal (1x)',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text(
                        'Fast (2x)',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 5,
                      child: Text(
                        'Blitz (5x)',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _StatBlock({required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: LightColors.textTertiary,
            fontWeight: FontWeight.w800,
            fontSize: 9,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: valueColor ?? LightColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _TrailMapPainter extends CustomPainter {
  final List<Waypoint> waypoints;
  final int currentIndex;
  final double lerpProgress;

  _TrailMapPainter({
    required this.waypoints,
    required this.currentIndex,
    required this.lerpProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waypoints.isEmpty) return;

    final paintLine = Paint()
      ..color = LightColors.dividerStrong
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintLineWalked = Paint()
      ..color = LightColors.trailGreen
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Find bounding box for scaling
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final wp in waypoints) {
      if (wp.lat < minLat) minLat = wp.lat;
      if (wp.lat > maxLat) maxLat = wp.lat;
      if (wp.lng < minLng) minLng = wp.lng;
      if (wp.lng > maxLng) maxLng = wp.lng;
    }

    double latSpan = maxLat - minLat;
    double lngSpan = maxLng - minLng;
    // Prevent division by zero
    if (latSpan == 0) latSpan = 1.0;
    if (lngSpan == 0) lngSpan = 1.0;

    // Map waypoints to screen coordinates with margins
    final double margin = 24.0;
    final double plotWidth = size.width - margin * 2;
    final double plotHeight = size.height - margin * 2;

    Offset getOffset(Waypoint wp) {
      // Norm coordinates to [0,1]
      final normX = (wp.lng - minLng) / lngSpan;
      final normY =
          1.0 - ((wp.lat - minLat) / latSpan); // Flutter Y is downwards
      return Offset(margin + normX * plotWidth, margin + normY * plotHeight);
    }

    final points = waypoints.map(getOffset).toList();

    // Draw background trail lines
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paintLine);

    // Calculate dynamic walked offset
    Offset hikerOffset;
    if (currentIndex >= points.length - 1) {
      hikerOffset = points.last;
    } else {
      final cur = points[currentIndex];
      final next = points[currentIndex + 1];
      hikerOffset = Offset(
        cur.dx + (next.dx - cur.dx) * lerpProgress,
        cur.dy + (next.dy - cur.dy) * lerpProgress,
      );
    }

    // Draw walked trail path
    final walkedPath = Path();
    walkedPath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i <= currentIndex; i++) {
      walkedPath.lineTo(points[i].dx, points[i].dy);
    }
    walkedPath.lineTo(hikerOffset.dx, hikerOffset.dy);
    canvas.drawPath(walkedPath, paintLineWalked);

    // Draw waypoints as circles
    final wpPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final wpBorder = Paint()
      ..color = LightColors.summitDark
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final passedPaint = Paint()
      ..color = LightColors.successGreen
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final radius = i == 0 || i == points.length - 1 ? 6.0 : 4.0;
      final isPassed = i < currentIndex;

      canvas.drawCircle(p, radius, isPassed ? passedPaint : wpPaint);
      canvas.drawCircle(p, radius, wpBorder);
    }

    // Draw current hiker position marker
    final hikerPaint = Paint()
      ..color = LightColors.forestPrimary
      ..style = PaintingStyle.fill;

    final hikerGlow = Paint()
      ..color = LightColors.forestPrimary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(hikerOffset, 12.0, hikerGlow);
    canvas.drawCircle(hikerOffset, 7.0, hikerPaint);
    canvas.drawCircle(hikerOffset, 7.0, wpBorder);
  }

  @override
  bool shouldRepaint(covariant _TrailMapPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.lerpProgress != lerpProgress;
  }
}
