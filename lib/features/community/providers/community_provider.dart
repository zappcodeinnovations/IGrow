import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return CommunityRepository(tokenStorage: tokenStorage);
});

// ─── Location Filter Providers ─────────────────────────────────────

final selectedStateProvider = StateProvider<String>((ref) {
  // Read once on initial creation so background auth polling timers never reset user's manual filter
  final authState = ref.read(authProvider);
  final userState = authState.user?.locationState;
  if (userState != null && userState.trim().isNotEmpty) {
    return userState.trim();
  }
  return 'Maharashtra';
});

final selectedDistrictProvider = StateProvider<String>((ref) {
  // Read once on initial creation so background auth polling timers never reset user's manual filter
  final authState = ref.read(authProvider);
  final userDistrict = authState.user?.locationDistrict;
  if (userDistrict != null && userDistrict.trim().isNotEmpty) {
    return userDistrict.trim();
  }
  return 'Pune';
});

// ─── Hubs Providers ────────────────────────────────────────────────

final selectedHubProvider = StateProvider<CommunityHub?>((ref) => null);

final communityHubsProvider = StateNotifierProvider<CommunityHubsNotifier, AsyncValue<List<CommunityHub>>>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  final state = ref.watch(selectedStateProvider);
  final district = ref.watch(selectedDistrictProvider);
  return CommunityHubsNotifier(repo, stateName: state, districtName: district);
});

class CommunityHubsNotifier extends StateNotifier<AsyncValue<List<CommunityHub>>> {
  CommunityHubsNotifier(this._repo, {required this.stateName, required this.districtName})
      : super(const AsyncValue.loading()) {
    fetchHubs();
  }

  final CommunityRepository _repo;
  final String stateName;
  final String districtName;

  Future<void> fetchHubs({String? search}) async {
    state = const AsyncValue.loading();
    try {
      final hubs = await _repo.getHubs(
        state: stateName,
        district: districtName,
        search: search,
      );
      state = AsyncValue.data(hubs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> toggleJoin(String hubId) async {
    final currentList = state.value;
    if (currentList == null) return false;

    final index = currentList.indexWhere((h) => h.id == hubId);
    if (index == -1) return false;

    final oldHub = currentList[index];
    final isJoining = !oldHub.isMember;
    final newCount = isJoining ? oldHub.memberCount + 1 : (oldHub.memberCount > 0 ? oldHub.memberCount - 1 : 0);

    // Optimistically update
    final updatedHub = oldHub.copyWith(
      isMember: isJoining,
      memberCount: newCount,
    );
    final updatedList = List<CommunityHub>.from(currentList);
    updatedList[index] = updatedHub;
    state = AsyncValue.data(updatedList);

    try {
      final res = await _repo.toggleJoinHub(hubId);
      final serverIsMember = res['is_member'] as bool?;
      final serverCount = res['member_count'] as int?;

      if (serverIsMember != null || serverCount != null) {
        final verifiedHub = updatedHub.copyWith(
          isMember: serverIsMember ?? isJoining,
          memberCount: serverCount ?? newCount,
        );
        final verifiedList = List<CommunityHub>.from(state.value ?? updatedList);
        final vIdx = verifiedList.indexWhere((h) => h.id == hubId);
        if (vIdx != -1) {
          verifiedList[vIdx] = verifiedHub;
          state = AsyncValue.data(verifiedList);
        }
      }
      return true;
    } catch (e) {
      // Revert on failure
      final revertedList = List<CommunityHub>.from(state.value ?? currentList);
      final rIdx = revertedList.indexWhere((h) => h.id == hubId);
      if (rIdx != -1) {
        revertedList[rIdx] = oldHub;
        state = AsyncValue.data(revertedList);
      }
      return false;
    }
  }
}

final hubDetailsProvider = FutureProvider.family<CommunityHub, String>((ref, hubId) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.getHubDetails(hubId);
});

// ─── Topics ────────────────────────────────────────────────────────

final communityTopicsProvider = FutureProvider<List<CommunityTopic>>((ref) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.getTopics();
});

final selectedTopicIdProvider = StateProvider<String?>((ref) => null);

// ─── Posts ─────────────────────────────────────────────────────────

final communityPostsProvider = StateNotifierProvider<CommunityPostsNotifier, AsyncValue<List<CommunityPost>>>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  final selectedTopic = ref.watch(selectedTopicIdProvider);
  final selectedHub = ref.watch(selectedHubProvider);
  return CommunityPostsNotifier(repo, ref, topicId: selectedTopic, hubId: selectedHub?.id);
});

