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
import 'package:path_app/features/map_weather/domain/entities/weather_report.dart';
import 'package:path_app/features/map_weather/presentation/viewmodels/weather_viewmodel.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

enum MapLayerType { standard, satellite, terrain }

class MapWeatherScreen extends ConsumerStatefulWidget {
  const MapWeatherScreen({super.key});

  @override
  ConsumerState<MapWeatherScreen> createState() => _MapWeatherScreenState();
}

class _MapWeatherScreenState extends ConsumerState<MapWeatherScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  String _selectedRegion = 'Everest';
  final List<String> _regions = ['Everest', 'Annapurna', 'Langtang', 'Poon Hill'];
  MapLayerType _activeLayer = MapLayerType.standard;
  bool _showWeatherSheet = false;
  LatLng? _userLocation;
  bool _isLocating = false;
  bool _followMode = false;
  StreamSubscription<Position>? _positionStream;
  double _currentZoom = 11.0;
  double _heading = 0;
  bool _isMapDownloaded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  static const Map<String, LatLng> _regionCenters = {
    'Everest': LatLng(27.9813, 86.9248),
    'Annapurna': LatLng(28.7972, 83.9782),
    'Langtang': LatLng(28.2167, 85.6167),
    'Poon Hill': LatLng(28.4, 83.7),
  };

  static const Map<String, String> _regionAltitudes = {
    'Everest': '5,364m',
    'Annapurna': '4,130m',
    'Langtang': '3,830m',
    'Poon Hill': '3,210m',
  };

  static const Map<String, String> _regionDownloadKeys = {
    'Everest': 'Everest Region',
    'Annapurna': 'Annapurna Conservation',
    'Langtang': 'Langtang Valley',
    'Poon Hill': 'Ghorepani Poon Hill',
  };

  @override
  void initState() {
    super.initState();
    final activeState = ref.read(activeTrekProvider);
    if (activeState.region != null) {
      for (final r in _regions) {
        if (activeState.region!.toLowerCase().contains(r.toLowerCase())) {
          _selectedRegion = r;
          break;
        }
      }
    }
    _requestUserLocation();
    _checkOfflineMapDownloaded();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkOfflineMapDownloaded() async {
    final downloadKey = _regionDownloadKeys[_selectedRegion];
    if (downloadKey != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final isDownloaded = prefs.getBool('offline_map_$downloadKey') ?? false;
        setState(() {
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

  Future<void> _requestUserLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLocating = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _heading = position.heading;
        _isLocating = false;
      });
      _startLiveTracking();
    } catch (_) {
      setState(() => _isLocating = false);
    }
  }

  void _startLiveTracking() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _heading = position.heading;
      });
      if (_followMode && _userLocation != null) {
        _mapController.move(_userLocation!, _currentZoom);
      }
    });
  }

  void _onRegionChanged(String region) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRegion = region;
      _followMode = false;
    });
    // Auto-frame the newly selected trail (falls back to region center).
    final points = _getTrailPoints(region);
    if (points.length > 1) {
      _fitToTrail();
    } else {
      final center = _regionCenters[region];
      if (center != null) _animatedMove(center, 11.0);
    }
    _checkOfflineMapDownloaded();
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
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
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

  void _zoomBy(double delta) {
    HapticFeedback.selectionClick();
    final target = (_mapController.camera.zoom + delta).clamp(4.0, 18.0);
    _animatedMove(_mapController.camera.center, target);
  }

  /// Auto-frame the whole trail so the user sees the route immediately.
  void _fitToTrail() {
    final points = _getTrailPoints(_selectedRegion);
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 13.0);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        // Leave room for the search bar (top) and weather sheet (bottom).
        padding: const EdgeInsets.fromLTRB(50, 130, 50, 180),
        maxZoom: 14,
      ),
    );
  }

  void _cycleMapLayer() {
    HapticFeedback.selectionClick();
    setState(() {
      _activeLayer = MapLayerType
          .values[(_activeLayer.index + 1) % MapLayerType.values.length];
    });
  }

  void _toggleFollowMode() {
    HapticFeedback.mediumImpact();
    if (_userLocation == null) {
      _requestUserLocation();
      return;
    }
    setState(() => _followMode = !_followMode);
    if (_followMode) {
      _startLiveTracking();
      _animatedMove(_userLocation!, 15.0);
    } else {
      _positionStream?.cancel();
    }
  }

  void _openOfflineMapViewer() {
    HapticFeedback.mediumImpact();
    final trail = _getTrailPoints(_selectedRegion);
    if (trail.isEmpty) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Full Map',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _FullScreenTrailMap(
          regionName: _selectedRegion,
          trailPoints: trail,
          tileUrl: _tileUrl,
        );
      },
    );
  }

  String get _tileUrl {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_activeLayer) {
      case MapLayerType.standard:
        // CARTO basemaps — clean, modern, Google-Maps-like (dark-aware).
        return isDark
            ? 'https://a.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png'
            : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
      case MapLayerType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapLayerType.terrain:
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
    }
  }

  IconData get _layerIcon {
    switch (_activeLayer) {
      case MapLayerType.standard:
        return Icons.map_outlined;
      case MapLayerType.satellite:
        return Icons.satellite_alt_outlined;
      case MapLayerType.terrain:
        return Icons.terrain_outlined;
    }
  }

  List<LatLng> _getTrailPoints(String region) {
    if (region == 'Everest') {
      return const [
        LatLng(27.6878, 86.7314), // Lukla
        LatLng(27.6896, 86.7214), // Phakding
        LatLng(27.8068, 86.7140), // Namche Bazaar
        LatLng(27.8361, 86.7645), // Tengboche Monastery
        LatLng(27.8920, 86.8315), // Dingboche
        LatLng(27.9485, 86.8118), // Lobuche
        LatLng(27.9784, 86.8281), // Gorak Shep
        LatLng(27.9813, 86.9248), // Everest Base Camp
      ];
    } else if (region == 'Annapurna') {
      return const [
        LatLng(28.2307, 84.3739), // Besisahar
        LatLng(28.3214, 84.3415), // Jagat
        LatLng(28.5204, 84.3596), // Dharapani
        LatLng(28.5524, 84.2415), // Chame
        LatLng(28.6214, 84.1485), // Pisang
        LatLng(28.6672, 84.0205), // Manang
        LatLng(28.7104, 83.9924), // Yak Kharka
        LatLng(28.7845, 83.9485), // Thorong Phedi
        LatLng(28.7996, 83.8712), // Thorong La Pass
        LatLng(28.7878, 83.7214), // Jomsom
      ];
    } else if (region == 'Langtang') {
      return const [
        LatLng(28.1672, 85.3415), // Syabrubesi
        LatLng(28.1672, 85.3415), // Lama Hotel
        LatLng(28.2145, 85.4985), // Langtang Village
        LatLng(28.2136, 85.5684), // Kyanjin Gompa
        LatLng(28.2167, 85.6167), // Langtang Valley Center
      ];
    } else if (region == 'Poon Hill') {
      return const [
        LatLng(28.2915, 83.7485), // Nayapul
        LatLng(28.2915, 83.7485), // Tikhedhunga
        LatLng(28.4012, 83.7014), // Ghorepani
        LatLng(28.3978, 83.7645), // Poon Hill Viewpoint
        LatLng(28.3812, 83.8115), // Tadapani
        LatLng(28.3812, 83.8115), // Ghandruk
      ];
    }
    return [];
  }

  List<SearchResult> _getSearchResults(String query, List<TrekSummary> treks) {
    final lowercaseQuery = query.toLowerCase();
    final results = <SearchResult>[];

    // 1. Regions
    for (final region in _regions) {
      if (region.toLowerCase().contains(lowercaseQuery)) {
        results.add(SearchResult(
          title: '$region Region',
          subtitle: 'Main mountain region',
          region: region,
          type: SearchResultType.region,
          center: _regionCenters[region],
        ));
      }
    }

    // 2. Treks
    for (final trek in treks) {
      if (trek.name.toLowerCase().contains(lowercaseQuery) ||
          trek.shortDescription.toLowerCase().contains(lowercaseQuery)) {
        String region = 'Everest';
        final lowerName = trek.name.toLowerCase();
        if (lowerName.contains('everest')) {
          region = 'Everest';
        } else if (lowerName.contains('annapurna')) {
          region = 'Annapurna';
        } else if (lowerName.contains('langtang')) {
          region = 'Langtang';
        } else if (lowerName.contains('poon') || lowerName.contains('ghorepani')) {
          region = 'Poon Hill';
        }

        results.add(SearchResult(
          title: trek.name,
          subtitle: '${trek.durationDays} Days • ${trek.difficulty}',
          region: region,
          type: SearchResultType.trek,
          center: _regionCenters[region],
        ));
      }

      // 3. Checkpoints
      for (final step in trek.detailedItinerary) {
        if (step.title.toLowerCase().contains(lowercaseQuery) ||
            step.description.toLowerCase().contains(lowercaseQuery)) {
          String region = 'Everest';
          final lowerName = trek.name.toLowerCase();
          if (lowerName.contains('everest')) {
            region = 'Everest';
          } else if (lowerName.contains('annapurna')) {
            region = 'Annapurna';
          } else if (lowerName.contains('langtang')) {
            region = 'Langtang';
          } else if (lowerName.contains('poon') || lowerName.contains('ghorepani')) {
            region = 'Poon Hill';
          }

          results.add(SearchResult(
            title: step.title,
            subtitle: '${trek.name} Landmark (${step.day})',
            region: region,
            type: SearchResultType.checkpoint,
            center: step.latitude != null && step.longitude != null
                ? LatLng(step.latitude!, step.longitude!)
                : _regionCenters[region],
          ));
        }
      }
    }

    final seen = <String>{};
    return results.where((r) => seen.add(r.title)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;
    final isDark = theme.isDark;

    final treksAsync = ref.watch(trekListProvider);
    final treks = treksAsync.value ?? [];

    final List<SearchResult> searchResults = _searchQuery.isEmpty
        ? []
        : _getSearchResults(_searchQuery, treks);

    final weatherAsync = ref.watch(weatherStateProvider(_selectedRegion));
    final regionCenter =
        _regionCenters[_selectedRegion] ?? const LatLng(27.9, 86.9);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen Map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: regionCenter,
              initialZoom: 11.0,
              minZoom: 4,
              maxZoom: 18,
              // Auto-frame the trail as soon as the map is ready.
              onMapReady: _fitToTrail,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && _followMode) {
                  setState(() => _followMode = false);
                  _positionStream?.cancel();
                }
                _currentZoom = pos.zoom;
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'com.path.app',
                maxZoom: 18,
              ),

              // Strava-style trail path (thick glowing orange/red line)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _getTrailPoints(_selectedRegion),
                    strokeWidth: 6.0,
                    color: const Color(0xFFFC6100), // Strava orange
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.white,
                  ),
                ],
              ),

              // User location blue dot (Google Maps style)
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    // Accuracy circle
                    Marker(
                      point: _userLocation!,
                      width: 80,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4285F4).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Blue dot
                    Marker(
                      point: _userLocation!,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF4285F4).withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Trail start / finish / checkpoint markers (trail only)
              MarkerLayer(
                markers: [
                  // Hiking checkpoints
                  ..._getTrailPoints(_selectedRegion).asMap().entries.map((entry) {
                    final idx = entry.key;
                    final pt = entry.value;
                    final isStart = idx == 0;
                    final isFinish = idx == _getTrailPoints(_selectedRegion).length - 1;

                    if (isStart || isFinish) {
                      return Marker(
                        point: pt,
                        width: 100,
                        height: 50,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isStart ? const Color(0xFFFC6100) : const Color(0xFFC62828),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white, width: 1),
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 1))
                                ],
                              ),
                              child: Text(
                                isStart ? 'Hike Start' : 'Hike Finish',
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Icon(isStart ? Icons.play_circle_fill_rounded : Icons.flag_rounded,
                                color: isStart ? const Color(0xFFFC6100) : const Color(0xFFC62828), size: 14),
                          ],
                        ),
                      );
                    }

                    return Marker(
                      point: pt,
                      width: 12,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFC6100), width: 2.5),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // ── Top: Search Bar (Google Maps-style floating pill) ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(Icons.search_rounded,
                        color: colors.textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search trails, places...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: colors.textSecondary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _searchFocusNode.unfocus();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                    // Layer toggle
                    _MiniControlButton(
                      icon: _layerIcon,
                      onTap: _cycleMapLayer,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),

          // ── Region Chips (below search bar) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 66,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _regions.length,
                itemBuilder: (context, index) {
                  final region = _regions[index];
                  final isSelected = _selectedRegion == region;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _onRegionChanged(region),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.terrain_rounded,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              region,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : colors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Search Autocomplete Dropdown overlay ──
          if (_searchQuery.isNotEmpty && searchResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 66,
              left: 16,
              right: 16,
              child: ClayContainer(
                borderRadius: 20,
                depth: 8,
                spread: 4,
                color: colors.surface,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      IconData iconData = Icons.location_on_rounded;
                      if (result.type == SearchResultType.region) {
                        iconData = Icons.terrain_rounded;
                      } else if (result.type == SearchResultType.trek) {
                        iconData = Icons.directions_walk_rounded;
                      }

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (result.type == SearchResultType.trek
                                    ? const Color(0xFFFC6100)
                                    : colors.primary)
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            iconData,
                            color: result.type == SearchResultType.trek
                                ? const Color(0xFFFC6100)
                                : colors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          result.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          result.subtitle,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        onTap: () {
                          _onRegionChanged(result.region);
                          if (result.center != null) {
                            _animatedMove(result.center!, 12.0);
                          }
                          _searchController.clear();
                          _searchFocusNode.unfocus();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

          // ── Left: Floating Offline Map button ──
          if (_isMapDownloaded)
            Positioned(
              left: 16,
              bottom: (_showWeatherSheet ? 300 : 130) + bottomPad,
              child: _OfflineMapFloatingButton(
                onTap: _openOfflineMapViewer,
              ),
            ),

          // ── Right: Floating Map Controls (Apple Maps-style / Strava layout) ──
          Positioned(
            right: 16,
            bottom: (_showWeatherSheet ? 300 : 130) + bottomPad,
            child: Column(
              children: [
                // Zoom in / out (Google & Apple Maps-style stacked control)
                _ZoomControl(
                  onZoomIn: () => _zoomBy(1.0),
                  onZoomOut: () => _zoomBy(-1.0),
                ),
                const SizedBox(height: 10),
                // Map layer toggle (standard / satellite / terrain)
                _FloatingMapButton(
                  icon: _layerIcon,
                  onTap: _cycleMapLayer,
                ),
                const SizedBox(height: 10),
                // Compass / Follow mode
                _FloatingMapButton(
                  icon: _followMode
                      ? Icons.navigation_rounded
                      : Icons.near_me_outlined,
                  isActive: _followMode,
                  onTap: _toggleFollowMode,
                  isLoading: _isLocating,
                ),
                const SizedBox(height: 10),
                // Navigate to trail
                _FloatingMapButton(
                  icon: Icons.directions_walk_rounded,
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    // Resolve database trek ID dynamically for this region before navigating
                    String actualTrekId = _selectedRegion;
                    if (treks.isNotEmpty) {
                      final matchingTrek = treks.firstWhere(
                        (t) => t.region.toLowerCase() == _selectedRegion.toLowerCase(),
                        orElse: () => treks.first,
                      );
                      actualTrekId = matchingTrek.id;
                    }
                    context.push('/map-weather/navigator', extra: actualTrekId);
                  },
                  accentColor: colors.primary,
                ),
              ],
            ),
          ),

          // ── Bottom: Weather Sheet (Google Maps-style bottom card) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -5) {
                  setState(() => _showWeatherSheet = true);
                } else if (details.primaryDelta! > 5) {
                  setState(() => _showWeatherSheet = false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                height: _showWeatherSheet ? 290 + bottomPad : 120 + bottomPad,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
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
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.background
                            : const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Region info + weather summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: weatherAsync.when(
                        loading: () => _WeatherSummaryRow(
                          region: _selectedRegion,
                          altitude: _regionAltitudes[_selectedRegion] ?? '',
                          temp: '--',
                          condition: 'loading',
                        ),
                        error: (_, __) => _WeatherSummaryRow(
                          region: _selectedRegion,
                          altitude: _regionAltitudes[_selectedRegion] ?? '',
                          temp: '--',
                          condition: 'offline',
                        ),
                        data: (report) => _WeatherSummaryRow(
                          region: report.region.isNotEmpty
                              ? report.region
                              : _selectedRegion,
                          altitude: _regionAltitudes[_selectedRegion] ?? '',
                          temp: report.temperature,
                          condition: report.condition,
                          description: report.description,
                          advisory: report.advisory,
                        ),
                      ),
                    ),

                    if (_showWeatherSheet) ...[
                      const SizedBox(height: 16),
                      // Expanded: Forecast + metrics
                      Expanded(
                        child: weatherAsync.when(
                          loading: () => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            ),
                          ),
                          error: (_, __) => Center(
                            child: Text(
                              'Weather data unavailable',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          data: (report) => _ExpandedWeatherPanel(
                            report: report,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Floating Offline Map Button (Claymorphic)
// ─────────────────────────────────────────
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
            const Icon(Icons.fullscreen_rounded, size: 18, color: LightColors.trailGreen),
            const SizedBox(width: 8),
            Text(
              'Full Map',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'SpaceGrotesk',
                color: isDark ? Colors.white : LightColors.summitDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Full-Screen Trail Map (real interactive map)
// ─────────────────────────────────────────
class _FullScreenTrailMap extends StatefulWidget {
  final String regionName;
  final List<LatLng> trailPoints;
  final String tileUrl;

  const _FullScreenTrailMap({
    required this.regionName,
    required this.trailPoints,
    required this.tileUrl,
  });

  @override
  State<_FullScreenTrailMap> createState() => _FullScreenTrailMapState();
}

class _FullScreenTrailMapState extends State<_FullScreenTrailMap> {
  final MapController _controller = MapController();

  void _fit() {
    if (widget.trailPoints.length < 2) return;
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: widget.trailPoints,
        padding: const EdgeInsets.fromLTRB(40, 110, 40, 60),
        maxZoom: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final start = widget.trailPoints.first;
    final end = widget.trailPoints.last;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Real interactive map of the trail
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.trailPoints[widget.trailPoints.length ~/ 2],
              initialZoom: 11,
              minZoom: 4,
              maxZoom: 18,
              onMapReady: _fit,
              interactionOptions:
                  const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: widget.tileUrl,
                userAgentPackageName: 'com.path.app',
                maxZoom: 18,
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.trailPoints,
                    strokeWidth: 6,
                    color: const Color(0xFFFC6100),
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: start,
                    width: 28,
                    height: 28,
                    child: const Icon(Icons.play_circle_fill_rounded,
                        color: Color(0xFFFC6100), size: 28),
                  ),
                  Marker(
                    point: end,
                    width: 28,
                    height: 28,
                    child: const Icon(Icons.flag_circle_rounded,
                        color: Color(0xFFC62828), size: 28),
                  ),
                ],
              ),
            ],
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
                      color: Colors.black.withValues(alpha: 0.5),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      '${widget.regionName} Trail — Full Map',
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
                const SizedBox(width: 10),
                // Re-fit to trail
                GestureDetector(
                  onTap: _fit,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.center_focus_strong_rounded,
                      size: 20,
                      color: Colors.white,
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
                  Icon(Icons.route_rounded, color: Color(0xFFFC6100), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pinch, drag and zoom the live trail map. Tap the focus icon to re-center on the route.',
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

// ─────────────────────────────────────────
// Mini control button (inside search bar)
// ─────────────────────────────────────────
class _MiniControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkColors.undergrowth : LightColors.surface90;
    final iconColor = isDark ? Colors.white70 : LightColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Zoom Control (Google / Apple Maps-style stacked +/-)
// ─────────────────────────────────────────
class _ZoomControl extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomControl({required this.onZoomIn, required this.onZoomOut});

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
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.add_rounded, color: iconColor, onTap: onZoomIn),
          Container(height: 1, width: 22, color: divider),
          _ZoomButton(
            icon: Icons.remove_rounded,
            color: iconColor,
            onTap: onZoomOut,
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ZoomButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Floating Map Button (Apple Maps-style)
// ─────────────────────────────────────────
class _FloatingMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isLoading;
  final Color? accentColor;

  const _FloatingMapButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isLoading = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = accentColor != null
        ? accentColor!
        : isActive
            ? const Color(0xFF4285F4)
            : (isDark ? DarkColors.deepCanopy : Colors.white);
    final iconColor = (accentColor != null || isActive)
        ? Colors.white
        : (isDark ? DarkColors.bioluminescent : LightColors.textPrimary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Weather Summary Row (compact bottom card)
// ─────────────────────────────────────────
class _WeatherSummaryRow extends StatelessWidget {
  final String region;
  final String altitude;
  final String temp;
  final String condition;
  final String? description;
  final String? advisory;

  const _WeatherSummaryRow({
    required this.region,
    required this.altitude,
    required this.temp,
    required this.condition,
    this.description,
    this.advisory,
  });

  IconData _conditionIcon(String c) {
    switch (c) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'rain':
        return Icons.water_drop_rounded;
      case 'storm':
        return Icons.thunderstorm_rounded;
      case 'wind':
        return Icons.air_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }

  Color _conditionColor(String c) {
    switch (c) {
      case 'clear':
        return const Color(0xFFF59E0B);
      case 'snow':
        return const Color(0xFF5B8DB8);
      case 'rain':
        return const Color(0xFF5B8DB8);
      case 'storm':
        return const Color(0xFFE63946);
      default:
        return const Color(0xFF999999);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DarkColors.bioluminescent : LightColors.summitDark;
    final textSecondary = isDark ? Colors.white70 : LightColors.textSecondary;
    final textTertiary = isDark ? Colors.white38 : LightColors.textTertiary;

    return Row(
      children: [
        // Weather icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _conditionColor(condition).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_conditionIcon(condition),
              size: 22, color: _conditionColor(condition)),
        ),
        const SizedBox(width: 14),
        // Region info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                region,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  fontFamily: 'SpaceGrotesk',
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description ?? 'Loading weather...',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'PlusJakartaSans',
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Temperature
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              temp,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'SpaceGrotesk',
                color: textPrimary,
              ),
            ),
            Text(
              altitude,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Expanded Weather Panel
// ─────────────────────────────────────────
class _ExpandedWeatherPanel extends StatelessWidget {
  final WeatherReport report;

  const _ExpandedWeatherPanel({required this.report});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DarkColors.bioluminescent : LightColors.textPrimary;
    final textSecondary = isDark ? Colors.white70 : LightColors.textSecondary;
    final containerColor = isDark ? DarkColors.undergrowth : LightColors.primaryLight;
    final advisoryTextColor = isDark ? Colors.white : LightColors.summitDark;
    final advisoryIconColor = isDark ? DarkColors.bioluminescent : LightColors.forestPrimary;
    final forecastBgColor = isDark ? DarkColors.undergrowth : LightColors.surface95;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics row
          Row(
            children: [
              _WeatherMetric(
                  icon: Icons.air_rounded,
                  value: report.windSpeed,
                  label: 'Wind'),
              _WeatherMetric(
                  icon: Icons.water_drop_outlined,
                  value: report.humidity,
                  label: 'Humidity'),
              _WeatherMetric(
                  icon: Icons.compress_rounded,
                  value: report.pressure,
                  label: 'Pressure'),
              _WeatherMetric(
                  icon: Icons.wb_sunny_outlined,
                  value: report.uvIndex,
                  label: 'UV'),
            ],
          ),
          const SizedBox(height: 14),

          // Advisory
          if (report.advisory.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: advisoryIconColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.advisory,
                      style: TextStyle(
                        fontSize: 12,
                        color: advisoryTextColor,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),

          // 5-day forecast
          if (report.forecast.isNotEmpty) ...[
            Text(
              'Forecast',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'SpaceGrotesk',
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: report.forecast.length,
                itemBuilder: (context, index) {
                  final day = report.forecast[index];
                  return Container(
                    width: 64,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: forecastBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.day,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          _conditionIcon(day.condition),
                          size: 18,
                          color: textPrimary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.tempMinMax,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _conditionIcon(String c) {
    switch (c) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'rain':
        return Icons.water_drop_rounded;
      case 'storm':
        return Icons.thunderstorm_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }
}

// ─────────────────────────────────────────
// Weather Metric Chip
// ─────────────────────────────────────────
class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : LightColors.textPrimary;
    final textSecondary = isDark ? Colors.white70 : LightColors.textSecondary;
    final textTertiary = isDark ? Colors.white38 : LightColors.textTertiary;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: textSecondary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              fontFamily: 'SpaceGrotesk',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    );
  }
}

// ─────────────────────────────────────────
// Search Result Entities
// ─────────────────────────────────────────
enum SearchResultType { region, trek, checkpoint }

class SearchResult {
  final String title;
  final String subtitle;
  final String region;
  final SearchResultType type;
  final LatLng? center;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.region,
    required this.type,
    this.center,
  });
}

