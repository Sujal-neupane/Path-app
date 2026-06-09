import 'package:path_app/features/treks/domain/entities/itinerary_step.dart';

class TrekSummary {
  final String id;
  final String name;
  final String region;
  final String difficulty;
  final int durationDays;
  final int distanceKm;
  final int elevationGainM;
  final int maxAltitudeM;
  final double rating;
  final String bestSeason;
  final String shortDescription;
  final String longDescription;
  final List<String> highlights;
  final List<String> itinerary;
  final List<ItineraryStep> detailedItinerary;

  const TrekSummary({
    required this.id,
    required this.name,
    required this.region,
    required this.difficulty,
    required this.durationDays,
    required this.distanceKm,
    required this.elevationGainM,
    required this.maxAltitudeM,
    required this.rating,
    required this.bestSeason,
    required this.shortDescription,
    required this.longDescription,
    required this.highlights,
    required this.itinerary,
    required this.detailedItinerary,
  });

  /// Deserialize from backend API JSON response.
  /// Maps snake_case backend fields to camelCase Dart properties.
  factory TrekSummary.fromJson(Map<String, dynamic> json) {
    // Map backend difficulty values to display-friendly labels
    final difficultyRaw = (json['difficulty'] as String?) ?? 'moderate';
    final difficultyLabel = switch (difficultyRaw.toLowerCase()) {
      'easy' => 'Easy',
      'moderate' => 'Moderate',
      'hard' => 'Challenging',
      'extreme' => 'Extreme',
      _ => difficultyRaw,
    };

    // Parse checkpoints as detailed itinerary steps
    final checkpointsRaw = json['checkpoints'] as List<dynamic>? ?? [];
    final detailedSteps = checkpointsRaw
        .where((cp) =>
            cp is Map<String, dynamic> &&
            cp['day'] != null &&
            (cp['day'] as String).isNotEmpty)
        .map((cp) => ItineraryStep.fromJson(cp as Map<String, dynamic>))
        .toList();

    return TrekSummary(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['title'] as String? ?? '',
      region: json['region'] as String? ?? '',
      difficulty: difficultyLabel,
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
      distanceKm: (json['expected_distance_km'] as num?)?.toInt() ?? 0,
      elevationGainM: (json['expected_elevation_gain_m'] as num?)?.toInt() ?? 0,
      maxAltitudeM: (json['max_altitude_m'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      bestSeason: json['best_season'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      longDescription: json['long_description'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      itinerary: (json['itinerary_summary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      detailedItinerary: detailedSteps,
    );
  }

  /// Serialize to JSON for local caching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'region': region,
      'difficulty': difficulty.toLowerCase(),
      'duration_days': durationDays,
      'expected_distance_km': distanceKm,
      'expected_elevation_gain_m': elevationGainM,
      'max_altitude_m': maxAltitudeM,
      'rating': rating,
      'best_season': bestSeason,
      'short_description': shortDescription,
      'long_description': longDescription,
      'highlights': highlights,
      'itinerary_summary': itinerary,
      'checkpoints':
          detailedItinerary.map((step) => step.toJson()).toList(),
    };
  }
}
