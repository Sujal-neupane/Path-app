// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trek_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePointApiModel _$RoutePointApiModelFromJson(Map<String, dynamic> json) =>
    RoutePointApiModel(
      id: json['_id'] as String,
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
      isHazardZone: json['isHazardZone'] as bool? ?? false,
      hazardDescription: json['hazardDescription'] as String?,
    );

Map<String, dynamic> _$RoutePointApiModelToJson(RoutePointApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
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

TrekApiModel _$TrekApiModelFromJson(Map<String, dynamic> json) => TrekApiModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  location: json['location'] as String,
  description: json['description'] as String,
  totalDistance: (json['totalDistance'] as num).toDouble(),
  totalElevationGain: (json['totalElevationGain'] as num).toDouble(),
  maxAltitude: (json['maxAltitude'] as num).toDouble(),
  estimatedDays: (json['estimatedDays'] as num).toInt(),
  difficultyRating: json['difficultyRating'] as String,
  bestSeason: json['bestSeason'] as String,
  routePoints: (json['routePoints'] as List<dynamic>)
      .map((e) => RoutePointApiModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  routeDataPath: json['routeDataPath'] as String?,
  permitsRequired: json['permitsRequired'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  createdBy: json['createdBy'] as String,
  isOfficial: json['isOfficial'] as bool? ?? false,
  completionCount: (json['completionCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$TrekApiModelToJson(TrekApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'description': instance.description,
      'totalDistance': instance.totalDistance,
      'totalElevationGain': instance.totalElevationGain,
      'maxAltitude': instance.maxAltitude,
      'estimatedDays': instance.estimatedDays,
      'difficultyRating': instance.difficultyRating,
      'bestSeason': instance.bestSeason,
      'routePoints': instance.routePoints,
      'routeDataPath': instance.routeDataPath,
      'permitsRequired': instance.permitsRequired,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'createdBy': instance.createdBy,
      'isOfficial': instance.isOfficial,
      'completionCount': instance.completionCount,
      'averageRating': instance.averageRating,
    };

TrekListApiResponse _$TrekListApiResponseFromJson(Map<String, dynamic> json) =>
    TrekListApiResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => TrekApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$TrekListApiResponseToJson(
  TrekListApiResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'total': instance.total,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
};
