// Course review models matching AgriLearn backend API schema.

class ApiCourseReview {
  const ApiCourseReview({
    required this.id,
    required this.studentName,
    this.studentAvatar,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.instructorReply,
    this.instructorReplyCreatedAt,
    this.instructorName,
  });

  final String id;
  final String studentName;
  final String? studentAvatar;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final String? instructorReply;
  final DateTime? instructorReplyCreatedAt;
  final String? instructorName;

  factory ApiCourseReview.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    if (json['created_at'] != null) {
      try {
        created = DateTime.parse(json['created_at'] as String);
      } catch (_) {}
    }

    DateTime? replyCreated;
    final rawReplyDate = json['reply_created_at'] ?? json['instructor_reply_date'] ?? json['replied_at'];
    if (rawReplyDate != null) {
      try {
        replyCreated = DateTime.parse(rawReplyDate.toString());
      } catch (_) {}
    }

    int parsedRating = 5;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toInt();
      } else if (json['rating'] is String) {
        parsedRating = int.tryParse(json['rating'] as String) ?? 5;
      }
    }

    final rawReply = (json['instructor_reply'] ?? json['reply'] ?? json['reply_content'] ?? json['response'])?.toString();
    final instructorReply = (rawReply != null && rawReply.trim().isNotEmpty) ? rawReply.trim() : null;

    return ApiCourseReview(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Anonymous Student',
      studentAvatar: json['student_avatar'] as String?,
      rating: parsedRating.clamp(1, 5),
      comment: json['comment']?.toString() ?? '',
      createdAt: created,
      instructorReply: instructorReply,
      instructorReplyCreatedAt: replyCreated,
      instructorName: json['instructor_name']?.toString() ?? 'Instructor',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'student_avatar': studentAvatar,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
      'instructor_reply': instructorReply,
      'instructor_reply_date': instructorReplyCreatedAt?.toIso8601String(),
      'instructor_name': instructorName,
    };
  }
}
