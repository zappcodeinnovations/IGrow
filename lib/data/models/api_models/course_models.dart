import 'package:flutter/foundation.dart';

/// Course-related models matching the IAgrow Swagger schema.

// ── Enums ───────────────────────────────────────────────────────

enum CourseCategory {
  soilScience('soil_science', 'Soil Science'),
  cropProduction('crop_production', 'Crop Production'),
  organicFarming('organic_farming', 'Organic Farming'),
  irrigation('irrigation', 'Irrigation & Water Management'),
  pestManagement('pest_management', 'Pest & Disease Management'),
  agribusiness('agribusiness', 'Agribusiness & Marketing'),
  livestock('livestock', 'Livestock Management'),
  horticulture('horticulture', 'Horticulture'),
  agroforestry('agroforestry', 'Agroforestry'),
  precisionAgriculture('precision_agriculture', 'Precision Agriculture'),
  foodProcessing('food_processing', 'Food Processing & Storage'),
  sustainableFarming('sustainable_farming', 'Sustainable Farming'),
  aquaculture('aquaculture', 'Aquaculture & Fish Farming'),
  dairyFarming('dairy_farming', 'Dairy Farming'),
  poultry('poultry', 'Poultry Science');

  const CourseCategory(this.value, this.display);
  final String value;
  final String display;

  static CourseCategory? fromValue(String? value) {
    if (value == null) return null;
    return CourseCategory.values.cast<CourseCategory?>().firstWhere(
          (e) => e!.value == value,
          orElse: () => null,
        );
  }
}

enum CourseLevel {
  beginner('beginner', 'Beginner'),
  intermediate('intermediate', 'Intermediate'),
  advanced('advanced', 'Advanced'),
  allLevels('all_levels', 'All Levels');

  const CourseLevel(this.value, this.display);
  final String value;
  final String display;

  static CourseLevel? fromValue(String? value) {
    if (value == null) return null;
    return CourseLevel.values.cast<CourseLevel?>().firstWhere(
          (e) => e!.value == value,
          orElse: () => null,
        );
  }
}

enum CourseStatus {
  draft('DRAFT', 'Draft'),
  processing('PROCESSING', 'Processing (AI Review)'),
  approved('APPROVED', 'Approved & Live'),
  rejected('REJECTED', 'Rejected');

  const CourseStatus(this.value, this.display);
  final String value;
  final String display;

  static CourseStatus? fromValue(String? value) {
    if (value == null) return null;
    return CourseStatus.values.cast<CourseStatus?>().firstWhere(
          (e) => e!.value == value,
          orElse: () => null,
        );
  }
}

