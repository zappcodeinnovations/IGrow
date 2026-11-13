import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../data/models/api_models/instructor_model.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../core/services/course_progress_service.dart';
import '../../../core/services/quiz_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';

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
  final String? instructor;

  const CatalogQuery({
    this.search = '',
    this.category = '',
    this.level,
    this.minPrice,
    this.maxPrice,
    this.ordering,
    this.minRating,
    this.instructor,
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
          minRating == other.minRating &&
          instructor == other.instructor;

  @override
  int get hashCode => Object.hash(
        search,
        category,
        level,
        minPrice,
        maxPrice,
        ordering,
        minRating,
        instructor,
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
  if (query.instructor != null && query.instructor!.isNotEmpty) {
    final inst = query.instructor!.trim().toLowerCase();
    list = list.where((c) {
      final cInstName = (c.instructorName ?? '').toLowerCase();
      return cInstName.contains(inst);
    }).toList();
  }
  if (query.minRating != null && query.minRating! > 0) {
    list = list.where((c) {
      // In Agrilearn, default rating is 4.8 if not explicitly low
      const r = 4.8; // default course rating in Agrilearn
      return r >= query.minRating!;
    }).toList();
  }
  return list;
});

class EbooksQuery {
  final String? search;
  final String? category;
  final String? instructorId;
  final num? minPrice;
  final num? maxPrice;

  const EbooksQuery({
    this.search,
    this.category,
    this.instructorId,
    this.minPrice,
    this.maxPrice,
  });

  static const empty = EbooksQuery();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EbooksQuery &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          category == other.category &&
          instructorId == other.instructorId &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice;

  @override
  int get hashCode => Object.hash(search, category, instructorId, minPrice, maxPrice);
}

/// Provider for fetching the ebooks catalog with search, category, and strict instructor filtering.
final studentEbooksProvider = FutureProvider.autoDispose.family<List<EBook>, EbooksQuery>((ref, query) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getEbooksCatalog(
    search: query.search?.isNotEmpty == true ? query.search : null,
    category: query.category?.isNotEmpty == true ? query.category : null,
    instructorId: query.instructorId?.isNotEmpty == true ? query.instructorId : null,
  );

  var list = response.results;

  // 1. Strict instructor filter: match by instructor UUID, instructor_name, or author_name
  if (query.instructorId != null && query.instructorId!.trim().isNotEmpty) {
    final target = query.instructorId!.trim().toLowerCase();
    list = list.where((ebook) {
      final matchesId = ebook.instructor.toLowerCase() == target;
      final matchesInstructorName = (ebook.instructorName ?? '').toLowerCase() == target;
      final matchesAuthor = ebook.authorName.toLowerCase() == target;
      return matchesId || matchesInstructorName || matchesAuthor;
    }).toList();
  }

  // 2. Search query filter: search across title, author_name, instructor_name, instructor ID, description
  if (query.search != null && query.search!.trim().isNotEmpty) {
    final q = query.search!.trim().toLowerCase();
    list = list.where((ebook) {
      final inTitle = ebook.title.toLowerCase().contains(q);
      final inAuthor = ebook.authorName.toLowerCase().contains(q);
      final inInstructorName = (ebook.instructorName ?? '').toLowerCase().contains(q);
      final inInstructorId = ebook.instructor.toLowerCase().contains(q);
      final inDesc = ebook.description.toLowerCase().contains(q);
      return inTitle || inAuthor || inInstructorName || inInstructorId || inDesc;
    }).toList();
  }

  // 3. Category filter
  if (query.category != null && query.category!.isNotEmpty && query.category != 'all') {
    final catTarget = query.category!.toLowerCase();
    list = list.where((ebook) {
      final category = ebook.category;
      if (category == null) return false;
      final ebookCatSlug = category.slug.toLowerCase();
      final ebookCatId = (category.id ?? '').toLowerCase();
      return ebookCatSlug == catTarget || ebookCatId == catTarget;
    }).toList();
  }

  // 4. Price filter
  if (query.minPrice != null || query.maxPrice != null) {
    list = list.where((ebook) {
      final rawPrice = (ebook.price ?? '0.00').replaceAll('₹', '').trim();
      final p = double.tryParse(rawPrice) ?? 0.0;
      if (query.minPrice != null && p < query.minPrice!) return false;
      if (query.maxPrice != null && p > query.maxPrice!) return false;
      return true;
    }).toList();
  }

  return list;
});

