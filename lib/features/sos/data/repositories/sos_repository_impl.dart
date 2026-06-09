import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/core/app/app_setup.dart';
import 'package:path_app/features/sos/domain/entities/sos_alert.dart';
import 'package:path_app/features/sos/domain/repository/sos_repository.dart';

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SosRepositoryImpl(
    apiClient: apiClient, 
    prefs: AppSetup.sharedPreferences,
  );
});

class SosRepositoryImpl implements SosRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  static const String _queueKey = 'sos_offline_queue';

  SosRepositoryImpl({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient,
       _prefs = prefs;

  @override
  Future<SosAlert> sendSosAlert(SosAlert alert) async {
    final response = await _apiClient.post(
      ApiEndpoints.sosAlert,
      data: {
        'latitude': alert.latitude,
        'longitude': alert.longitude,
        if (alert.altitude != null) 'altitude': alert.altitude,
        if (alert.batteryLevel != null) 'batteryLevel': alert.batteryLevel,
        if (alert.message != null && alert.message!.isNotEmpty) 'message': alert.message,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = response.data['data'];
      return SosAlert(
        id: data['id']?.toString(),
        userId: data['user_id']?.toString() ?? alert.userId,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        altitude: data['altitude'] != null ? (data['altitude'] as num).toDouble() : alert.altitude,
        batteryLevel: data['battery_level'] != null ? (data['battery_level'] as num).toDouble() : alert.batteryLevel,
        status: data['status']?.toString() ?? 'pending',
        message: data['message']?.toString() ?? alert.message,
        createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : alert.createdAt,
        isSynced: true,
      );
    }
    throw Exception('Failed to send SOS alert');
  }

  @override
  Future<List<SosAlert>> getQueuedAlerts() async {
    final list = _prefs.getStringList(_queueKey) ?? [];
    return list.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return SosAlert(
        userId: map['userId']?.toString() ?? '',
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        altitude: map['altitude'] != null ? (map['altitude'] as num).toDouble() : null,
        batteryLevel: map['batteryLevel'] != null ? (map['batteryLevel'] as num).toDouble() : null,
        status: map['status']?.toString() ?? 'pending',
        message: map['message']?.toString(),
        createdAt: DateTime.parse(map['createdAt'].toString()),
        isSynced: false,
      );
    }).toList();
  }

  @override
  Future<void> saveAlertLocally(SosAlert alert) async {
    final alerts = await getQueuedAlerts();
    alerts.add(alert.copyWith(isSynced: false));
    await _saveQueue(alerts);
  }

  @override
  Future<void> deleteAlertLocally(String timestampKey) async {
    final alerts = await getQueuedAlerts();
    alerts.removeWhere((item) => item.createdAt.toIso8601String() == timestampKey);
    await _saveQueue(alerts);
  }

  Future<void> _saveQueue(List<SosAlert> alerts) async {
    final list = alerts.map((item) {
      return jsonEncode({
        'userId': item.userId,
        'latitude': item.latitude,
        'longitude': item.longitude,
        'altitude': item.altitude,
        'batteryLevel': item.batteryLevel,
        'status': item.status,
        'message': item.message,
        'createdAt': item.createdAt.toIso8601String(),
      });
    }).toList();
    await _prefs.setStringList(_queueKey, list);
  }

  @override
  Future<List<SosAlert>> getMySosAlerts() async {
    final response = await _apiClient.get(ApiEndpoints.sosHistory);
    final Map<String, dynamic> payload = response.data is Map ? Map<String, dynamic>.from(response.data) : {};
    final dataList = payload['data'];

    if (dataList is List) {
      return dataList.map((data) {
        return SosAlert(
          id: data['_id']?.toString() ?? data['id']?.toString(),
          userId: data['user_id']?.toString() ?? '',
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          altitude: data['altitude'] != null ? (data['altitude'] as num).toDouble() : null,
          batteryLevel: data['battery_level'] != null ? (data['battery_level'] as num).toDouble() : null,
          status: data['status']?.toString() ?? 'pending',
          message: data['message']?.toString(),
          createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : DateTime.now(),
          isSynced: true,
        );
      }).toList();
    }
    return [];
  }
}