// ── Generic Paginated Response ──────────────────────────────────

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      PaginatedResponse<T>(
        count: (json['count'] is num)
            ? (json['count'] as num).toInt()
            : (int.tryParse(json['count']?.toString() ?? '') ?? 0),
        next: json['next']?.toString(),
        previous: json['previous']?.toString(),
        results: (json['results'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((e) {
                  try {
                    return fromJson(e);
                  } catch (err) {
                    debugPrint('⚠️ [PaginatedResponse] Error parsing item: $err');
                    return null;
                  }
                })
                .whereType<T>()
                .toList() ??
            [],
      );
}

// ── Course List (catalog card) ──────────────────────────────────

class ApiCourseList {
  const ApiCourseList({
    required this.id,
    this.slug,
    required this.title,
    this.shortDescription,
    this.thumbnail,
    this.category,
    this.categoryDisplay,
    this.level,
    this.levelDisplay,
    this.price,
    this.instructorName,
    this.instructorAvatar,
    this.enrollmentCount,
    this.totalLectures,
    this.totalDuration,
    this.status,
    this.createdAt,
  });

  final String id;
  final String? slug;
  final String title;
  final String? shortDescription;
  final String? thumbnail;
  final String? category;
  final String? categoryDisplay;
  final String? level;
  final String? levelDisplay;
  final String? price;
  final String? instructorName;
  final String? instructorAvatar;
  final String? enrollmentCount;
  final String? totalLectures;
  final String? totalDuration;
  final String? status;
  final DateTime? createdAt;

  CourseCategory? get categoryEnum => CourseCategory.fromValue(category);
  CourseLevel? get levelEnum => CourseLevel.fromValue(level);
  CourseStatus? get statusEnum => CourseStatus.fromValue(status);

  factory ApiCourseList.fromJson(Map<String, dynamic> json) => ApiCourseList(
        id: json['id']?.toString() ?? '',
        slug: json['slug']?.toString(),
        title: json['title']?.toString() ?? '',
        shortDescription: json['short_description']?.toString(),
        thumbnail: json['thumbnail']?.toString(),
        category: json['category'] is Map ? (json['category']['id']?.toString() ?? json['category']['slug']?.toString()) : json['category']?.toString(),
        categoryDisplay: json['category_display']?.toString(),
        level: json['level']?.toString(),
        levelDisplay: json['level_display']?.toString(),
        price: json['price']?.toString(),
        instructorName: json['instructor_name']?.toString(),
        instructorAvatar: json['instructor_avatar']?.toString(),
        enrollmentCount: json['enrollment_count']?.toString(),
        totalLectures: json['total_lectures']?.toString(),
        totalDuration: json['total_duration']?.toString(),
        status: json['status']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );
}

// ── Lecture Resource ────────────────────────────────────────────

class ApiLectureResource {
  const ApiLectureResource({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
  });

  final String id;
  final String fileName;
  final String fileUrl;
  final String? fileType;

  factory ApiLectureResource.fromJson(Map<String, dynamic> json) =>
      ApiLectureResource(
        id: json['id']?.toString() ?? '',
        fileName: json['file_name']?.toString() ?? '',
        fileUrl: json['file_url']?.toString() ?? '',
        fileType: json['file_type']?.toString(),
      );
}

// ── Lecture ──────────────────────────────────────────────────────

class ApiLecture {
  const ApiLecture({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.bunnyVideoId,
    this.bunnyStatus,
    this.duration,
    this.durationFormatted,
    this.sortOrder,
    this.isPreview = false,
    this.resources = const [],
  });

  final String id;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? bunnyVideoId;
  final int? bunnyStatus;
  final int? duration;
  final String? durationFormatted;
  final int? sortOrder;
  final bool isPreview;
  final List<ApiLectureResource> resources;

  factory ApiLecture.fromJson(Map<String, dynamic> json) {
    try {
      return ApiLecture(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        videoUrl: json['video_url']?.toString(),
        bunnyVideoId: json['bunny_video_id']?.toString(),
        bunnyStatus: json['bunny_status'] is num
            ? (json['bunny_status'] as num).toInt()
            : int.tryParse(json['bunny_status']?.toString() ?? ''),
        duration: json['duration'] is num
            ? (json['duration'] as num).toInt()
            : int.tryParse(json['duration']?.toString() ?? ''),
        durationFormatted: json['duration_formatted']?.toString(),
        sortOrder: json['sort_order'] is num
            ? (json['sort_order'] as num).toInt()
            : int.tryParse(json['sort_order']?.toString() ?? ''),
        isPreview: json['is_preview'] == true ||
            json['is_preview']?.toString().toLowerCase() == 'true',
        resources: (json['resources'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((e) => ApiLectureResource.fromJson(e))
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint('Error parsing ApiLecture: $e\nJSON: $json');
      rethrow;
    }
  }
}

// ── Course Section ──────────────────────────────────────────────

class ApiCourseSection {
  const ApiCourseSection({
    required this.id,
    required this.title,
    this.description,
    this.sortOrder,
    this.lectures = const [],
    this.lectureCount,
    this.quiz,
  });

  final String id;
  final String title;
  final String? description;
  final int? sortOrder;
  final List<ApiLecture> lectures;
  final String? lectureCount;
  final dynamic quiz;

  bool get hasQuiz {
    if (quiz == null) return false;
    if (quiz is bool) return quiz as bool;
    if (quiz is Map) return (quiz as Map).isNotEmpty;
    if (quiz is String) return (quiz as String).isNotEmpty;
    if (quiz is List) return (quiz as List).isNotEmpty;
    return true;
  }

  factory ApiCourseSection.fromJson(Map<String, dynamic> json) {
    try {
      return ApiCourseSection(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        sortOrder: json['sort_order'] is num
            ? (json['sort_order'] as num).toInt()
            : int.tryParse(json['sort_order']?.toString() ?? ''),
        lectures: (json['lectures'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((e) => ApiLecture.fromJson(e))
                .toList() ??
            [],
        lectureCount: json['lecture_count']?.toString(),
        quiz: json['quiz'] ?? json['has_quiz'] ?? json['quiz_id'],
      );
    } catch (e) {
      debugPrint('Error parsing ApiCourseSection: $e\nJSON: $json');
      rethrow;
    }
  }
}

// ── Course Detail (full) ────────────────────────────────────────

class ApiCourseDetail {
  const ApiCourseDetail({
    required this.id,
    this.slug,
    required this.title,
    this.description,
    this.shortDescription,
    this.thumbnail,
    this.previewVideoUrl,
    this.category,
    this.categoryDisplay,
    this.level,
    this.levelDisplay,
    this.price,
    this.language,
    this.whatYouLearn,
    this.requirements,
    this.tags,
    this.instructorName,
    this.instructorAvatar,
    this.enrollmentCount,
    this.totalLectures,
    this.totalDuration,
    this.status,
    this.sections = const [],
    this.createdAt,
    this.publishedAt,
    this.isEnrolled,
  });

  final String id;
  final String? slug;
  final String title;
  final String? description;
  final String? shortDescription;
  final String? thumbnail;
  final String? previewVideoUrl;
  final String? category;
  final String? categoryDisplay;
  final String? level;
  final String? levelDisplay;
  final String? price;
  final String? language;
  final String? whatYouLearn;
  final String? requirements;
  final String? tags;
  final String? instructorName;
  final String? instructorAvatar;
  final String? enrollmentCount;
  final String? totalLectures;
  final String? totalDuration;
  final String? status;
  final List<ApiCourseSection> sections;
  final DateTime? createdAt;
  final DateTime? publishedAt;
  final dynamic isEnrolled;

  factory ApiCourseDetail.fromJson(Map<String, dynamic> json) {
    try {
      String? parseStringOrList(dynamic val) {
        if (val == null) return null;
        if (val is List) return val.map((e) => e.toString()).join('\n');
        return val.toString();
      }

      DateTime? parseDate(dynamic val) {
        if (val == null) return null;
        return DateTime.tryParse(val.toString());
      }

      return ApiCourseDetail(
        id: json['id']?.toString() ?? '',
        slug: json['slug']?.toString(),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        shortDescription: json['short_description']?.toString(),
        thumbnail: json['thumbnail']?.toString(),
        previewVideoUrl: json['preview_video_url']?.toString(),
        category: json['category'] is Map
            ? (json['category']['id']?.toString() ??
                json['category']['slug']?.toString() ??
                json['category']['name']?.toString())
            : json['category']?.toString(),
        categoryDisplay: json['category_display']?.toString(),
        level: json['level']?.toString(),
        levelDisplay: json['level_display']?.toString(),
        price: json['price']?.toString(),
        language: json['language']?.toString(),
        whatYouLearn: parseStringOrList(json['what_you_learn']),
        requirements: parseStringOrList(json['requirements']),
        tags: parseStringOrList(json['tags']),
        instructorName: json['instructor_name']?.toString(),
        instructorAvatar: json['instructor_avatar']?.toString(),
        enrollmentCount: json['enrollment_count']?.toString(),
        totalLectures: json['total_lectures']?.toString(),
        totalDuration: json['total_duration']?.toString(),
        status: json['status']?.toString(),
        sections: (json['sections'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((e) => ApiCourseSection.fromJson(e))
                .toList() ??
            [],
        createdAt: parseDate(json['created_at']),
        publishedAt: parseDate(json['published_at']),
        isEnrolled: json['is_enrolled'],
      );
    } catch (e) {
      debugPrint('Error parsing ApiCourseDetail: $e\nJSON: $json');
      rethrow;
    }
  }
}

// ── Enrollment ──────────────────────────────────────────────────

class ApiEnrollment {
  const ApiEnrollment({
    required this.id,
    required this.course,
    this.courseTitle,
    this.courseSlug,
    this.courseThumbnail,
    this.enrolledAt,
    this.completed = false,
    this.completionPercentage = 0,
  });

  final String id;
  final String course;
  final String? courseTitle;
  final String? courseSlug;
  final String? courseThumbnail;
  final DateTime? enrolledAt;
  final bool completed;
  final double completionPercentage;

  factory ApiEnrollment.fromJson(Map<String, dynamic> json) => ApiEnrollment(
        id: json['id'].toString(),
        course: json['course'].toString(),
        courseTitle: json['course_title'] as String?,
        courseSlug: json['course_slug'] as String?,
        courseThumbnail: json['course_thumbnail'] as String?,
        enrolledAt: json['enrolled_at'] != null
            ? DateTime.tryParse(json['enrolled_at'] as String)
            : null,
        completed: json['completed'] as bool? ?? false,
        completionPercentage:
            (json['completion_percentage'] as num?)?.toDouble() ?? 0,
      );
}
