import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/course_models.dart';
import '../../../data/repositories/course_repository.dart';
import '../../auth/providers/auth_provider.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(appApi: ref.watch(appApiProvider));
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
