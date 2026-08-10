import 'dart:convert';
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
    final response = await appApi.apiV1InstructorCoursesGet(
      ordering: ordering,
      page: page,
      search: search,
    );
    final data = jsonDecode(response.bodyString) as Map<String, dynamic>;

    return PaginatedResponse.fromJson(
      data,
      ApiCourseList.fromJson,
    );
  }

  /// Create a new course.
  Future<Map<String, dynamic>> createCourse(
      Map<String, dynamic> courseData) async {
    debugPrint('📤 [InstructorRepository] createCourse: sending $courseData');
    final response = await appApi.apiV1InstructorCoursesPost(
      body: CourseCreateRequest.fromJson(courseData),
    );
    if (!response.isSuccessful) {
      debugPrint('❌ [InstructorRepository] createCourse ERROR: ${response.error}');
      throw Exception('Failed to create course: ${response.error}');
    }
    debugPrint('✅ [InstructorRepository] createCourse SUCCESS: ${response.bodyString}');
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Get course detail.
  Future<ApiCourseDetail> getCourseDetail(String courseId) async {
    final response = await appApi.apiV1InstructorCoursesIdGet(id: courseId);
    final data = jsonDecode(response.bodyString) as Map<String, dynamic>;
    return ApiCourseDetail.fromJson(data);
  }

  /// Update a course.
  Future<Map<String, dynamic>> updateCourse(
      String courseId, Map<String, dynamic> updates) async {
    final response = await appApi.apiV1InstructorCoursesIdPatch(
      id: courseId,
      body: PatchedCourseCreateRequest.fromJson(updates),
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to update course: ${response.error}');
    }
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Delete a course.
  Future<void> deleteCourse(String courseId) async {
    await appApi.apiV1InstructorCoursesIdDelete(id: courseId);
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
    final response = await appApi.apiV1InstructorCoursesCoursePkSectionsPost(
      coursePk: coursePk,
      body: CourseSectionCreateRequest.fromJson(sectionData),
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to create section: ${response.error}');
    }
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Update a section.
  Future<Map<String, dynamic>> updateSection(
      String coursePk, String sectionId, Map<String, dynamic> updates) async {
    final response = await appApi.apiV1InstructorCoursesCoursePkSectionsIdPatch(
      coursePk: coursePk,
      id: sectionId,
      body: PatchedCourseSectionCreateRequest.fromJson(updates),
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to update section: ${response.error}');
    }
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Delete a section.
  Future<void> deleteSection(String coursePk, String sectionId) async {
    await appApi.apiV1InstructorCoursesCoursePkSectionsIdDelete(
      coursePk: coursePk,
      id: sectionId,
    );
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
    final response = await appApi.apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesPost(
      coursePk: coursePk,
      sectionPk: sectionPk,
      body: LectureCreateRequest.fromJson(lectureData),
    );
    if (!response.isSuccessful) {
      debugPrint('❌ [InstructorRepository] createLecture ERROR: ${response.error}');
      throw Exception('Failed to create lecture: ${response.error}');
    }
    debugPrint('✅ [InstructorRepository] createLecture SUCCESS: ${response.bodyString}');
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Update a lecture.
  Future<Map<String, dynamic>> updateLecture(
    String coursePk,
    String sectionPk,
    String lectureId,
    Map<String, dynamic> updates,
  ) async {
    final response = await appApi.apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPatch(
      coursePk: coursePk,
      sectionPk: sectionPk,
      id: lectureId,
      body: PatchedLectureCreateRequest.fromJson(updates),
    );
    if (!response.isSuccessful) {
      throw Exception('Failed to update lecture: ${response.error}');
    }
    return jsonDecode(response.bodyString) as Map<String, dynamic>;
  }

  /// Delete a lecture.
  Future<void> deleteLecture(
      String coursePk, String sectionPk, String lectureId) async {
    await appApi.apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdDelete(
      coursePk: coursePk,
      sectionPk: sectionPk,
      id: lectureId,
    );
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
  Future<Map<String, dynamic>> createEBook(Map<String, dynamic> data, {String? filePath}) async {
    debugPrint('📤 [InstructorRepository] createEBook: sending data=$data, filePath=$filePath');
    if (filePath != null) {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/ebooks/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      request.files.add(await http.MultipartFile.fromPath('pdf_file', filePath));
      
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
    // The endpoint is a POST with no body schema? Let's check how to pass answer.
    // Assuming we pass it in raw form if there's no typed body.
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/instructor/qa/$questionId/answer/');
    final rawResponse = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'answer': answer}),
    );
    if (rawResponse.statusCode >= 300) {
      throw Exception('Failed to answer question: ${rawResponse.body}');
    }
  }

  /// Upload video for a lecture.
  Future<Map<String, dynamic>> uploadVideo(String lectureId, String filePath) async {
    // We use standard http.MultipartRequest here because Chopper's multipart
    // might require generating specific MultipartFile objects which can be tricky.
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/lectures/$lectureId/upload-video/');
    
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('video', filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {};
    } else {
      throw Exception('Failed to upload video (${response.statusCode}): ${response.body}');
    }
  }
}
