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
      specialtyCrops: json['specialty_crops']?.toString() ?? json['expertise_tags']?.toString() ?? 'Agricultural Specialist',
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
