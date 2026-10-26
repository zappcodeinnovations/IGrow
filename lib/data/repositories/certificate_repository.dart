import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/network/token_storage.dart';
import '../models/api_models/certificate_model.dart';

/// Repository for handling Course Certificate API endpoints.
class CertificateRepository {
  CertificateRepository({required this.tokenStorage, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final TokenStorage tokenStorage;
  final http.Client _http;

  static const String _baseUrl = 'https://iagrow.zappcode.in/api/v1/certificates';

  /// Helper to get common headers
  Future<Map<String, String>> _authHeaders() async {
    final token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── 1. Get All My Certificates (Student) ─────────────────────────
  /// GET /api/v1/certificates/my/
  /// Fetches all official certificates earned by the logged-in student across completed courses.
  Future<List<CertificateModel>> getMyCertificates() async {
    final uri = Uri.parse('$_baseUrl/my/');
    debugPrint('🎓 [CertificateRepository] Fetching my certificates: $uri');

    final headers = await _authHeaders();
    final response = await _http.get(uri, headers: headers);

    debugPrint('🎓 [CertificateRepository] my certificates response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .map((item) => CertificateModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
        final list = decoded['results'] as List;
        return list
            .map((item) => CertificateModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      debugPrint('❌ [CertificateRepository] getMyCertificates failed: ${response.body}');
      throw Exception('Failed to load certificates: ${response.statusCode}');
    }
  }

  // ── 2. Get or Issue Certificate for Specific Course ──────────────
  /// `GET /api/v1/certificates/course/<course_id>/`
  /// Checks if the student has completed 100% of the course. Auto-issues if completed.
  Future<CourseCertificateStatus> getCourseCertificate(String courseId) async {
    final uri = Uri.parse('$_baseUrl/course/$courseId/');
    debugPrint('🏅 [CertificateRepository] Fetching certificate for course: $uri');

    final headers = await _authHeaders();
    final response = await _http.get(uri, headers: headers);

    debugPrint('🏅 [CertificateRepository] course certificate response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final cert = CertificateModel.fromJson(data);
      return CourseCertificateStatus.completed(cert);
    } else if (response.statusCode == 400) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error']?.toString() ?? 'Course not completed yet.';
        final completionPercentage = (data['completion_percentage'] as num?)?.toDouble() ?? 0.0;
        return CourseCertificateStatus.incomplete(
          percentage: completionPercentage,
          error: error,
        );
      } catch (_) {
        return CourseCertificateStatus.incomplete(
          percentage: 0.0,
          error: 'Course not completed yet.',
        );
      }
    } else if (response.statusCode == 404) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CourseCertificateStatus.notEnrolled(
          data['error']?.toString() ?? 'You are not enrolled in this course.',
        );
      } catch (_) {
        return CourseCertificateStatus.notEnrolled('You are not enrolled in this course.');
      }
    } else {
      throw Exception('Failed to fetch course certificate (${response.statusCode}): ${response.body}');
    }
  }

  // ── 3. Public Certificate Verification (QR Code / Link) ─────────
  /// `GET /api/v1/certificates/verify/<certificate_code>/`
  /// Public verification (No authentication required).
  Future<CertificateVerificationResult> verifyCertificate(String certificateCode) async {
    final cleanCode = Uri.encodeComponent(certificateCode.trim());
    final uri = Uri.parse('$_baseUrl/verify/$cleanCode/');
    debugPrint('🔍 [CertificateRepository] Verifying certificate: $uri');

    final response = await _http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    debugPrint('🔍 [CertificateRepository] verification response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return CertificateVerificationResult.fromJson(data);
    } else {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CertificateVerificationResult.fromJson(data);
      } catch (_) {
        return CertificateVerificationResult(
          isValid: false,
          error: 'Certificate not found or invalid verification code.',
        );
      }
    }
  }

  // ── 4. Preview Live Demo Certificate (Instructor / Admin) ────────
  /// `GET /api/v1/certificates/preview/<course_id>/`
  /// Returns a preview of how the certificate will look for any course with demo data.
  Future<CertificateModel> getPreviewCertificate(String courseId) async {
    final uri = Uri.parse('$_baseUrl/preview/$courseId/');
    debugPrint('👁️ [CertificateRepository] Fetching certificate preview: $uri');

    final headers = await _authHeaders();
    final response = await _http.get(uri, headers: headers);

    debugPrint('👁️ [CertificateRepository] preview response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return CertificateModel.fromJson(data);
    } else {
      throw Exception('Failed to load certificate preview (${response.statusCode}): ${response.body}');
    }
  }
}
