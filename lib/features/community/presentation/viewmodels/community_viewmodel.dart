import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';
import 'package:path_app/features/community/data/repositories/community_repository_impl.dart';
import 'package:path_app/features/community/domain/entities/community_post.dart';

final communityViewModelProvider =
    NotifierProvider<CommunityViewModel, AsyncValue<List<CommunityPost>>>(() {
  return CommunityViewModel();
});

class CommunityViewModel extends Notifier<AsyncValue<List<CommunityPost>>> {
  @override
  AsyncValue<List<CommunityPost>> build() {
    // Load feed asynchronously on initialization
    Future.microtask(() => loadFeed());
    return const AsyncValue.loading();
  }

  String get _currentUserId {
    final sessionState = ref.read(authSessionControllerProvider);
    return sessionState.value?.user?.id ?? '';
  }

  Future<void> loadFeed() async {
    try {
      state = const AsyncValue.loading();
      final repository = ref.read(communityRepositoryProvider);
      final feed = await repository.getFeed(page: 1, limit: 30, currentUserId: _currentUserId);
      state = AsyncValue.data(feed);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentList = state.value;
    if (currentList == null) return;

    // Optimistically update the UI
    final updatedList = currentList.map((post) {
      if (post.id == postId) {
        final newIsLiked = !post.isLikedByMe;
        final newLikeCount = newIsLiked ? post.likeCount + 1 : post.likeCount - 1;
        return post.copyWith(
          isLikedByMe: newIsLiked,
          likeCount: newLikeCount,
        );
      }
      return post;
    }).toList();

    state = AsyncValue.data(updatedList);

    try {
      final repository = ref.read(communityRepositoryProvider);
      final serverLiked = await repository.toggleLike(postId);
      
      // Update with correct server status
      final finalFeed = state.value?.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLikedByMe: serverLiked,
          );
        }
        return post;
      }).toList();
      if (finalFeed != null) {
        state = AsyncValue.data(finalFeed);
      }
    } catch (_) {
      // Revert if error
      state = AsyncValue.data(currentList);
    }
  }

  Future<void> createPost(String caption, {List<String>? imageUrls}) async {
    try {
      final repository = ref.read(communityRepositoryProvider);
      final newPost = await repository.createPost(
        caption: caption,
        imageUrls: imageUrls,
        currentUserId: _currentUserId,
      );

      // Prepend to current feed
      final currentList = state.value ?? [];
      state = AsyncValue.data([newPost, ...currentList]);
    } catch (e) {
      rethrow;
    }
  }
}
