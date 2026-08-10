/// Notification & Moderation models matching the IAgrow Swagger schema.

// ── Notification ────────────────────────────────────────────────

enum NotificationType {
  approved('APPROVED', 'Course Approved'),
  rejected('REJECTED', 'Course Rejected'),
  processing('PROCESSING', 'AI Processing Started'),
  warning('WARNING', 'Account Warning');

  const NotificationType(this.value, this.display);
  final String value;
  final String display;

  static NotificationType? fromValue(String? value) {
    if (value == null) return null;
    return NotificationType.values.cast<NotificationType?>().firstWhere(
          (e) => e!.value == value,
          orElse: () => null,
        );
  }
}

class ApiNotification {
  const ApiNotification({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.course,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String notificationType;
  final String title;
  final String message;
  final String? course;
  final bool isRead;
  final DateTime? createdAt;

  NotificationType? get type => NotificationType.fromValue(notificationType);

  factory ApiNotification.fromJson(Map<String, dynamic> json) =>
      ApiNotification(
        id: json['id'] as String,
        notificationType: json['notification_type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        course: json['course'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}

// ── Moderation Log ──────────────────────────────────────────────

class ApiModerationLog {
  const ApiModerationLog({
    required this.id,
    required this.courseId,
    this.courseTitle,
    this.failedStep,
    this.rejectedTokens,
    this.fullAnalysis,
    this.createdAt,
  });

  final String id;
  final String courseId;
  final String? courseTitle;
  final String? failedStep; // 'TEXT_SCAN' | 'AUDIO_WHISPER' | 'VISION_FRAME'
  final dynamic rejectedTokens;
  final dynamic fullAnalysis;
  final DateTime? createdAt;

  factory ApiModerationLog.fromJson(Map<String, dynamic> json) =>
      ApiModerationLog(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        courseTitle: json['course_title'] as String?,
        failedStep: json['failed_step'] as String?,
        rejectedTokens: json['rejected_tokens'],
        fullAnalysis: json['full_analysis'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}
