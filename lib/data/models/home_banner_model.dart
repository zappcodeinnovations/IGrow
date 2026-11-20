class HomeBannerItem {
  final String id;
  final String title;
  final String imageUrl;
  final bool bannerCourse;
  final String? courseId;
  final String? courseTitle;
  final String? courseSlug;
  final String? courseInstructorName;
  final String? targetLink;
  final bool isActive;
  final int displayOrder;
  final String? createdAt;

  const HomeBannerItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.bannerCourse = false,
    this.courseId,
    this.courseTitle,
    this.courseSlug,
    this.courseInstructorName,
    this.targetLink,
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
  });

  factory HomeBannerItem.fromJson(Map<String, dynamic> json) {
    return HomeBannerItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      bannerCourse: json['banner_course'] == true || json['bannerCourse'] == true,
      courseId: json['course_id']?.toString() ?? json['courseId']?.toString(),
      courseTitle: json['course_title']?.toString() ?? json['courseTitle']?.toString(),
      courseSlug: json['course_slug']?.toString() ?? json['courseSlug']?.toString(),
      courseInstructorName: json['course_instructor_name']?.toString() ?? json['courseInstructorName']?.toString(),
      targetLink: json['target_link']?.toString() ?? json['targetLink']?.toString(),
      isActive: json['is_active'] == true || json['isActive'] == true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString(),
    );
  }
}
