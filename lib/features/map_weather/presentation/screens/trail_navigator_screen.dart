import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_theme.dart';
import 'package:path_app/core/theme/dark_colors.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/features/map_weather/data/datasources/map_remote_data_source.dart';
import 'package:path_app/features/map_weather/domain/entities/trail_track.dart';
import 'package:path_app/features/treks/data/datasources/trek_remote_data_source.dart';
import 'package:path_app/features/treks/domain/entities/waypoint.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

/// Provider that fetches the GPS track for a given trek from the backend.
final trekGpsTrackProvider = FutureProvider.family<TrailTrack?, String>((
  ref,
  trekId,
) async {
  final mapDataSource = ref.read(mapRemoteDataSourceProvider);
  try {
    return await mapDataSource.fetchTrekGpsTrack(trekId);
  } catch (_) {
    return null;
  }
});

/// Provider that fetches waypoints from the backend for a given trek.
final trekWaypointsProvider = FutureProvider.family<List<Waypoint>, String>((
  ref,
  trekId,
) async {
  final trekDataSource = ref.read(trekRemoteDataSourceProvider);
  return trekDataSource.fetchTrekWaypoints(trekId);
});

class TrailNavigatorScreen extends ConsumerStatefulWidget {
  final String? trekId;

  const TrailNavigatorScreen({super.key, this.trekId});

  @override
  ConsumerState<TrailNavigatorScreen> createState() =>
      _TrailNavigatorScreenState();
}

