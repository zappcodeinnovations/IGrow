import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/course_models.dart';
import '../../explore/providers/explore_provider.dart';

/// Provider fetching all user enrollments for certificate management.
final studentEnrollmentsProvider = FutureProvider<List<ApiEnrollment>>((ref) async {
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

/// Provider filtering enrollments that are 100% completed with certificates available.
final completedCertificatesProvider = Provider<List<ApiEnrollment>>((ref) {
  final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
  return enrollmentsAsync.maybeWhen(
    data: (list) => list.where((e) => e.completed || e.completionPercentage >= 100.0).toList(),
    orElse: () => [],
  );
});

/// Provider filtering enrollments still in progress.
final inProgressEnrollmentsProvider = Provider<List<ApiEnrollment>>((ref) {
  final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
  return enrollmentsAsync.maybeWhen(
    data: (list) => list.where((e) => !e.completed && e.completionPercentage < 100.0).toList(),
    orElse: () => [],
  );
});
