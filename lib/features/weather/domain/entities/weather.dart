import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temperature;
  final String condition;
  final String iconCode;
  final double humidity;
  final double windSpeed;
  final double altitude;
  final String locationName;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.altitude,
    required this.locationName,
  });

  @override
  List<Object?> get props => [
        temperature,
        condition,
        iconCode,
        humidity,
        windSpeed,
        altitude,
        locationName,
      ];
}
