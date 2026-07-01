import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';

final aiGuideRemoteDataSourceProvider = Provider<AiGuideRemoteDataSource>((ref) {
  return AiGuideRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class AiGuideRemoteDataSource {
  Future<Map<String, dynamic>> sendMessage({required String message, String? region, double? altitude});
  Future<Map<String, dynamic>> fetchDailyTips();
  Future<Map<String, dynamic>> fetchChatHistory();
}

class AiGuideRemoteDataSourceImpl implements AiGuideRemoteDataSource {
  final ApiClient _apiClient;

  AiGuideRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> sendMessage({required String message, String? region, double? altitude}) async {
    final context = <String, dynamic>{
      if (region != null && region.isNotEmpty) 'currentRegion': region,
      if (altitude != null) 'currentAltitudeM': altitude,
    };
    final response = await _apiClient.post(
      ApiEndpoints.aiChat,
      data: {
        'message': message,
        if (context.isNotEmpty) 'context': context,
      },
    );
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchDailyTips() async {
    final response = await _apiClient.get(ApiEndpoints.aiTips);
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchChatHistory() async {
    final response = await _apiClient.get('/ai/history');
    return _extractData(response.data);
  }

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['success'] == true) {
        return responseData;
      }
      throw Exception(responseData['message'] ?? 'API error');
    }
    throw Exception('Invalid response format');
  }
}
