import 'package:path_app/features/weather/domain/entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeatherByCoordinates(double lat, double lon);
}
