import '../models/trek_api_model.dart';

/// Remote trekking datasource interface
/// 
/// Defines contract for backend API operations
/// Can throw [NetworkException] or [ServerException]
abstract class TrekkingRemoteDataSource {
  /// Fetch all treks from backend API
  /// 
  /// [page]: Page number (1-indexed)
  /// [pageSize]: Items per page
  /// [locationFilter]: Optional location filter
  /// [difficultyFilter]: Optional difficulty filter
  /// 
  /// Returns paginated response from backend
  /// Throws [NetworkException] if network unavailable
  /// Throws [ServerException] if backend error (4xx, 5xx)
  Future<TrekListApiResponse> getAllTreks({
    int page = 1,
    int pageSize = 10,
    String? locationFilter,
    String? difficultyFilter,
  });

  /// Fetch single trek from backend with all route data
  /// 
  /// [trekId]: Trek ID to fetch
  /// Returns complete trek with waypoints
  /// Throws [ServerException] if trek not found (404)
  Future<TrekApiModel> getTrekById(String trekId);

  /// Create new trek on backend
  /// 
  /// [trekData]: Trek data to create
  /// Returns created trek with assigned ID
  /// Throws [ValidationException] if data invalid
  /// Throws [ServerException] if create fails
  Future<TrekApiModel> createTrek(Map<String, dynamic> trekData);

  /// Update trek on backend
  /// 
  /// [trekId]: Trek to update
  /// [updates]: Fields to update
  /// Returns updated trek
  /// Throws [ServerException] if update fails
  Future<TrekApiModel> updateTrek(String trekId, Map<String, dynamic> updates);

  /// Delete trek from backend
  /// 
  /// [trekId]: Trek to delete
  /// Returns true if successful
  /// Throws [ServerException] if delete fails
  Future<bool> deleteTrek(String trekId);

  /// Search treks by query string
  /// 
  /// [query]: Search term
  /// Returns matching treks
  Future<List<TrekApiModel>> searchTreks(String query);

  /// Filter treks by criteria
  /// 
  /// [difficulty]: Difficulty level
  /// [maxDays]: Maximum duration
  /// [season]: Best season
  /// Returns filtered treks
  Future<List<TrekApiModel>> filterTreks({
    String? difficulty,
    int? maxDays,
    String? season,
  });

  /// Download trek route data for offline use
  /// 
  /// [trekId]: Trek to download
  /// Returns local file path where data was saved
  /// Throws [NetworkException] if download fails
  Future<String> downloadTrekData(String trekId);
}
