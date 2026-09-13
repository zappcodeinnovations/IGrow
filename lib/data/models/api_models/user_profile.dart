/// User profile model matching the backend `UserProfile` schema.
///
/// This is the response from `GET /api/v1/auth/me/`.
class ApiUserProfile {
  const ApiUserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.role,
    this.avatar,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
    this.dateJoined,
    this.instructorProfile,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String role; // 'STUDENT' | 'INSTRUCTOR' | 'ADMIN'
  final String? avatar;
  final String? locationState;
  final String? locationDistrict;
  final String? farmingExperience; // 'BEGINNER' | 'INTERMEDIATE' | 'EXPERT'
  final List<String>? areasOfInterest;
  final DateTime? dateJoined;
  final dynamic instructorProfile; // Nested or null

  factory ApiUserProfile.fromJson(Map<String, dynamic> json) {
    List<String>? interests;
    if (json['areas_of_interest'] != null) {
      if (json['areas_of_interest'] is List) {
        interests =
            (json['areas_of_interest'] as List).map((e) => e.toString()).toList();
      }
    }

    return ApiUserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String? ?? 'STUDENT',
      avatar: json['avatar'] as String?,
      locationState: json['location_state'] as String?,
      locationDistrict: json['location_district'] as String?,
      farmingExperience: json['farming_experience'] as String?,
      areasOfInterest: interests,
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'] as String)
          : null,
      instructorProfile: json['instructor_profile'],
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (avatar != null) 'avatar': avatar,
        if (locationState != null) 'location_state': locationState,
        if (locationDistrict != null) 'location_district': locationDistrict,
        if (farmingExperience != null) 'farming_experience': farmingExperience,
        if (areasOfInterest != null) 'areas_of_interest': areasOfInterest,
      };
}

/// Instructor profile details — from `GET /api/v1/auth/instructor-profile/`.
class ApiInstructorProfile {
  const ApiInstructorProfile({
    this.bio,
    this.expertiseTags,
    this.website,
    this.yearsOfExperience,
    this.specialtyCrops,
    this.socialLink,
    this.qualifications,
    this.currentOccupation,
    this.verificationStatus,
    this.rejectionCounter,
    this.totalStudents,
    this.totalRevenue,
    this.createdAt,
    this.kycVerified,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.kycDocumentType,
    this.kycDocumentNumber,
    this.kycDocumentImage,
  });

  final String? bio;
  final String? expertiseTags;
  final String? website;
  final int? yearsOfExperience;
  final String? specialtyCrops;
  final String? socialLink;
  final String? qualifications;
  final String? currentOccupation;
  final String? verificationStatus; // 'PENDING' | 'VERIFIED' | 'SUSPENDED'
  final int? rejectionCounter;
  final int? totalStudents;
  final String? totalRevenue;
  final DateTime? createdAt;
  final bool? kycVerified;
  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? kycDocumentType; // 'AADHAAR' | 'PAN'
  final String? kycDocumentNumber;
  final String? kycDocumentImage;

  factory ApiInstructorProfile.fromJson(Map<String, dynamic> json) =>
      ApiInstructorProfile(
        bio: json['bio'] as String?,
        expertiseTags: json['expertise_tags'] as String?,
        website: json['website'] as String?,
        yearsOfExperience: json['years_of_experience'] as int?,
        specialtyCrops: json['specialty_crops'] as String?,
        socialLink: json['social_link'] as String?,
        qualifications: json['qualifications'] as String?,
        currentOccupation: json['current_occupation'] as String?,
        verificationStatus: json['verification_status'] as String?,
        rejectionCounter: json['rejection_counter'] as int?,
        totalStudents: json['total_students'] as int?,
        totalRevenue: json['total_revenue']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        kycVerified: json['kyc_verified'] as bool?,
        bankName: json['bank_name'] as String?,
        bankAccountName: json['bank_account_name'] as String?,
        bankAccountNumber: json['bank_account_number'] as String?,
        bankIfscCode: json['bank_ifsc_code'] as String?,
        kycDocumentType: json['kyc_document_type'] as String?,
        kycDocumentNumber: json['kyc_document_number'] as String?,
        kycDocumentImage: json['kyc_document_image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (bio != null) 'bio': bio,
        if (expertiseTags != null) 'expertise_tags': expertiseTags,
        if (website != null) 'website': website,
        if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
        if (specialtyCrops != null) 'specialty_crops': specialtyCrops,
        if (socialLink != null) 'social_link': socialLink,
        if (qualifications != null) 'qualifications': qualifications,
        if (currentOccupation != null) 'current_occupation': currentOccupation,
        if (bankName != null) 'bank_name': bankName,
        if (bankAccountName != null) 'bank_account_name': bankAccountName,
        if (bankAccountNumber != null) 'bank_account_number': bankAccountNumber,
        if (bankIfscCode != null) 'bank_ifsc_code': bankIfscCode,
        if (kycDocumentType != null) 'kyc_document_type': kycDocumentType,
        if (kycDocumentNumber != null) 'kyc_document_number': kycDocumentNumber,
        if (kycDocumentImage != null) 'kyc_document_image': kycDocumentImage,
      };
}
