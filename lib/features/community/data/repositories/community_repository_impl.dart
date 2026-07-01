import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/community/data/datasources/community_remote_data_source.dart';
import 'package:path_app/features/community/domain/entities/community_post.dart';
import 'package:path_app/features/community/domain/repository/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(
    remoteDataSource: ref.read(communityRemoteDataSourceProvider),
  );
});

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource _remoteDataSource;

  CommunityRepositoryImpl({required CommunityRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<CommunityPost>> getFeed({
    required int page,
    required int limit,
    required String currentUserId,
  }) async {
    final response = await _remoteDataSource.fetchFeed(page: page, limit: limit);
    final list = (response['data'] as List?) ?? [];
    return list
        .map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e), currentUserId))
        .toList();
  }

  @override
  Future<CommunityPost> createPost({
    required String caption,
    List<String>? imageUrls,
    required String currentUserId,
  }) async {
    final response = await _remoteDataSource.createPost(
      caption: caption,
      imageUrls: imageUrls,
    );
    final postData = response['data'] ?? response;
    return CommunityPost.fromJson(Map<String, dynamic>.from(postData), currentUserId);
  }

  @override
  Future<bool> toggleLike(String postId) async {
    final response = await _remoteDataSource.toggleLike(postId);
    final data = response['data'] ?? response;
    return data['liked'] ?? false;
  }
}
