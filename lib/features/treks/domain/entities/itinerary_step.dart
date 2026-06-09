class ItineraryStep {
  final String day;
  final String title;
  final String description;
  final int altitudeM;
  final String hikingTime;
  final String difficulty;
  final List<String> stays;
  final double? latitude;
  final double? longitude;

  const ItineraryStep({
    required this.day,
    required this.title,
    required this.description,
    required this.altitudeM,
    required this.hikingTime,
    required this.difficulty,
    required this.stays,
    this.latitude,
    this.longitude,
  });

  /// Deserialize from backend JSON (checkpoint format).
  factory ItineraryStep.fromJson(Map<String, dynamic> json) {
    return ItineraryStep(
      day: json['day'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      altitudeM: (json['altitude_m'] as num?)?.toInt() ?? 0,
      hikingTime: json['hiking_time'] as String? ?? '',
      difficulty: json['step_difficulty'] as String? ?? '',
      stays: (json['stays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Serialize to JSON for local caching.
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'description': description,
      'altitude_m': altitudeM,
      'hiking_time': hikingTime,
      'step_difficulty': difficulty,
      'stays': stays,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
