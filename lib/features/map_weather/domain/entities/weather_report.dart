class ForecastDay {
  final String day;
  final String tempMinMax;
  final String condition; // 'clear' | 'cloudy' | 'snow' | 'wind' | 'storm'

  const ForecastDay({
    required this.day,
    required this.tempMinMax,
    required this.condition,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      day: json['day'] as String? ?? '',
      tempMinMax: json['tempMinMax'] as String? ?? '',
      condition: json['condition'] as String? ?? 'clear',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'tempMinMax': tempMinMax,
      'condition': condition,
    };
  }
}

class WeatherReport {
  final String region;
  final double latitude;
  final double longitude;
  final int altitudeM;
  final String temperature;
  final String tempMinMax;
  final String windSpeed;
  final String humidity;
  final String pressure;
  final String uvIndex;
  final String condition; // 'clear' | 'cloudy' | 'snow' | 'wind' | 'storm'
  final String description;
  final String advisory;
  final List<ForecastDay> forecast;

  const WeatherReport({
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.altitudeM,
    required this.temperature,
    required this.tempMinMax,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    required this.uvIndex,
    required this.condition,
    required this.description,
    required this.advisory,
    required this.forecast,
  });

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['forecast'] as List<dynamic>?)
            ?.map((e) => ForecastDay.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WeatherReport(
      region: json['region'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      altitudeM: (json['altitudeM'] as num?)?.toInt() ?? 0,
      temperature: json['temperature'] as String? ?? '',
      tempMinMax: json['tempMinMax'] as String? ?? '',
      windSpeed: json['windSpeed'] as String? ?? '',
      humidity: json['humidity'] as String? ?? '',
      pressure: json['pressure'] as String? ?? '',
      uvIndex: json['uvIndex'] as String? ?? '',
      condition: json['condition'] as String? ?? 'clear',
      description: json['description'] as String? ?? '',
      advisory: json['advisory'] as String? ?? '',
      forecast: forecastList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'altitudeM': altitudeM,
      'temperature': temperature,
      'tempMinMax': tempMinMax,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'pressure': pressure,
      'uvIndex': uvIndex,
      'condition': condition,
      'description': description,
      'advisory': advisory,
      'forecast': forecast.map((e) => e.toJson()).toList(),
    };
  }
}
