import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../models/api_models/course_models.dart';
import '../models/api_models/user_profile.dart';

/// Repository for instructor-specific operations.
///
/// All endpoints require JWT and INSTRUCTOR role (enforced server-side).
class InstructorRepository {
  InstructorRepository({required this.appApi, required this.tokenStorage});

  final AppApi appApi;
  final TokenStorage tokenStorage;

  // ── Profile ───────────────────────────────────────────────────

  /// Get instructor profile details.
  Future<ApiInstructorProfile> getProfile() async {
    final response = await appApi.apiV1AuthInstructorProfileGet();
    final dynamic data = response.body;
    if (data is Map<String, dynamic>) return ApiInstructorProfile.fromJson(data);
    return ApiInstructorProfile.fromJson(data?.toJson() as Map<String, dynamic>);
  }

  /// Update instructor profile.
  Future<ApiInstructorProfile> updateProfile(
      Map<String, dynamic> updates) async {
    final response = await appApi.apiV1AuthInstructorProfilePatch(
      body: PatchedInstructorProfileRequest.fromJson(updates),
    );
    final dynamic data = response.body;
    if (data is Map<String, dynamic>) return ApiInstructorProfile.fromJson(data);
    return ApiInstructorProfile.fromJson(data?.toJson() as Map<String, dynamic>);
  }

  /// Get instructor dashboard stats.
  Future<Map<String, dynamic>> getStats() async {
    final response = await appApi.apiV1AuthInstructorStatsGet();
    final dynamic data = response.body;
    if (data is Map<String, dynamic>) return data;
    return data?.toJson() as Map<String, dynamic>? ?? {};
  }

  /// Get instructor transactions.
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await appApi.apiV1InstructorTransactionsGet();
    final dynamic data = response.body;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ── Courses ───────────────────────────────────────────────────

  /// List instructor's own courses.
  Future<PaginatedResponse<ApiCourseList>> getCourses({
    int? page,
    String? search,
    String? ordering,
  }) async {
    // 1. Direct HTTP call to avoid Chopper generated serializer TypeErrors
    try {
      final token = await tokenStorage.getAccessToken();
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (ordering != null && ordering.isNotEmpty) queryParams['ordering'] = ordering;

      final baseUri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/');
      final uri = queryParams.isNotEmpty ? baseUri.replace(queryParameters: queryParams) : baseUri;

      final rawResponse = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
        final dynamic decoded = jsonDecode(rawResponse.body);
        if (decoded is Map<String, dynamic>) {
          return PaginatedResponse.fromJson(
            decoded,
            ApiCourseList.fromJson,
          );
        } else if (decoded is List) {
          return PaginatedResponse<ApiCourseList>(
            count: decoded.length,
            results: decoded
                .whereType<Map<String, dynamic>>()
                .map((e) => ApiCourseList.fromJson(e))
                .toList(),
          );
        }
      }
      debugPrint('⚠️ [InstructorRepository] getCourses HTTP ${rawResponse.statusCode}: ${rawResponse.body}');
    } catch (e) {
      debugPrint('⚠️ [InstructorRepository] getCourses raw HTTP error: $e');
    }

