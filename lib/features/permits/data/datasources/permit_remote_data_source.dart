import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';

final permitRemoteDataSourceProvider = Provider<PermitRemoteDataSource>((ref) {
  return PermitRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class PermitRemoteDataSource {
  Future<Map<String, dynamic>> fetchAllPermits();
  Future<Map<String, dynamic>> fetchPermitByRegion(String region);
  Future<Map<String, dynamic>> createCheckoutSession({required String regionKey, required int trekkerCount});
}

class PermitRemoteDataSourceImpl implements PermitRemoteDataSource {
  final ApiClient _apiClient;

  PermitRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> fetchAllPermits() async {
    final response = await _apiClient.get(ApiEndpoints.permits);
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchPermitByRegion(String region) async {
    final response = await _apiClient.get('${ApiEndpoints.permits}/$region');
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> createCheckoutSession({required String regionKey, required int trekkerCount}) async {
    final response = await _apiClient.post(
      ApiEndpoints.permitsCheckout,
      data: {
        'regionKey': regionKey,
        'trekkerCount': trekkerCount,
      },
    );
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
