import 'route_point.dart';

/// Complete trek/expedition entity
/// 
/// Represents a full trekking expedition with route,
/// difficulty, duration, and all waypoints.
/// 
/// Follows clean architecture domain pattern:
/// - Independent of framework/UI
/// - Contains business logic
/// - Uses value objects for immutability
class Trek {
  /// Unique trek identifier
  final String id;

  /// Trek name (e.g., "Nepal Everest Base Camp")
  final String name;

  /// Location/region (e.g., "Nepal", "Himalaya")
  final String location;

  /// Detailed description
  final String description;

  /// Total distance in kilometers
  final double totalDistance;

  /// Total elevation gain in meters
  final double totalElevationGain;

  /// Maximum altitude reached in meters
  final double maxAltitude;

  /// Estimated duration in days
  final int estimatedDays;

  /// Difficulty rating: 'easy', 'moderate', 'challenging', 'expert'
  final String difficultyRating;

  /// Best season to trek: 'spring', 'summer', 'autumn', 'winter'
  final String bestSeason;

  /// Ordered list of waypoints/checkpoints along the route
  final List<RoutePoint> routePoints;

  /// Path to route file for offline use (GPX/GeoJSON)
  final String? routeDataPath;

  /// Permits required (comma-separated list)
  final String? permitsRequired;

  /// Created timestamp (ISO 8601)
  final String createdAt;

  /// Last updated timestamp (ISO 8601)
  final String updatedAt;

  /// User who created this trek
  final String createdBy;

  /// Is this trek official/verified?
  final bool isOfficial;

  /// Number of people who have completed this trek
  final int completionCount;

  /// Average rating (1-5 stars)
  final double averageRating;

  Trek({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.totalDistance,
    required this.totalElevationGain,
    required this.maxAltitude,
    required this.estimatedDays,
    required this.difficultyRating,
    required this.bestSeason,
    required this.routePoints,
    this.routeDataPath,
    this.permitsRequired,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isOfficial = false,
    this.completionCount = 0,
    this.averageRating = 0.0,
  });

  /// Calculate pace (km/day)
  double get paceKmPerDay => totalDistance / estimatedDays;

  /// Calculate elevation per day
  double get elevationPerDay => totalElevationGain / estimatedDays;

  /// Check if trek has route data for offline use
  bool get hasOfflineRoute => routeDataPath != null && routeDataPath!.isNotEmpty;

  /// Get first waypoint (start of trek)
  RoutePoint? get startPoint => routePoints.isEmpty ? null : routePoints.first;

  /// Get last waypoint (end of trek)
  RoutePoint? get endPoint => routePoints.isEmpty ? null : routePoints.last;

  @override
  String toString() {
    return 'Trek(id: $id, name: $name, distance: $totalDistance km, days: $estimatedDays, difficulty: $difficultyRating)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trek &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
