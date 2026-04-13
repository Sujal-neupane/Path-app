import '../entities/trek.dart';

/// Trekking repository interface
/// 
/// Defines contract for trek data operations:
/// - Fetch all treks
/// - Fetch specific trek (with route data)
/// - Create new trek
/// - Update trek
/// - Delete trek
/// - Search/filter treks
/// 
/// Implementation can use local DB, REST API, or both
abstract class TrekkingRepository {
  /// Fetch all available treks
  /// 
  /// Returns paginated list of treks
  /// Throws [NetworkException] if network error
  /// Throws [DataException] if cache/DB error
  Future<List<Trek>> getAllTreks({
    int page = 1,
    int pageSize = 10,
    String? locationFilter,
    String? difficultyFilter,
  });

  /// Fetch single trek with complete route data
  /// 
  /// [trekId]: Trek to fetch
  /// Returns trek with all waypoints
  /// Throws [NetworkException] if not found or network error
  Future<Trek> getTrekById(String trekId);

  /// Create new trek
  /// 
  /// [trek]: Trek data to create
  /// Returns created trek with ID assigned
  /// Throws [ValidationException] if trek data invalid
  /// Throws [NetworkException] if creation fails
  Future<Trek> createTrek(Trek trek);

  /// Update existing trek
  /// 
  /// [trekId]: Trek ID to update
  /// [updates]: Fields to update
  /// Returns updated trek
  /// Throws [NetworkException] if not found
  /// Throws [PermissionException] if not authorized
  Future<Trek> updateTrek(String trekId, Map<String, dynamic> updates);

  /// Delete trek
  /// 
  /// [trekId]: Trek to delete
  /// Returns true if successful
  /// Throws [NetworkException] if deletion fails
  /// Throws [PermissionException] if not authorized
  Future<bool> deleteTrek(String trekId);

  /// Search treks by query
  /// 
  /// [query]: Search term (name, location)
  /// Returns matching treks
  Future<List<Trek>> searchTreks(String query);

  /// Filter treks by criteria
  /// 
  /// [difficulty]: Difficulty level
  /// [maxDays]: Maximum estimated days
  /// [season]: Season filter
  /// Returns filtered treks
  Future<List<Trek>> filterTreks({
    String? difficulty,
    int? maxDays,
    String? season,
  });

  /// Download trek data for offline use
  /// 
  /// [trekId]: Trek to download
  /// Returns path to stored route data
  Future<String> downloadTrekForOffline(String trekId);

  /// Get list of treks available offline
  Future<List<Trek>> getOfflineTreks();
}
