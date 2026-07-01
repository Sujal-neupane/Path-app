import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';

final gearRemoteDataSourceProvider = Provider<GearRemoteDataSource>((ref) {
  return GearRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class GearRemoteDataSource {
  Future<Map<String, dynamic>> fetchGearList(String trekId);
  Future<Map<String, dynamic>> addGearItem(String trekId, Map<String, dynamic> itemData);
  Future<Map<String, dynamic>> togglePackedStatus(String trekId, String itemId);
  Future<Map<String, dynamic>> removeGearItem(String trekId, String itemId);
}

class GearRemoteDataSourceImpl implements GearRemoteDataSource {
  final ApiClient _apiClient;

  GearRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> fetchGearList(String trekId) async {
    final response = await _apiClient.get('${ApiEndpoints.gearList}/$trekId');
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> addGearItem(String trekId, Map<String, dynamic> itemData) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.gearList}/$trekId/items',
      data: itemData,
    );
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> togglePackedStatus(String trekId, String itemId) async {
    final response = await _apiClient
        .patch('${ApiEndpoints.gearList}/$trekId/items/$itemId/toggle');
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> removeGearItem(String trekId, String itemId) async {
    final response = await _apiClient
        .delete('${ApiEndpoints.gearList}/$trekId/items/$itemId');
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
