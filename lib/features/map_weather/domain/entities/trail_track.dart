import 'package:latlong2/latlong.dart';

/// A single GPS point on a trail.
class TrailGpsPoint {
  final double lat;
  final double lng;
  final double alt;
  final String? name;

  const TrailGpsPoint({
    required this.lat,
    required this.lng,
    required this.alt,
    this.name,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory TrailGpsPoint.fromJson(Map<String, dynamic> json) {
    return TrailGpsPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      alt: (json['alt'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'alt': alt,
    if (name != null) 'name': name,
  };
}

/// A complete trail track containing the polyline and named waypoints.
class TrailTrack {
  final String trekId;
  final String title;
  final String region;
  final List<TrailGpsPoint> waypoints; // Named checkpoints
  final List<TrailGpsPoint> trail; // Full polyline

  const TrailTrack({
    required this.trekId,
    required this.title,
    required this.region,
    required this.waypoints,
    required this.trail,
  });

  List<LatLng> get polyline => trail.map((p) => p.latLng).toList();
  List<LatLng> get waypointPositions => waypoints.map((p) => p.latLng).toList();

  /// Center point of the trail for initial map positioning.
  LatLng get center {
    if (trail.isEmpty) return const LatLng(27.9, 86.9); // Default Everest
    final avgLat = trail.map((p) => p.lat).reduce((a, b) => a + b) / trail.length;
    final avgLng = trail.map((p) => p.lng).reduce((a, b) => a + b) / trail.length;
    return LatLng(avgLat, avgLng);
  }

  /// Max altitude on the trail.
  double get maxAltitude {
    if (trail.isEmpty) return 0;
    return trail.map((p) => p.alt).reduce((a, b) => a > b ? a : b);
  }

  /// Min altitude on the trail.
  double get minAltitude {
    if (trail.isEmpty) return 0;
    return trail.map((p) => p.alt).reduce((a, b) => a < b ? a : b);
  }

  factory TrailTrack.fromJson(Map<String, dynamic> json) {
    return TrailTrack(
      trekId: json['trekId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      region: json['region'] as String? ?? '',
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((e) => TrailGpsPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trail: (json['trail'] as List<dynamic>?)
              ?.map((e) => TrailGpsPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
