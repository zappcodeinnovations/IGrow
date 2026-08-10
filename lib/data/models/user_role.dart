import 'package:flutter/material.dart';

/// The three roles in IGrow.
///
/// A user account has **one active role at a time**, chosen during onboarding
/// and switchable later from Profile. The navigation shell, bottom-nav config,
/// and route guards are all derived from [activeRole].
///
/// **Backend mapping**: The server uses `STUDENT` / `INSTRUCTOR` / `ADMIN`.
/// We map `STUDENT ↔ farmer` in the app.
enum UserRole {
  farmer,
  instructor,
  admin;

  /// Human-readable label for UI.
  String get label {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer / Student';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  /// Short label for badges/chips.
  String get shortLabel {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  /// Icon representing the role.
  IconData get icon {
    switch (this) {
      case UserRole.farmer:
        return Icons.agriculture_rounded;
      case UserRole.instructor:
        return Icons.school_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  /// Description for the role-picker card.
  String get description {
    switch (this) {
      case UserRole.farmer:
        return 'Learn farming techniques, watch video courses, buy products, and connect with experts.';
      case UserRole.instructor:
        return 'Create & sell courses, share expertise, mentor farmers, and grow your audience.';
      case UserRole.admin:
        return 'Manage users, content, and platform settings.';
    }
  }

  /// Convert to backend API string value.
  String get apiValue {
    switch (this) {
      case UserRole.farmer:
        return 'STUDENT';
      case UserRole.instructor:
        return 'INSTRUCTOR';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  /// Create [UserRole] from backend API string (e.g. 'STUDENT' → farmer).
  static UserRole fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'STUDENT':
        return UserRole.farmer;
      case 'INSTRUCTOR':
        return UserRole.instructor;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.farmer; // Default to farmer if unknown
    }
  }
}