    // 2. Fallback to appApi
    try {
      final response = await appApi.apiV1InstructorCoursesGet(
        ordering: ordering,
        page: page,
        search: search,
      );
      if (response.isSuccessful && response.bodyString.isNotEmpty) {
        final data = jsonDecode(response.bodyString) as Map<String, dynamic>;
        return PaginatedResponse.fromJson(
          data,
          ApiCourseList.fromJson,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [InstructorRepository] getCourses appApi fallback error: $e');
    }

    return const PaginatedResponse(count: 0, results: []);
  }

  /// Create a new course.
  Future<Map<String, dynamic>> createCourse(
      Map<String, dynamic> courseData, {String? imagePath}) async {
    debugPrint('📤 [InstructorRepository] createCourse: sending $courseData, imagePath=$imagePath');
    if (imagePath != null && imagePath.isNotEmpty) {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/');
      final request = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      courseData.forEach((key, value) {
        if (value != null) {
          if (value is String && value.isEmpty && (key == 'preview_video_url' || key == 'category_id')) {
            return;
          }
          request.fields[key] = value.toString();
        }
      });

      request.files.add(await http.MultipartFile.fromPath('thumbnail', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [InstructorRepository] createCourse MULTIPART SUCCESS: ${response.body}');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('❌ [InstructorRepository] createCourse MULTIPART ERROR (${response.statusCode}): ${response.body}');
        throw Exception('Failed to create course: ${response.body}');
      }
    } else {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/');

      // Sanitize fields to prevent null validation errors on non-nullable backend model fields
      final cleanData = <String, dynamic>{};
      courseData.forEach((key, value) {
        if (value != null) {
          cleanData[key] = value;
        }
      });
      // Django models for course do not allow null for these text fields (blank=True but not null=True)
      cleanData.putIfAbsent('preview_video_url', () => '');
      cleanData.putIfAbsent('what_you_learn', () => '');
      cleanData.putIfAbsent('requirements', () => '');
      cleanData.putIfAbsent('tags', () => '');

      final response = await http.post(
        uri,
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(cleanData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [InstructorRepository] createCourse SUCCESS: ${response.body}');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('❌ [InstructorRepository] createCourse ERROR (${response.statusCode}): ${response.body}');
        throw Exception('Failed to create course (${response.statusCode}): ${response.body}');
      }
    }
  }

  /// Get course detail.
  Future<ApiCourseDetail> getCourseDetail(String courseId) async {
    debugPrint('🔍 [InstructorRepository] getCourseDetail: courseId=$courseId');
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$courseId/');
      final rawResponse = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
        final data = jsonDecode(rawResponse.body) as Map<String, dynamic>;
        debugPrint('✅ [InstructorRepository] getCourseDetail SUCCESS: ${data['title']} (status=${data['status']}, sections=${(data['sections'] as List?)?.length ?? 0})');
        // Log lecture video fields for debugging
        final sections = data['sections'] as List? ?? [];
        for (final section in sections) {
          final lectures = (section as Map<String, dynamic>)['lectures'] as List? ?? [];
          for (final lec in lectures) {
            final l = lec as Map<String, dynamic>;
            debugPrint('📹 [getCourseDetail] Lecture "${l['title']}": video_url=${l['video_url']}, bunny_video_id=${l['bunny_video_id']}, bunny_status=${l['bunny_status']}');
          }
        }
        return ApiCourseDetail.fromJson(data);
      }
      debugPrint('⚠️ [InstructorRepository] getCourseDetail raw HTTP (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Server returned ${rawResponse.statusCode}: ${rawResponse.body}');
    } catch (e) {
      debugPrint('❌ [InstructorRepository] getCourseDetail error: $e');
      rethrow;
    }
  }

  /// Update a course.
  Future<Map<String, dynamic>> updateCourse(
      String courseId, Map<String, dynamic> updates) async {
    debugPrint('✏️ [InstructorRepository] updateCourse: courseId=$courseId, updates=$updates');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$courseId/');

    final sanitized = Map<String, dynamic>.from(updates);
    if (sanitized.containsKey('price') && sanitized['price'] != null) {
      sanitized['price'] = sanitized['price'].toString();
    }

    final rawResponse = await http.patch(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(sanitized),
    );

    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] updateCourse ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Failed to update course (${rawResponse.statusCode}): ${rawResponse.body}');
    }
    debugPrint('✅ [InstructorRepository] updateCourse SUCCESS: ${rawResponse.body}');
    if (rawResponse.body.isEmpty) return {};
    return jsonDecode(rawResponse.body) as Map<String, dynamic>;
  }

  /// Delete a course.
  Future<void> deleteCourse(String courseId) async {
    debugPrint('🗑️ [InstructorRepository] deleteCourse: courseId=$courseId');
    await appApi.apiV1InstructorCoursesIdDelete(id: courseId);
    debugPrint('✅ [InstructorRepository] deleteCourse SUCCESS');
  }

  /// Publish a course (triggers AI moderation).
  Future<Map<String, dynamic>> publishCourse(String courseId) async {
    // Use raw HTTP to avoid Chopper trying to deserialize CourseList from
    // the publish response body (which may be empty or not match the schema).
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse(
      'https://iagrow.zappcode.in/api/v1/instructor/courses/$courseId/publish/',
    );
    debugPrint('📤 [InstructorRepository] publishCourse: POST $uri');
    final rawResponse = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] publishCourse ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception(
        'Failed to publish course (${rawResponse.statusCode}): ${rawResponse.body}',
      );
    }
    final body = rawResponse.body;
    debugPrint('✅ [InstructorRepository] publishCourse SUCCESS: $body');
    if (body.isEmpty) return {};
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// Get moderation status for a course.
  Future<Map<String, dynamic>> getModerationStatus(String courseId) async {
    final response = await appApi.apiV1InstructorCoursesIdModerationStatusGet(id: courseId);
    if (!response.isSuccessful) {
      throw Exception('Failed to get moderation status: ${response.error}');
    }
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  // ── Sections ──────────────────────────────────────────────────

  /// List sections for a course.
  Future<PaginatedResponse<ApiCourseSection>> getSections(
    String coursePk, {
    int? page,
    String? ordering,
  }) async {
    final response = await appApi.apiV1InstructorCoursesCoursePkSectionsGet(
      coursePk: coursePk,
    );
    final data = jsonDecode(response.bodyString) as Map<String, dynamic>;

    return PaginatedResponse.fromJson(
      data,
      ApiCourseSection.fromJson,
    );
  }

  /// Create a section in a course.
  Future<Map<String, dynamic>> createSection(
      String coursePk, Map<String, dynamic> sectionData) async {
    debugPrint('➕ [InstructorRepository] createSection: coursePk=$coursePk, data=$sectionData');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$coursePk/sections/');
    final rawResponse = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(sectionData),
    );
    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] createSection ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Failed to create section (${rawResponse.statusCode}): ${rawResponse.body}');
    }
    debugPrint('✅ [InstructorRepository] createSection SUCCESS: ${rawResponse.body}');
    if (rawResponse.body.isEmpty) return {};
    return jsonDecode(rawResponse.body) as Map<String, dynamic>;
  }

  /// Update a section.
  Future<Map<String, dynamic>> updateSection(
      String coursePk, String sectionId, Map<String, dynamic> updates) async {
    debugPrint('✏️ [InstructorRepository] updateSection: coursePk=$coursePk, sectionId=$sectionId, updates=$updates');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$coursePk/sections/$sectionId/');
    final rawResponse = await http.patch(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );
    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] updateSection ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Failed to update section (${rawResponse.statusCode}): ${rawResponse.body}');
    }
    debugPrint('✅ [InstructorRepository] updateSection SUCCESS: ${rawResponse.body}');
    if (rawResponse.body.isEmpty) return {};
    return jsonDecode(rawResponse.body) as Map<String, dynamic>;
  }

  /// Delete a section.
  Future<void> deleteSection(String coursePk, String sectionId) async {
    debugPrint('🗑️ [InstructorRepository] deleteSection: coursePk=$coursePk, sectionId=$sectionId');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$coursePk/sections/$sectionId/');
    final rawResponse = await http.delete(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] deleteSection ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Failed to delete section (${rawResponse.statusCode}): ${rawResponse.body}');
    }
    debugPrint('✅ [InstructorRepository] deleteSection SUCCESS');
  }

  // ── Lectures ──────────────────────────────────────────────────

  /// List lectures in a section.
  Future<PaginatedResponse<ApiLecture>> getLectures(
    String coursePk,
    String sectionPk, {
    int? page,
  }) async {
    final response = await appApi.apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesGet(
      coursePk: coursePk,
      sectionPk: sectionPk,
    );
    final dynamic data = response.body;

    return PaginatedResponse.fromJson(
      data?.toJson() as Map<String, dynamic>,
      ApiLecture.fromJson,
    );
  }

  /// Create a lecture.
  Future<Map<String, dynamic>> createLecture(
    String coursePk,
    String sectionPk,
    Map<String, dynamic> lectureData,
  ) async {
    debugPrint('📤 [InstructorRepository] createLecture: sending $lectureData');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$coursePk/sections/$sectionPk/lectures/');
    final rawResponse = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(lectureData),
    );
    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] createLecture ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Failed to create lecture (${rawResponse.statusCode}): ${rawResponse.body}');
    }
    debugPrint('✅ [InstructorRepository] createLecture SUCCESS: ${rawResponse.body}');
    if (rawResponse.body.isEmpty) return {};
    return jsonDecode(rawResponse.body) as Map<String, dynamic>;
  }

  /// Update a lecture.
  Future<Map<String, dynamic>> updateLecture(
    String coursePk,
    String sectionPk,
    String lectureId,
    Map<String, dynamic> updates,
  ) async {
    debugPrint('✏️ [InstructorRepository] updateLecture: lectureId=$lectureId, updates=$updates');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$coursePk/sections/$sectionPk/lectures/$lectureId/');
    final rawResponse = await http.patch(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );
    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] updateLecture ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Failed to update lecture (${rawResponse.statusCode}): ${rawResponse.body}');
    }
    debugPrint('✅ [InstructorRepository] updateLecture SUCCESS: ${rawResponse.body}');
    if (rawResponse.body.isEmpty) return {};
    return jsonDecode(rawResponse.body) as Map<String, dynamic>;
  }

  /// Delete a lecture.
  Future<void> deleteLecture(
      String coursePk, String sectionPk, String lectureId) async {
    debugPrint('🗑️ [InstructorRepository] deleteLecture: lectureId=$lectureId');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$coursePk/sections/$sectionPk/lectures/$lectureId/');
    final rawResponse = await http.delete(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (rawResponse.statusCode < 200 || rawResponse.statusCode >= 300) {
      debugPrint('❌ [InstructorRepository] deleteLecture ERROR (${rawResponse.statusCode}): ${rawResponse.body}');
      throw Exception('Failed to delete lecture (${rawResponse.statusCode}): ${rawResponse.body}');
    }
    debugPrint('✅ [InstructorRepository] deleteLecture SUCCESS');
  }

  // ── Certificates ────────────────────────────────────────────────

  /// List certificates for a course.
  Future<PaginatedCertificateTemplateList> getCertificates(String coursePk, {int? page}) async {
    final response = await appApi.apiV1InstructorCoursesCoursePkCertificateGet(coursePk: coursePk, page: page);
    if (!response.isSuccessful) {
      throw Exception('Failed to get certificates: ${response.error}');
    }
    return response.body!;
  }

  /// Create a certificate.
  Future<Map<String, dynamic>> createCertificate(String coursePk, Map<String, dynamic> data) async {
    final response = await appApi.apiV1InstructorCoursesCoursePkCertificatePost(
      coursePk: coursePk,
      body: CertificateTemplateRequest.fromJson(data),
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to create certificate: ${response.error}');
    }
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Delete a certificate.
  Future<void> deleteCertificate(String coursePk, String certId) async {
    await appApi.apiV1InstructorCoursesCoursePkCertificateIdDelete(
      coursePk: coursePk,
      id: certId,
    );
  }

  // ── E-Books ─────────────────────────────────────────────────────

  /// List instructor's ebooks.
  Future<PaginatedEBookList> getEBooks({int? page}) async {
    final response = await appApi.apiV1InstructorEbooksGet(page: page);
    if (!response.isSuccessful) {
      throw Exception('Failed to get ebooks: ${response.error}');
    }
    return response.body!;
  }

  /// Create E-Book draft.
  Future<Map<String, dynamic>> createEBook(
    Map<String, dynamic> data, {
    String? filePath,
    String? coverImagePath,
  }) async {
    debugPrint('📤 [InstructorRepository] createEBook: sending data=$data, filePath=$filePath, coverImagePath=$coverImagePath');
    if (filePath != null || coverImagePath != null) {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/ebooks/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('pdf_file', filePath));
      }
      if (coverImagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('cover_image', coverImagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [InstructorRepository] createEBook MULTIPART SUCCESS: ${response.body}');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('❌ [InstructorRepository] createEBook MULTIPART ERROR (${response.statusCode}): ${response.body}');
        throw Exception('Failed to create ebook (${response.statusCode}): ${response.body}');
      }
    } else {
      final response = await appApi.apiV1InstructorEbooksPost(
        body: EBookCreateUpdateRequest.fromJson(data),
      );
      if (!response.isSuccessful) {
        debugPrint('❌ [InstructorRepository] createEBook ERROR: ${response.error}');
        throw Exception('Failed to create ebook: ${response.error}');
      }
      debugPrint('✅ [InstructorRepository] createEBook SUCCESS: ${response.bodyString}');
      return jsonDecode(response.bodyString) as Map<String, dynamic>;
    }
  }

  /// Update E-Book.
  Future<Map<String, dynamic>> updateEBook(String ebookId, Map<String, dynamic> updates) async {
    final response = await appApi.apiV1InstructorEbooksIdPatch(
      id: ebookId,
      body: PatchedEBookCreateUpdateRequest.fromJson(updates),
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to update ebook: ${response.error}');
    }
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Submit E-Book.
  Future<Map<String, dynamic>> submitEBook(String ebookId) async {
    debugPrint('📤 [InstructorRepository] submitEBook: submitting $ebookId');
    final response = await appApi.apiV1InstructorEbooksIdSubmitPost(
      id: ebookId,
      body: null,
    );
    if (!response.isSuccessful) {
      debugPrint('❌ [InstructorRepository] submitEBook ERROR: ${response.error}');
      throw Exception('Failed to submit ebook: ${response.error}');
    }
    debugPrint('✅ [InstructorRepository] submitEBook SUCCESS: ${response.bodyString}');
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Delete E-Book.
  Future<void> deleteEBook(String ebookId) async {
    final response = await appApi.apiV1InstructorEbooksIdDelete(id: ebookId);
    if (!response.isSuccessful) {
      if (response.statusCode >= 500) {
        throw Exception('Server Error: Failed to delete e-book. The backend crashed.');
      }
      
      String errorMsg = 'Failed to delete ebook';
      if (response.error != null) {
        final errorStr = response.error.toString();
        // Prevent showing HTML if backend returns 404/400 HTML page
        if (errorStr.trim().startsWith('<')) {
          errorMsg = '$errorMsg (HTTP ${response.statusCode})';
        } else {
          errorMsg = '$errorMsg: $errorStr';
        }
      }
      throw Exception(errorMsg);
    }
  }

  // ── Q&A ─────────────────────────────────────────────────────────

  /// Fetch pending questions.
  Future<List<Map<String, dynamic>>> getQuestions() async {
    final response = await appApi.apiV1InstructorQaGet();
    final dynamic data = response.body;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Answer a question.
  Future<void> answerQuestion(String questionId, String answer) async {
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/qa/$questionId/answer/');
    final rawResponse = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'answer_text': answer,
        'answer': answer,
      }),
    );
    if (rawResponse.statusCode >= 300) {
      throw Exception('Failed to answer question: ${rawResponse.body}');
    }
  }

  /// Upload video for a lecture.
  Future<Map<String, dynamic>> uploadVideo(
    String lectureId,
    String filePath, {
    Duration timeout = const Duration(minutes: 5),
    http.Client? client,
  }) async {
    debugPrint('📤 [InstructorRepository] uploadVideo START: lectureId=$lectureId, path=$filePath');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/lectures/$lectureId/upload-video/');
    
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('video', filePath));
    
    final httpClient = client ?? http.Client();
    try {
      final streamedResponse = await httpClient.send(request).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Video upload timed out (${timeout.inSeconds}s). Server or internet connection is too slow.');
        },
      );
      final response = await http.Response.fromStream(streamedResponse).timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw TimeoutException('Server took too long to acknowledge video upload.');
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [InstructorRepository] uploadVideo SUCCESS (${response.statusCode}): ${response.body}');
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        return {};
      } else {
        debugPrint('❌ [InstructorRepository] uploadVideo ERROR (${response.statusCode}): ${response.body}');
        if (response.body.contains('Bunny Stream API') || response.body.contains('Failed to initialize video')) {
          throw Exception('Video server notice: Bunny Stream CDN is currently being activated or under maintenance.');
        } else if (response.statusCode == 413) {
          throw Exception('Video file size is too large for the server. Please compress the file.');
        } else if (response.statusCode >= 500) {
          throw Exception('Video server error (${response.statusCode}). Please retry in a few moments.');
        }
        throw Exception('Failed to upload video (${response.statusCode}): ${response.body}');
      }
    } on TimeoutException {
      rethrow;
    } on SocketException catch (sErr) {
      debugPrint('❌ [InstructorRepository] uploadVideo network error: $sErr');
      throw Exception('Network connection failed during video upload. Please check your internet.');
    } catch (e) {
      debugPrint('❌ [InstructorRepository] uploadVideo error: $e');
      rethrow;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Upload study material / resource (PDF, docx, xlsx, etc.) for a lecture.
  Future<Map<String, dynamic>> uploadResource(
    String lectureId,
    String filePath, {
    String? fileName,
    Duration timeout = const Duration(seconds: 30),
    http.Client? client,
  }) async {
    final name = fileName ?? filePath.split(RegExp(r'[/\\]')).last;
    debugPrint('📄 [InstructorRepository] uploadResource START: lectureId=$lectureId, name=$name, path=$filePath');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/lectures/$lectureId/upload-resource/');
    
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['file_name'] = name;
    request.files.add(await http.MultipartFile.fromPath('file', filePath, filename: name));
    
    final httpClient = client ?? http.Client();
    try {
      final streamedResponse = await httpClient.send(request).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Study material upload timed out (${timeout.inSeconds}s). Please check your internet connection.');
        },
      );
      final response = await http.Response.fromStream(streamedResponse).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Server took too long to acknowledge file upload.');
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [InstructorRepository] uploadResource SUCCESS (${response.statusCode}): ${response.body}');
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        return {};
      } else {
        debugPrint('❌ [InstructorRepository] uploadResource ERROR (${response.statusCode}): ${response.body}');
        if (response.statusCode == 413) {
          throw Exception('File size is too large for the server.');
        }
        throw Exception('Failed to upload resource (${response.statusCode}): ${response.body}');
      }
    } on TimeoutException {
      rethrow;
    } on SocketException catch (sErr) {
      debugPrint('❌ [InstructorRepository] uploadResource network error: $sErr');
      throw Exception('Network error while uploading study material. Please check your internet.');
    } catch (e) {
      debugPrint('❌ [InstructorRepository] uploadResource error: $e');
      rethrow;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Upload a certificate template (image or PDF) for a course.
  Future<Map<String, dynamic>> uploadCertificateTemplate(
    String coursePk,
    String filePath, {
    String title = 'Certificate of Completion',
  }) async {
    debugPrint('🎓 [InstructorRepository] uploadCertificateTemplate START: coursePk=$coursePk, path=$filePath');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/courses/$coursePk/certificate/');
    
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.files.add(await http.MultipartFile.fromPath('template_image', filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [InstructorRepository] uploadCertificateTemplate SUCCESS (${response.statusCode}): ${response.body}');
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {};
    } else {
      debugPrint('❌ [InstructorRepository] uploadCertificateTemplate ERROR (${response.statusCode}): ${response.body}');
      throw Exception('Failed to upload certificate (${response.statusCode}): ${response.body}');
    }
  }

  // ── Reviews & Ratings ──────────────────────────────────────────

  /// Fetch all reviews received on instructor's courses.
  Future<List<Map<String, dynamic>>> getInstructorReviews() async {
    final token = await tokenStorage.getAccessToken();

    // 1. First try the dedicated instructor reviews endpoint
    try {
      final response = await http.get(
        Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/reviews/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          debugPrint('⭐ [InstructorRepository] Loaded ${decoded.length} reviews from /instructor/reviews/');
          return decoded.cast<Map<String, dynamic>>();
        } else if (decoded is Map && decoded['results'] is List && (decoded['results'] as List).isNotEmpty) {
          final list = (decoded['results'] as List).cast<Map<String, dynamic>>();
          debugPrint('⭐ [InstructorRepository] Loaded ${list.length} paginated reviews from /instructor/reviews/');
          return list;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [InstructorRepository] /instructor/reviews/ error: $e');
    }

    // 2. Fallback: Aggregate reviews directly across instructor's authored courses
    try {
      final coursesRes = await getCourses();
      final courses = coursesRes.results;
      final List<Map<String, dynamic>> allReviews = [];

      // Build ID and title to slug mapping from catalog in case instructor course object has null slug
      final Map<String, String> idToSlug = {};
      final Map<String, String> titleToSlug = {};
      try {
        final catRes = await http.get(
          Uri.parse('https://iagrow.zappcode.in/api/v1/courses/catalog/'),
          headers: {'Accept': 'application/json'},
        );
        if (catRes.statusCode >= 200 && catRes.statusCode < 300) {
          final catDecoded = jsonDecode(catRes.body);
          final catList = (catDecoded is Map ? catDecoded['results'] : catDecoded) as List?;
          if (catList != null) {
            for (final c in catList) {
              if (c is Map<String, dynamic>) {
                final id = c['id']?.toString() ?? '';
                final slug = c['slug']?.toString() ?? '';
                final title = c['title']?.toString() ?? '';
                if (id.isNotEmpty && slug.isNotEmpty) idToSlug[id] = slug;
                if (title.isNotEmpty && slug.isNotEmpty) titleToSlug[title.toLowerCase()] = slug;
              }
            }
          }
        }
      } catch (_) {}

      await Future.wait(courses.map((course) async {
        String? slug = course.slug;
        if (slug == null || slug.isEmpty) {
          slug = idToSlug[course.id] ?? titleToSlug[course.title.toLowerCase()];
        }
        if (slug == null || slug.isEmpty) return;

        try {
          final res = await http.get(
            Uri.parse('https://iagrow.zappcode.in/api/v1/courses/$slug/reviews/'),
            headers: {'Accept': 'application/json'},
          );
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final decoded = jsonDecode(res.body);
            if (decoded is List) {
              for (final r in decoded) {
                if (r is Map<String, dynamic>) {
                  allReviews.add({
                    ...r,
                    if (!r.containsKey('course_title') || r['course_title'] == null)
                      'course_title': course.title,
                  });
                }
              }
            }
          }
        } catch (_) {}
      }));

      // Sort by newest created_at first
      allReviews.sort((a, b) {
        final aDate = a['created_at']?.toString() ?? '';
        final bDate = b['created_at']?.toString() ?? '';
        return bDate.compareTo(aDate);
      });

      debugPrint('⭐ [InstructorRepository] Consolidated ${allReviews.length} reviews across ${courses.length} courses');
      return allReviews;
    } catch (e) {
      debugPrint('⚠️ [InstructorRepository] getInstructorReviews fallback error: $e');
      return [];
    }
  }

  /// Reply to a student review.
  Future<void> replyToReview(String reviewId, String reply) async {
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/reviews/$reviewId/reply/');
    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reply': reply,
        'instructor_reply': reply,
        'reply_text': reply,
        'comment': reply,
      }),
    );
    if (response.statusCode >= 300) {
      debugPrint('⚠️ [InstructorRepository] replyToReview status ${response.statusCode}: ${response.body}');
      throw Exception('Failed to send reply (${response.statusCode})');
    }
  }
}
