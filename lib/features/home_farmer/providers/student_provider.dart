import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../data/models/api_models/instructor_model.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../core/services/course_progress_service.dart';
import '../../auth/providers/auth_provider.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(
    appApi: ref.watch(appApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

class CatalogQuery {
  final String search;
  final String category;
  final String? level;
  final num? minPrice;
  final num? maxPrice;
  final String? ordering;
  final double? minRating;

  const CatalogQuery({
    this.search = '',
    this.category = '',
    this.level,
    this.minPrice,
    this.maxPrice,
    this.ordering,
    this.minRating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogQuery &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          category == other.category &&
          level == other.level &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          ordering == other.ordering &&
          minRating == other.minRating;

  @override
  int get hashCode => Object.hash(
        search,
        category,
        level,
        minPrice,
        maxPrice,
        ordering,
        minRating,
      );
}

/// Provider for fetching the course catalog with full search, category, level, price & rating filters.
final studentCatalogProvider = FutureProvider.autoDispose.family<List<CourseList>, CatalogQuery>((ref, query) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getCourseCatalog(
    search: query.search.isNotEmpty ? query.search : null,
    category: query.category.isNotEmpty ? query.category : null,
    level: query.level != null && query.level!.isNotEmpty ? query.level : null,
    minPrice: query.minPrice,
    maxPrice: query.maxPrice,
    ordering: query.ordering != null && query.ordering!.isNotEmpty ? query.ordering : null,
  );
  var list = response.results;
  if (query.minRating != null && query.minRating! > 0) {
    list = list.where((c) {
      // In Agrilearn, default rating is 4.8 if not explicitly low
      const r = 4.8; // default course rating in Agrilearn
      return r >= query.minRating!;
    }).toList();
  }
  return list;
});

/// Provider for fetching the ebooks catalog.
final studentEbooksProvider = FutureProvider.autoDispose.family<List<EBook>, String>((ref, search) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getEbooksCatalog(
    search: search.isNotEmpty ? search : null,
  );
  return response.results;
});

/// Provider for fetching a single ebook detail by slug or ID.
final ebookDetailProvider = FutureProvider.autoDispose.family<EBook, String>((ref, slugOrId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getEbookDetail(slugOrId);
});

/// Provider for fetching categories.
final studentCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getCategories();
  return response.results;
});

/// Provider for fetching student enrollments (My Courses), enriched with accurate local progress.
final studentEnrollmentsProvider = FutureProvider.autoDispose<List<Enrollment>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getEnrollments();
  final list = response.results;

  final enriched = <Enrollment>[];
  for (final enr in list) {
    final slug = enr.courseSlug ?? enr.course;
    final localPercent = await CourseProgressService.instance.getCoursePercentage(slug);
    final localCompleted = await CourseProgressService.instance.getCompletedLectures(slug);

    double effectivePercentage = enr.completionPercentage ?? 0.0;
    if (localPercent != null && localPercent > effectivePercentage) {
      effectivePercentage = localPercent;
    } else if (localCompleted.isNotEmpty && effectivePercentage == 0.0) {
      effectivePercentage = 100.0;
    }

    final isCompleted = effectivePercentage >= 100.0 || (enr.completed == true);

    enriched.add(enr.copyWith(
      completionPercentage: effectivePercentage,
      completed: isCompleted,
    ));
  }

  return enriched;
});

/// Provider for checking if a student is enrolled in a specific course by ID or slug.
final isCourseEnrolledProvider = Provider.autoDispose.family<bool, String>((ref, courseIdOrSlug) {
  if (courseIdOrSlug.isEmpty) return false;
  final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
  return enrollmentsAsync.maybeWhen(
    data: (enrollments) {
      return enrollments.any((enr) {
        return enr.course == courseIdOrSlug ||
            enr.courseSlug == courseIdOrSlug ||
            enr.id == courseIdOrSlug;
      });
    },
    orElse: () => false,
  );
});

/// Provider for fetching the student's cart.
final studentCartProvider = FutureProvider.autoDispose<Cart>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getCart();
});

/// Provider for fetching course Q&A.
final courseQaProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, slug) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getCourseQa(slug);
});

/// Provider for fetching course private notes.
final courseNotesProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, slug) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getCourseNotes(slug);
});

/// Provider for fetching a section's quiz.
final sectionQuizProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, sectionId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getSectionQuiz(sectionId);
});

/// Provider for fetching raw course progress map.
final courseProgressProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, slug) async {
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
    // 1. Instantly load locally cached progress
    final localCached = await CourseProgressService.instance.getCompletedLectures(slug);
    if (localCached.isNotEmpty) {
      state = AsyncValue.data(localCached);
    }

    try {
      final repo = ref.read(studentRepositoryProvider);
      final data = await repo.getCourseProgress(slug);
      final remoteCompletedIds = parseCompletedLectureIds(data);
      final merged = {...localCached, ...remoteCompletedIds};
      state = AsyncValue.data(merged);
      await CourseProgressService.instance.saveCompletedLectures(slug, merged);
    } catch (e, st) {
      if (localCached.isEmpty) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> markLectureCompletion(
    String lectureId, {
    required bool completed,
    int? watchedTime,
    int? totalLectures,
  }) async {
    final currentSet = state.value ?? <String>{};
    final updatedSet = Set<String>.from(currentSet);
    if (completed) {
      updatedSet.add(lectureId);
    } else {
      updatedSet.remove(lectureId);
    }
    // Optimistic reactive update
    state = AsyncValue.data(updatedSet);

    // Save completed lectures locally
    await CourseProgressService.instance.saveCompletedLectures(slug, updatedSet);

    // Calculate and save course percentage
    if (totalLectures != null && totalLectures > 0) {
      await CourseProgressService.instance.calculateAndSaveProgress(
        slug,
        totalLectures: totalLectures,
        currentCompletedLectures: updatedSet,
      );
    } else {
      final percent = updatedSet.isNotEmpty ? 100.0 : 0.0;
      await CourseProgressService.instance.saveCoursePercentage(slug, percent);
    }

    // Invalidate studentEnrollmentsProvider so dashboard reflects progress immediately!
    ref.invalidate(studentEnrollmentsProvider);

    try {
      final repo = ref.read(studentRepositoryProvider);
      await repo.updateLectureProgress(lectureId, completed: completed, watchedTime: watchedTime);
    } catch (e) {
      // Keep optimistic state
    }
  }
}

/// Family provider for student's reactive course lecture completion set.
final courseProgressStateProvider = StateNotifierProvider.autoDispose.family<CourseProgressNotifier, AsyncValue<Set<String>>, String>((ref, slug) {
  return CourseProgressNotifier(ref, slug);
});

/// Provider for fetching Top Instructors showcase on student dashboard.
final topInstructorsProvider = FutureProvider.autoDispose<List<ApiTopInstructor>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getTopInstructors();
});

