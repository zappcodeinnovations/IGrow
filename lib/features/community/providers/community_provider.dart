import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return CommunityRepository(tokenStorage: tokenStorage);
});

final communityPostsProvider = StateNotifierProvider<CommunityPostsNotifier, AsyncValue<List<CommunityPost>>>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  return CommunityPostsNotifier(repo);
});

class CommunityPostsNotifier extends StateNotifier<AsyncValue<List<CommunityPost>>> {
  CommunityPostsNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchPosts();
  }

  final CommunityRepository _repo;

  Future<void> fetchPosts() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repo.getPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> toggleLike(String postId) async {
    if (state.value == null) return false;

    // Optimistically update the UI
    final oldPosts = state.value!;
    final index = oldPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;

    final post = oldPosts[index];
    final isLikedNow = !post.isLikedByMe;
    final newLikesCount = isLikedNow ? post.likesCount + 1 : post.likesCount - 1;

    final newPost = post.copyWith(
      isLikedByMe: isLikedNow,
      likesCount: newLikesCount,
    );

    final newPosts = List<CommunityPost>.from(oldPosts);
    newPosts[index] = newPost;
    state = AsyncValue.data(newPosts);

    // Call API
    try {
      final response = await _repo.likePost(postId);
      // Optional: sync with real server values if needed
      final serverLikesCount = response['likes_count'] as int?;
      final serverIsLiked = response['is_liked_by_me'] as bool?;
      
      if (serverLikesCount != null && serverIsLiked != null) {
        final verifiedPost = newPost.copyWith(
          likesCount: serverLikesCount,
          isLikedByMe: serverIsLiked,
        );
        final verifiedPosts = List<CommunityPost>.from(state.value!);
        final vIndex = verifiedPosts.indexWhere((p) => p.id == postId);
        if (vIndex != -1) {
          verifiedPosts[vIndex] = verifiedPost;
          state = AsyncValue.data(verifiedPosts);
        }
      }
      return true;
    } catch (e) {
      // Revert on failure
      final revertedPosts = List<CommunityPost>.from(state.value!);
      final rIndex = revertedPosts.indexWhere((p) => p.id == postId);
      if (rIndex != -1) {
        revertedPosts[rIndex] = post;
        state = AsyncValue.data(revertedPosts);
      }
      return false;
    }
  }
}
