import '../../core/network/api_client.dart';
import '../models/api_models/course_models.dart';
import '../models/api_models/notification_models.dart';

/// Repository for notifications and moderation logs.
class NotificationRepository {
  NotificationRepository({required this.appApi});

  final AppApi appApi;

  /// List notifications (paginated).
  Future<PaginatedResponse<ApiNotification>> getNotifications({
    int? page,
    String? ordering,
  }) async {
    final response = await appApi.apiV1NotificationsGet(
      ordering: ordering,
    );
    final dynamic data = response.body;

    return PaginatedResponse.fromJson(
      data?.toJson() as Map<String, dynamic>,
      ApiNotification.fromJson,
    );
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await appApi.apiV1NotificationsNotificationIdReadPatch(notificationId: notificationId);
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    await appApi.apiV1NotificationsReadAllPatch();
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
