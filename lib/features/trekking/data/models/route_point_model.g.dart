// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePointModel _$RoutePointModelFromJson(Map<String, dynamic> json) =>
    RoutePointModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      distanceFromStart: (json['distanceFromStart'] as num).toDouble(),
      type: json['type'] as String,
      estimatedHoursFromStart: (json['estimatedHoursFromStart'] as num)
          .toDouble(),
      description: json['description'] as String?,
      difficultyLevel: json['difficultyLevel'] as String,
      isHazardZone: json['isHazardZone'] as bool,
      hazardDescription: json['hazardDescription'] as String?,
    );

Map<String, dynamic> _$RoutePointModelToJson(RoutePointModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'distanceFromStart': instance.distanceFromStart,
      'type': instance.type,
      'estimatedHoursFromStart': instance.estimatedHoursFromStart,
      'description': instance.description,
      'difficultyLevel': instance.difficultyLevel,
      'isHazardZone': instance.isHazardZone,
      'hazardDescription': instance.hazardDescription,
    };
