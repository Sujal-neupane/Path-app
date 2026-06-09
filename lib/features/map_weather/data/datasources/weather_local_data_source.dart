import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/features/map_weather/domain/entities/weather_report.dart';

const String _weatherCachePrefix = 'cache_weather_';
const String _weatherTimestampPrefix = 'cache_weather_ts_';
const int _weatherCacheTtlMs = 30 * 60 * 1000; // 30 minutes

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  return WeatherLocalDataSourceImpl();
});

abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(String region, WeatherReport report);
  Future<WeatherReport?> getCachedWeather(String region);
  Future<void> clearCache();
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  @override
  Future<void> cacheWeather(String region, WeatherReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final sanitizedRegion = region.replaceAll(' ', '_').toLowerCase();
    
    await prefs.setString(
      '$_weatherCachePrefix$sanitizedRegion',
      jsonEncode(report.toJson()),
    );
    await prefs.setInt(
      '$_weatherTimestampPrefix$sanitizedRegion',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<WeatherReport?> getCachedWeather(String region) async {
    final prefs = await SharedPreferences.getInstance();
    final sanitizedRegion = region.replaceAll(' ', '_').toLowerCase();
    
    final cachedStr = prefs.getString('$_weatherCachePrefix$sanitizedRegion');
    final timestamp = prefs.getInt('$_weatherTimestampPrefix$sanitizedRegion');

    if (cachedStr == null || timestamp == null) return null;

    // Check expiry
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > _weatherCacheTtlMs) {
      await prefs.remove('$_weatherCachePrefix$sanitizedRegion');
      await prefs.remove('$_weatherTimestampPrefix$sanitizedRegion');
      return null;
    }

    try {
      final decoded = jsonDecode(cachedStr) as Map<String, dynamic>;
      return WeatherReport.fromJson(decoded);
    } catch (e) {
      await prefs.remove('$_weatherCachePrefix$sanitizedRegion');
      await prefs.remove('$_weatherTimestampPrefix$sanitizedRegion');
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_weatherCachePrefix) || key.startsWith(_weatherTimestampPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
