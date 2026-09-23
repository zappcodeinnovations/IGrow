import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Provider for fetching the instructor's pending Q&A questions.
final instructorQaProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(instructorRepositoryProvider);
  return await repo.getQuestions();
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
  final response = await repo.getEBooks();
  return response.results;
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

