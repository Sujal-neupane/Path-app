import '../entities/itinerary.dart';

/// Repository contract for custom trekking itineraries
///
/// Core responsibility: Abstract the data layer. Implementation handles
/// API calls, caching, and offline fallback.
///
/// Pattern: Offline-first
/// - READ: Cache first → on miss/expire → API → update cache
/// - WRITE: API always → cache update immediately
/// - FALLBACK: Use stale cache if network unavailable
abstract class ItineraryRepository {
  /// Get all custom itineraries for current user
  ///
  /// Returns cached data if available and not expired.
  /// Falls back to stale cache if network unavailable.
  Future<List<Itinerary>> getUserItineraries();

  /// Get single itinerary by ID
  /// 
  /// Full itinerary with all days populated.
  Future<Itinerary> getItineraryById(String itineraryId);

  /// Create a new custom itinerary from a trek
  ///
  /// Generates itinerary by applying acclimatization logic to trek route.
  /// Returns the created itinerary with auto-generated days.
  ///
  /// Params:
  ///   - trekId: Trek to base itinerary on
  ///   - acclimatizationPreference: 'none', 'modest', 'aggressive'
  ///   - startDate: Optional start date
  Future<Itinerary> createItinerary({
    required String trekId,
    required String acclimatizationPreference,
    DateTime? startDate,
  });

  /// Update an existing itinerary
  ///
  /// Allows user to modify days, acclimatization, notes.
  /// Only certain fields are editable by user (days[], notes, startDate).
  /// Recomputes metrics (totalElevationGainM, etc.) automatically.
  Future<Itinerary> updateItinerary({
    required String itineraryId,
    required Map<String, dynamic> updates,
  });

  /// Delete an itinerary
  Future<bool> deleteItinerary(String itineraryId);

  /// Set an itinerary as the active one (user starts this trek)
  ///
  /// Only one itinerary can be active per user.
  /// Deactivates previous active if exists.
  Future<Itinerary> setActiveItinerary(String itineraryId);

  /// Get the currently active itinerary (if user is on a trek)
  ///
  /// Returns null if no active itinerary.
  Future<Itinerary?> getActiveItinerary();

  /// Get previous day progress (for the active itinerary)
  ///
  /// Timestamp of when user completed previous day.
  /// Used to calculate progress, stats, etc.
  Future<DateTime?> getLastCompletedDayDate(String itineraryId);

  /// Mark a day as completed
  ///
  /// Logs completion timestamp for tracking progress.
  Future<bool> completeDayInItinerary({
    required String itineraryId,
    required int dayNumber,
  });

  /// Search/filter user's itineraries
  ///
  /// Filter by trek name, difficulty, date range.
  Future<List<Itinerary>> searchItineraries({
    String? query,
    String? difficultyFilter,
    DateTime? afterDate,
  });

  /// Cache the itinerary locally for offline access
  ///
  /// Stores full itinerary including route data for offline viewing.
  Future<bool> cacheItineraryForOffline(String itineraryId);

  /// Get all locally cached itineraries available for offline
  Future<List<Itinerary>> getOfflineItineraries();

  /// Clear offline cache for an itinerary
  Future<bool> clearOfflineItinerary(String itineraryId);
}
