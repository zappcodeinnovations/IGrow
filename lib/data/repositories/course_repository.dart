import '../../core/network/api_client.dart';
import '../models/api_models/course_models.dart';

/// Repository for public course catalog, course detail, and enrollments.
class CourseRepository {
  CourseRepository({required this.appApi});

  final AppApi appApi;

  /// Fetch paginated course catalog with optional filters.
  ///
  /// Supports: `category`, `level`, `search`, `ordering`, `page`.
  Future<PaginatedResponse<ApiCourseList>> getCatalog({
    String? category,
    String? level,
    String? search,
    String? ordering,
    int? page,
  }) async {
    final response = await appApi.apiV1CoursesCatalogGet(
      category: category,
      level: level,
      search: search,
      ordering: ordering,
      page: page,
    );
    final dynamic data = response.body;

    return PaginatedResponse.fromJson(
      data?.toJson() as Map<String, dynamic>,
      ApiCourseList.fromJson,
    );
  }

  /// Fetch full course detail by slug.
  Future<ApiCourseDetail> getCourseDetail(String slug) async {
    final response = await appApi.apiV1CoursesSlugGet(slug: slug);
    final dynamic data = response.body;
    return ApiCourseDetail.fromJson(data?.toJson() as Map<String, dynamic>);
  }

  /// Fetch student's enrollment list.
  Future<PaginatedResponse<ApiEnrollment>> getEnrollments({
    int? page,
    String? search,
    String? ordering,
  }) async {
    final response = await appApi.apiV1EnrollmentsGet(
      page: page,
      search: search,
      ordering: ordering,
    );
    final dynamic data = response.body;

    return PaginatedResponse.fromJson(
      data?.toJson() as Map<String, dynamic>,
      ApiEnrollment.fromJson,
    );
  }

  /// Check if the current user is enrolled in a specific course.
  Future<bool> checkEnrollment(String courseId) async {
    try {
      final response = await appApi.apiV1EnrollmentsCheckCourseIdGet(courseId: courseId);
      final dynamic data = response.body;
      if (data is Map && data.containsKey('enrolled')) {
        return data['enrolled'] as bool;
      }
      if (data != null && (data as dynamic).enrolled != null) {
         return (data as dynamic).enrolled as bool;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
