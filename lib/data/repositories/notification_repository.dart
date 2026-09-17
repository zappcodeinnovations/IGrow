import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../models/api_models/course_models.dart';
import '../models/api_models/notification_models.dart';

/// Repository for notifications and moderation logs matching AgriLearn.
class NotificationRepository {
  NotificationRepository({
    required this.appApi,
    required this.tokenStorage,
  });

  final AppApi appApi;
  final TokenStorage tokenStorage;

  /// Fetch notifications (Student or Instructor based on role).
  Future<List<ApiNotification>> getNotifications({
    bool isStudent = false,
    String? ordering,
  }) async {
    debugPrint('🔔 [NotificationRepository] getNotifications: isStudent=$isStudent');
    final token = await tokenStorage.getAccessToken();
    final endpoint = isStudent
        ? 'https://iagrow.zappcode.in/api/v1/notifications/student/'
        : 'https://iagrow.zappcode.in/api/v1/notifications/';

    final uri = Uri.parse(endpoint);

    try {
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = <dynamic>[];
        if (decoded is List) {
          list.addAll(decoded);
        } else if (decoded is Map && decoded['results'] is List) {
          list.addAll(decoded['results'] as List);
        }

        final notifications = list
            .whereType<Map<String, dynamic>>()
            .map((e) => ApiNotification.fromJson(e))
            .toList();

        debugPrint('✅ [NotificationRepository] getNotifications SUCCESS: loaded ${notifications.length} items');
        return notifications;
      } else {
        debugPrint('⚠️ [NotificationRepository] getNotifications HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [NotificationRepository] getNotifications HTTP error: $e');
    }

    // Fallback to Swagger Chopper client
    try {
      if (isStudent) {
        final res = await appApi.apiV1NotificationsStudentGet(ordering: ordering);
        final list = res.body ?? [];
        return list.map((e) => ApiNotification(
          id: e.id ?? '',
          notificationType: e.notificationType.value ?? 'NOTIFICATION',
          title: e.title,
          message: e.message,
          course: e.course,
          courseTitle: e.courseTitle,
          ebookId: e.ebookId,
          ebookTitle: e.ebookTitle,
          isRead: e.isRead ?? false,
          createdAt: e.createdAt,
        )).toList();
      } else {
        final res = await appApi.apiV1NotificationsGet(ordering: ordering);
        final list = res.body ?? [];
        return list.map((e) => ApiNotification(
          id: e.id ?? '',
          notificationType: e.notificationType.value ?? 'NOTIFICATION',
          title: e.title,
          message: e.message,
          course: e.course,
          isRead: e.isRead ?? false,
          createdAt: e.createdAt,
        )).toList();
      }
    } catch (e) {
      debugPrint('❌ [NotificationRepository] Chopper fallback error: $e');
    }

    return [];
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId, {bool isStudent = false}) async {
    debugPrint('🔔 [NotificationRepository] markAsRead: id=$notificationId, isStudent=$isStudent');
    final token = await tokenStorage.getAccessToken();
    final path = isStudent
        ? 'https://iagrow.zappcode.in/api/v1/notifications/student/$notificationId/read/'
        : 'https://iagrow.zappcode.in/api/v1/notifications/$notificationId/read/';

    try {
      final response = await http.patch(
        Uri.parse(path),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [NotificationRepository] markAsRead SUCCESS');
        return;
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationRepository] markAsRead direct HTTP failed: $e');
    }

    // Fallback
    if (isStudent) {
      await appApi.apiV1NotificationsStudentNotificationIdReadPatch(notificationId: notificationId);
    } else {
      await appApi.apiV1NotificationsNotificationIdReadPatch(notificationId: notificationId);
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead({bool isStudent = false}) async {
    debugPrint('🔔 [NotificationRepository] markAllAsRead: isStudent=$isStudent');
    final token = await tokenStorage.getAccessToken();
    final path = isStudent
        ? 'https://iagrow.zappcode.in/api/v1/notifications/student/read-all/'
        : 'https://iagrow.zappcode.in/api/v1/notifications/read-all/';

    try {
      final response = await http.patch(
        Uri.parse(path),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [NotificationRepository] markAllAsRead SUCCESS');
        return;
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationRepository] markAllAsRead direct HTTP failed: $e');
    }

    if (isStudent) {
      await appApi.apiV1NotificationsStudentReadAllPatch();
    } else {
      await appApi.apiV1NotificationsReadAllPatch();
    }
  }

  /// Get moderation logs (paginated).
  Future<PaginatedResponse<ApiModerationLog>> getModerationLogs({
    int? page,
    String? ordering,
  }) async {
    final response = await appApi.apiV1ModerationLogsGet(
      ordering: ordering,
    );
    final dynamic data = response.body;

    return PaginatedResponse.fromJson(
      data?.toJson() as Map<String, dynamic>,
      ApiModerationLog.fromJson,
    );
  }

  /// Poll moderation status for a specific course.
  Future<Map<String, dynamic>?> getModerationStatus(String courseId) async {
    final response = await appApi.apiV1ModerationStatusCourseIdGet(courseId: courseId);
    final dynamic data = response.body;
    if (data is Map<String, dynamic>?) return data;
    return data?.toJson() as Map<String, dynamic>?;
  }
}
