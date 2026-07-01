import 'package:path_app/features/community/domain/entities/community_post.dart';

abstract class CommunityRepository {
  Future<List<CommunityPost>> getFeed({required int page, required int limit, required String currentUserId});
  Future<CommunityPost> createPost({required String caption, List<String>? imageUrls, required String currentUserId});
  Future<bool> toggleLike(String postId);
}
