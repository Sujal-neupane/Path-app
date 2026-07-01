import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/features/map_weather/domain/entities/trail_track.dart';

/// Provider for the map remote data source.
final mapRemoteDataSourceProvider = Provider<MapRemoteDataSource>((ref) {
  return MapRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

/// Contract for map-related API calls.
abstract class MapRemoteDataSource {
  /// Fetch the GPS trail track for a trek by its ID.
  Future<TrailTrack> fetchTrekGpsTrack(String trekId);

  /// Reverse geocode coordinates to a named location.
  Future<Map<String, dynamic>> reverseGeocode(double lat, double lon);

  /// Find nearby hiking trails around given coordinates.
  Future<List<Map<String, dynamic>>> findNearbyTrails(double lat, double lon, {double radiusKm = 25});

  /// Fetch elevation profile for a list of coordinates.
  Future<List<Map<String, dynamic>>> fetchElevation(List<Map<String, double>> coordinates);

  /// Fetch weather by exact coordinates (not region name).
  Future<Map<String, dynamic>> fetchWeatherByCoords(double lat, double lon);
}

/// Implementation using Dio-based ApiClient.
class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final ApiClient _apiClient;

  MapRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<TrailTrack> fetchTrekGpsTrack(String trekId) async {
    final endpoint = ApiEndpoints.trekGpsTrack.replaceFirst('{id}', trekId);
    final response = await _apiClient.get(endpoint);

    final payload = _asMap(response.data);
    final data = payload['data'];

    if (data is Map<String, dynamic>) {
      return TrailTrack.fromJson(data);
    }

    throw Exception('Failed to parse GPS track');
  }

  @override
  Future<Map<String, dynamic>> reverseGeocode(double lat, double lon) async {
    final response = await _apiClient.get(
      ApiEndpoints.mapsGeocode,
      queryParameters: {'lat': lat, 'lon': lon},
    );

    final payload = _asMap(response.data);
    final data = payload['data'];

    if (data is Map<String, dynamic>) return data;
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> findNearbyTrails(
    double lat,
    double lon, {
    double radiusKm = 25,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.mapsNearbyTrails,
      queryParameters: {'lat': lat, 'lon': lon, 'radius': radiusKm},
    );

    final payload = _asMap(response.data);
    final dataList = payload['data'];

    if (dataList is List) {
      return dataList.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchElevation(
    List<Map<String, double>> coordinates,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.mapsElevation,
      data: {'coordinates': coordinates},
    );

    final payload = _asMap(response.data);
    final dataList = payload['data'];

    if (dataList is List) {
      return dataList.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> fetchWeatherByCoords(double lat, double lon) async {
    final response = await _apiClient.get(
      ApiEndpoints.weatherByCoords,
      queryParameters: {'lat': lat, 'lon': lon},
    );

    final payload = _asMap(response.data);
    final data = payload['data'];

    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
