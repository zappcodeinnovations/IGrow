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

    int parsedRating = 5;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toInt();
      } else if (json['rating'] is String) {
        parsedRating = int.tryParse(json['rating'] as String) ?? 5;
      }
    }

    dynamic replySource = json['instructor_reply'] ??
        json['reply'] ??
        json['reply_text'] ??
        json['instructor_reply_text'] ??
        json['reply_content'] ??
        json['response'] ??
        json['instructor_response'] ??
        json['replies'];

    final instructorReply = _extractReply(replySource);
    final instructorReplyCreatedAt = _extractReplyDate(json, replySource);
    final instructorName = _extractInstructorName(replySource, json['instructor_name']) ?? 'Instructor';

    return ApiCourseReview(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Anonymous Student',
      studentAvatar: json['student_avatar'] as String?,
      rating: parsedRating.clamp(1, 5),
      comment: json['comment']?.toString() ?? '',
      createdAt: created,
      instructorReply: instructorReply,
      instructorReplyCreatedAt: instructorReplyCreatedAt,
      instructorName: instructorName,
    );
  }

  static String? _extractReply(dynamic val) {
    if (val == null) return null;
    if (val is String) {
      final trimmed = val.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }
    if (val is Map) {
      final possible = val['reply'] ??
          val['reply_text'] ??
          val['comment'] ??
          val['content'] ??
          val['text'] ??
          val['message'] ??
          val['instructor_reply'] ??
          val['response'];
      return _extractReply(possible);
    }
    if (val is List && val.isNotEmpty) {
      for (final item in val) {
        final res = _extractReply(item);
        if (res != null && res.isNotEmpty) return res;
      }
    }
    return null;
  }

  static DateTime? _extractReplyDate(Map<String, dynamic> json, dynamic replySource) {
    dynamic rawDate = json['reply_created_at'] ??
        json['instructor_reply_date'] ??
        json['replied_at'] ??
        json['reply_date'];
    if (rawDate == null && replySource is Map) {
      rawDate = replySource['created_at'] ??
          replySource['date'] ??
          replySource['replied_at'] ??
          replySource['reply_date'];
    } else if (rawDate == null && replySource is List && replySource.isNotEmpty) {
      final first = replySource.first;
      if (first is Map) {
        rawDate = first['created_at'] ?? first['date'] ?? first['replied_at'];
      }
    }
    if (rawDate != null) {
      try {
        return DateTime.parse(rawDate.toString());
      } catch (_) {}
    }
    return null;
  }

  static String? _extractInstructorName(dynamic replySource, dynamic fallbackName) {
    if (replySource is Map) {
      final name = replySource['instructor_name'] ??
          replySource['author_name'] ??
          replySource['user_name'] ??
          replySource['name'] ??
          replySource['user']?['name'] ??
          replySource['user']?['username'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } else if (replySource is List && replySource.isNotEmpty) {
      final first = replySource.first;
      if (first is Map) {
        final name = first['instructor_name'] ??
            first['author_name'] ??
            first['user_name'] ??
            first['name'] ??
            first['user']?['name'];
        if (name != null && name.toString().trim().isNotEmpty) {
          return name.toString().trim();
        }
      }
    }
    if (fallbackName != null && fallbackName.toString().trim().isNotEmpty) {
      return fallbackName.toString().trim();
    }
    return null;
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
