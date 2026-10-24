import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../models/api_models/course_models.dart';
import '../models/api_models/review_models.dart';

/// Repository for public course catalog, course detail, and enrollments.
class CourseRepository {
  CourseRepository({required this.appApi, this.tokenStorage});

  final AppApi appApi;
  final TokenStorage? tokenStorage;
  static const String _baseUrl = 'https://iagrow.zappcode.in/api/v1';

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

  /// Fetch full course detail by slug or ID with resilient type parsing.
  Future<ApiCourseDetail> getCourseDetail(String slug) async {
    final token = await tokenStorage?.getAccessToken();
    final headers = {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // 1. Try public courses endpoint
    try {
      final uri = Uri.parse('$_baseUrl/courses/$slug/');
      final response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ApiCourseDetail.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [CourseRepository] direct HTTP getCourseDetail error: $e');
    }

    // 2. If not found in public courses, try instructor courses endpoint (if course is draft / creator preview)
    if (token != null && token.isNotEmpty) {
      try {
        final instructorUri = Uri.parse('$_baseUrl/instructor/courses/$slug/');
        final instructorResponse = await http.get(instructorUri, headers: headers);
        if (instructorResponse.statusCode >= 200 && instructorResponse.statusCode < 300) {
          final decoded = jsonDecode(instructorResponse.body);
          if (decoded is Map<String, dynamic>) {
            return ApiCourseDetail.fromJson(decoded);
          }
        }
      } catch (e) {
        debugPrint('⚠️ [CourseRepository] instructor getCourseDetail error: $e');
      }
    }

    // 3. Fallback to Chopper appApi safely without unsafe type casting
    try {
      final response = await appApi.apiV1CoursesSlugGet(slug: slug);
      if (response.isSuccessful && response.body != null) {
        final dynamic data = response.body;
        Map<String, dynamic>? map;
        if (data is Map<String, dynamic>) {
          map = data;
        } else {
          try {
            final json = data.toJson();
            if (json is Map<String, dynamic>) map = json;
          } catch (_) {}
        }
        if (map != null) {
          return ApiCourseDetail.fromJson(map);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [CourseRepository] appApi fallback error: $e');
    }

    throw Exception('This course has not been approved or published yet.');
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

  /// Fetch all reviews for a course by slug or ID.
  Future<List<ApiCourseReview>> getCourseReviews(String slugOrId) async {
    debugPrint('⭐ [CourseRepository] getCourseReviews: slug=$slugOrId');
    try {
      final token = await tokenStorage?.getAccessToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/courses/$slugOrId/reviews/'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        List? list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['results'] is List) {
          list = decoded['results'] as List;
        }

        if (list != null) {
          final reviews = list
              .whereType<Map<String, dynamic>>()
              .map(ApiCourseReview.fromJson)
              .toList();
          debugPrint('✅ [CourseRepository] getCourseReviews: loaded ${reviews.length} reviews');
          return reviews;
        }
      } else {
        debugPrint('⚠️ [CourseRepository] getCourseReviews HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [CourseRepository] getCourseReviews error: $e');
    }
    return [];
  }

  /// Submit or update review for an enrolled course.
  Future<ApiCourseReview> submitCourseReview(
    String slugOrId, {
    required int rating,
    required String comment,
  }) async {
    debugPrint('⭐ [CourseRepository] submitCourseReview: slug=$slugOrId, rating=$rating');
    final token = await tokenStorage?.getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/courses/$slugOrId/reviews/'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );

    debugPrint('⭐ [CourseRepository] submit review status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('✅ [CourseRepository] submit review SUCCESS');
      return ApiCourseReview.fromJson(decoded);
    } else if (response.statusCode == 403) {
      throw Exception('You must be enrolled in this course to leave a review.');
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = (decoded is Map && decoded.containsKey('error'))
          ? decoded['error']
          : 'Failed to submit review (HTTP ${response.statusCode})';
      throw Exception(errorMsg);
    }
  }
}
