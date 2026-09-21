import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/api_models/course_models.dart';
import '../../../data/models/api_models/review_models.dart';
import '../../../data/repositories/course_repository.dart';
import '../../auth/providers/auth_provider.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(
    appApi: ref.watch(appApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

typedef ExploreCoursesQuery = ({String search, String category, String level, String ordering});

/// Provider for fetching courses in explore screen with optional search and category query.
final exploreCoursesProvider = FutureProvider.family<List<ApiCourseList>, ExploreCoursesQuery>((ref, query) async {
  final repo = ref.watch(courseRepositoryProvider);
  final search = query.search;
  final category = query.category;
  final level = query.level;
  final ordering = query.ordering;
  final response = await repo.getCatalog(
    search: (search.isNotEmpty) ? search : null,
    category: (category.isNotEmpty && category != 'all') ? category : null,
    level: (level.isNotEmpty && level != 'all') ? level : null,
    ordering: (ordering.isNotEmpty) ? ordering : null,
  );
  return response.results;
});

final courseDetailProvider = FutureProvider.family<ApiCourseDetail, String>((ref, id) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getCourseDetail(id);
});

/// Provider for fetching live student reviews for a course.
final courseReviewsProvider = FutureProvider.family<List<ApiCourseReview>, String>((ref, slugOrId) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getCourseReviews(slugOrId);
});

/// Reactive StateNotifier for managing persistent lecture bookmarks per course.
class LectureBookmarksNotifier extends StateNotifier<Set<String>> {
  LectureBookmarksNotifier(this.courseSlug) : super({}) {
    _loadBookmarks();
  }

  final String courseSlug;

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('lecture_bookmarks_$courseSlug') ?? [];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> toggleBookmark(String lectureId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(lectureId)) {
      updated.remove(lectureId);
    } else {
      updated.add(lectureId);
    }
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('lecture_bookmarks_$courseSlug', updated.toList());
    } catch (_) {}
  }

  bool isBookmarked(String lectureId) => state.contains(lectureId);
}

final lectureBookmarksProvider = StateNotifierProvider.family<LectureBookmarksNotifier, Set<String>, String>((ref, courseSlug) {
  return LectureBookmarksNotifier(courseSlug);
});
