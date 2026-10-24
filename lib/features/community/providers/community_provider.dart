import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/weather_service.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_farmer/providers/weather_provider.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return CommunityRepository(tokenStorage: tokenStorage);
});

// ─── Student Discovery Tabs Provider ──────────────────────────────
final studentCommunityTabProvider = StateProvider<int>((ref) => 0); // 0: Recommended, 1: All, 2: My Communities

// ─── Suggested Hubs Provider (Location-Aware) ──────────────────────
final suggestedHubsProvider = FutureProvider<List<CommunityHub>>((ref) async {
  final repo = ref.watch(communityRepositoryProvider);
  final district = ref.watch(selectedDistrictProvider);
  return repo.getSuggestedHubs(district: district);
});

// ─── Instructor Owned Hub Provider (State A vs State B) ────────────
final myInstructorHubProvider = FutureProvider<CommunityHub?>((ref) async {
  final authUser = ref.watch(authProvider).user;
  if (authUser == null || (!authUser.isInstructor && !authUser.isAdmin)) {
    return null;
  }
  final repo = ref.watch(communityRepositoryProvider);
  final allHubs = await repo.getHubs();
  final myHub = allHubs.where((h) {
    if (h.instructorId.isNotEmpty && h.instructorId == authUser.id) return true;
    if (h.instructorName.trim().toLowerCase() == authUser.fullName.trim().toLowerCase()) return true;
    return false;
  }).toList();
  return myHub.isNotEmpty ? myHub.first : null;
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
  // 1. Profile saved district
  final authState = ref.read(authProvider);
  final userDistrict = authState.user?.locationDistrict;
  if (userDistrict != null && userDistrict.trim().isNotEmpty) {
    return userDistrict.trim();
  }

  // 2. Real-time GPS location resolved on dashboard by weatherProvider
  final liveCity = ref.read(weatherProvider).valueOrNull?.locationName;
  if (liveCity != null && liveCity.trim().isNotEmpty) {
    return liveCity.trim();
  }

  // 3. Last resolved GPS city cached by WeatherService
  final cachedCity = WeatherService.lastResolvedCity;
  if (cachedCity != null && cachedCity.trim().isNotEmpty) {
    return cachedCity.trim();
  }

  // 4. Default fallback
  return 'Pune';
});

// ─── Hubs Providers ────────────────────────────────────────────────

final selectedHubProvider = StateProvider<CommunityHub?>((ref) => null);

final communityHubsProvider = StateNotifierProvider<CommunityHubsNotifier, AsyncValue<List<CommunityHub>>>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  final state = ref.watch(selectedStateProvider);
  final district = ref.watch(selectedDistrictProvider);
  return CommunityHubsNotifier(repo, ref: ref, stateName: state, districtName: district);
});

class CommunityHubsNotifier extends StateNotifier<AsyncValue<List<CommunityHub>>> {
  CommunityHubsNotifier(this._repo, {this.ref, required this.stateName, required this.districtName})
      : super(const AsyncValue.loading()) {
    fetchHubs();
  }

  final CommunityRepository _repo;
  final Ref? ref;
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

