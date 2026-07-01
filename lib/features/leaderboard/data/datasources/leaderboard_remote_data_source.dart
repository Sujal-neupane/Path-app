import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';

final leaderboardRemoteDataSourceProvider = Provider<LeaderboardRemoteDataSource>((ref) {
  return LeaderboardRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class LeaderboardRemoteDataSource {
  Future<Map<String, dynamic>> fetchLeaderboard({required String type, required String period});
  Future<Map<String, dynamic>> fetchMyRank();
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final ApiClient _apiClient;

  LeaderboardRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> fetchLeaderboard({required String type, required String period}) async {
    final response = await _apiClient.get(
      ApiEndpoints.leaderboard,
      queryParameters: {'type': type, 'period': period},
    );
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchMyRank() async {
    final response = await _apiClient.get('${ApiEndpoints.leaderboard}/me');
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
