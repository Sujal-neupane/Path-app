import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';

final communityRemoteDataSourceProvider = Provider<CommunityRemoteDataSource>((ref) {
  return CommunityRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class CommunityRemoteDataSource {
  Future<Map<String, dynamic>> fetchFeed({required int page, required int limit});
  Future<Map<String, dynamic>> createPost({required String caption, List<String>? imageUrls});
  Future<Map<String, dynamic>> toggleLike(String postId);
  Future<Map<String, dynamic>> addComment(String postId, String text);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final ApiClient _apiClient;

  CommunityRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> fetchFeed({required int page, required int limit}) async {
    final response = await _apiClient.get(
      ApiEndpoints.communityFeed,
      queryParameters: {'page': page, 'limit': limit},
    );
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> createPost({required String caption, List<String>? imageUrls}) async {
    final response = await _apiClient.post(
      ApiEndpoints.communityPosts,
      data: {
        'caption': caption,
        'imageUrls': ?imageUrls,
      },
    );
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final url = ApiEndpoints.communityLike.replaceAll('{id}', postId);
    final response = await _apiClient.post(url);
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> addComment(String postId, String text) async {
    final url = ApiEndpoints.communityComment.replaceAll('{id}', postId);
    final response = await _apiClient.post(
      url,
      data: {'text': text},
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
