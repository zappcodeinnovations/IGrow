import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/certificate_model.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../../data/repositories/certificate_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../explore/providers/explore_provider.dart';

// ── Repository Provider ─────────────────────────────────────────────

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return CertificateRepository(tokenStorage: tokenStorage);
});

// ── Student Official Certificates ───────────────────────────────────

/// Fetches all official certificates earned by the logged-in student across completed courses.
/// Calls GET /api/v1/certificates/my/
final myCertificatesProvider = FutureProvider.autoDispose<List<CertificateModel>>((ref) async {
  final repo = ref.watch(certificateRepositoryProvider);
  try {
    debugPrint('🎓 [CertificatesProvider] Fetching my certificates from backend');
    final certs = await repo.getMyCertificates();
    debugPrint('✅ [CertificatesProvider] Fetched ${certs.length} certificates');
    return certs;
  } catch (e) {
    debugPrint('❌ [CertificatesProvider] Error fetching certificates: $e');
    rethrow;
  }
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

/// Provider fetching all user enrollments for tracking progress.
final certificateEnrollmentsProvider = FutureProvider.autoDispose<List<ApiEnrollment>>((ref) async {
  final repo = ref.watch(courseRepositoryProvider);
  try {
    debugPrint('🎓 [CertificatesProvider] Fetching student enrollments');
    final response = await repo.getEnrollments(page: 1);
    debugPrint('✅ [CertificatesProvider] Loaded ${response.results.length} enrollments');
    return response.results;
  } catch (e) {
    debugPrint('❌ [CertificatesProvider] Error loading enrollments: $e');
    return [];
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
