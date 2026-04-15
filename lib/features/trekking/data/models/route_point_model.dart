import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/route_point.dart';

part 'route_point_model.g.dart';

/// API model for route waypoint
///
/// Maps JSON from backend API ↔ Dart objects.
/// Includes conversion to domain entity.
@JsonSerializable()
class RoutePointModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double altitude;
  final double distanceFromStart;
  final String type;
  final double estimatedHoursFromStart;
  final String? description;
  final String difficultyLevel;
  final bool isHazardZone;
  final String? hazardDescription;

  const RoutePointModel({
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
    required this.isHazardZone,
    this.hazardDescription,
  });

  factory RoutePointModel.fromJson(Map<String, dynamic> json) =>
      _$RoutePointModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePointModelToJson(this);

  /// Convert to domain entity
  RoutePoint toDomain() => RoutePoint(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        distanceFromStart: distanceFromStart,
        type: type,
        estimatedHoursFromStart: estimatedHoursFromStart,
        description: description,
        difficultyLevel: difficultyLevel,
        isHazardZone: isHazardZone,
        hazardDescription: hazardDescription,
      );

  /// Create from domain entity
  factory RoutePointModel.fromDomain(RoutePoint point) => RoutePointModel(
        id: point.id,
        name: point.name,
        latitude: point.latitude,
        longitude: point.longitude,
        altitude: point.altitude,
        distanceFromStart: point.distanceFromStart,
        type: point.type,
        estimatedHoursFromStart: point.estimatedHoursFromStart,
        description: point.description,
        difficultyLevel: point.difficultyLevel,
        isHazardZone: point.isHazardZone,
        hazardDescription: point.hazardDescription,
      );
}
