import 'package:equatable/equatable.dart';
import 'route_point.dart';

/// Represents a single day in a custom trekking itinerary
///
/// Core responsibility: Encapsulate a day's trekking plan with location, 
/// distance, elevation, and safety metadata.
///
/// Example:
/// ```
/// Day 1: Kathmandu (1400m) → Bhagwati (2100m)
/// - Distance: 18 km
/// - Elevation gain: 700m
/// - Duration: 6 hours
/// - Acclimatization: false (travel day)
/// - AMS Risk: Low
/// ```
class ItineraryDay extends Equatable {
  /// Day number (1-indexed)
  final int dayNumber;

  /// Display name: "Day 1: Kathmandu → Namche"
  final String displayName;

  /// Starting location
  final String startLocation;

  /// Ending location
  final String endLocation;

  /// Distance in kilometers
  final double distanceKm;

  /// Elevation gain in meters
  final int elevationGainM;

  /// Elevation loss in meters (0 if only gain)
  final int elevationLossM;

  /// Starting altitude in meters
  final int startAltitudeM;

  /// Ending altitude in meters
  final int endAltitudeM;

  /// Estimated trekking time in hours
  final double estimatedHours;

  /// Is this an acclimatization/rest day
  final bool isAcclimatizationDay;

  /// Route waypoints for this day
  final List<RoutePoint> waypoints;

  /// AMS Risk level: 'low', 'moderate', 'high'
  /// Based on altitude gain and daily ascent rate
  final String altitudeRiskLevel;

  /// Optional notes/description
  final String? notes;

  /// Difficulty: 'easy', 'moderate', 'difficult'
  final String difficulty;

  /// Whether terrain has rock/snow (technical)
  final bool isTechnical;

  const ItineraryDay({
    required this.dayNumber,
    required this.displayName,
    required this.startLocation,
    required this.endLocation,
    required this.distanceKm,
    required this.elevationGainM,
    required this.elevationLossM,
    required this.startAltitudeM,
    required this.endAltitudeM,
    required this.estimatedHours,
    required this.isAcclimatizationDay,
    required this.waypoints,
    required this.altitudeRiskLevel,
    this.notes,
    required this.difficulty,
    required this.isTechnical,
  });

  /// Altitude gain rate (meters per hour) - used for AMS assessment
  double get ascendRatePerHour =>
      elevationGainM / (estimatedHours > 0 ? estimatedHours : 1);

  /// Whether this day has high altitude risk (gain >500m or final alt >3800m)
  bool get hasHighAltitudeRisk =>
      elevationGainM > 500 || endAltitudeM > 3800;

  /// Expected calories burn (rough estimate: 400 cal/hour * terrain factor)
  int get estimatedCalories {
    final baseCals = (estimatedHours * 400).toInt();
    if (isTechnical) return (baseCals * 1.3).toInt();
    return baseCals;
  }

  /// Format: "Day 1 (18km, 700m↑)"
  String get summaryLabel =>
      'Day $dayNumber (${distanceKm.toStringAsFixed(1)}km, '
      '${elevationGainM}m↑)';

  @override
  List<Object?> get props => [
        dayNumber,
        displayName,
        startLocation,
        endLocation,
        distanceKm,
        elevationGainM,
        elevationLossM,
        startAltitudeM,
        endAltitudeM,
        estimatedHours,
        isAcclimatizationDay,
        waypoints,
        altitudeRiskLevel,
        notes,
        difficulty,
        isTechnical,
      ];
}
