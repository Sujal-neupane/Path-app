import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/itinerary_day.dart';
import 'route_point_model.dart';

part 'itinerary_day_model.g.dart';

/// API model for a single day in trekking itinerary
///
/// Maps JSON from backend API ↔ Dart objects.
/// Includes conversion to domain entity.
@JsonSerializable()
class ItineraryDayModel {
  final int dayNumber;
  final String displayName;
  final String startLocation;
  final String endLocation;
  final double distanceKm;
  final int elevationGainM;
  final int elevationLossM;
  final int startAltitudeM;
  final int endAltitudeM;
  final double estimatedHours;
  final bool isAcclimatizationDay;
  final List<RoutePointModel> waypoints;
  final String altitudeRiskLevel;
  final String? notes;
  final String difficulty;
  final bool isTechnical;

  const ItineraryDayModel({
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

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDayModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryDayModelToJson(this);

  /// Convert to domain entity
  ItineraryDay toDomain() => ItineraryDay(
        dayNumber: dayNumber,
        displayName: displayName,
        startLocation: startLocation,
        endLocation: endLocation,
        distanceKm: distanceKm,
        elevationGainM: elevationGainM,
        elevationLossM: elevationLossM,
        startAltitudeM: startAltitudeM,
        endAltitudeM: endAltitudeM,
        estimatedHours: estimatedHours,
        isAcclimatizationDay: isAcclimatizationDay,
        waypoints: waypoints.map((w) => w.toDomain()).toList(),
        altitudeRiskLevel: altitudeRiskLevel,
        notes: notes,
        difficulty: difficulty,
        isTechnical: isTechnical,
      );

  /// Create from domain entity
  factory ItineraryDayModel.fromDomain(ItineraryDay day) => ItineraryDayModel(
        dayNumber: day.dayNumber,
        displayName: day.displayName,
        startLocation: day.startLocation,
        endLocation: day.endLocation,
        distanceKm: day.distanceKm,
        elevationGainM: day.elevationGainM,
        elevationLossM: day.elevationLossM,
        startAltitudeM: day.startAltitudeM,
        endAltitudeM: day.endAltitudeM,
        estimatedHours: day.estimatedHours,
        isAcclimatizationDay: day.isAcclimatizationDay,
        waypoints: day.waypoints.map(RoutePointModel.fromDomain).toList(),
        altitudeRiskLevel: day.altitudeRiskLevel,
        notes: day.notes,
        difficulty: day.difficulty,
        isTechnical: day.isTechnical,
      );
}
