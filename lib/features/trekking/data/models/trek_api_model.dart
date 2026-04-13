import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/route_point.dart';
import '../../domain/entities/trek.dart';

part 'trek_api_model.g.dart';

/// API model for route waypoint
/// 
/// Deserialized from backend JSON, then converted to domain entity
@JsonSerializable()
class RoutePointApiModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  @JsonKey(name: 'altitude')
  final double altitude;

  @JsonKey(name: 'distanceFromStart')
  final double distanceFromStart;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'estimatedHoursFromStart')
  final double estimatedHoursFromStart;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'difficultyLevel')
  final String difficultyLevel;

  @JsonKey(name: 'isHazardZone')
  final bool isHazardZone;

  @JsonKey(name: 'hazardDescription')
  final String? hazardDescription;

  RoutePointApiModel({
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

  factory RoutePointApiModel.fromJson(Map<String, dynamic> json) =>
      _$RoutePointApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePointApiModelToJson(this);

  /// Convert API model to domain entity
  RoutePoint toDomain() {
    return RoutePoint(
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
  }
}

/// API model for full trek
/// 
/// Represents trek data from backend API
/// Includes all route points and metadata
@JsonSerializable()
class TrekApiModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'location')
  final String location;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'totalDistance')
  final double totalDistance;

  @JsonKey(name: 'totalElevationGain')
  final double totalElevationGain;

  @JsonKey(name: 'maxAltitude')
  final double maxAltitude;

  @JsonKey(name: 'estimatedDays')
  final int estimatedDays;

  @JsonKey(name: 'difficultyRating')
  final String difficultyRating;

  @JsonKey(name: 'bestSeason')
  final String bestSeason;

  @JsonKey(name: 'routePoints')
  final List<RoutePointApiModel> routePoints;

  @JsonKey(name: 'routeDataPath')
  final String? routeDataPath;

  @JsonKey(name: 'permitsRequired')
  final String? permitsRequired;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  @JsonKey(name: 'createdBy')
  final String createdBy;

  @JsonKey(name: 'isOfficial')
  final bool isOfficial;

  @JsonKey(name: 'completionCount')
  final int completionCount;

  @JsonKey(name: 'averageRating')
  final double averageRating;

  TrekApiModel({
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

  factory TrekApiModel.fromJson(Map<String, dynamic> json) =>
      _$TrekApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrekApiModelToJson(this);

  /// Convert API model to domain entity
  Trek toDomain() {
    return Trek(
      id: id,
      name: name,
      location: location,
      description: description,
      totalDistance: totalDistance,
      totalElevationGain: totalElevationGain,
      maxAltitude: maxAltitude,
      estimatedDays: estimatedDays,
      difficultyRating: difficultyRating,
      bestSeason: bestSeason,
      routePoints: routePoints.map((p) => p.toDomain()).toList(),
      routeDataPath: routeDataPath,
      permitsRequired: permitsRequired,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      isOfficial: isOfficial,
      completionCount: completionCount,
      averageRating: averageRating,
    );
  }
}

/// API response wrapper for paginated trek list
@JsonSerializable()
class TrekListApiResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'data')
  final List<TrekApiModel> data;

  @JsonKey(name: 'total')
  final int total;

  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'pageSize')
  final int pageSize;

  @JsonKey(name: 'totalPages')
  final int totalPages;

  TrekListApiResponse({
    required this.success,
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory TrekListApiResponse.fromJson(Map<String, dynamic> json) =>
      _$TrekListApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrekListApiResponseToJson(this);
}
