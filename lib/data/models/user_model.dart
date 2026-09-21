import '../../core/network/api_client.dart';
import 'user_role.dart';

/// Represents an authenticated IGrow user.
///
/// Supports dual-role toggling: [grantedRoles] lists all roles the account is
/// eligible for, while [activeRole] is the currently selected one. The entire
/// navigation shell is derived from [activeRole].
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.activeRole,
    required this.grantedRoles,
    this.avatarUrl,
    this.bio,
    this.expertiseTags,
    this.website,
    this.yearsOfExperience,
    this.specialtyCrops,
    this.socialLink,
    this.qualifications,
    this.currentOccupation,
    this.location,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
    this.language = 'English',
    this.createdAt,
    this.kycVerified,
    this.verificationStatus,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.kycDocumentType,
    this.kycDocumentNumber,
    this.kycDocumentImage,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole activeRole;
  final List<UserRole> grantedRoles;
  final String? avatarUrl;
  
  // Instructor Profile fields
  final String? bio;
  final String? expertiseTags;
  final String? website;
  final int? yearsOfExperience;
  final String? specialtyCrops;
  final String? socialLink;
  final String? qualifications;
  final String? currentOccupation;

  // Instructor KYC & Bank fields
  final bool? kycVerified;
  final String? verificationStatus; // 'PENDING' | 'VERIFIED' | 'SUSPENDED'
  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? kycDocumentType; // 'AADHAAR' | 'PAN'
  final String? kycDocumentNumber;
  final String? kycDocumentImage;

  // Student fields
  final String? location;
  final String? locationState;
  final String? locationDistrict;
  final String? farmingExperience;
  final List<String>? areasOfInterest;
  final String language;
  final DateTime? createdAt;

  /// Whether this user can switch to [role].
  bool canSwitchTo(UserRole role) => grantedRoles.contains(role);

  /// Whether the user is currently acting as a farmer/student.
  bool get isFarmer => activeRole == UserRole.farmer;

  /// Whether the user is currently acting as an instructor.
  bool get isInstructor => activeRole == UserRole.instructor;

  /// Whether the user is currently acting as an admin.
  bool get isAdmin => activeRole == UserRole.admin;

  /// Whether the user has submitted KYC details.
  bool get hasSubmittedKyc =>
      (kycDocumentNumber != null && kycDocumentNumber!.trim().isNotEmpty) ||
      (bankAccountNumber != null && bankAccountNumber!.trim().isNotEmpty);

  /// Whether KYC is currently verified.
  bool get isKycVerified =>
      kycVerified == true || verificationStatus == 'VERIFIED';

  /// Whether KYC was submitted and is currently under review by admin.
  bool get isKycPending =>
      !isKycVerified && hasSubmittedKyc && (verificationStatus == 'PENDING');

  /// Create a [UserModel] from the backend [UserProfile] response.
  factory UserModel.fromApiProfile(UserProfile profile) {
    final role = UserRole.fromApiValue(profile.role?.value ?? '');

    // Build location string from state + district
    String? locationStr;
    if (profile.locationDistrict != null && profile.locationState != null) {
      locationStr = '${profile.locationDistrict}, ${profile.locationState}';
    } else if (profile.locationState != null) {
      locationStr = profile.locationState;
    } else if (profile.locationDistrict != null) {
      locationStr = profile.locationDistrict;
    }

    InstructorProfile? instructorDetails;
    Map<String, dynamic>? rawInstructorMap;
    if (profile.instructorProfile is Map<String, dynamic>) {
      rawInstructorMap = profile.instructorProfile as Map<String, dynamic>;
      instructorDetails = InstructorProfile.fromJson(rawInstructorMap);
    }

    String? verStatus = instructorDetails?.verificationStatus?.value;
    if (verStatus == null && rawInstructorMap != null) {
      verStatus = rawInstructorMap['verification_status']?.toString();
    }

    return UserModel(
      id: profile.id ?? '',
      fullName: profile.fullName ?? '',
      email: profile.email ?? '',
      phone: profile.phoneNumber ?? '',
      activeRole: role,
      grantedRoles: [role], // Backend sends single role
      avatarUrl: profile.avatar,
      bio: instructorDetails?.bio,
      expertiseTags: instructorDetails?.expertiseTags,
      website: instructorDetails?.website,
      yearsOfExperience: instructorDetails?.yearsOfExperience,
      specialtyCrops: instructorDetails?.specialtyCrops,
      socialLink: instructorDetails?.socialLink,
      qualifications: instructorDetails?.qualifications ?? (rawInstructorMap?['qualifications'] as String?),
      currentOccupation: instructorDetails?.currentOccupation,
      kycVerified: instructorDetails?.kycVerified ?? (rawInstructorMap?['kyc_verified'] as bool?),
      verificationStatus: verStatus,
      bankName: instructorDetails?.bankName ?? (rawInstructorMap?['bank_name'] as String?),
      bankAccountName: instructorDetails?.bankAccountName ?? (rawInstructorMap?['bank_account_name'] as String?),
      bankAccountNumber: instructorDetails?.bankAccountNumber ?? (rawInstructorMap?['bank_account_number'] as String?),
      bankIfscCode: instructorDetails?.bankIfscCode ?? (rawInstructorMap?['bank_ifsc_code'] as String?),
      kycDocumentType: instructorDetails?.kycDocumentType?.toString() ?? (rawInstructorMap?['kyc_document_type'] as String?),
      kycDocumentNumber: instructorDetails?.kycDocumentNumber ?? (rawInstructorMap?['kyc_document_number'] as String?),
      kycDocumentImage: instructorDetails?.kycDocumentImage ?? (rawInstructorMap?['kyc_document_image'] as String?),
      location: locationStr,
      locationState: profile.locationState,
      locationDistrict: profile.locationDistrict,
      farmingExperience: profile.farmingExperience?.toString(),
      areasOfInterest: (profile.areasOfInterest as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt: profile.dateJoined,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? activeRole,
    List<UserRole>? grantedRoles,
    String? avatarUrl,
    String? bio,
    String? expertiseTags,
    String? website,
    int? yearsOfExperience,
    String? specialtyCrops,
    String? socialLink,
    String? qualifications,
    String? currentOccupation,
    bool? kycVerified,
    String? verificationStatus,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? kycDocumentType,
    String? kycDocumentNumber,
    String? kycDocumentImage,
    String? location,
    String? locationState,
    String? locationDistrict,
    String? farmingExperience,
    List<String>? areasOfInterest,
    String? language,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      activeRole: activeRole ?? this.activeRole,
      grantedRoles: grantedRoles ?? this.grantedRoles,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      expertiseTags: expertiseTags ?? this.expertiseTags,
      website: website ?? this.website,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      specialtyCrops: specialtyCrops ?? this.specialtyCrops,
      socialLink: socialLink ?? this.socialLink,
      qualifications: qualifications ?? this.qualifications,
      currentOccupation: currentOccupation ?? this.currentOccupation,
      kycVerified: kycVerified ?? this.kycVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      kycDocumentType: kycDocumentType ?? this.kycDocumentType,
      kycDocumentNumber: kycDocumentNumber ?? this.kycDocumentNumber,
      kycDocumentImage: kycDocumentImage ?? this.kycDocumentImage,
      location: location ?? this.location,
      locationState: locationState ?? this.locationState,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $fullName, role: $activeRole)';
}
