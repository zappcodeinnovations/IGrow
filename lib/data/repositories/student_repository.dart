import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../models/api_models/instructor_model.dart';

/// Repository for student-specific operations.
class StudentRepository {
  StudentRepository({required this.appApi, required this.tokenStorage});

  final AppApi appApi;
  final TokenStorage tokenStorage;

  // ── Catalog ───────────────────────────────────────────────────

  /// Fetch course catalog.
  Future<PaginatedCourseListList> getCourseCatalog({
    int? page,
    String? search,
    String? category,
    String? level,
    num? minPrice,
    num? maxPrice,
    String? ordering,
  }) async {
    final response = await appApi.apiV1CoursesCatalogGet(
      page: page,
      search: search,
      category: category,
      level: level != null && level.isNotEmpty ? level.toLowerCase() : null,
      minPrice: minPrice,
      maxPrice: maxPrice,
      ordering: ordering != null && ordering.isNotEmpty ? ordering : null,
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to load courses catalog: ${response.error}');
    }
    return response.body!;
  }

  /// Fetch ebooks catalog.
  Future<PaginatedEBookList> getEbooksCatalog({
    int? page,
    String? search,
  }) async {
    final response = await appApi.apiV1EbooksGet(
      page: page,
      search: search,
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to load ebooks catalog: ${response.error}');
    }
    return response.body!;
  }

