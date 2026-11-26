/// Top Instructor model matching the AgriLearn backend API (`/api/v1/instructors/top/`).
class ApiTopInstructor {
  const ApiTopInstructor({
    required this.id,
    required this.fullName,
    this.avatar,
    this.bio,
    this.specialtyCrops,
    this.expertiseTags,
    required this.experience,
    this.rating = 4.9,
    this.reviewCount = 0,
    this.totalStudents = 0,
    this.totalCourses = 1,
  });

  final String id;
  final String fullName;
  final String? avatar;
  final String? bio;
  final String? specialtyCrops;
  final String? expertiseTags;
  final String experience;
  final double rating;
  final int reviewCount;
  final int totalStudents;
  final int totalCourses;

  factory ApiTopInstructor.fromJson(Map<String, dynamic> json) {
    double parseRating(dynamic val) {
      if (val == null) return 4.9;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 4.9;
    }

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? fallback;
    }

    return ApiTopInstructor(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Verified Instructor',
      avatar: json['avatar']?.toString(),
      bio: json['bio']?.toString(),
      specialtyCrops:
          json['specialty_crops']?.toString() ??
          json['expertise_tags']?.toString() ??
          'Agricultural Specialist',
      expertiseTags: json['expertise_tags']?.toString(),
      experience: json['experience']?.toString() ?? 'Expert',
      rating: parseRating(json['rating']),
      reviewCount: parseInt(json['review_count'], 0),
      totalStudents: parseInt(json['total_students'], 0),
      totalCourses: parseInt(json['total_courses'], 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'avatar': avatar,
    'bio': bio,
    'specialty_crops': specialtyCrops,
    'expertise_tags': expertiseTags,
    'experience': experience,
    'rating': rating,
    'review_count': reviewCount,
    'total_students': totalStudents,
    'total_courses': totalCourses,
  };

  /// Fallback verified instructors matching AgriLearn web platform defaults.
  static const List<ApiTopInstructor> fallbacks = [
    ApiTopInstructor(
      id: 'inst-1',
      fullName: 'Yash Gedam',
      avatar: null,
      bio: 'Done MY Master in MSC in agriculture',
      specialtyCrops: 'Agricultural Specialist',
      experience: '23 yrs exp',
      rating: 5.0,
      reviewCount: 1,
      totalStudents: 2,
      totalCourses: 5,
    ),
    ApiTopInstructor(
      id: 'inst-2',
      fullName: 'testinstructor',
      avatar: null,
      bio: 'test instructor',
      specialtyCrops: 'wheat farming',
      experience: '12 yrs exp',
      rating: 4.9,
      reviewCount: 0,
      totalStudents: 2,
      totalCourses: 2,
    ),
  ];
}

/// Detailed Public Instructor profile matching `/api/v1/instructors/<id>/`.
class ApiPublicInstructorDetail {
  const ApiPublicInstructorDetail({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatar,
    this.bio,
    this.expertiseTags,
    this.specialtyCrops,
    this.qualifications,
    this.website,
    this.socialLink,
    this.experience = 'Expert',
    this.rating = 4.9,
    this.totalStudents = 0,
    this.totalCourses = 0,
    this.courses = const [],
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  final String? expertiseTags;
  final String? specialtyCrops;
  final String? qualifications;
  final String? website;
  final String? socialLink;
  final String experience;
  final double rating;
  final int totalStudents;
  final int totalCourses;
  final List<ApiInstructorCourseItem> courses;

  factory ApiPublicInstructorDetail.fromJson(Map<String, dynamic> json) {
    double parseRating(dynamic val) {
      if (val == null) return 4.9;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 4.9;
    }

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? fallback;
    }

    final rawCourses = json['courses'] as List? ?? [];
    final courseList = rawCourses
        .whereType<Map<String, dynamic>>()
        .map((e) => ApiInstructorCourseItem.fromJson(e))
        .toList();

    final bioText = json['bio']?.toString();

    // 1. Resolve Website: direct field, or fallback to parsing from bio
    String? resolvedWebsite = json['website']?.toString().trim();
    if (resolvedWebsite == null || resolvedWebsite.isEmpty) {
      if (bioText != null && bioText.isNotEmpty) {
        // Look for "website :- <url>" or "website : <url>" or raw URL matching
        final match = RegExp(
          r'(?:website\s*(?::-|:|=)\s*)(https?:\/\/[^\s\r\n]+|[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[^\s\r\n]*)',
          caseSensitive: false,
        ).firstMatch(bioText);
        if (match != null) {
          resolvedWebsite = match.group(1)?.trim();
        }
      }
    }

    // 2. Resolve Social Link (Instagram / YouTube / etc.): direct field, or fallback to parsing from bio
    String? resolvedSocialLink =
        (json['social_link']?.toString() ?? json['social_links']?.toString())
            ?.trim();
    if (resolvedSocialLink == null || resolvedSocialLink.isEmpty) {
      if (bioText != null && bioText.isNotEmpty) {
        // Look for "instagram :- <url>" or "instagram : <url>" or "youtube :- <url>" or direct instagram.com links
        final match = RegExp(
          r'(?:(?:instagram|social|youtube|fb|facebook)\s*(?::-|:|=)\s*)(https?:\/\/[^\s\r\n]+|[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[^\s\r\n]*)|(https?:\/\/(?:www\.)?(?:instagram\.com|youtube\.com|youtu\.be|facebook\.com|linkedin\.com)\/[^\s\r\n]+)',
          caseSensitive: false,
        ).firstMatch(bioText);
        if (match != null) {
          resolvedSocialLink = (match.group(1) ?? match.group(2))?.trim();
        }
      }
    }

    return ApiPublicInstructorDetail(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Instructor',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      avatar: json['avatar']?.toString(),
      bio: bioText,
      expertiseTags: json['expertise_tags']?.toString(),
      specialtyCrops: json['specialty_crops']?.toString(),
      qualifications: json['qualifications']?.toString(),
      website: resolvedWebsite,
      socialLink: resolvedSocialLink,
      experience: json['experience']?.toString() ?? 'Expert',
      rating: parseRating(json['rating']),
      totalStudents: parseInt(json['total_students'], 0),
      totalCourses: parseInt(json['total_courses'], courseList.length),
      courses: courseList,
    );
  }
}

class ApiInstructorCourseItem {
  const ApiInstructorCourseItem({
    required this.id,
    required this.title,
    this.slug,
    this.thumbnail,
    this.price,
    this.level,
    this.categoryName,
  });

  final String id;
  final String title;
  final String? slug;
  final String? thumbnail;
  final String? price;
  final String? level;
  final String? categoryName;

  factory ApiInstructorCourseItem.fromJson(Map<String, dynamic> json) {
    return ApiInstructorCourseItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Course',
      slug: json['slug']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      price: json['price']?.toString(),
      level: json['level']?.toString(),
      categoryName: json['category_name']?.toString(),
    );
  }
}