class _TrailNavigatorScreenState extends ConsumerState<TrailNavigatorScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  LatLng? _currentPosition;
  double _currentSpeed = 0;
  double _distanceTraveled = 0;
  LatLng? _previousPosition;
  bool _isTracking = false;
  bool _followUser = true;
  DateTime? _startTime;
  int _nearestWaypointIndex = 0;
  Timer? _durationTimer;

  // Track data from backend
  List<LatLng> _trailPolyline = [];
  List<LatLng> _walkedPath = [];
  List<Waypoint> _waypoints = [];
  String _trekTitle = '';
  bool _loadingTrack = true;
  bool _isMapDownloaded = false;
  String _resolvedRegion = '';

  static const Map<String, String> _regionOfflineMapAssets = {
    'Everest': 'assets/images/everest_base_camp.png',
    'Annapurna': 'assets/images/annapurna_circuit.png',
    'Langtang': 'assets/images/langtang_valley.png',
    'Poon Hill': 'assets/images/poon_hill.png',
  };

  @override
  void initState() {
    super.initState();
    _loadTrailData();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkOfflineMapDownloaded() async {
    final title = _trekTitle.toLowerCase();
    String? regionKey;
    String? downloadKey;

    if (title.contains('everest')) {
      regionKey = 'Everest';
      downloadKey = 'Everest Region';
    } else if (title.contains('annapurna')) {
      regionKey = 'Annapurna';
      downloadKey = 'Annapurna Conservation';
    } else if (title.contains('langtang')) {
      regionKey = 'Langtang';
      downloadKey = 'Langtang Valley';
    } else if (title.contains('poon') || title.contains('ghorepani')) {
      regionKey = 'Poon Hill';
      downloadKey = 'Ghorepani Poon Hill';
    }

    if (regionKey != null && downloadKey != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final isDownloaded = prefs.getBool('offline_map_$downloadKey') ?? false;
        setState(() {
          _resolvedRegion = regionKey!;
          _isMapDownloaded = isDownloaded;
        });
      } catch (_) {
        setState(() {
          _isMapDownloaded = false;
        });
      }
    } else {
      setState(() {
        _isMapDownloaded = false;
      });
    }
  }

  void _openOfflineMapViewer() {
    HapticFeedback.mediumImpact();
    final assetPath = _regionOfflineMapAssets[_resolvedRegion];
    if (assetPath == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Offline Map',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _OfflineMapFullscreenViewer(
          regionName: _resolvedRegion,
          assetPath: assetPath,
        );
      },
    );
  }

  Future<void> _loadTrailData() async {
    final trekId = widget.trekId;
    if (trekId == null || trekId.isEmpty) {
      setState(() => _loadingTrack = false);
      return;
    }

    try {
      final mapDataSource = ref.read(mapRemoteDataSourceProvider);
      final track = await mapDataSource.fetchTrekGpsTrack(trekId);

      final trekDataSource = ref.read(trekRemoteDataSourceProvider);
      final waypoints = await trekDataSource.fetchTrekWaypoints(trekId);

      setState(() {
        _trailPolyline = track.polyline;
        _waypoints = waypoints;
        _trekTitle = track.title;
        _loadingTrack = false;
      });

      if (track.polyline.isNotEmpty) {
        _animatedMove(track.center, 12.0);
      }

      await _checkOfflineMapDownloaded();
      _startTracking();
    } catch (e) {
      setState(() => _loadingTrack = false);
    }
  }

  void _zoomBy(double delta) {
    HapticFeedback.selectionClick();
    final target = (_mapController.camera.zoom + delta).clamp(4.0, 20.0);
    _animatedMove(_mapController.camera.center, target);
  }

  void _animatedMove(LatLng target, double zoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: zoom,
    );
    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) controller.dispose();
    });
    controller.forward();
  }

  Future<void> _startTracking() async {
    HapticFeedback.heavyImpact();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
      _distanceTraveled = 0;
      _walkedPath = [];
    });

    // Timer to update duration display
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          final newPos = LatLng(position.latitude, position.longitude);

          if (_previousPosition != null) {
            final dist = const Distance().as(
              LengthUnit.Kilometer,
              _previousPosition!,
              newPos,
            );
            _distanceTraveled += dist;
          }

          // Find nearest waypoint
          if (_waypoints.isNotEmpty) {
            double minDist = double.infinity;
            int minIdx = 0;
            for (int i = 0; i < _waypoints.length; i++) {
              final wp = _waypoints[i];
              final d = const Distance().as(
                LengthUnit.Kilometer,
                newPos,
                LatLng(wp.lat, wp.lng),
              );
              if (d < minDist) {
                minDist = d;
                minIdx = i;
              }
            }
            _nearestWaypointIndex = minIdx;
          }

          setState(() {
            _previousPosition = _currentPosition;
            _currentPosition = newPos;
            _currentSpeed = position.speed * 3.6;
            _walkedPath.add(newPos);
          });

          ref
              .read(activeTrekProvider.notifier)
              .updateProgress(
                region: _trekTitle,
                currentIndex: _nearestWaypointIndex,
                distanceWalkedKm: _distanceTraveled,
                isFinished: false,
                latitude: position.latitude,
                longitude: position.longitude,
                altitude: position.altitude,
                totalCheckpoints: _waypoints.length,
              );

          if (_followUser) {
            _mapController.move(newPos, _mapController.camera.zoom);
          }
        });
  }

  void _stopTracking() {
    HapticFeedback.heavyImpact();
    _positionStream?.cancel();
    _positionStream = null;
    _durationTimer?.cancel();

    ref
        .read(activeTrekProvider.notifier)
        .updateProgress(
          region: _trekTitle,
          currentIndex: _nearestWaypointIndex,
          distanceWalkedKm: _distanceTraveled,
          isFinished: true,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
          totalCheckpoints: _waypoints.length,
        );

    setState(() => _isTracking = false);
  }

  String _formatDuration() {
    if (_startTime == null) return '00:00';
    final elapsed = DateTime.now().difference(_startTime!);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;
    final isDark = theme.isDark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen Map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _trailPolyline.isNotEmpty
                  ? _trailPolyline[_trailPolyline.length ~/ 2]
                  : const LatLng(27.9, 86.9),
              initialZoom: 12.0,
              minZoom: 4,
              maxZoom: 18,
              onPositionChanged: (_, hasGesture) {
                if (hasGesture && _followUser) {
                  setState(() => _followUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                // Clean, modern CARTO basemap (dark-aware) — matches the
                // main map screen instead of the busy OpenTopoMap relief.
                urlTemplate: Theme.of(context).brightness == Brightness.dark
                    ? 'https://a.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png'
                    : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.path.app',
                maxZoom: 20,
              ),

              // Trail polyline (remaining path)
              if (_trailPolyline.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _trailPolyline,
                      strokeWidth: 5,
                      color: colors.primary.withValues(alpha: 0.7),
                      borderStrokeWidth: 1,
                      borderColor: Colors.white.withValues(alpha: 0.4),
                    ),
                  ],
                ),

              // Walked path overlay (Google Maps blue line)
              if (_walkedPath.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _walkedPath,
                      strokeWidth: 5,
                      color: const Color(0xFF4285F4),
                      borderStrokeWidth: 1.5,
                      borderColor: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),

              // Waypoint markers
              if (_waypoints.isNotEmpty)
                MarkerLayer(
                  markers: _waypoints.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final wp = entry.value;
                    final isNearest =
                        idx == _nearestWaypointIndex && _isTracking;
                    final isPassed = _isTracking && idx < _nearestWaypointIndex;
                    return Marker(
                      point: LatLng(wp.lat, wp.lng),
                      width: isNearest ? 40 : 32,
                      height: isNearest ? 40 : 32,
                      child: _WaypointPin(
                        index: idx,
                        isActive: isNearest,
                        isPassed: isPassed,
                      ),
                    );
                  }).toList(),
                ),

              // User location (Google Maps blue dot with direction cone)
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    // Accuracy pulse
                    Marker(
                      point: _currentPosition!,
                      width: 64,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF4285F4,
                          ).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Blue dot
                    Marker(
                      point: _currentPosition!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF4285F4,
                              ).withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Loading Overlay ──
          if (_loadingTrack)
            Container(
              color: colors.background.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: colors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Loading trail...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Top Bar (Google Maps navigation-style) ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.pop();
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isTracking
                                  ? LightColors.successGreen
                                  : colors.textSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _trekTitle.isNotEmpty
                                  ? _trekTitle
                                  : 'Trail Navigator',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                fontFamily: 'SpaceGrotesk',
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Recenter button
                  if (!_followUser && _isTracking)
                    GestureDetector(
                      onTap: () {
                        setState(() => _followUser = true);
                        if (_currentPosition != null) {
                          _animatedMove(
                            _currentPosition!,
                            _mapController.camera.zoom,
                          );
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF4285F4,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.near_me_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Next Waypoint Card (shown while tracking) ──
          if (_isTracking &&
              _waypoints.isNotEmpty &&
              _nearestWaypointIndex < _waypoints.length)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              right: 16,
              child: _NextWaypointCard(
                waypoint: _waypoints[_nearestWaypointIndex],
                index: _nearestWaypointIndex,
                total: _waypoints.length,
                currentPosition: _currentPosition,
              ),
            ),

          // ── Left: Floating Offline Map button (clears the bottom panel) ──
          if (_isMapDownloaded)
            Positioned(
              left: 16,
              bottom: 228 + bottomPad,
              child: _OfflineMapFloatingButton(onTap: _openOfflineMapViewer),
            ),

          // ── Right: Zoom controls (Google/Apple Maps-style) ──
          Positioned(
            right: 16,
            bottom: 210 + bottomPad,
            child: _NavZoomControl(
              onZoomIn: () => _zoomBy(1.0),
              onZoomOut: () => _zoomBy(-1.0),
            ),
          ),

          // ── Bottom Panel ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                bottomPad > 0 ? bottomPad + 8 : 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.background
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.route_rounded,
                        value: '${_distanceTraveled.toStringAsFixed(1)} km',
                        label: 'Distance',
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.speed_rounded,
                        value: '${_currentSpeed.toStringAsFixed(1)} km/h',
                        label: 'Speed',
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.timer_outlined,
                        value: _formatDuration(),
                        label: 'Time',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Start/Stop Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                      style: FilledButton.styleFrom(
                        backgroundColor: _isTracking
                            ? colors.error
                            : colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isTracking
                                ? Icons.stop_rounded
                                : Icons.navigation_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTracking ? 'End Navigation' : 'Start Navigation',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                        ],
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
  }
}

// ── Next Waypoint Card ──
class _NextWaypointCard extends StatelessWidget {
  final Waypoint waypoint;
  final int index;
  final int total;
  final LatLng? currentPosition;

  const _NextWaypointCard({
    required this.waypoint,
    required this.index,
    required this.total,
    this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    String distanceText = '';
    if (currentPosition != null) {
      final dist = const Distance().as(
        LengthUnit.Kilometer,
        currentPosition!,
        LatLng(waypoint.lat, waypoint.lng),
      );
      distanceText = dist < 1
          ? '${(dist * 1000).toInt()}m away'
          : '${dist.toStringAsFixed(1)}km away';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DarkColors.deepCanopy : Colors.white;
    final textPrimary = isDark
        ? DarkColors.bioluminescent
        : LightColors.textPrimary;
    final textSecondary = isDark ? Colors.white70 : LightColors.textSecondary;
    final badgeBg = isDark ? DarkColors.undergrowth : LightColors.primaryLight;
    final badgeText = isDark
        ? DarkColors.bioluminescent
        : LightColors.forestPrimary;
    final pinBg = isDark
        ? DarkColors.bioluminescent
        : LightColors.forestPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: pinBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waypoint.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'SpaceGrotesk',
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${waypoint.alt.toInt()}m elevation',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (distanceText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                distanceText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Waypoint Pin Marker ──
class _WaypointPin extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isPassed;

  const _WaypointPin({
    required this.index,
    required this.isActive,
    this.isPassed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isPassed
        ? (isDark ? Colors.white30 : LightColors.textTertiary)
        : isActive
        ? LightColors.peakAmber
        : (isDark ? DarkColors.bioluminescent : LightColors.forestPrimary);

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: isActive ? 10 : 4,
            spreadRadius: isActive ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: isPassed
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
            : Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

// ── Stat Pill ──
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkColors.undergrowth : LightColors.surface95;
    final textPrimary = isDark ? Colors.white : LightColors.textPrimary;
    final textSecondary = isDark ? Colors.white70 : LightColors.textSecondary;
    final textTertiary = isDark ? Colors.white38 : LightColors.textTertiary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: textSecondary),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                fontFamily: 'SpaceGrotesk',
                color: textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Floating Offline Map Button (Claymorphic)
// ─────────────────────────────────────────
class _NavZoomControl extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _NavZoomControl({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DarkColors.deepCanopy : Colors.white;
    final iconColor =
        isDark ? DarkColors.bioluminescent : LightColors.textPrimary;
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _navZoomBtn(Icons.add_rounded, iconColor, onZoomIn),
          Container(height: 1, width: 22, color: divider),
          _navZoomBtn(Icons.remove_rounded, iconColor, onZoomOut),
        ],
      ),
    );
  }

  Widget _navZoomBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: color),
        ),
      );
}

class _OfflineMapFloatingButton extends StatelessWidget {
  final VoidCallback onTap;

  const _OfflineMapFloatingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClayContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_rounded,
              size: 16,
              color: LightColors.trailGreen,
            ),
            const SizedBox(width: 8),
            Text(
              'Offline Map',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'SpaceGrotesk',
                color: isDark ? Colors.white : LightColors.summitDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: LightColors.successGreen,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Offline Map Fullscreen Viewer
// ─────────────────────────────────────────
class _OfflineMapFullscreenViewer extends StatelessWidget {
  final String regionName;
  final String assetPath;

  const _OfflineMapFullscreenViewer({
    required this.regionName,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable image viewer
          InteractiveViewer(
            maxScale: 6.0,
            minScale: 1.0,
            child: Center(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white60,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Map image not found',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Header Bar
          Positioned(
            top: topPad + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Back/Close button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title pill
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      '$regionName Trail Map (Offline)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'SpaceGrotesk',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Legend / Instructions at bottom
          Positioned(
            bottom: bottomPad + 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pinch or double tap to zoom in and navigate the high-resolution topo trail path.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w500,
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
  }
}
