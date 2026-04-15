import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/itinerary.dart';
import 'itinerary_day_model.dart';

part 'itinerary_model.g.dart';

/// API model for custom trekking itineraries
///
/// Maps JSON from backend API ↔ Dart objects.
/// Includes conversion to domain entity.
@JsonSerializable()
class ItineraryModel {
  final String id;
  final String trekId;
  final String userId;
  final String name;
  final int totalDays;
  final List<ItineraryDayModel> days;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final DateTime? startDate;
  final String? notes;
  final double totalDistanceKm;
  final int totalElevationGainM;
  final String difficultyLevel;

  const ItineraryModel({
    required this.id,
    required this.trekId,
    required this.userId,
    required this.name,
    required this.totalDays,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.startDate,
    this.notes,
    required this.totalDistanceKm,
    required this.totalElevationGainM,
    required this.difficultyLevel,
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryModelToJson(this);

  /// Convert to domain entity
  Itinerary toDomain() => Itinerary(
        id: id,
        trekId: trekId,
        userId: userId,
        name: name,
        totalDays: totalDays,
        days: days.map((d) => d.toDomain()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: isActive,
        startDate: startDate,
        notes: notes,
        totalDistanceKm: totalDistanceKm,
        totalElevationGainM: totalElevationGainM,
        difficultyLevel: difficultyLevel,
      );

  /// Create from domain entity
  factory ItineraryModel.fromDomain(Itinerary itinerary) => ItineraryModel(
        id: itinerary.id,
        trekId: itinerary.trekId,
        userId: itinerary.userId,
        name: itinerary.name,
        totalDays: itinerary.totalDays,
        days: itinerary.days.map(ItineraryDayModel.fromDomain).toList(),
        createdAt: itinerary.createdAt,
        updatedAt: itinerary.updatedAt,
        isActive: itinerary.isActive,
        startDate: itinerary.startDate,
        notes: itinerary.notes,
        totalDistanceKm: itinerary.totalDistanceKm,
        totalElevationGainM: itinerary.totalElevationGainM,
        difficultyLevel: itinerary.difficultyLevel,
      );
}
