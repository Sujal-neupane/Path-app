// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_day_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryDayModel _$ItineraryDayModelFromJson(Map<String, dynamic> json) =>
    ItineraryDayModel(
      dayNumber: (json['dayNumber'] as num).toInt(),
      displayName: json['displayName'] as String,
      startLocation: json['startLocation'] as String,
      endLocation: json['endLocation'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      elevationGainM: (json['elevationGainM'] as num).toInt(),
      elevationLossM: (json['elevationLossM'] as num).toInt(),
      startAltitudeM: (json['startAltitudeM'] as num).toInt(),
      endAltitudeM: (json['endAltitudeM'] as num).toInt(),
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      isAcclimatizationDay: json['isAcclimatizationDay'] as bool,
      waypoints: (json['waypoints'] as List<dynamic>)
          .map((e) => RoutePointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      altitudeRiskLevel: json['altitudeRiskLevel'] as String,
      notes: json['notes'] as String?,
      difficulty: json['difficulty'] as String,
      isTechnical: json['isTechnical'] as bool,
    );

Map<String, dynamic> _$ItineraryDayModelToJson(ItineraryDayModel instance) =>
    <String, dynamic>{
      'dayNumber': instance.dayNumber,
      'displayName': instance.displayName,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
      'distanceKm': instance.distanceKm,
      'elevationGainM': instance.elevationGainM,
      'elevationLossM': instance.elevationLossM,
      'startAltitudeM': instance.startAltitudeM,
      'endAltitudeM': instance.endAltitudeM,
      'estimatedHours': instance.estimatedHours,
      'isAcclimatizationDay': instance.isAcclimatizationDay,
      'waypoints': instance.waypoints,
      'altitudeRiskLevel': instance.altitudeRiskLevel,
      'notes': instance.notes,
      'difficulty': instance.difficulty,
      'isTechnical': instance.isTechnical,
    };