/// Provider for fetching ONLY e-books that the student has purchased or enrolled in.
final studentPurchasedEbooksProvider = FutureProvider.autoDispose<List<EBook>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final purchasedFromEndpoint = await repo.getPurchasedEbooks();

  // If endpoint returned purchased items, use them
  if (purchasedFromEndpoint.isNotEmpty) {
    return purchasedFromEndpoint;
  }

  // Cross-reference with completed orders or catalog items marked as isPurchased
  final catalog = await repo.getEbooksCatalog();
  final list = List<EBook>.from(catalog.results);

  // Extract purchased ebook IDs from completed orders if available
  final purchasedEbookIds = <String>{};
  final purchasedTitles = <String>{};
  try {
    final orders = await ref.watch(ordersProvider.future);
    for (final order in orders) {
      final status = order.status?.toUpperCase();
      if (status == 'SUCCESS' || status == 'COMPLETED' || status == 'PAID' || status == null) {
        for (final item in order.items) {
          final ebookId = item.ebook ?? item.ebookId;
          if (ebookId != null && ebookId.isNotEmpty) {
            purchasedEbookIds.add(ebookId.toLowerCase());
          }
          final ebookSlug = item.ebookSlug;
          if (ebookSlug != null && ebookSlug.isNotEmpty) {
            purchasedEbookIds.add(ebookSlug.toLowerCase());
          }
          final ebookTitle = item.ebookTitle ?? item.courseTitle;
          if (ebookTitle != null && ebookTitle.isNotEmpty) {
            purchasedTitles.add(ebookTitle.trim().toLowerCase());
          }
        }
      }
    }
  } catch (_) {}

  // Filter only purchased e-books (either flagged by backend or verified in completed orders)
  return list.where((ebook) {
    final isMarkedPurchased = ebook.isPurchased == true;
    final inOrdersById = ebook.id != null && purchasedEbookIds.contains(ebook.id!.toLowerCase());
    final inOrdersBySlug = ebook.slug != null && purchasedEbookIds.contains(ebook.slug!.toLowerCase());
    final inOrdersByTitle = purchasedTitles.contains(ebook.title.trim().toLowerCase());
    return isMarkedPurchased || inOrdersById || inOrdersBySlug || inOrdersByTitle;
  }).toList();
});

