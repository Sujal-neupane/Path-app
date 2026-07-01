import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/domain/entities/waypoint.dart';

/// Provider for the trek remote data source.
final trekRemoteDataSourceProvider = Provider<TrekRemoteDataSource>((ref) {
  return TrekRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

/// Contract for fetching trek data from the backend API.
abstract class TrekRemoteDataSource {
  /// Fetch the list of official curated treks from the catalog.
  Future<List<TrekSummary>> fetchOfficialTreks();

  /// Fetch a single trek by its ID.
  Future<TrekSummary?> fetchTrekById(String trekId);

  /// Fetch waypoints (checkpoints with coordinates) for a trek.
  Future<List<Waypoint>> fetchTrekWaypoints(String trekId);

  /// Search treks with optional filters.
  Future<List<TrekSummary>> searchTreks({
    String? region,
    String? difficulty,
    int? limit,
    int? page,
  });
}

/// Implementation using Dio-based ApiClient.
class TrekRemoteDataSourceImpl implements TrekRemoteDataSource {
  final ApiClient _apiClient;

  TrekRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<TrekSummary>> fetchOfficialTreks() async {
    final response = await _apiClient.get(
      ApiEndpoints.treksList,
      queryParameters: {'isOfficial': true},
    );

    final payload = _asMap(response.data);
    final dataList = payload['data'];

    if (dataList is List) {
      return dataList
          .whereType<Map<String, dynamic>>()
          .map((json) => TrekSummary.fromJson(json))
          .toList();
    }

    return [];
  }

  @override
  Future<TrekSummary?> fetchTrekById(String trekId) async {
    final endpoint = ApiEndpoints.withId(ApiEndpoints.trekById, trekId);
    final response = await _apiClient.get(endpoint);

    final payload = _asMap(response.data);
    final data = payload['data'];

    if (data is Map<String, dynamic>) {
      return TrekSummary.fromJson(data);
    }

    return null;
  }

  @override
  Future<List<Waypoint>> fetchTrekWaypoints(String trekId) async {
    final endpoint = ApiEndpoints.withId(ApiEndpoints.trekGpsTrack, trekId);
    final response = await _apiClient.get(endpoint);

    final payload = _asMap(response.data);
    final data = payload['data'];

    if (data is Map<String, dynamic>) {
      final waypoints = data['waypoints'] as List<dynamic>?;
      if (waypoints != null) {
        return waypoints
            .whereType<Map<String, dynamic>>()
            .map((json) => Waypoint.fromJson(json))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<List<TrekSummary>> searchTreks({
    String? region,
    String? difficulty,
    int? limit,
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (region != null) queryParams['region'] = region;
    if (difficulty != null) queryParams['difficulty'] = difficulty;
    if (limit != null) queryParams['limit'] = limit;
    if (page != null) queryParams['page'] = page;

    final response = await _apiClient.get(
      ApiEndpoints.treksList,
      queryParameters: queryParams,
    );

    final payload = _asMap(response.data);
    final dataList = payload['data'];

    if (dataList is List) {
      return dataList
          .whereType<Map<String, dynamic>>()
          .map((json) => TrekSummary.fromJson(json))
          .toList();
    }

    return [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
