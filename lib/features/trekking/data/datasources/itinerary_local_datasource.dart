import '../models/itinerary_model.dart';

/// Contract for local itinerary data source (cache)
///
/// Responsible for SharedPreferences caching, offline storage.
/// Handles TTL validation, cache expiration.
abstract class ItineraryLocalDataSource {
  /// Cache user's itineraries list
  Future<void> cacheUserItineraries(List<ItineraryModel> itineraries);

  /// Get cached itineraries list
  ///
  /// Returns empty list if not cached or expired.
  Future<List<ItineraryModel>> getCachedUserItineraries();

  /// Cache a single itinerary
  Future<void> cacheItinerary(ItineraryModel itinerary);

  /// Get cached itinerary by ID
  ///
  /// Returns null if not cached or expired.
  Future<ItineraryModel?> getCachedItinerary(String itineraryId);

  /// Check if cache has expired
  ///
  /// Default TTL: 1 hour
  /// Custom TTL supported for specific keys.
  Future<bool> isCacheExpired({String? key, Duration? customTTL});

  /// Clear all cached itineraries
  Future<void> clearAllItineraryCache();

  /// Clear specific itinerary cache
  Future<void> clearItineraryCache(String itineraryId);

  /// Cache the active itinerary ID
  Future<void> cacheActiveItineraryId(String itineraryId);

  /// Get cached active itinerary ID
  Future<String?> getCachedActiveItineraryId();

  /// Save itinerary for offline access
  ///
  /// Stores complete itinerary data including route info.
  Future<void> saveOfflineItinerary(ItineraryModel itinerary);

  /// Get offline itineraries list
  Future<List<ItineraryModel>> getOfflineItineraries();

  /// Remove offline itinerary
  Future<void> removeOfflineItinerary(String itineraryId);

  /// Cache completion timestamp for a day
  Future<void> cacheDayCompletion({
    required String itineraryId,
    required int dayNumber,
    required DateTime completedAt,
  });

  /// Get cached day completion date
  Future<DateTime?> getCachedDayCompletion({
    required String itineraryId,
    required int dayNumber,
  });
}
