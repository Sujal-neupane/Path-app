import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> fetchProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;
  ProfileRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _apiClient.get('${ApiEndpoints.profile}/me');
    final data = response.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return data;
    }
    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Failed to load profile',
    );
  }
}
