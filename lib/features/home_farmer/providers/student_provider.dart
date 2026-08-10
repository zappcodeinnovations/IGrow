import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../data/repositories/student_repository.dart';
import '../../auth/providers/auth_provider.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(
    appApi: ref.watch(appApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

typedef CatalogQuery = ({String search, String category});

/// Provider for fetching the course catalog.
final studentCatalogProvider = FutureProvider.family<List<CourseList>, CatalogQuery>((ref, query) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getCourseCatalog(
    search: query.search.isNotEmpty ? query.search : null,
    category: query.category.isNotEmpty ? query.category : null,
  );
  return response.results ?? [];
});

/// Provider for fetching the ebooks catalog.
final studentEbooksProvider = FutureProvider.family<List<EBook>, String>((ref, search) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getEbooksCatalog(
    search: search.isNotEmpty ? search : null,
  );
  return response.results;
});

/// Provider for fetching categories.
final studentCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getCategories();
  return response.results;
});

/// Provider for fetching student enrollments (My Courses).
final studentEnrollmentsProvider = FutureProvider<List<Enrollment>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getEnrollments();
  return response.results;
});

/// Provider for fetching the student's cart.
final studentCartProvider = FutureProvider<Cart>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getCart();
});

/// Provider for fetching course Q&A.
final courseQaProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, slug) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getCourseQa(slug);
});

/// Provider for fetching course private notes.
final courseNotesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, slug) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getCourseNotes(slug);
});

/// Provider for fetching a section's quiz.
final sectionQuizProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, sectionId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getSectionQuiz(sectionId);
});

/// Dummy Provider for fetching Top Instructors until backend API is ready.
final topInstructorsProvider = FutureProvider<List<dynamic>>((ref) async {
  // Simulating an empty list from the backend
  return [];
});
