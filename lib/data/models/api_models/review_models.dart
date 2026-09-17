// Course review models matching AgriLearn backend API schema.

class ApiCourseReview {
  const ApiCourseReview({
    required this.id,
    required this.studentName,
    this.studentAvatar,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final String studentName;
  final String? studentAvatar;
  final int rating;
  final String comment;
  final DateTime? createdAt;

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

    return ApiCourseReview(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Anonymous Student',
      studentAvatar: json['student_avatar'] as String?,
      rating: parsedRating.clamp(1, 5),
      comment: json['comment']?.toString() ?? '',
      createdAt: created,
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
    };
  }
}
