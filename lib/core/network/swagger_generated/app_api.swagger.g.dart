// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_api.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminInstructorReview _$AdminInstructorReviewFromJson(
  Map<String, dynamic> json,
) => AdminInstructorReview(
  status: statusC09EnumFromJson(json['status']),
  kycVerified: json['kyc_verified'] as bool?,
  reviewComments: json['review_comments'] as String?,
);

Map<String, dynamic> _$AdminInstructorReviewToJson(
  AdminInstructorReview instance,
) => <String, dynamic>{
  'status': statusC09EnumToJson(instance.status),
  'kyc_verified': instance.kycVerified,
  'review_comments': instance.reviewComments,
};

AdminInstructorReviewRequest _$AdminInstructorReviewRequestFromJson(
  Map<String, dynamic> json,
) => AdminInstructorReviewRequest(
  status: statusC09EnumFromJson(json['status']),
  kycVerified: json['kyc_verified'] as bool?,
  reviewComments: json['review_comments'] as String?,
);

Map<String, dynamic> _$AdminInstructorReviewRequestToJson(
  AdminInstructorReviewRequest instance,
) => <String, dynamic>{
  'status': statusC09EnumToJson(instance.status),
  'kyc_verified': instance.kycVerified,
  'review_comments': instance.reviewComments,
};

