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
  return response.results;
});

/// Provider for fetching the ebooks catalog.
final studentEbooksProvider = FutureProvider.family<List<EBook>, String>((ref, search) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getEbooksCatalog(
    search: search.isNotEmpty ? search : null,
  );
  return response.results;
});

/// Provider for fetching a single ebook detail by slug or ID.
final ebookDetailProvider = FutureProvider.family<EBook, String>((ref, slugOrId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getEbookDetail(slugOrId);
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

/// Provider for fetching raw course progress map.
final courseProgressProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getCourseProgress(slug);
});

/// Helper to parse completed lecture IDs from various backend response shapes.
Set<String> parseCompletedLectureIds(dynamic progressData) {
  final completed = <String>{};
  if (progressData == null) return completed;

  if (progressData is Map) {
    final pMap = progressData['progress'];
    if (pMap is Map) {
      pMap.forEach((key, val) {
        if (val is Map && (val['is_completed'] == true || val['completed'] == true)) {
          completed.add(key.toString());
        } else if (val == true) {
          completed.add(key.toString());
        }
      });
    }

    final cList = progressData['completed_lectures'] ?? progressData['lectures'];
    if (cList is List) {
      for (final item in cList) {
        if (item is Map) {
          final id = item['lecture_id'] ?? item['lecture'] ?? item['id'];
          final isDone = item['is_completed'] == true || item['completed'] == true;
          if (id != null && isDone) {
            completed.add(id.toString());
          }
        } else if (item != null) {
          completed.add(item.toString());
        }
      }
    }
  } else if (progressData is List) {
    for (final item in progressData) {
      if (item is Map) {
        final id = item['lecture_id'] ?? item['lecture'] ?? item['id'];
        final isDone = item['is_completed'] == true || item['completed'] == true;
        if (id != null && isDone) {
          completed.add(id.toString());
        }
      } else if (item != null) {
        completed.add(item.toString());
      }
    }
  }
  return completed;
}

/// State notifier for tracking and optimistically updating course completed lecture IDs.
class CourseProgressNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  CourseProgressNotifier(this.ref, this.slug) : super(const AsyncValue.loading()) {
    loadProgress();
  }

  final Ref ref;
  final String slug;

  Future<void> loadProgress() async {
    try {
      final repo = ref.read(studentRepositoryProvider);
      final data = await repo.getCourseProgress(slug);
      final completedIds = parseCompletedLectureIds(data);
      state = AsyncValue.data(completedIds);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markLectureCompletion(String lectureId, {required bool completed, int? watchedTime}) async {
    final currentSet = state.value ?? <String>{};
    final updatedSet = Set<String>.from(currentSet);
    if (completed) {
      updatedSet.add(lectureId);
    } else {
      updatedSet.remove(lectureId);
    }
    // Optimistic reactive update
    state = AsyncValue.data(updatedSet);

    try {
      final repo = ref.read(studentRepositoryProvider);
      await repo.updateLectureProgress(lectureId, completed: completed, watchedTime: watchedTime);
    } catch (e) {
      // Keep optimistic state or handle error gracefully
    }
  }
}

/// Family provider for student's reactive course lecture completion set.
final courseProgressStateProvider = StateNotifierProvider.family<CourseProgressNotifier, AsyncValue<Set<String>>, String>((ref, slug) {
  return CourseProgressNotifier(ref, slug);
});

/// Dummy Provider for fetching Top Instructors until backend API is ready.
final topInstructorsProvider = FutureProvider<List<dynamic>>((ref) async {
  // Simulating an empty list from the backend
  return [];
});

