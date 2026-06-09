import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/map_weather/data/repositories/weather_repository_impl.dart';
import 'package:path_app/features/map_weather/domain/entities/weather_report.dart';

final weatherStateProvider = FutureProvider.family<WeatherReport, String>((ref, region) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getWeather(region);
});
