import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/api_models/course_models.dart';
import '../../../data/repositories/instructor_repository.dart';
import '../../auth/providers/auth_provider.dart';

final instructorRepositoryProvider = Provider<InstructorRepository>((ref) {
  return InstructorRepository(
    appApi: ref.watch(appApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Provider for fetching the instructor's stats overview.
final instructorStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(instructorRepositoryProvider);
  return await repo.getStats();
});

/// Provider for fetching the instructor's transactions.
final instructorTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(instructorRepositoryProvider);
  return await repo.getTransactions();
});

typedef InstructorQaQuery = ({String status, String courseId});

/// Provider for fetching the instructor's Q&A questions with filters.
final instructorQaFilteredProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, InstructorQaQuery>((ref, query) async {
  final repo = ref.watch(instructorRepositoryProvider);
  return await repo.getQuestions(status: query.status, courseId: query.courseId);
});

/// Backward-compatible provider for fetching the instructor's pending Q&A questions.
final instructorQaProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(instructorRepositoryProvider);
  return await repo.getQuestions(status: 'ALL');
});

typedef InstructorCoursesQuery = ({String search, String ordering});

/// Provider for fetching the instructor's authored courses.
final instructorCoursesProvider = FutureProvider.autoDispose.family<List<ApiCourseList>, InstructorCoursesQuery>((ref, query) async {
  final repo = ref.watch(instructorRepositoryProvider);
  final search = query.search;
  final ordering = query.ordering;
  final response = await repo.getCourses(
    search: (search.isNotEmpty) ? search : null,
    ordering: (ordering.isNotEmpty) ? ordering : null,
  );
  return response.results;
});

/// Provider for fetching the instructor's authored ebooks.
final instructorEbooksProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(instructorRepositoryProvider);
  try {
    final response = await repo.getEBooks();
    return response.results;
  } catch (e) {
    return [];
  }
});

/// Provider for fetching a specific course's details for the instructor.
final instructorCourseDetailProvider = FutureProvider.family<ApiCourseDetail, String>((ref, id) async {
  final repo = ref.watch(instructorRepositoryProvider);
  return await repo.getCourseDetail(id);
});

/// Provider for fetching course certificates.
final instructorCourseCertificatesProvider = FutureProvider.family<List<dynamic>, String>((ref, courseId) async {
  final repo = ref.watch(instructorRepositoryProvider);
  try {
    final response = await repo.getCertificates(courseId);
    return response.results;
  } catch (e) {
    return [];
  }
});

/// Provider for fetching all live reviews on the instructor's courses.
final instructorReviewsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(instructorRepositoryProvider);
  return await repo.getInstructorReviews();
});

/// Provider for tracking courses deactivated/archived by the instructor
/// Persisted locally via SharedPreferences so deactivated courses never show a delete button.
class DeactivatedCoursesNotifier extends StateNotifier<Set<String>> {
  DeactivatedCoursesNotifier() : super(<String>{}) {
    _load();
  }

  static const _key = 'instructor_deactivated_course_ids';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> markDeactivated(String courseId) async {
    if (courseId.isEmpty) return;
    final next = {...state, courseId};
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, next.toList());
    } catch (_) {}
  }

  Future<void> markReactivated(String courseId) async {
    if (courseId.isEmpty) return;
    final next = {...state}..remove(courseId);
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, next.toList());
    } catch (_) {}
  }

  bool isDeactivated(String courseId) => state.contains(courseId);
}

final deactivatedCoursesProvider =
    StateNotifierProvider<DeactivatedCoursesNotifier, Set<String>>((ref) {
  return DeactivatedCoursesNotifier();
});

/// Tracks the active content tab on the Instructor Home dashboard
/// 0 = Recent Courses (हाल के कोर्सेस), 1 = My E-Books (मेरी ई-पुस्तकें)
final instructorDashboardTabProvider = StateProvider<int>((ref) => 0);

