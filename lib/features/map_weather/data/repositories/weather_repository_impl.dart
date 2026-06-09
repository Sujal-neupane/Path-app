import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/map_weather/data/datasources/weather_local_data_source.dart';
import 'package:path_app/features/map_weather/data/datasources/weather_remote_data_source.dart';
import 'package:path_app/features/map_weather/domain/entities/weather_report.dart';
import 'package:path_app/features/map_weather/domain/repository/weather_repository.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    remoteDataSource: ref.read(weatherRemoteDataSourceProvider),
    localDataSource: ref.read(weatherLocalDataSourceProvider),
  );
});

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;
  final WeatherLocalDataSource _localDataSource;

  WeatherRepositoryImpl({
    required WeatherRemoteDataSource remoteDataSource,
    required WeatherLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<WeatherReport> getWeather(String region) async {
    try {
      // 1. Fetch remote weather report from API
      final remoteReport = await _remoteDataSource.fetchWeatherForRegion(region);
      
      // 2. Cache successful result locally
      await _localDataSource.cacheWeather(region, remoteReport);
      return remoteReport;
    } catch (e) {
      // ignore: avoid_print
      print('[WeatherRepository] Fetch failed for region $region: $e — falling back to local cache.');
    }

    // 3. Fallback to local cache
    final cachedReport = await _localDataSource.getCachedWeather(region);
    if (cachedReport != null) {
      return cachedReport;
    }

    // If no cache, throw network error
    throw Exception('Offline. No cached weather forecast found for $region.');
  }
}
