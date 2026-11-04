import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/certificate_model.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../../data/repositories/certificate_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../explore/providers/explore_provider.dart';
import '../../home_farmer/providers/student_provider.dart';

// ── Repository Provider ─────────────────────────────────────────────

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return CertificateRepository(tokenStorage: tokenStorage);
});

// ── Student Official Certificates ───────────────────────────────────

/// Fetches all official certificates earned by the logged-in student across completed courses.
/// Calls GET /api/v1/certificates/my/, with automatic self-healing sync from completed student enrollments.
final myCertificatesProvider = FutureProvider.autoDispose<List<CertificateModel>>((ref) async {
  final repo = ref.watch(certificateRepositoryProvider);
  List<CertificateModel> certs = [];
  try {
    debugPrint('🎓 [CertificatesProvider] Fetching my certificates from backend');
    certs = await repo.getMyCertificates();
    debugPrint('✅ [CertificatesProvider] Fetched ${certs.length} certificates');
  } catch (e) {
    debugPrint('❌ [CertificatesProvider] Error fetching certificates: $e');
  }

  // Cross-reference completed enrollments: if a student has completed a course (100%),
  // auto-request/claim its certificate via GET /api/v1/certificates/course/{id}/ if missing from `my/`
  try {
    final enrollments = await ref.watch(studentEnrollmentsProvider.future);
    final completedList = enrollments.where((e) {
      final pct = (e.completionPercentage ?? 0).toDouble();
      return e.completed == true || pct >= 100.0;
    }).toList();

    for (final completedCourse in completedList) {
      final courseId = completedCourse.course;
      final courseSlug = completedCourse.courseSlug;
      final alreadyPresent = certs.any((c) =>
          (c.courseId != null && c.courseId == courseId) ||
          (courseSlug != null && c.courseSlug == courseSlug) ||
          (c.courseTitle.trim().toLowerCase() == (completedCourse.courseTitle ?? '').trim().toLowerCase()));

      if (!alreadyPresent && courseId.isNotEmpty) {
        try {
          final status = await repo.getCourseCertificate(courseId);
          if (status.certificate != null) {
            certs.add(status.certificate!);
          } else if (courseSlug != null && courseSlug.isNotEmpty && courseSlug != courseId) {
            final slugStatus = await repo.getCourseCertificate(courseSlug);
            if (slugStatus.certificate != null) {
              certs.add(slugStatus.certificate!);
            }
          }
        } catch (_) {}
      }
    }
  } catch (_) {}

  return certs;
});

/// Fetches or auto-issues a certificate for a specific course.
/// Calls GET `/api/v1/certificates/course/{course_id}/`
final courseCertificateProvider = FutureProvider.family.autoDispose<CourseCertificateStatus, String>((ref, courseId) async {
  final repo = ref.watch(certificateRepositoryProvider);
  return await repo.getCourseCertificate(courseId);
});

/// Verifies a certificate public code.
/// Calls GET `/api/v1/certificates/verify/{certificate_code}/`
final certificateVerificationProvider = FutureProvider.family.autoDispose<CertificateVerificationResult, String>((ref, code) async {
  final repo = ref.watch(certificateRepositoryProvider);
  return await repo.verifyCertificate(code);
});

// ── Enrollments for Course Progress ─────────────────────────────────

/// Provider fetching all user enrollments for tracking progress, synchronized with local progress and completed orders.
final certificateEnrollmentsProvider = FutureProvider.autoDispose<List<ApiEnrollment>>((ref) async {
  try {
    debugPrint('🎓 [CertificatesProvider] Syncing enrollments with studentEnrollmentsProvider');
    final enrollments = await ref.watch(studentEnrollmentsProvider.future);
    return enrollments.map((e) {
      final pct = (e.completionPercentage ?? 0).toDouble();
      return ApiEnrollment(
        id: e.id ?? '',
        course: e.course,
        courseTitle: e.courseTitle,
        courseSlug: e.courseSlug,
        courseThumbnail: e.courseThumbnail,
        enrolledAt: e.enrolledAt,
        completed: e.completed == true || pct >= 100.0,
        completionPercentage: pct,
      );
    }).toList();
  } catch (e) {
    debugPrint('❌ [CertificatesProvider] Error syncing enrollments: $e');
    // Fallback to courseRepository
    try {
      final repo = ref.watch(courseRepositoryProvider);
      final response = await repo.getEnrollments(page: 1);
      return response.results;
    } catch (_) {
      return [];
    }
  }
});

/// Legacy backward compatibility for completed enrollments
final completedCertificatesProvider = Provider.autoDispose<List<ApiEnrollment>>((ref) {
  final enrollmentsAsync = ref.watch(certificateEnrollmentsProvider);
  return enrollmentsAsync.maybeWhen(
    data: (list) => list.where((e) => e.completed || e.completionPercentage >= 100.0).toList(),
    orElse: () => [],
  );
});

/// Provider filtering enrollments still in progress.
final inProgressEnrollmentsProvider = Provider.autoDispose<List<ApiEnrollment>>((ref) {
  final enrollmentsAsync = ref.watch(certificateEnrollmentsProvider);
  return enrollmentsAsync.maybeWhen(
    data: (list) => list.where((e) => !e.completed && e.completionPercentage < 100.0).toList(),
    orElse: () => [],
  );
});