  /// Fetch specific ebook details (with live PDF stream URL).
  Future<EBook> getEbookDetail(String slugOrId) async {
    debugPrint('📖 [StudentRepository] getEbookDetail: slugOrId=$slugOrId');
    try {
      // 1. Try apiV1EbooksSlugReadGet which returns the read file URL directly
      final readResponse = await appApi.apiV1EbooksSlugReadGet(slug: slugOrId);
      if (readResponse.isSuccessful && readResponse.body != null) {
        debugPrint('✅ [StudentRepository] getEbookDetail SUCCESS from read endpoint: ${readResponse.body?.title}');
        return readResponse.body!;
      }
    } catch (e) {
      debugPrint('⚠️ [StudentRepository] getEbookDetail read endpoint failed: $e, falling back to slug get');
    }

    try {
      // 2. Fallback to apiV1EbooksSlugGet
      final response = await appApi.apiV1EbooksSlugGet(slug: slugOrId);
      if (response.isSuccessful && response.body != null) {
        debugPrint('✅ [StudentRepository] getEbookDetail SUCCESS from slug endpoint: ${response.body?.title}');
        return response.body!;
      }
    } catch (e) {
      debugPrint('⚠️ [StudentRepository] getEbookDetail slug endpoint failed: $e, falling back to direct HTTP');
    }

    // 3. Fallback to direct HTTP call with token if available
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/ebooks/$slugOrId/');
      final rawResponse = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
        final data = jsonDecode(rawResponse.body) as Map<String, dynamic>;
        debugPrint('✅ [StudentRepository] getEbookDetail direct HTTP SUCCESS: ${data['title']}');
        return EBook.fromJson(data);
      }
    } catch (e) {
      debugPrint('❌ [StudentRepository] getEbookDetail direct HTTP error: $e');
    }

    throw Exception('Failed to load E-Book. Please check your connection.');
  }

  /// Fetch categories.
  Future<PaginatedCategoryList> getCategories({int? page}) async {
    final response = await appApi.apiV1CategoriesGet(page: page);
    if (!response.isSuccessful) {
      throw Exception('Failed to load categories: ${response.error}');
    }
    return response.body!;
  }

  // ── Course Details ────────────────────────────────────────────

  /// Fetch specific course details by slug.
  Future<CourseDetail> getCourseDetails(String slug) async {
    final response = await appApi.apiV1CoursesSlugGet(slug: slug);
    if (!response.isSuccessful) {
      throw Exception('Failed to load course details: ${response.error}');
    }
    return response.body!;
  }

  // ── Enrollments ───────────────────────────────────────────────

  /// Fetch student enrollments (My Courses).
  Future<PaginatedEnrollmentList> getEnrollments({int? page}) async {
    final response = await appApi.apiV1EnrollmentsGet(page: page);
    if (!response.isSuccessful) {
      throw Exception('Failed to load enrollments: ${response.error}');
    }
    return response.body!;
  }

  /// Check if enrolled in a specific course.
  Future<bool> checkEnrollment(String courseId) async {
    final response = await appApi.apiV1EnrollmentsCheckCourseIdGet(courseId: courseId);
    return response.isSuccessful;
  }

  // ── Cart ──────────────────────────────────────────────────────

  /// Fetch user cart.
  Future<Cart> getCart() async {
    final response = await appApi.apiV1CartGet();
    if (!response.isSuccessful) {
      throw Exception('Failed to load cart: ${response.error}');
    }
    return response.body!;
  }

  /// Add item to cart.
  Future<void> addToCart({String? courseId, String? ebookId}) async {
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/cart/add/');
    
    final body = <String, dynamic>{};
    if (courseId != null) body['course_id'] = courseId;
    if (ebookId != null) body['ebook_id'] = ebookId;

    debugPrint('📤 [StudentRepository] addToCart: sending $body');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [StudentRepository] addToCart SUCCESS');
    } else {
      debugPrint('❌ [StudentRepository] addToCart ERROR (${response.statusCode}): ${response.body}');
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }

  /// Remove item from cart.
  Future<void> removeFromCart(String itemId) async {
    final response = await appApi.apiV1CartRemoveCourseIdDelete(courseId: itemId);
    if (!response.isSuccessful) {
      throw Exception('Failed to remove from cart: ${response.error}');
    }
  }

  // ── Progress ──────────────────────────────────────────────────

  /// Get course progress for all lectures in a course.
  Future<Map<String, dynamic>> getCourseProgress(String slug) async {
    debugPrint('🔍 [StudentRepository] getCourseProgress: courseSlug=$slug');
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/progress/course/$slug/');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [StudentRepository] getCourseProgress SUCCESS (${response.statusCode})');
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is List) return {'lectures': decoded};
        return {};
      }
      debugPrint('⚠️ [StudentRepository] getCourseProgress status (${response.statusCode}): ${response.body}');
      return {};
    } catch (e) {
      debugPrint('❌ [StudentRepository] getCourseProgress error: $e');
      return {};
    }
  }

  /// Update student's watched time and completion status for a lecture.
  Future<Map<String, dynamic>> updateLectureProgress(
    String lectureId, {
    bool completed = true,
    int? watchedTime,
  }) async {
    debugPrint('🎥 [StudentRepository] updateLectureProgress: lectureId=$lectureId, completed=$completed, watchedTime=$watchedTime');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/progress/$lectureId/');

    final payload = <String, dynamic>{
      'completed': completed,
      if (watchedTime != null) 'watched_time': watchedTime,
    };

    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [StudentRepository] updateLectureProgress SUCCESS (${response.statusCode})');
      if (response.body.isNotEmpty) {
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {}
      }
      return {'completed': completed};
    } else {
      debugPrint('❌ [StudentRepository] updateLectureProgress ERROR (${response.statusCode}): ${response.body}');
      throw Exception('Failed to update lecture progress (${response.statusCode}): ${response.body}');
    }
  }

  /// Get authorized lecture stream details (signed HLS stream URL for Bunny Stream).
  Future<Map<String, dynamic>> getLectureStream(String lectureId) async {
    debugPrint('🎬 [StudentRepository] getLectureStream: lectureId=$lectureId');
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/lectures/$lectureId/stream/');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [StudentRepository] getLectureStream SUCCESS (${response.statusCode}): ${response.body}');
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        return {};
      }
      debugPrint('⚠️ [StudentRepository] getLectureStream status (${response.statusCode}): ${response.body}');
      return {};
    } catch (e) {
      debugPrint('❌ [StudentRepository] getLectureStream error: $e');
      return {};
    }
  }

  // ── Q&A ─────────────────────────────────────────────────────────

  /// Get Q&A for a course.
  Future<List<Map<String, dynamic>>> getCourseQa(String slug) async {
    final response = await appApi.apiV1ProgressCourseCourseSlugQaGet(courseSlug: slug);
    if (!response.isSuccessful) {
      throw Exception('Failed to load course Q&A: ${response.error}');
    }
    final body = response.body;
    if (body is List) return body.cast<Map<String, dynamic>>();
    try {
      final decoded = jsonDecode(response.bodyString);
      if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  /// Post a question to course Q&A.
  Future<void> postCourseQa(String slug, String question) async {
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/progress/course/$slug/qa/');
    
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'question': question}),
    );
    if (response.statusCode >= 300) {
      throw Exception('Failed to post question: ${response.body}');
    }
  }

  /// Delete a Q&A question.
  Future<void> deleteQaQuestion(String questionId) async {
    final response = await appApi.apiV1ProgressQaQuestionIdDelete(questionId: questionId);
    if (!response.isSuccessful) {
      throw Exception('Failed to delete question: ${response.error}');
    }
  }

  // ── Notes ───────────────────────────────────────────────────────

  /// Get private notes for a course.
  Future<List<Map<String, dynamic>>> getCourseNotes(String slug) async {
    final response = await appApi.apiV1ProgressCourseCourseSlugNotesGet(courseSlug: slug);
    if (!response.isSuccessful) {
      throw Exception('Failed to load course notes: ${response.error}');
    }
    final body = response.body;
    if (body is List) return body.cast<Map<String, dynamic>>();
    try {
      final decoded = jsonDecode(response.bodyString);
      if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  /// Post a new private note.
  Future<void> postCourseNote(String slug, String text, int timestampSeconds) async {
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/progress/course/$slug/notes/');
    
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': text,
        'note_text': text,
        'timestamp': timestampSeconds,
      }),
    );
    if (response.statusCode >= 300) {
      throw Exception('Failed to post note: ${response.body}');
    }
  }

  /// Delete a note.
  Future<void> deleteNote(String noteId) async {
    final response = await appApi.apiV1ProgressNotesNoteIdDelete(noteId: noteId);
    if (!response.isSuccessful) {
      throw Exception('Failed to delete note: ${response.error}');
    }
  }

  // ── Quizzes ─────────────────────────────────────────────────────

  /// Get quiz for a section.
  Future<Map<String, dynamic>?> getSectionQuiz(String sectionId) async {
    final response = await appApi.apiV1QuizSectionSectionIdGet(sectionId: sectionId);
    if (!response.isSuccessful) {
      if (response.statusCode == 404) return null;
      throw Exception('Failed to load quiz: ${response.error}');
    }
    final body = response.body;
    if (body is Map<String, dynamic>) return body;
    try {
      return jsonDecode(response.bodyString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Submit a quiz.
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> answers) async {
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/quiz/$quizId/submit/');
    
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'answers': answers}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    } else {
      throw Exception('Failed to submit quiz: ${response.body}');
    }
  }

  // ── Instructors ─────────────────────────────────────────────────

  /// Fetch Top Instructors for student home screen and verified faculty showcase.
  Future<List<ApiTopInstructor>> getTopInstructors() async {
    debugPrint('👨‍🏫 [StudentRepository] getTopInstructors: fetching top instructors');
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructors/top/');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is Map && decoded['results'] is List) {
          list = decoded['results'] as List;
        } else if (decoded is List) {
          list = decoded;
        }

        if (list.isNotEmpty) {
          final instructors = list
              .whereType<Map>()
              .map((item) => ApiTopInstructor.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          debugPrint('✅ [StudentRepository] getTopInstructors SUCCESS: loaded ${instructors.length} instructors');
          return instructors;
        }
      }
      debugPrint('⚠️ [StudentRepository] getTopInstructors returned HTTP ${response.statusCode}, using verified faculty fallbacks');
    } catch (e) {
      debugPrint('❌ [StudentRepository] getTopInstructors error: $e, falling back to verified faculty');
    }

    return ApiTopInstructor.fallbacks;
  }
}
