import 'package:flutter/foundation.dart';

/// Model representing a course completion certificate issued by IAgrow.
class CertificateModel {
  const CertificateModel({
    required this.id,
    required this.certificateCode,
    this.courseId,
    this.courseSlug,
    required this.studentName,
    required this.courseTitle,
    this.instructorName,
    this.instructorTitle,
    this.templateStyle,
    this.signatureImage,
    this.issuedAt,
    this.verificationUrl,
  });

  final String id;
  final String certificateCode;
  final String? courseId;
  final String? courseSlug;
  final String studentName;
  final String courseTitle;
  final String? instructorName;
  final String? instructorTitle;
  final String? templateStyle;
  final String? signatureImage;
  final DateTime? issuedAt;
  final String? verificationUrl;

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['issued_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['issued_at'].toString());
      } catch (e) {
        debugPrint('⚠️ [CertificateModel] Error parsing issued_at: $e');
      }
    }

    // Clean signature image url if relative
    String? signature = json['signature_image']?.toString();
    if (signature != null && signature.isNotEmpty) {
      if (!signature.startsWith('http')) {
        signature = 'https://iagrow.zappcode.in${signature.startsWith('/') ? '' : '/'}$signature';
      }
    }

    return CertificateModel(
      id: json['id']?.toString() ?? '',
      certificateCode: json['certificate_code']?.toString() ?? '',
      courseId: json['course_id']?.toString(),
      courseSlug: json['course_slug']?.toString(),
      studentName: json['student_name']?.toString() ?? 'Student',
      courseTitle: json['course_title']?.toString() ?? 'Course Certificate',
      instructorName: json['instructor_name']?.toString(),
      instructorTitle: json['instructor_title']?.toString(),
      templateStyle: json['template_style']?.toString() ?? 'modern',
      signatureImage: signature,
      issuedAt: parsedDate,
      verificationUrl: json['verification_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'certificate_code': certificateCode,
      if (courseId != null) 'course_id': courseId,
      if (courseSlug != null) 'course_slug': courseSlug,
      'student_name': studentName,
      'course_title': courseTitle,
      if (instructorName != null) 'instructor_name': instructorName,
      if (instructorTitle != null) 'instructor_title': instructorTitle,
      if (templateStyle != null) 'template_style': templateStyle,
      if (signatureImage != null) 'signature_image': signatureImage,
      if (issuedAt != null) 'issued_at': issuedAt?.toIso8601String(),
      if (verificationUrl != null) 'verification_url': verificationUrl,
    };
  }

  CertificateModel copyWith({
    String? id,
    String? certificateCode,
    String? courseId,
    String? courseSlug,
    String? studentName,
    String? courseTitle,
    String? instructorName,
    String? instructorTitle,
    String? templateStyle,
    String? signatureImage,
    DateTime? issuedAt,
    String? verificationUrl,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      certificateCode: certificateCode ?? this.certificateCode,
      courseId: courseId ?? this.courseId,
      courseSlug: courseSlug ?? this.courseSlug,
      studentName: studentName ?? this.studentName,
      courseTitle: courseTitle ?? this.courseTitle,
      instructorName: instructorName ?? this.instructorName,
      instructorTitle: instructorTitle ?? this.instructorTitle,
      templateStyle: templateStyle ?? this.templateStyle,
      signatureImage: signatureImage ?? this.signatureImage,
      issuedAt: issuedAt ?? this.issuedAt,
      verificationUrl: verificationUrl ?? this.verificationUrl,
    );
  }
}

/// Result of public certificate verification endpoint:
/// `GET /api/v1/certificates/verify/<certificate_code>/`
class CertificateVerificationResult {
  const CertificateVerificationResult({
    required this.isValid,
    this.certificateCode,
    this.studentName,
    this.courseTitle,
    this.instructorName,
    this.issuedAt,
    this.message,
    this.error,
  });

  final bool isValid;
  final String? certificateCode;
  final String? studentName;
  final String? courseTitle;
  final String? instructorName;
  final DateTime? issuedAt;
  final String? message;
  final String? error;

  factory CertificateVerificationResult.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['issued_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['issued_at'].toString());
      } catch (_) {}
    }

    return CertificateVerificationResult(
      isValid: json['is_valid'] == true || json['valid'] == true,
      certificateCode: json['certificate_code']?.toString(),
      studentName: json['student_name']?.toString(),
      courseTitle: json['course_title']?.toString(),
      instructorName: json['instructor_name']?.toString(),
      issuedAt: parsedDate,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
    );
  }
}

/// Status wrapper for course certificate retrieval:
/// `GET /api/v1/certificates/course/<course_id>/`
class CourseCertificateStatus {
  const CourseCertificateStatus({
    required this.isCompleted,
    this.completionPercentage = 0.0,
    this.certificate,
    this.error,
  });

  final bool isCompleted;
  final double completionPercentage;
  final CertificateModel? certificate;
  final String? error;

  factory CourseCertificateStatus.completed(CertificateModel cert) {
    return CourseCertificateStatus(
      isCompleted: true,
      completionPercentage: 100.0,
      certificate: cert,
    );
  }

  factory CourseCertificateStatus.incomplete({
    required double percentage,
    required String error,
  }) {
    return CourseCertificateStatus(
      isCompleted: false,
      completionPercentage: percentage,
      error: error,
    );
  }

  factory CourseCertificateStatus.notEnrolled(String error) {
    return CourseCertificateStatus(
      isCompleted: false,
      completionPercentage: 0.0,
      error: error,
    );
  }
}
