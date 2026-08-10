// ── Login ───────────────────────────────────────────────────────

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  const LoginResponse({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );
}

// ── Register ────────────────────────────────────────────────────

class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.passwordConfirm,
    this.fullName,
    this.phoneNumber,
    this.role,
  });

  final String email;
  final String password;
  final String passwordConfirm;
  final String? fullName;
  final String? phoneNumber;
  final String? role; // 'STUDENT' | 'INSTRUCTOR'

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (role != null) 'role': role,
      };
}

class RegisterResponse {
  const RegisterResponse({
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
  });

  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? role;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        phoneNumber: json['phone_number'] as String?,
        role: json['role'] as String?,
      );
}

// ── Forgot Password (Step 1) ────────────────────────────────────

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

// ── Verify Reset OTP (Step 2) ───────────────────────────────────

class VerifyResetOtpRequest {
  const VerifyResetOtpRequest({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class VerifyResetOtpResponse {
  const VerifyResetOtpResponse({required this.resetToken});

  final String resetToken;

  factory VerifyResetOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyResetOtpResponse(
        resetToken: json['reset_token'] as String,
      );
}

// ── Reset Password (Step 3) ─────────────────────────────────────

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
        'reset_token': resetToken,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
}

// ── Resend OTP ──────────────────────────────────────────────────

class ResendOtpRequest {
  const ResendOtpRequest({required this.email, this.purpose = 'PASSWORD_RESET'});

  final String email;
  final String purpose;

  Map<String, dynamic> toJson() => {'email': email, 'purpose': purpose};
}

// ── Change Password (authenticated) ─────────────────────────────

class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
}

// ── Token Refresh ───────────────────────────────────────────────

class TokenRefreshRequest {
  const TokenRefreshRequest({required this.refresh});

  final String refresh;

  Map<String, dynamic> toJson() => {'refresh': refresh};
}

class TokenRefreshResponse {
  const TokenRefreshResponse({required this.access, this.refresh});

  final String access;
  final String? refresh;

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) =>
      TokenRefreshResponse(
        access: json['access'] as String,
        refresh: json['refresh'] as String?,
      );
}
