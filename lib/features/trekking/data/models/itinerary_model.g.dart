// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryModel _$ItineraryModelFromJson(Map<String, dynamic> json) =>
    ItineraryModel(
      id: json['id'] as String,
      trekId: json['trekId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      totalDays: (json['totalDays'] as num).toInt(),
      days: (json['days'] as List<dynamic>)
          .map((e) => ItineraryDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      notes: json['notes'] as String?,
      totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
      totalElevationGainM: (json['totalElevationGainM'] as num).toInt(),
      difficultyLevel: json['difficultyLevel'] as String,
    );

Map<String, dynamic> _$ItineraryModelToJson(ItineraryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trekId': instance.trekId,
      'userId': instance.userId,
      'name': instance.name,
      'totalDays': instance.totalDays,
      'days': instance.days,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'startDate': instance.startDate?.toIso8601String(),
      'notes': instance.notes,
      'totalDistanceKm': instance.totalDistanceKm,
      'totalElevationGainM': instance.totalElevationGainM,
      'difficultyLevel': instance.difficultyLevel,
    };