  Future<bool> toggleJoin(String hubId, {bool? currentIsMember, int? currentMemberCount}) async {
    final currentList = state.value;
    final index = currentList != null ? currentList.indexWhere((h) => h.id == hubId) : -1;
    final oldHub = index != -1 ? currentList![index] : null;

    final isCurrentlyMember = oldHub?.isMember ?? currentIsMember ?? false;
    final isJoining = !isCurrentlyMember;
    final oldCount = oldHub?.memberCount ?? currentMemberCount ?? 0;
    final newCount = isJoining ? oldCount + 1 : (oldCount > 0 ? oldCount - 1 : 0);

    // Optimistically update communityHubsProvider if present
    if (index != -1 && currentList != null) {
      final updatedHub = oldHub!.copyWith(
        isMember: isJoining,
        memberCount: newCount,
      );
      final updatedList = List<CommunityHub>.from(currentList);
      updatedList[index] = updatedHub;
      state = AsyncValue.data(updatedList);
    }

    try {
      final res = await _repo.toggleJoinHub(hubId);
      final rawIsMember = res['is_member'] ?? res['is_joined'] ?? res['joined'];
      final serverIsMember = rawIsMember is bool
          ? rawIsMember
          : (rawIsMember == 1 || rawIsMember == 'true' || (rawIsMember == null ? isJoining : false));
      final rawCount = res['member_count'] ?? res['members_count'] ?? res['total_members'];
      final serverCount = (rawCount is int) ? rawCount : int.tryParse(rawCount?.toString() ?? '');

      if (index != -1 && state.value != null) {
        final verifiedList = List<CommunityHub>.from(state.value!);
        final vIdx = verifiedList.indexWhere((h) => h.id == hubId);
        if (vIdx != -1) {
          verifiedList[vIdx] = verifiedList[vIdx].copyWith(
            isMember: serverIsMember,
            memberCount: serverCount ?? newCount,
          );
          state = AsyncValue.data(verifiedList);
        }
      }

      // Invalidate dependent providers to synchronize all screens (Recommended, Details, etc.)
      ref?.invalidate(suggestedHubsProvider);
      ref?.invalidate(hubDetailsProvider(hubId));
      return serverIsMember;
    } catch (e) {
      // Revert if was present in currentList
      if (index != -1 && oldHub != null && state.value != null) {
        final revertedList = List<CommunityHub>.from(state.value!);
        final rIdx = revertedList.indexWhere((h) => h.id == hubId);
        if (rIdx != -1) {
          revertedList[rIdx] = oldHub;
          state = AsyncValue.data(revertedList);
        }
      }
      rethrow;
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

final communityHubPostsProvider = StateNotifierProvider.family<CommunityPostsNotifier, AsyncValue<List<CommunityPost>>, String>((ref, hubId) {
  final repo = ref.watch(communityRepositoryProvider);
  return CommunityPostsNotifier(repo, ref, hubId: hubId);
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

  final Set<String> _viewedPosts = {};

  Future<void> recordView(String postId) async {
    if (_viewedPosts.contains(postId)) return;
    _viewedPosts.add(postId);

    if (state.value != null) {
      final oldPosts = state.value!;
      final index = oldPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = oldPosts[index];
        final updatedPost = post.copyWith(viewsCount: post.viewsCount + 1);
        final updatedList = List<CommunityPost>.from(oldPosts);
        updatedList[index] = updatedPost;
        state = AsyncValue.data(updatedList);
      }
    }

    try {
      final res = await _repo.incrementPostView(postId);
      final serverViews = res['views_count'] as int?;
      if (serverViews != null && state.value != null) {
        final currentPosts = state.value!;
        final idx = currentPosts.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          final p = currentPosts[idx];
          final updated = p.copyWith(viewsCount: serverViews);
          final updatedList = List<CommunityPost>.from(currentPosts);
          updatedList[idx] = updated;
          state = AsyncValue.data(updatedList);
        }
      }
    } catch (_) {}
  }

  Future<bool> reactToPost(String postId, String reaction) async {
    if (state.value == null) return false;
    final oldPosts = state.value!;
    final index = oldPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;

    final post = oldPosts[index];
    final isUnreacting = post.userReaction == reaction;
    final newUserReaction = isUnreacting ? null : reaction;
    int newCount = post.reactionsCount;
    if (isUnreacting) {
      newCount = (newCount > 0) ? newCount - 1 : 0;
    } else if (post.userReaction == null) {
      newCount += 1;
    }

    final newPost = post.copyWith(
      userReaction: newUserReaction,
      reactionsCount: newCount,
    );

    final newPosts = List<CommunityPost>.from(oldPosts);
    newPosts[index] = newPost;
    state = AsyncValue.data(newPosts);

    try {
      final response = await _repo.reactToPost(postId, reaction);
      final serverCount = (response['reactions_count'] ?? response['likes_count']) as int?;
      final serverReaction = response['user_reaction']?.toString();

      if (serverCount != null || serverReaction != null) {
        final verifiedPost = newPost.copyWith(
          reactionsCount: serverCount ?? newCount,
          userReaction: serverReaction ?? newUserReaction,
        );
        final verifiedPosts = List<CommunityPost>.from(state.value ?? newPosts);
        final vIdx = verifiedPosts.indexWhere((p) => p.id == postId);
        if (vIdx != -1) {
          verifiedPosts[vIdx] = verifiedPost;
          state = AsyncValue.data(verifiedPosts);
        }
      }
      return true;
    } catch (e) {
      final revertedPosts = List<CommunityPost>.from(state.value ?? oldPosts);
      final rIndex = revertedPosts.indexWhere((p) => p.id == postId);
      if (rIndex != -1) {
        revertedPosts[rIndex] = post;
        state = AsyncValue.data(revertedPosts);
      }
      return false;
    }
  }

  Future<bool> toggleLike(String postId) async {
    return reactToPost(postId, 'LIKE');
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
