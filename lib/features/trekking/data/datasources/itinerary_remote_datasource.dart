import '../models/itinerary_model.dart';

/// Contract for remote itinerary data source (API)
///
/// Responsible for all HTTP calls to backend API.
/// Does NOT handle caching (that's local datasource).
/// Does handle error conversion to app exceptions.
abstract class ItineraryRemoteDataSource {
  /// Fetch all itineraries for current user
  Future<List<ItineraryModel>> getUserItineraries();

  /// Fetch single itinerary with all days
  Future<ItineraryModel> getItineraryById(String itineraryId);

  /// Create new itinerary from trek
  ///
  /// Backend applies acclimatization logic and returns complete itinerary.
  Future<ItineraryModel> createItinerary({
    required String trekId,
    required String acclimatizationPreference,
    DateTime? startDate,
  });

  /// Update itinerary (days, notes, etc.)
  Future<ItineraryModel> updateItinerary({
    required String itineraryId,
    required Map<String, dynamic> updates,
  });

  /// Delete itinerary
  Future<bool> deleteItinerary(String itineraryId);

  /// Set as active itinerary
  Future<ItineraryModel> setActiveItinerary(String itineraryId);

  /// Get currently active itinerary
  Future<ItineraryModel?> getActiveItinerary();

  /// Get last completed day date
  Future<DateTime?> getLastCompletedDayDate(String itineraryId);

  /// Mark day as completed
  Future<bool> completeDayInItinerary({
    required String itineraryId,
    required int dayNumber,
  });

  /// Search itineraries
  Future<List<ItineraryModel>> searchItineraries({
    String? query,
    String? difficultyFilter,
    DateTime? afterDate,
  });
}
