import 'package:path_app/features/map_weather/domain/entities/weather_report.dart';

abstract class WeatherRepository {
  Future<WeatherReport> getWeather(String region);
}
