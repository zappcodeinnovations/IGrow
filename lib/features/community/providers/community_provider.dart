import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return CommunityRepository(tokenStorage: tokenStorage);
});

final communityTopicsProvider = FutureProvider<List<CommunityTopic>>((ref) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.getTopics();
});

final selectedTopicIdProvider = StateProvider<String?>((ref) => null);

final communityPostsProvider = StateNotifierProvider<CommunityPostsNotifier, AsyncValue<List<CommunityPost>>>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  final selectedTopic = ref.watch(selectedTopicIdProvider);
  return CommunityPostsNotifier(repo, topicId: selectedTopic);
});

class CommunityPostsNotifier extends StateNotifier<AsyncValue<List<CommunityPost>>> {
  CommunityPostsNotifier(this._repo, {this.topicId}) : super(const AsyncValue.loading()) {
    fetchPosts();
  }

  final CommunityRepository _repo;
  final String? topicId;

  Future<void> fetchPosts({String? search}) async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repo.getPosts(topicId: topicId, search: search);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<CommunityPost> createPost({
    required String title,
    required String content,
    String? topicId,
    String? imagePath,
  }) async {
    final newPost = await _repo.createPost(
      title: title,
      content: content,
      topicId: topicId,
      imagePath: imagePath,
    );

    if (state.hasValue && state.value != null) {
      state = AsyncValue.data([newPost, ...state.value!]);
    } else {
      state = AsyncValue.data([newPost]);
    }

    return newPost;
  }

  Future<void> refreshPosts() async {
    try {
      final posts = await _repo.getPosts(topicId: topicId);
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
    final newLikesCount = isLikedNow ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);

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
      final serverLikesCount = (response['upvotes_count'] ?? response['likes_count']) as int?;
      final serverIsLiked = (response['is_liked'] ?? response['is_liked_by_me']) as bool?;

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