class CommunityPostsNotifier extends StateNotifier<AsyncValue<List<CommunityPost>>> {
  CommunityPostsNotifier(this._repo, this._ref, {this.topicId, this.hubId}) : super(const AsyncValue.loading()) {
    fetchPosts();
  }

  final CommunityRepository _repo;
  final Ref _ref;
  final String? topicId;
  final String? hubId;

  Future<void> fetchPosts({String? search, String? ordering}) async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repo.getPosts(
        hubId: hubId,
        topicId: topicId,
        search: search,
        ordering: ordering,
      );
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<CommunityPost> createPost({
    required String title,
    required String content,
    String? hubId,
    String? postType,
    String? topicId,
    String? courseId,
    DateTime? eventDate,
    String? venueAddress,
    String? link,
    String? imagePath,
  }) async {
    final newPost = await _repo.createPost(
      title: title,
      content: content,
      hubId: hubId,
      postType: postType,
      topicId: topicId,
      courseId: courseId,
      eventDate: eventDate,
      venueAddress: venueAddress,
      link: link,
      imagePath: imagePath,
    );

    final currentUser = _ref.read(authProvider).user;
    var postToInsert = newPost;
    if (currentUser != null) {
      if (postToInsert.author.id.isEmpty || postToInsert.author.id != currentUser.id) {
        postToInsert = postToInsert.copyWith(
          author: postToInsert.author.copyWith(
            id: currentUser.id,
            fullName: currentUser.fullName.isNotEmpty ? currentUser.fullName : postToInsert.author.fullName,
            avatarUrl: currentUser.avatarUrl ?? postToInsert.author.avatarUrl,
            role: currentUser.activeRole.apiValue,
            isExpert: currentUser.isInstructor || currentUser.isAdmin,
          ),
        );
      }
    }

    if (state.hasValue && state.value != null) {
      state = AsyncValue.data([postToInsert, ...state.value!]);
    } else {
      state = AsyncValue.data([postToInsert]);
    }

    // Silently sync latest posts from backend in background to guarantee full consistency
    unawaited(refreshPosts());

    return postToInsert;
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _repo.deletePost(postId);
      if (state.hasValue && state.value != null) {
        state = AsyncValue.data(
          state.value!.where((p) => p.id != postId).toList(),
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshPosts() async {
    try {
      final posts = await _repo.getPosts(hubId: hubId, topicId: topicId);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void incrementCommentsCount(String postId) {
    if (state.value == null) return;
    final oldPosts = state.value!;
    final index = oldPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = oldPosts[index];
    final updatedPost = post.copyWith(commentsCount: post.commentsCount + 1);
    final updatedList = List<CommunityPost>.from(oldPosts);
    updatedList[index] = updatedPost;
    state = AsyncValue.data(updatedList);
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

// ─── Comments ──────────────────────────────────────────────────────

final postCommentsProvider = StateNotifierProvider.family<PostCommentsNotifier, AsyncValue<List<CommunityComment>>, String>((ref, postId) {
  final repo = ref.watch(communityRepositoryProvider);
  return PostCommentsNotifier(repo, postId);
});

class PostCommentsNotifier extends StateNotifier<AsyncValue<List<CommunityComment>>> {
  PostCommentsNotifier(this._repo, this.postId) : super(const AsyncValue.loading()) {
    fetchComments();
  }

  final CommunityRepository _repo;
  final String postId;

  Future<void> fetchComments() async {
    state = const AsyncValue.loading();
    try {
      final comments = await _repo.getComments(postId);
      state = AsyncValue.data(comments);
    } catch (_) {
      state = AsyncValue.data(<CommunityComment>[]);
    }
  }

  Future<void> addComment({
    required String text,
    required CommunityAuthor author,
    String? parentId,
  }) async {
    final localComment = CommunityComment(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      author: author,
      parentId: parentId,
      authorRole: author.role,
      content: text,
      createdAt: DateTime.now(),
    );

    // Optimistically add to list immediately so user sees it right away
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, localComment]);

    // Persist to backend
    try {
      final serverComment = await _repo.addComment(postId, text, parentId: parentId);
      if (serverComment.id != localComment.id) {
        final updatedList = (state.value ?? []).map((c) {
          return c.id == localComment.id ? serverComment : c;
        }).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (_) {
      // Retain optimistic comment in list
    }
  }
}
