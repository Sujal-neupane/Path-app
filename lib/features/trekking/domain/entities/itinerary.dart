import 'package:equatable/equatable.dart';
import 'itinerary_day.dart';

/// Custom trekking itinerary created by merging a Trek with acclimatization logic
///
/// Core responsibility: Represent a complete, editable day-by-day plan.
/// User can view, adjust rest days, split/combine days per preferences.
///
/// Example:
/// ```
/// Everest Base Camp (13 days)
/// - Day 1-2: Kathmandu
/// - Day 3: Phaplu → Phaplu (rest)
/// - Day 4-5: Climbing section (high altitude risk)
/// - Day 6: Acclimatization at Namche
/// ...
/// ```
///
/// This differs from Trek (which is the published route) - this is the USER'S
/// custom plan created after selecting a trek and choosing acclimatization.
class Itinerary extends Equatable {
  /// Unique identifier for this custom itinerary
  final String id;

  /// Reference to the original trek this itinerary is based on
  final String trekId;

  /// User who created this itinerary
  final String userId;

  /// Display name: "Everest Base Camp (Custom Plan)"
  final String name;

  /// Total planned days (including acclimatization)
  final int totalDays;

  /// Ordered list of days
  final List<ItineraryDay> days;

  /// When was this itinerary created
  final DateTime createdAt;

  /// When was this last edited
  final DateTime updatedAt;

  /// Is this the active itinerary (started trekking)?
  final bool isActive;

  /// Starting date for this trek
  final DateTime? startDate;

  /// Notes about the custom plan
  final String? notes;

  /// Total distance for entire trek (km)
  final double totalDistanceKm;

  /// Total elevation gain across all days
  final int totalElevationGainM;

  /// Average difficulty
  final String difficultyLevel;

  const Itinerary({
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

  /// Get a specific day by number (1-indexed)
  ItineraryDay? getDayByNumber(int dayNumber) {
    try {
      return days.firstWhere((d) => d.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }

  /// Acclimatization days count
  int get acclimatizationDaysCount =>
      days.where((d) => d.isAcclimatizationDay).length;

  /// Active trekking days count
  int get activeTrekkingDaysCount => totalDays - acclimatizationDaysCount;

  /// Days with high altitude risk
  List<ItineraryDay> get highAltitudeRiskDays =>
      days.where((d) => d.hasHighAltitudeRisk).toList();

  /// Whether itinerary has any high-risk altitude days
  bool get hasAltitudeRisk => highAltitudeRiskDays.isNotEmpty;

  /// Average daily distance (km)
  double get averageDailyDistanceKm =>
      totalDistanceKm / (activeTrekkingDaysCount > 0 ? activeTrekkingDaysCount : 1);

  /// Average daily elevation gain (meters)
  int get averageDailyElevationGainM =>
      totalElevationGainM ~/ (activeTrekkingDaysCount > 0 ? activeTrekkingDaysCount : 1);

  /// Is trek acclimatization-friendly (accl days >= 25% of trek)
  bool get hasGoodAcclimatization =>
      (acclimatizationDaysCount / totalDays) >= 0.25;

  /// Create a modified copy of this itinerary
  Itinerary copyWith({
    String? id,
    String? trekId,
    String? userId,
    String? name,
    int? totalDays,
    List<ItineraryDay>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    DateTime? startDate,
    String? notes,
    double? totalDistanceKm,
    int? totalElevationGainM,
    String? difficultyLevel,
  }) {
    return Itinerary(
      id: id ?? this.id,
      trekId: trekId ?? this.trekId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalDays: totalDays ?? this.totalDays,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalElevationGainM: totalElevationGainM ?? this.totalElevationGainM,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trekId,
        userId,
        name,
        totalDays,
        days,
        createdAt,
        updatedAt,
        isActive,
        startDate,
        notes,
        totalDistanceKm,
        totalElevationGainM,
        difficultyLevel,
      ];
}
