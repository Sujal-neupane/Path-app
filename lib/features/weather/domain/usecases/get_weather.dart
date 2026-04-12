import 'package:path_app/features/weather/domain/entities/weather.dart';
import 'package:path_app/features/weather/domain/repositories/weather_repository.dart';

class GetWeather {
  final WeatherRepository repository;

  GetWeather(this.repository);

  Future<Weather> execute(double lat, double lon) {
    return repository.getWeatherByCoordinates(lat, lon);
  }
}
