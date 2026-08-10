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
    this.currentOccupation,
    this.location,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
    this.language = 'English',
    this.createdAt,
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
  final String? currentOccupation;

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
    if (profile.instructorProfile is Map<String, dynamic>) {
      instructorDetails = InstructorProfile.fromJson(profile.instructorProfile as Map<String, dynamic>);
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
      currentOccupation: instructorDetails?.currentOccupation,
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
    String? currentOccupation,
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
      currentOccupation: currentOccupation ?? this.currentOccupation,
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