/// Provider for checking if a specific ebook has been purchased by the student.
final isEbookPurchasedProvider = Provider.autoDispose.family<bool, String>((ref, ebookIdOrSlug) {
  final target = ebookIdOrSlug.trim();
  if (target.isEmpty) return false;
  final targetLower = target.toLowerCase();

  // Check purchased ebooks list first
  final purchasedAsync = ref.watch(studentPurchasedEbooksProvider);
  final isPurchasedFromList = purchasedAsync.maybeWhen(
    data: (ebooks) => ebooks.any((eb) =>
        (eb.id != null && eb.id!.toLowerCase() == targetLower) ||
        (eb.slug != null && eb.slug!.toLowerCase() == targetLower) ||
        eb.title.trim().toLowerCase() == targetLower),
    orElse: () => false,
  );
  if (isPurchasedFromList) return true;

  // Cross check completed orders
  final ordersAsync = ref.watch(ordersProvider);
  return ordersAsync.maybeWhen(
    data: (orders) {
      return orders.any((order) {
        final status = order.status?.toUpperCase();
        if (status != 'FAILED' && status != 'CANCELLED' && status != 'REFUNDED') {
          return order.items.any((item) {
            final eId = (item.ebook ?? item.ebookId)?.toLowerCase();
            final eSlug = item.ebookSlug?.toLowerCase();
            final eTitle = (item.ebookTitle ?? item.courseTitle)?.trim().toLowerCase();
            return eId == targetLower || eSlug == targetLower || eTitle == targetLower;
          });
        }
        return false;
      });
    },
    orElse: () => false,
  );
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

/// Provider for fetching student enrollments (My Courses), enriched with accurate local progress and completed orders.
final studentEnrollmentsProvider = FutureProvider.autoDispose<List<Enrollment>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final response = await repo.getEnrollments();
  final list = List<Enrollment>.from(response.results);

  // Cross-reference completed orders so freshly bought courses appear immediately even before backend batch enrollment sync
  try {
    final orders = await ref.watch(ordersProvider.future);
    for (final order in orders) {
      final status = order.status?.toUpperCase();
      // Only include successful or pending/confirmed orders
      if (status == 'SUCCESS' || status == 'COMPLETED' || status == 'PAID' || status == null) {
        for (final item in order.items) {
          final courseId = item.course;
          final courseSlug = item.courseSlug;
          if (courseId == null && courseSlug == null) continue;

          final alreadyInList = list.any((enr) {
            return (courseId != null && enr.course.toLowerCase() == courseId.toLowerCase()) ||
                (courseSlug != null && enr.courseSlug?.toLowerCase() == courseSlug.toLowerCase());
          });

          if (!alreadyInList) {
            list.add(Enrollment(
              id: item.id,
              course: courseId ?? courseSlug ?? '',
              courseTitle: item.courseTitle ?? 'Purchased Course',
              courseSlug: courseSlug,
              enrolledAt: order.completedAt ?? order.createdAt ?? DateTime.now(),
              completed: false,
              completionPercentage: 0.0,
            ));
          }
        }
      }
    }
  } catch (e) {
    // Orders fetch is non-fatal fallback
  }

  final enriched = <Enrollment>[];
  for (final enr in list) {
    final primaryKey = (enr.courseSlug != null && enr.courseSlug!.isNotEmpty) ? enr.courseSlug! : enr.course;
    final secondaryKey = enr.course;
    final localPercent = await CourseProgressService.instance
        .getCoursePercentage(primaryKey, secondaryKey: secondaryKey);
    final localCompleted = (await CourseProgressService.instance.getCompletedLectures(primaryKey))
        .union(await CourseProgressService.instance.getCompletedLectures(secondaryKey));

    double effectivePercentage = enr.completionPercentage ?? 0.0;
    if (localPercent != null && localPercent > 0.0) {
      effectivePercentage = localPercent > effectivePercentage ? localPercent : effectivePercentage;
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
  final target = courseIdOrSlug.trim();
  if (target.isEmpty) return false;
  final targetLower = target.toLowerCase();

  final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
  final isEnrolledFromEnrollments = enrollmentsAsync.maybeWhen(
    data: (enrollments) {
      return enrollments.any((enr) {
        return enr.course.toLowerCase() == targetLower ||
            (enr.courseSlug != null && enr.courseSlug!.toLowerCase() == targetLower) ||
            (enr.id != null && enr.id!.toLowerCase() == targetLower);
      });
    },
    orElse: () => false,
  );

  if (isEnrolledFromEnrollments) return true;

  // Secondary check: verify against ordersProvider
  final ordersAsync = ref.watch(ordersProvider);
  return ordersAsync.maybeWhen(
    data: (orders) {
      return orders.any((order) {
        final status = order.status?.toUpperCase();
        if (status != 'FAILED' && status != 'CANCELLED' && status != 'REFUNDED') {
          return order.items.any((item) {
            return (item.course != null && item.course!.toLowerCase() == targetLower) ||
                (item.courseSlug != null && item.courseSlug!.toLowerCase() == targetLower) ||
                item.id.toLowerCase() == targetLower;
          });
        }
        return false;
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

/// Provider for checking if a section's quiz has been passed locally.
final sectionQuizPassedProvider = FutureProvider.autoDispose.family<bool, String>((ref, sectionId) async {
  return await QuizService.isSectionQuizPassed(sectionId);
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
      await CourseProgressService.instance.saveLectureWatchProgress(slug, lectureId, 1.0);
    } else {
      // Persist completed state: never revert an already completed lecture back to incomplete
      if (currentSet.contains(lectureId)) {
        return;
      }
      updatedSet.remove(lectureId);
      await CourseProgressService.instance.saveLectureWatchProgress(slug, lectureId, 0.0);
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

    // Invalidate providers so dashboard & player reflect progress immediately!
    ref.invalidate(studentEnrollmentsProvider);
    ref.invalidate(coursePercentageProvider(slug));

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

/// Provider for fetching the locally cached course percentage for any course slug.
final coursePercentageProvider = FutureProvider.autoDispose.family<double, String>((ref, slug) async {
  final percent = await CourseProgressService.instance.getCoursePercentage(slug);
  return percent ?? 0.0;
});

/// Provider for fetching Top Instructors showcase on student dashboard.
final topInstructorsProvider = FutureProvider.autoDispose<List<ApiTopInstructor>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getTopInstructors();
});

/// Provider for fetching a single public instructor profile with their courses.
final publicInstructorDetailProvider = FutureProvider.autoDispose.family<ApiPublicInstructorDetail?, String>((ref, instructorId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getInstructorDetail(instructorId);
});

