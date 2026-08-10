import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for fetching the featured courses from the catalog.
final featuredCoursesProvider = FutureProvider<List<CourseList>>((ref) async {
  final appApi = ref.watch(appApiProvider);
  final response = await appApi.apiV1CoursesCatalogGet();
  if (!response.isSuccessful) {
    throw Exception('Failed to load featured courses');
  }
  return response.body?.results ?? [];
});

/// Provider for fetching the farmer's active enrollments.
final myEnrollmentsProvider = FutureProvider<List<Enrollment>>((ref) async {
  final appApi = ref.watch(appApiProvider);
  final response = await appApi.apiV1EnrollmentsGet();
  if (!response.isSuccessful) {
    throw Exception('Failed to load enrollments');
  }
  return response.body?.results ?? [];
});