AdminNotification _$AdminNotificationFromJson(Map<String, dynamic> json) =>
    AdminNotification(
      id: json['id'] as String?,
      notificationType: adminNotificationNotificationTypeEnumFromJson(
        json['notification_type'],
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      instructorId: json['instructor_id'] as String?,
      instructorName: json['instructor_name'] as String?,
      instructorEmail: json['instructor_email'] as String?,
      isRead: json['is_read'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminNotificationToJson(AdminNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notification_type': adminNotificationNotificationTypeEnumToJson(
        instance.notificationType,
      ),
      'title': instance.title,
      'message': instance.message,
      'instructor_id': instance.instructorId,
      'instructor_name': instance.instructorName,
      'instructor_email': instance.instructorEmail,
      'is_read': instance.isRead,
      'created_at': instance.createdAt?.toIso8601String(),
    };

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
  id: json['id'] as String?,
  email: json['email'] as String,
  fullName: json['full_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  role: roleEnumNullableFromJson(json['role']),
  avatar: json['avatar'] as String?,
  locationState: json['location_state'] as String?,
  locationDistrict: json['location_district'] as String?,
  farmingExperience: json['farming_experience'],
  areasOfInterest: json['areas_of_interest'],
  isActive: json['is_active'] as bool?,
  isStaff: json['is_staff'] as bool?,
  isSuperuser: json['is_superuser'] as bool?,
  dateJoined: json['date_joined'] == null
      ? null
      : DateTime.parse(json['date_joined'] as String),
  lastLogin: json['last_login'] == null
      ? null
      : DateTime.parse(json['last_login'] as String),
  instructorProfile: json['instructor_profile'],
);

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'role': roleEnumNullableToJson(instance.role),
  'avatar': instance.avatar,
  'location_state': instance.locationState,
  'location_district': instance.locationDistrict,
  'farming_experience': instance.farmingExperience,
  'areas_of_interest': instance.areasOfInterest,
  'is_active': instance.isActive,
  'is_staff': instance.isStaff,
  'is_superuser': instance.isSuperuser,
  'date_joined': instance.dateJoined?.toIso8601String(),
  'last_login': instance.lastLogin?.toIso8601String(),
  'instructor_profile': instance.instructorProfile,
};

AdminUserRequest _$AdminUserRequestFromJson(Map<String, dynamic> json) =>
    AdminUserRequest(
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: roleEnumNullableFromJson(json['role']),
      avatar: json['avatar'] as String?,
      locationState: json['location_state'] as String?,
      locationDistrict: json['location_district'] as String?,
      farmingExperience: json['farming_experience'],
      areasOfInterest: json['areas_of_interest'],
      isActive: json['is_active'] as bool?,
      isStaff: json['is_staff'] as bool?,
      isSuperuser: json['is_superuser'] as bool?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$AdminUserRequestToJson(AdminUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'role': roleEnumNullableToJson(instance.role),
      'avatar': instance.avatar,
      'location_state': instance.locationState,
      'location_district': instance.locationDistrict,
      'farming_experience': instance.farmingExperience,
      'areas_of_interest': instance.areasOfInterest,
      'is_active': instance.isActive,
      'is_staff': instance.isStaff,
      'is_superuser': instance.isSuperuser,
      'password': instance.password,
    };

Cart _$CartFromJson(Map<String, dynamic> json) => Cart(
  id: json['id'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  total: json['total'] as String?,
  itemCount: json['item_count'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
  'id': instance.id,
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'item_count': instance.itemCount,
  'updated_at': instance.updatedAt?.toIso8601String(),
};

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  id: json['id'] as String?,
  course: json['course'] as String,
  courseDetail: json['course_detail'] == null
      ? null
      : CourseList.fromJson(json['course_detail'] as Map<String, dynamic>),
  addedAt: json['added_at'] == null
      ? null
      : DateTime.parse(json['added_at'] as String),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'course': instance.course,
  'course_detail': instance.courseDetail?.toJson(),
  'added_at': instance.addedAt?.toIso8601String(),
};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String?,
  slug: json['slug'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  contentType: contentTypeEnumNullableFromJson(json['content_type']),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'description': instance.description,
  'content_type': contentTypeEnumNullableToJson(instance.contentType),
  'sort_order': instance.sortOrder,
};

CategoryAdmin _$CategoryAdminFromJson(Map<String, dynamic> json) =>
    CategoryAdmin(
      id: json['id'] as String?,
      slug: json['slug'] as String,
      contentType: contentTypeEnumNullableFromJson(json['content_type']),
      isActive: json['is_active'] as bool?,
      sortOrder: (json['sort_order'] as num?)?.toInt(),
      nameEn: json['name_en'] as String?,
      descriptionEn: json['description_en'] as String?,
      nameHi: json['name_hi'] as String?,
      descriptionHi: json['description_hi'] as String?,
      nameMr: json['name_mr'] as String?,
      descriptionMr: json['description_mr'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CategoryAdminToJson(CategoryAdmin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'content_type': contentTypeEnumNullableToJson(instance.contentType),
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
      'name_en': instance.nameEn,
      'description_en': instance.descriptionEn,
      'name_hi': instance.nameHi,
      'description_hi': instance.descriptionHi,
      'name_mr': instance.nameMr,
      'description_mr': instance.descriptionMr,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

CategoryAdminRequest _$CategoryAdminRequestFromJson(
  Map<String, dynamic> json,
) => CategoryAdminRequest(
  slug: json['slug'] as String,
  contentType: contentTypeEnumNullableFromJson(json['content_type']),
  isActive: json['is_active'] as bool?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  nameEn: json['name_en'] as String?,
  descriptionEn: json['description_en'] as String?,
  nameHi: json['name_hi'] as String?,
  descriptionHi: json['description_hi'] as String?,
  nameMr: json['name_mr'] as String?,
  descriptionMr: json['description_mr'] as String?,
);

Map<String, dynamic> _$CategoryAdminRequestToJson(
  CategoryAdminRequest instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'content_type': contentTypeEnumNullableToJson(instance.contentType),
  'is_active': instance.isActive,
  'sort_order': instance.sortOrder,
  'name_en': instance.nameEn,
  'description_en': instance.descriptionEn,
  'name_hi': instance.nameHi,
  'description_hi': instance.descriptionHi,
  'name_mr': instance.nameMr,
  'description_mr': instance.descriptionMr,
};

CategoryRequest _$CategoryRequestFromJson(Map<String, dynamic> json) =>
    CategoryRequest(
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      contentType: contentTypeEnumNullableFromJson(json['content_type']),
      sortOrder: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryRequestToJson(CategoryRequest instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'content_type': contentTypeEnumNullableToJson(instance.contentType),
      'sort_order': instance.sortOrder,
    };

CertificateTemplate _$CertificateTemplateFromJson(Map<String, dynamic> json) =>
    CertificateTemplate(
      id: json['id'] as String?,
      title: json['title'] as String?,
      templateImage: json['template_image'] as String,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CertificateTemplateToJson(
  CertificateTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'template_image': instance.templateImage,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
};

CertificateTemplateRequest _$CertificateTemplateRequestFromJson(
  Map<String, dynamic> json,
) => CertificateTemplateRequest(
  title: json['title'] as String?,
  templateImage: json['template_image'] as String,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$CertificateTemplateRequestToJson(
  CertificateTemplateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'template_image': instance.templateImage,
  'is_active': instance.isActive,
};

ChangePassword _$ChangePasswordFromJson(Map<String, dynamic> json) =>
    ChangePassword(
      oldPassword: json['old_password'] as String,
      newPassword: json['new_password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$ChangePasswordToJson(ChangePassword instance) =>
    <String, dynamic>{
      'old_password': instance.oldPassword,
      'new_password': instance.newPassword,
      'confirm_password': instance.confirmPassword,
    };

ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) => ChangePasswordRequest(
  oldPassword: json['old_password'] as String,
  newPassword: json['new_password'] as String,
  confirmPassword: json['confirm_password'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestToJson(
  ChangePasswordRequest instance,
) => <String, dynamic>{
  'old_password': instance.oldPassword,
  'new_password': instance.newPassword,
  'confirm_password': instance.confirmPassword,
};

CourseCreate _$CourseCreateFromJson(Map<String, dynamic> json) => CourseCreate(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  shortDescription: json['short_description'] as String?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  level: levelEnumNullableFromJson(json['level']),
  price: json['price'] as String?,
  thumbnail: json['thumbnail'] as String?,
  previewVideoUrl: json['preview_video_url'] as String?,
  language: json['language'] as String?,
  whatYouLearn: json['what_you_learn'] as String?,
  requirements: json['requirements'] as String?,
  tags: json['tags'] as String?,
);

Map<String, dynamic> _$CourseCreateToJson(CourseCreate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'category': instance.category?.toJson(),
      'level': levelEnumNullableToJson(instance.level),
      'price': instance.price,
      'thumbnail': instance.thumbnail,
      'preview_video_url': instance.previewVideoUrl,
      'language': instance.language,
      'what_you_learn': instance.whatYouLearn,
      'requirements': instance.requirements,
      'tags': instance.tags,
    };

CourseCreateRequest _$CourseCreateRequestFromJson(Map<String, dynamic> json) =>
    CourseCreateRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      shortDescription: json['short_description'] as String?,
      categoryId: json['category_id'] as String?,
      level: levelEnumNullableFromJson(json['level']),
      price: json['price'] as String?,
      thumbnail: json['thumbnail'] as String?,
      previewVideoUrl: json['preview_video_url'] as String?,
      language: json['language'] as String?,
      whatYouLearn: json['what_you_learn'] as String?,
      requirements: json['requirements'] as String?,
      tags: json['tags'] as String?,
    );

Map<String, dynamic> _$CourseCreateRequestToJson(
  CourseCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'short_description': instance.shortDescription,
  'category_id': instance.categoryId,
  'level': levelEnumNullableToJson(instance.level),
  'price': instance.price,
  'thumbnail': instance.thumbnail,
  'preview_video_url': instance.previewVideoUrl,
  'language': instance.language,
  'what_you_learn': instance.whatYouLearn,
  'requirements': instance.requirements,
  'tags': instance.tags,
};

CourseDetail _$CourseDetailFromJson(Map<String, dynamic> json) => CourseDetail(
  id: json['id'] as String?,
  slug: json['slug'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  shortDescription: json['short_description'] as String?,
  thumbnail: json['thumbnail'] as String?,
  previewVideoUrl: json['preview_video_url'] as String?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  level: levelEnumNullableFromJson(json['level']),
  levelDisplay: json['level_display'] as String?,
  price: json['price'] as String?,
  language: json['language'] as String?,
  whatYouLearn: json['what_you_learn'] as String?,
  requirements: json['requirements'] as String?,
  tags: json['tags'] as String?,
  instructorName: json['instructor_name'] as String?,
  instructorAvatar: json['instructor_avatar'] as String?,
  enrollmentCount: json['enrollment_count']?.toString(),
  totalLectures: json['total_lectures']?.toString(),
  totalDuration: json['total_duration']?.toString(),
  status: status76eEnumNullableFromJson(json['status']),
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map((e) => CourseSection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  isEnrolled: json['is_enrolled']?.toString(),
);

Map<String, dynamic> _$CourseDetailToJson(CourseDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'thumbnail': instance.thumbnail,
      'preview_video_url': instance.previewVideoUrl,
      'category': instance.category?.toJson(),
      'level': levelEnumNullableToJson(instance.level),
      'level_display': instance.levelDisplay,
      'price': instance.price,
      'language': instance.language,
      'what_you_learn': instance.whatYouLearn,
      'requirements': instance.requirements,
      'tags': instance.tags,
      'instructor_name': instance.instructorName,
      'instructor_avatar': instance.instructorAvatar,
      'enrollment_count': instance.enrollmentCount,
      'total_lectures': instance.totalLectures,
      'total_duration': instance.totalDuration,
      'status': status76eEnumNullableToJson(instance.status),
      'sections': instance.sections?.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt?.toIso8601String(),
      'published_at': instance.publishedAt?.toIso8601String(),
      'is_enrolled': instance.isEnrolled,
    };

CourseDetailRequest _$CourseDetailRequestFromJson(Map<String, dynamic> json) =>
    CourseDetailRequest(
      slug: json['slug'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      shortDescription: json['short_description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      previewVideoUrl: json['preview_video_url'] as String?,
      level: levelEnumNullableFromJson(json['level']),
      price: json['price'] as String?,
      language: json['language'] as String?,
      whatYouLearn: json['what_you_learn'] as String?,
      requirements: json['requirements'] as String?,
      tags: json['tags'] as String?,
      status: status76eEnumNullableFromJson(json['status']),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
    );

Map<String, dynamic> _$CourseDetailRequestToJson(
  CourseDetailRequest instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'title': instance.title,
  'description': instance.description,
  'short_description': instance.shortDescription,
  'thumbnail': instance.thumbnail,
  'preview_video_url': instance.previewVideoUrl,
  'level': levelEnumNullableToJson(instance.level),
  'price': instance.price,
  'language': instance.language,
  'what_you_learn': instance.whatYouLearn,
  'requirements': instance.requirements,
  'tags': instance.tags,
  'status': status76eEnumNullableToJson(instance.status),
  'published_at': instance.publishedAt?.toIso8601String(),
};

CourseList _$CourseListFromJson(Map<String, dynamic> json) => CourseList(
  id: json['id'] as String?,
  slug: json['slug'] as String?,
  title: json['title'] as String,
  shortDescription: json['short_description'] as String?,
  thumbnail: json['thumbnail'] as String?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  level: levelEnumNullableFromJson(json['level']),
  levelDisplay: json['level_display'] as String?,
  price: json['price'] as String?,
  instructorName: json['instructor_name'] as String?,
  instructorAvatar: json['instructor_avatar'] as String?,
  enrollmentCount: json['enrollment_count']?.toString(),
  totalLectures: json['total_lectures']?.toString(),
  totalDuration: json['total_duration']?.toString(),
  status: status76eEnumNullableFromJson(json['status']),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CourseListToJson(CourseList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'thumbnail': instance.thumbnail,
      'category': instance.category?.toJson(),
      'level': levelEnumNullableToJson(instance.level),
      'level_display': instance.levelDisplay,
      'price': instance.price,
      'instructor_name': instance.instructorName,
      'instructor_avatar': instance.instructorAvatar,
      'enrollment_count': instance.enrollmentCount,
      'total_lectures': instance.totalLectures,
      'total_duration': instance.totalDuration,
      'status': status76eEnumNullableToJson(instance.status),
      'created_at': instance.createdAt?.toIso8601String(),
    };

CourseListRequest _$CourseListRequestFromJson(Map<String, dynamic> json) =>
    CourseListRequest(
      slug: json['slug'] as String?,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      level: levelEnumNullableFromJson(json['level']),
      price: json['price'] as String?,
      status: status76eEnumNullableFromJson(json['status']),
    );

Map<String, dynamic> _$CourseListRequestToJson(CourseListRequest instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'thumbnail': instance.thumbnail,
      'level': levelEnumNullableToJson(instance.level),
      'price': instance.price,
      'status': status76eEnumNullableToJson(instance.status),
    };

CourseSection _$CourseSectionFromJson(Map<String, dynamic> json) =>
    CourseSection(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt(),
      lectures:
          (json['lectures'] as List<dynamic>?)
              ?.map((e) => Lecture.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lectureCount: json['lecture_count']?.toString(),
    );

Map<String, dynamic> _$CourseSectionToJson(CourseSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'sort_order': instance.sortOrder,
      'lectures': instance.lectures?.map((e) => e.toJson()).toList(),
      'lecture_count': instance.lectureCount,
    };

CourseSectionCreate _$CourseSectionCreateFromJson(Map<String, dynamic> json) =>
    CourseSectionCreate(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CourseSectionCreateToJson(
  CourseSectionCreate instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'sort_order': instance.sortOrder,
};

CourseSectionCreateRequest _$CourseSectionCreateRequestFromJson(
  Map<String, dynamic> json,
) => CourseSectionCreateRequest(
  title: json['title'] as String,
  description: json['description'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CourseSectionCreateRequestToJson(
  CourseSectionCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'sort_order': instance.sortOrder,
};

CourseSectionRequest _$CourseSectionRequestFromJson(
  Map<String, dynamic> json,
) => CourseSectionRequest(
  title: json['title'] as String,
  description: json['description'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CourseSectionRequestToJson(
  CourseSectionRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'sort_order': instance.sortOrder,
};

CustomTokenObtainPairRequest _$CustomTokenObtainPairRequestFromJson(
  Map<String, dynamic> json,
) => CustomTokenObtainPairRequest(
  email: json['email'] as String?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$CustomTokenObtainPairRequestToJson(
  CustomTokenObtainPairRequest instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};

EBook _$EBookFromJson(Map<String, dynamic> json) => EBook(
  id: json['id'] as String?,
  instructor: json['instructor'] as String,
  instructorName: json['instructor_name'] as String?,
  title: json['title'] as String,
  slug: json['slug'] as String?,
  description: json['description'] as String,
  authorName: json['author_name'] as String,
  coverImage: json['cover_image'] as String?,
  pdfFile: json['pdf_file'] as String,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  status: status1bcEnumNullableFromJson(json['status']),
  rejectionReason: json['rejection_reason'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$EBookToJson(EBook instance) => <String, dynamic>{
  'id': instance.id,
  'instructor': instance.instructor,
  'instructor_name': instance.instructorName,
  'title': instance.title,
  'slug': instance.slug,
  'description': instance.description,
  'author_name': instance.authorName,
  'cover_image': instance.coverImage,
  'pdf_file': instance.pdfFile,
  'category': instance.category?.toJson(),
  'status': status1bcEnumNullableToJson(instance.status),
  'rejection_reason': instance.rejectionReason,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

EBookCreateUpdate _$EBookCreateUpdateFromJson(Map<String, dynamic> json) =>
    EBookCreateUpdate(
      id: json['id'] as String?,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      status: status1bcEnumNullableFromJson(json['status']),
      description: json['description'] as String,
      authorName: json['author_name'] as String,
      coverImage: json['cover_image'] as String?,
      pdfFile: json['pdf_file'] as String,
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EBookCreateUpdateToJson(EBookCreateUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'status': status1bcEnumNullableToJson(instance.status),
      'description': instance.description,
      'author_name': instance.authorName,
      'cover_image': instance.coverImage,
      'pdf_file': instance.pdfFile,
      'category': instance.category?.toJson(),
    };

EBookCreateUpdateRequest _$EBookCreateUpdateRequestFromJson(
  Map<String, dynamic> json,
) => EBookCreateUpdateRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  authorName: json['author_name'] as String,
  coverImage: json['cover_image'] as String?,
  pdfFile: json['pdf_file'] as String,
  categoryId: json['category_id'] as String?,
);

Map<String, dynamic> _$EBookCreateUpdateRequestToJson(
  EBookCreateUpdateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'author_name': instance.authorName,
  'cover_image': instance.coverImage,
  'pdf_file': instance.pdfFile,
  'category_id': instance.categoryId,
};

EBookRequest _$EBookRequestFromJson(Map<String, dynamic> json) => EBookRequest(
  instructor: json['instructor'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  authorName: json['author_name'] as String,
  coverImage: json['cover_image'] as String?,
  pdfFile: json['pdf_file'] as String,
);

Map<String, dynamic> _$EBookRequestToJson(EBookRequest instance) =>
    <String, dynamic>{
      'instructor': instance.instructor,
      'title': instance.title,
      'description': instance.description,
      'author_name': instance.authorName,
      'cover_image': instance.coverImage,
      'pdf_file': instance.pdfFile,
    };

Enrollment _$EnrollmentFromJson(Map<String, dynamic> json) => Enrollment(
  id: json['id'] as String?,
  course: json['course'] as String,
  courseTitle: json['course_title'] as String?,
  courseSlug: json['course_slug'] as String?,
  courseThumbnail: json['course_thumbnail'] as String?,
  enrolledAt: json['enrolled_at'] == null
      ? null
      : DateTime.parse(json['enrolled_at'] as String),
  completed: json['completed'] as bool?,
  completionPercentage: (json['completion_percentage'] as num?)?.toDouble(),
);

Map<String, dynamic> _$EnrollmentToJson(Enrollment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course': instance.course,
      'course_title': instance.courseTitle,
      'course_slug': instance.courseSlug,
      'course_thumbnail': instance.courseThumbnail,
      'enrolled_at': instance.enrolledAt?.toIso8601String(),
      'completed': instance.completed,
      'completion_percentage': instance.completionPercentage,
    };

FCMTokenRequest _$FCMTokenRequestFromJson(Map<String, dynamic> json) =>
    FCMTokenRequest(
      fcmToken: json['fcm_token'] as String,
      deviceType: FCMTokenRequest.deviceTypeEnumDeviceTypeNullableFromJson(
        json['device_type'],
      ),
    );

Map<String, dynamic> _$FCMTokenRequestToJson(FCMTokenRequest instance) =>
    <String, dynamic>{
      'fcm_token': instance.fcmToken,
      'device_type': deviceTypeEnumNullableToJson(instance.deviceType),
    };

ForgotPassword _$ForgotPasswordFromJson(Map<String, dynamic> json) =>
    ForgotPassword(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordToJson(ForgotPassword instance) =>
    <String, dynamic>{'email': instance.email};

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) => ForgotPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordRequestToJson(
  ForgotPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

InstructorProfile _$InstructorProfileFromJson(Map<String, dynamic> json) =>
    InstructorProfile(
      bio: json['bio'] as String?,
      expertiseTags: json['expertise_tags'] as String?,
      website: json['website'] as String?,
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt(),
      specialtyCrops: json['specialty_crops'] as String?,
      socialLink: json['social_link'] as String?,
      qualifications: json['qualifications'] as String?,
      currentOccupation: json['current_occupation'] as String?,
      verificationStatus: verificationStatusEnumNullableFromJson(
        json['verification_status'],
      ),
      rejectionCounter: (json['rejection_counter'] as num?)?.toInt(),
      totalStudents: (json['total_students'] as num?)?.toInt(),
      totalRevenue: json['total_revenue'] as String?,
      kycVerified: json['kyc_verified'] as bool?,
      bankName: json['bank_name'] as String?,
      bankAccountName: json['bank_account_name'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankIfscCode: json['bank_ifsc_code'] as String?,
      kycDocumentType: json['kyc_document_type'],
      kycDocumentNumber: json['kyc_document_number'] as String?,
      kycDocumentImage: json['kyc_document_image'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$InstructorProfileToJson(InstructorProfile instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'expertise_tags': instance.expertiseTags,
      'website': instance.website,
      'years_of_experience': instance.yearsOfExperience,
      'specialty_crops': instance.specialtyCrops,
      'social_link': instance.socialLink,
      'qualifications': instance.qualifications,
      'current_occupation': instance.currentOccupation,
      'verification_status': verificationStatusEnumNullableToJson(
        instance.verificationStatus,
      ),
      'rejection_counter': instance.rejectionCounter,
      'total_students': instance.totalStudents,
      'total_revenue': instance.totalRevenue,
      'kyc_verified': instance.kycVerified,
      'bank_name': instance.bankName,
      'bank_account_name': instance.bankAccountName,
      'bank_account_number': instance.bankAccountNumber,
      'bank_ifsc_code': instance.bankIfscCode,
      'kyc_document_type': instance.kycDocumentType,
      'kyc_document_number': instance.kycDocumentNumber,
      'kyc_document_image': instance.kycDocumentImage,
      'created_at': instance.createdAt?.toIso8601String(),
    };

InstructorProfileRequest _$InstructorProfileRequestFromJson(
  Map<String, dynamic> json,
) => InstructorProfileRequest(
  bio: json['bio'] as String?,
  expertiseTags: json['expertise_tags'] as String?,
  website: json['website'] as String?,
  yearsOfExperience: (json['years_of_experience'] as num?)?.toInt(),
  specialtyCrops: json['specialty_crops'] as String?,
  socialLink: json['social_link'] as String?,
  qualifications: json['qualifications'] as String?,
  currentOccupation: json['current_occupation'] as String?,
  bankName: json['bank_name'] as String?,
  bankAccountName: json['bank_account_name'] as String?,
  bankAccountNumber: json['bank_account_number'] as String?,
  bankIfscCode: json['bank_ifsc_code'] as String?,
  kycDocumentType: json['kyc_document_type'],
  kycDocumentNumber: json['kyc_document_number'] as String?,
  kycDocumentImage: json['kyc_document_image'] as String?,
);

Map<String, dynamic> _$InstructorProfileRequestToJson(
  InstructorProfileRequest instance,
) => <String, dynamic>{
  'bio': instance.bio,
  'expertise_tags': instance.expertiseTags,
  'website': instance.website,
  'years_of_experience': instance.yearsOfExperience,
  'specialty_crops': instance.specialtyCrops,
  'social_link': instance.socialLink,
  'qualifications': instance.qualifications,
  'current_occupation': instance.currentOccupation,
  'bank_name': instance.bankName,
  'bank_account_name': instance.bankAccountName,
  'bank_account_number': instance.bankAccountNumber,
  'bank_ifsc_code': instance.bankIfscCode,
  'kyc_document_type': instance.kycDocumentType,
  'kyc_document_number': instance.kycDocumentNumber,
  'kyc_document_image': instance.kycDocumentImage,
};

Lecture _$LectureFromJson(Map<String, dynamic> json) => Lecture(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  videoUrl: json['video_url'] as String?,
  bunnyVideoId: json['bunny_video_id'] as String?,
  bunnyStatus: bunnyStatusEnumNullableFromJson(json['bunny_status']),
  duration: (json['duration'] as num?)?.toInt(),
  durationFormatted: json['duration_formatted'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  isPreview: json['is_preview'] as bool?,
  resources:
      (json['resources'] as List<dynamic>?)
          ?.map((e) => LectureResource.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$LectureToJson(Lecture instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'video_url': instance.videoUrl,
  'bunny_video_id': instance.bunnyVideoId,
  'bunny_status': bunnyStatusEnumNullableToJson(instance.bunnyStatus),
  'duration': instance.duration,
  'duration_formatted': instance.durationFormatted,
  'sort_order': instance.sortOrder,
  'is_preview': instance.isPreview,
  'resources': instance.resources?.map((e) => e.toJson()).toList(),
};

LectureCreate _$LectureCreateFromJson(Map<String, dynamic> json) =>
    LectureCreate(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      bunnyVideoId: json['bunny_video_id'] as String?,
      bunnyStatus: bunnyStatusEnumNullableFromJson(json['bunny_status']),
      duration: (json['duration'] as num?)?.toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt(),
      isPreview: json['is_preview'] as bool?,
    );

Map<String, dynamic> _$LectureCreateToJson(LectureCreate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'video_url': instance.videoUrl,
      'bunny_video_id': instance.bunnyVideoId,
      'bunny_status': bunnyStatusEnumNullableToJson(instance.bunnyStatus),
      'duration': instance.duration,
      'sort_order': instance.sortOrder,
      'is_preview': instance.isPreview,
    };

LectureCreateRequest _$LectureCreateRequestFromJson(
  Map<String, dynamic> json,
) => LectureCreateRequest(
  title: json['title'] as String,
  description: json['description'] as String?,
  videoUrl: json['video_url'] as String?,
  bunnyVideoId: json['bunny_video_id'] as String?,
  bunnyStatus: bunnyStatusEnumNullableFromJson(json['bunny_status']),
  duration: (json['duration'] as num?)?.toInt(),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  isPreview: json['is_preview'] as bool?,
);

Map<String, dynamic> _$LectureCreateRequestToJson(
  LectureCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'video_url': instance.videoUrl,
  'bunny_video_id': instance.bunnyVideoId,
  'bunny_status': bunnyStatusEnumNullableToJson(instance.bunnyStatus),
  'duration': instance.duration,
  'sort_order': instance.sortOrder,
  'is_preview': instance.isPreview,
};

LectureRequest _$LectureRequestFromJson(Map<String, dynamic> json) =>
    LectureRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      bunnyVideoId: json['bunny_video_id'] as String?,
      bunnyStatus: bunnyStatusEnumNullableFromJson(json['bunny_status']),
      duration: (json['duration'] as num?)?.toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt(),
      isPreview: json['is_preview'] as bool?,
    );

Map<String, dynamic> _$LectureRequestToJson(LectureRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'video_url': instance.videoUrl,
      'bunny_video_id': instance.bunnyVideoId,
      'bunny_status': bunnyStatusEnumNullableToJson(instance.bunnyStatus),
      'duration': instance.duration,
      'sort_order': instance.sortOrder,
      'is_preview': instance.isPreview,
    };

LectureResource _$LectureResourceFromJson(Map<String, dynamic> json) =>
    LectureResource(
      id: json['id'] as String?,
      fileName: json['file_name'] as String,
      file: json['file'] as String?,
      fileUrl: json['file_url'] as String?,
      fileType: fileTypeEnumNullableFromJson(json['file_type']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LectureResourceToJson(LectureResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file_name': instance.fileName,
      'file': instance.file,
      'file_url': instance.fileUrl,
      'file_type': fileTypeEnumNullableToJson(instance.fileType),
      'created_at': instance.createdAt?.toIso8601String(),
    };

LectureResourceRequest _$LectureResourceRequestFromJson(
  Map<String, dynamic> json,
) => LectureResourceRequest(
  fileName: json['file_name'] as String,
  file: json['file'] as String?,
  fileUrl: json['file_url'] as String?,
  fileType: fileTypeEnumNullableFromJson(json['file_type']),
);

Map<String, dynamic> _$LectureResourceRequestToJson(
  LectureResourceRequest instance,
) => <String, dynamic>{
  'file_name': instance.fileName,
  'file': instance.file,
  'file_url': instance.fileUrl,
  'file_type': fileTypeEnumNullableToJson(instance.fileType),
};

ModerationLog _$ModerationLogFromJson(Map<String, dynamic> json) =>
    ModerationLog(
      id: json['id'] as String?,
      courseId: json['course_id'] as String?,
      courseTitle: json['course_title'] as String?,
      failedStep: failedStepEnumFromJson(json['failed_step']),
      rejectedTokens: json['rejected_tokens'],
      fullAnalysis: json['full_analysis'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ModerationLogToJson(ModerationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_id': instance.courseId,
      'course_title': instance.courseTitle,
      'failed_step': failedStepEnumToJson(instance.failedStep),
      'rejected_tokens': instance.rejectedTokens,
      'full_analysis': instance.fullAnalysis,
      'created_at': instance.createdAt?.toIso8601String(),
    };

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['id'] as String?,
  notificationType: notificationNotificationTypeEnumFromJson(
    json['notification_type'],
  ),
  title: json['title'] as String,
  message: json['message'] as String,
  course: json['course'] as String?,
  isRead: json['is_read'] as bool?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notification_type': notificationNotificationTypeEnumToJson(
        instance.notificationType,
      ),
      'title': instance.title,
      'message': instance.message,
      'course': instance.course,
      'is_read': instance.isRead,
      'created_at': instance.createdAt?.toIso8601String(),
    };

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String?,
  totalAmount: json['total_amount'] as String,
  gatewayReference: json['gateway_reference'] as String?,
  gatewayName: json['gateway_name'] as String?,
  status: orderStatusEnumNullableFromJson(json['status']),
  paymentMethod: json['payment_method'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'total_amount': instance.totalAmount,
  'gateway_reference': instance.gatewayReference,
  'gateway_name': instance.gatewayName,
  'status': orderStatusEnumNullableToJson(instance.status),
  'payment_method': instance.paymentMethod,
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: json['id'] as String?,
  course: json['course'] as String?,
  courseTitle: json['course_title'] as String?,
  courseSlug: json['course_slug'] as String?,
  priceAtPurchase: json['price_at_purchase'] as String,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'course': instance.course,
  'course_title': instance.courseTitle,
  'course_slug': instance.courseSlug,
  'price_at_purchase': instance.priceAtPurchase,
};

PaginatedAdminUserList _$PaginatedAdminUserListFromJson(
  Map<String, dynamic> json,
) => PaginatedAdminUserList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedAdminUserListToJson(
  PaginatedAdminUserList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedCategoryAdminList _$PaginatedCategoryAdminListFromJson(
  Map<String, dynamic> json,
) => PaginatedCategoryAdminList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => CategoryAdmin.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedCategoryAdminListToJson(
  PaginatedCategoryAdminList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedCategoryList _$PaginatedCategoryListFromJson(
  Map<String, dynamic> json,
) => PaginatedCategoryList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedCategoryListToJson(
  PaginatedCategoryList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedCertificateTemplateList _$PaginatedCertificateTemplateListFromJson(
  Map<String, dynamic> json,
) => PaginatedCertificateTemplateList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => CertificateTemplate.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedCertificateTemplateListToJson(
  PaginatedCertificateTemplateList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedCourseDetailList _$PaginatedCourseDetailListFromJson(
  Map<String, dynamic> json,
) => PaginatedCourseDetailList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => CourseDetail.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedCourseDetailListToJson(
  PaginatedCourseDetailList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedCourseListList _$PaginatedCourseListListFromJson(
  Map<String, dynamic> json,
) => PaginatedCourseListList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => CourseList.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedCourseListListToJson(
  PaginatedCourseListList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedCourseSectionList _$PaginatedCourseSectionListFromJson(
  Map<String, dynamic> json,
) => PaginatedCourseSectionList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => CourseSection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedCourseSectionListToJson(
  PaginatedCourseSectionList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedEBookList _$PaginatedEBookListFromJson(Map<String, dynamic> json) =>
    PaginatedEBookList(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => EBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$PaginatedEBookListToJson(PaginatedEBookList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results.map((e) => e.toJson()).toList(),
    };

PaginatedEnrollmentList _$PaginatedEnrollmentListFromJson(
  Map<String, dynamic> json,
) => PaginatedEnrollmentList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => Enrollment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedEnrollmentListToJson(
  PaginatedEnrollmentList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedLectureList _$PaginatedLectureListFromJson(
  Map<String, dynamic> json,
) => PaginatedLectureList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => Lecture.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedLectureListToJson(
  PaginatedLectureList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedModerationLogList _$PaginatedModerationLogListFromJson(
  Map<String, dynamic> json,
) => PaginatedModerationLogList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => ModerationLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedModerationLogListToJson(
  PaginatedModerationLogList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedOrderList _$PaginatedOrderListFromJson(Map<String, dynamic> json) =>
    PaginatedOrderList(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$PaginatedOrderListToJson(PaginatedOrderList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results.map((e) => e.toJson()).toList(),
    };

PatchedAdminUserRequest _$PatchedAdminUserRequestFromJson(
  Map<String, dynamic> json,
) => PatchedAdminUserRequest(
  email: json['email'] as String?,
  fullName: json['full_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  role: roleEnumNullableFromJson(json['role']),
  avatar: json['avatar'] as String?,
  locationState: json['location_state'] as String?,
  locationDistrict: json['location_district'] as String?,
  farmingExperience: json['farming_experience'],
  areasOfInterest: json['areas_of_interest'],
  isActive: json['is_active'] as bool?,
  isStaff: json['is_staff'] as bool?,
  isSuperuser: json['is_superuser'] as bool?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$PatchedAdminUserRequestToJson(
  PatchedAdminUserRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'role': roleEnumNullableToJson(instance.role),
  'avatar': instance.avatar,
  'location_state': instance.locationState,
  'location_district': instance.locationDistrict,
  'farming_experience': instance.farmingExperience,
  'areas_of_interest': instance.areasOfInterest,
  'is_active': instance.isActive,
  'is_staff': instance.isStaff,
  'is_superuser': instance.isSuperuser,
  'password': instance.password,
};

PatchedCategoryAdminRequest _$PatchedCategoryAdminRequestFromJson(
  Map<String, dynamic> json,
) => PatchedCategoryAdminRequest(
  slug: json['slug'] as String?,
  contentType: contentTypeEnumNullableFromJson(json['content_type']),
  isActive: json['is_active'] as bool?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  nameEn: json['name_en'] as String?,
  descriptionEn: json['description_en'] as String?,
  nameHi: json['name_hi'] as String?,
  descriptionHi: json['description_hi'] as String?,
  nameMr: json['name_mr'] as String?,
  descriptionMr: json['description_mr'] as String?,
);

Map<String, dynamic> _$PatchedCategoryAdminRequestToJson(
  PatchedCategoryAdminRequest instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'content_type': contentTypeEnumNullableToJson(instance.contentType),
  'is_active': instance.isActive,
  'sort_order': instance.sortOrder,
  'name_en': instance.nameEn,
  'description_en': instance.descriptionEn,
  'name_hi': instance.nameHi,
  'description_hi': instance.descriptionHi,
  'name_mr': instance.nameMr,
  'description_mr': instance.descriptionMr,
};

PatchedCertificateTemplateRequest _$PatchedCertificateTemplateRequestFromJson(
  Map<String, dynamic> json,
) => PatchedCertificateTemplateRequest(
  title: json['title'] as String?,
  templateImage: json['template_image'] as String?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$PatchedCertificateTemplateRequestToJson(
  PatchedCertificateTemplateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'template_image': instance.templateImage,
  'is_active': instance.isActive,
};

PatchedCourseCreateRequest _$PatchedCourseCreateRequestFromJson(
  Map<String, dynamic> json,
) => PatchedCourseCreateRequest(
  title: json['title'] as String?,
  description: json['description'] as String?,
  shortDescription: json['short_description'] as String?,
  categoryId: json['category_id'] as String?,
  level: levelEnumNullableFromJson(json['level']),
  price: json['price'] as String?,
  thumbnail: json['thumbnail'] as String?,
  previewVideoUrl: json['preview_video_url'] as String?,
  language: json['language'] as String?,
  whatYouLearn: json['what_you_learn'] as String?,
  requirements: json['requirements'] as String?,
  tags: json['tags'] as String?,
);

Map<String, dynamic> _$PatchedCourseCreateRequestToJson(
  PatchedCourseCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'short_description': instance.shortDescription,
  'category_id': instance.categoryId,
  'level': levelEnumNullableToJson(instance.level),
  'price': instance.price,
  'thumbnail': instance.thumbnail,
  'preview_video_url': instance.previewVideoUrl,
  'language': instance.language,
  'what_you_learn': instance.whatYouLearn,
  'requirements': instance.requirements,
  'tags': instance.tags,
};

PatchedCourseSectionCreateRequest _$PatchedCourseSectionCreateRequestFromJson(
  Map<String, dynamic> json,
) => PatchedCourseSectionCreateRequest(
  title: json['title'] as String?,
  description: json['description'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$PatchedCourseSectionCreateRequestToJson(
  PatchedCourseSectionCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'sort_order': instance.sortOrder,
};

PatchedEBookCreateUpdateRequest _$PatchedEBookCreateUpdateRequestFromJson(
  Map<String, dynamic> json,
) => PatchedEBookCreateUpdateRequest(
  title: json['title'] as String?,
  description: json['description'] as String?,
  authorName: json['author_name'] as String?,
  coverImage: json['cover_image'] as String?,
  pdfFile: json['pdf_file'] as String?,
  categoryId: json['category_id'] as String?,
);

Map<String, dynamic> _$PatchedEBookCreateUpdateRequestToJson(
  PatchedEBookCreateUpdateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'author_name': instance.authorName,
  'cover_image': instance.coverImage,
  'pdf_file': instance.pdfFile,
  'category_id': instance.categoryId,
};

PatchedEBookRequest _$PatchedEBookRequestFromJson(Map<String, dynamic> json) =>
    PatchedEBookRequest(
      instructor: json['instructor'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      authorName: json['author_name'] as String?,
      coverImage: json['cover_image'] as String?,
      pdfFile: json['pdf_file'] as String?,
    );

Map<String, dynamic> _$PatchedEBookRequestToJson(
  PatchedEBookRequest instance,
) => <String, dynamic>{
  'instructor': instance.instructor,
  'title': instance.title,
  'description': instance.description,
  'author_name': instance.authorName,
  'cover_image': instance.coverImage,
  'pdf_file': instance.pdfFile,
};

PatchedInstructorProfileRequest _$PatchedInstructorProfileRequestFromJson(
  Map<String, dynamic> json,
) => PatchedInstructorProfileRequest(
  bio: json['bio'] as String?,
  expertiseTags: json['expertise_tags'] as String?,
  website: json['website'] as String?,
  yearsOfExperience: (json['years_of_experience'] as num?)?.toInt(),
  specialtyCrops: json['specialty_crops'] as String?,
  socialLink: json['social_link'] as String?,
  qualifications: json['qualifications'] as String?,
  currentOccupation: json['current_occupation'] as String?,
  bankName: json['bank_name'] as String?,
  bankAccountName: json['bank_account_name'] as String?,
  bankAccountNumber: json['bank_account_number'] as String?,
  bankIfscCode: json['bank_ifsc_code'] as String?,
  kycDocumentType: json['kyc_document_type'],
  kycDocumentNumber: json['kyc_document_number'] as String?,
  kycDocumentImage: json['kyc_document_image'] as String?,
);

Map<String, dynamic> _$PatchedInstructorProfileRequestToJson(
  PatchedInstructorProfileRequest instance,
) => <String, dynamic>{
  'bio': instance.bio,
  'expertise_tags': instance.expertiseTags,
  'website': instance.website,
  'years_of_experience': instance.yearsOfExperience,
  'specialty_crops': instance.specialtyCrops,
  'social_link': instance.socialLink,
  'qualifications': instance.qualifications,
  'current_occupation': instance.currentOccupation,
  'bank_name': instance.bankName,
  'bank_account_name': instance.bankAccountName,
  'bank_account_number': instance.bankAccountNumber,
  'bank_ifsc_code': instance.bankIfscCode,
  'kyc_document_type': instance.kycDocumentType,
  'kyc_document_number': instance.kycDocumentNumber,
  'kyc_document_image': instance.kycDocumentImage,
};

PatchedLectureCreateRequest _$PatchedLectureCreateRequestFromJson(
  Map<String, dynamic> json,
) => PatchedLectureCreateRequest(
  title: json['title'] as String?,
  description: json['description'] as String?,
  videoUrl: json['video_url'] as String?,
  bunnyVideoId: json['bunny_video_id'] as String?,
  bunnyStatus: bunnyStatusEnumNullableFromJson(json['bunny_status']),
  duration: (json['duration'] as num?)?.toInt(),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  isPreview: json['is_preview'] as bool?,
);

Map<String, dynamic> _$PatchedLectureCreateRequestToJson(
  PatchedLectureCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'video_url': instance.videoUrl,
  'bunny_video_id': instance.bunnyVideoId,
  'bunny_status': bunnyStatusEnumNullableToJson(instance.bunnyStatus),
  'duration': instance.duration,
  'sort_order': instance.sortOrder,
  'is_preview': instance.isPreview,
};

PatchedUserProfileRequest _$PatchedUserProfileRequestFromJson(
  Map<String, dynamic> json,
) => PatchedUserProfileRequest(
  fullName: json['full_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  avatar: json['avatar'] as String?,
  locationState: json['location_state'] as String?,
  locationDistrict: json['location_district'] as String?,
  farmingExperience: json['farming_experience'],
  areasOfInterest: json['areas_of_interest'],
);

Map<String, dynamic> _$PatchedUserProfileRequestToJson(
  PatchedUserProfileRequest instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'avatar': instance.avatar,
  'location_state': instance.locationState,
  'location_district': instance.locationDistrict,
  'farming_experience': instance.farmingExperience,
  'areas_of_interest': instance.areasOfInterest,
};

Register _$RegisterFromJson(Map<String, dynamic> json) => Register(
  email: json['email'] as String,
  fullName: json['full_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  role: roleEnumNullableFromJson(json['role']),
);

Map<String, dynamic> _$RegisterToJson(Register instance) => <String, dynamic>{
  'email': instance.email,
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'role': roleEnumNullableToJson(instance.role),
};

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: roleEnumNullableFromJson(json['role']),
      password: json['password'] as String?,
      passwordConfirm: json['password_confirm'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'role': roleEnumNullableToJson(instance.role),
      'password': instance.password,
      'password_confirm': instance.passwordConfirm,
    };

ResendOTP _$ResendOTPFromJson(Map<String, dynamic> json) => ResendOTP(
  email: json['email'] as String,
  purpose: ResendOTP.purposeEnumPurposeNullableFromJson(json['purpose']),
);

Map<String, dynamic> _$ResendOTPToJson(ResendOTP instance) => <String, dynamic>{
  'email': instance.email,
  'purpose': purposeEnumNullableToJson(instance.purpose),
};

ResendOTPRequest _$ResendOTPRequestFromJson(Map<String, dynamic> json) =>
    ResendOTPRequest(
      email: json['email'] as String,
      purpose: ResendOTPRequest.purposeEnumPurposeNullableFromJson(
        json['purpose'],
      ),
    );

Map<String, dynamic> _$ResendOTPRequestToJson(ResendOTPRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'purpose': purposeEnumNullableToJson(instance.purpose),
    };

ResetPassword _$ResetPasswordFromJson(Map<String, dynamic> json) =>
    ResetPassword(
      resetToken: json['reset_token'] as String,
      newPassword: json['new_password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$ResetPasswordToJson(ResetPassword instance) =>
    <String, dynamic>{
      'reset_token': instance.resetToken,
      'new_password': instance.newPassword,
      'confirm_password': instance.confirmPassword,
    };

ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequest(
  resetToken: json['reset_token'] as String,
  newPassword: json['new_password'] as String,
  confirmPassword: json['confirm_password'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  ResetPasswordRequest instance,
) => <String, dynamic>{
  'reset_token': instance.resetToken,
  'new_password': instance.newPassword,
  'confirm_password': instance.confirmPassword,
};

StudentNotification _$StudentNotificationFromJson(Map<String, dynamic> json) =>
    StudentNotification(
      id: json['id'] as String?,
      notificationType: studentNotificationNotificationTypeEnumFromJson(
        json['notification_type'],
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      course: json['course'] as String?,
      courseSlug: json['course_slug'] as String?,
      courseTitle: json['course_title'] as String?,
      ebook: json['ebook'] as String?,
      ebookId: json['ebook_id'] as String?,
      ebookTitle: json['ebook_title'] as String?,
      isRead: json['is_read'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$StudentNotificationToJson(
  StudentNotification instance,
) => <String, dynamic>{
  'id': instance.id,
  'notification_type': studentNotificationNotificationTypeEnumToJson(
    instance.notificationType,
  ),
  'title': instance.title,
  'message': instance.message,
  'course': instance.course,
  'course_slug': instance.courseSlug,
  'course_title': instance.courseTitle,
  'ebook': instance.ebook,
  'ebook_id': instance.ebookId,
  'ebook_title': instance.ebookTitle,
  'is_read': instance.isRead,
  'created_at': instance.createdAt?.toIso8601String(),
};

TokenRefresh _$TokenRefreshFromJson(Map<String, dynamic> json) => TokenRefresh(
  access: json['access'] as String?,
  refresh: json['refresh'] as String,
);

Map<String, dynamic> _$TokenRefreshToJson(TokenRefresh instance) =>
    <String, dynamic>{'access': instance.access, 'refresh': instance.refresh};

TokenRefreshRequest _$TokenRefreshRequestFromJson(Map<String, dynamic> json) =>
    TokenRefreshRequest(refresh: json['refresh'] as String);

Map<String, dynamic> _$TokenRefreshRequestToJson(
  TokenRefreshRequest instance,
) => <String, dynamic>{'refresh': instance.refresh};

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String?,
  email: json['email'] as String?,
  fullName: json['full_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
  role: roleEnumNullableFromJson(json['role']),
  avatar: json['avatar'] as String?,
  locationState: json['location_state'] as String?,
  locationDistrict: json['location_district'] as String?,
  farmingExperience: json['farming_experience'],
  areasOfInterest: json['areas_of_interest'],
  dateJoined: json['date_joined'] == null
      ? null
      : DateTime.parse(json['date_joined'] as String),
  instructorProfile: json['instructor_profile'],
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'role': roleEnumNullableToJson(instance.role),
      'avatar': instance.avatar,
      'location_state': instance.locationState,
      'location_district': instance.locationDistrict,
      'farming_experience': instance.farmingExperience,
      'areas_of_interest': instance.areasOfInterest,
      'date_joined': instance.dateJoined?.toIso8601String(),
      'instructor_profile': instance.instructorProfile,
    };

UserProfileRequest _$UserProfileRequestFromJson(Map<String, dynamic> json) =>
    UserProfileRequest(
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      locationState: json['location_state'] as String?,
      locationDistrict: json['location_district'] as String?,
      farmingExperience: json['farming_experience'],
      areasOfInterest: json['areas_of_interest'],
    );

Map<String, dynamic> _$UserProfileRequestToJson(UserProfileRequest instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'avatar': instance.avatar,
      'location_state': instance.locationState,
      'location_district': instance.locationDistrict,
      'farming_experience': instance.farmingExperience,
      'areas_of_interest': instance.areasOfInterest,
    };

VerifyResetOTP _$VerifyResetOTPFromJson(Map<String, dynamic> json) =>
    VerifyResetOTP(email: json['email'] as String, otp: json['otp'] as String);

Map<String, dynamic> _$VerifyResetOTPToJson(VerifyResetOTP instance) =>
    <String, dynamic>{'email': instance.email, 'otp': instance.otp};

VerifyResetOTPRequest _$VerifyResetOTPRequestFromJson(
  Map<String, dynamic> json,
) => VerifyResetOTPRequest(
  email: json['email'] as String,
  otp: json['otp'] as String,
);

Map<String, dynamic> _$VerifyResetOTPRequestToJson(
  VerifyResetOTPRequest instance,
) => <String, dynamic>{'email': instance.email, 'otp': instance.otp};

ApiV1AuthFcmTokenPost$Response _$ApiV1AuthFcmTokenPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AuthFcmTokenPost$Response(message: json['message'] as String?);

Map<String, dynamic> _$ApiV1AuthFcmTokenPost$ResponseToJson(
  ApiV1AuthFcmTokenPost$Response instance,
) => <String, dynamic>{'message': instance.message};
