import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/features/map_weather/domain/entities/weather_report.dart';

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((ref) {
  return WeatherRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class WeatherRemoteDataSource {
  Future<WeatherReport> fetchWeatherForRegion(String region);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient _apiClient;

  WeatherRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<WeatherReport> fetchWeatherForRegion(String region) async {
    final response = await _apiClient.get(
      ApiEndpoints.weather,
      queryParameters: {'region': region},
    );

    final payload = _asMap(response.data);
    final data = payload['data'];

    if (data is Map<String, dynamic>) {
      return WeatherReport.fromJson(data);
    }
    throw Exception(_message(payload, 'Failed to parse weather report'));
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  String _message(Map<String, dynamic> payload, String fallback) {
    final message = payload['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
