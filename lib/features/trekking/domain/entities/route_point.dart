/// Individual waypoint/checkpoint on a trek route
/// 
/// Represents a specific location, camping site, or checkpoint
/// with GPS coordinates, altitude, and travel information
class RoutePoint {
  /// Unique identifier for this waypoint
  final String id;

  /// Name of the location (e.g., "Base Camp", "Tea House")
  final String name;

  /// GPS latitude coordinate
  final double latitude;

  /// GPS longitude coordinate
  final double longitude;

  /// Altitude in meters
  final double altitude;

  /// Distance from start in kilometers
  final double distanceFromStart;

  /// Type: 'checkpoint', 'camping', 'teahouse', 'viewpoint'
  final String type;

  /// Estimated time to reach this point (in hours)
  final double estimatedHoursFromStart;

  /// Optional description of the location
  final String? description;

  /// Difficulty level: 'easy', 'moderate', 'challenging'
  final String difficultyLevel;

  /// Is this a danger zone or hazard area?
  final bool isHazardZone;

  /// Optional hazard details (altitude sickness risk, wildlife, etc.)
  final String? hazardDescription;

  RoutePoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.distanceFromStart,
    required this.type,
    required this.estimatedHoursFromStart,
    this.description,
    required this.difficultyLevel,
    this.isHazardZone = false,
    this.hazardDescription,
  });

  @override
  String toString() {
    return 'RoutePoint(id: $id, name: $name, altitude: $altitude m, distance: $distanceFromStart km)';
  }
}
