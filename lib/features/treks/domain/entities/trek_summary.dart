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
  });
}
