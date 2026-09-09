import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/token_storage.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({required String email, required String password});
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required UserRole role,
  });
  Future<void> forgotPassword({required String email});
  Future<String> verifyResetOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> resendOtp({required String email});
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<UserModel> switchRole(UserRole newRole);
  Future<void> logout();
  Future<bool> hasSession();
  
  Future<UserModel> updateProfile(PatchedUserProfileRequest request);
  Future<UserModel> updateInstructorProfile(PatchedInstructorProfileRequest request);
  Future<void> uploadAvatar(String imagePath);
  Future<void> deleteAvatar();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required this.appApi,
    required this.tokenStorage,
  });

  final AppApi appApi;
  final TokenStorage tokenStorage;

  UserModel? _currentUser;

  void _handleError(chopper.Response response) {
    if (!response.isSuccessful) {
      String errorMessage = 'Error: ${response.statusCode} - ${response.error}';
      Map<String, dynamic>? errorData;

      try {
        if (response.error is String) {
          errorData = jsonDecode(response.error as String);
        } else if (response.error != null) {
          errorData = jsonDecode(jsonEncode(response.error));
        } else if (response.bodyString.isNotEmpty) {
          errorData = jsonDecode(response.bodyString);
        }
      } catch (_) {}

      if (response.statusCode == 400 && errorData != null) {
        throw ApiException.validation(errorData);
      }

      if (response.statusCode == 401) {
        if (errorData != null && errorData.containsKey('detail')) {
          throw ApiException.unauthorized(errorData['detail'].toString());
        }
        throw ApiException.unauthorized();
      }

      if (errorData != null) {
        if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData.containsKey('non_field_errors')) {
          final nfe = errorData['non_field_errors'];
          errorMessage = nfe is List ? nfe.first.toString() : nfe.toString();
        } else {
          errorMessage = errorData.toString();
        }
      }

      throw ApiException(statusCode: response.statusCode, message: errorMessage);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final hasToken = await tokenStorage.hasToken();
    if (!hasToken) return null;

    try {
      final response = await appApi.apiV1AuthMeGet();
      _handleError(response);
      final profile = response.body;
      if (profile == null) return null;
      _currentUser = UserModel.fromApiProfile(profile);
      return _currentUser;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await tokenStorage.clearTokens();
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await appApi.apiV1AuthLoginPost(
      body: CustomTokenObtainPairRequest(email: email.trim(), password: password),
    );
    _handleError(response);

    final data = response.body as Map<String, dynamic>?;
    if (data == null || !data.containsKey('access')) {
      throw ApiException.server('Invalid login response');
    }

    await tokenStorage.saveTokens(
      access: data['access'],
      refresh: data['refresh'],
    );

    final meResponse = await appApi.apiV1AuthMeGet();
    _handleError(meResponse);
    final profile = meResponse.body;
    if (profile == null) throw ApiException.server('Failed to fetch profile');
    
    _currentUser = UserModel.fromApiProfile(profile);
    return _currentUser!;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required UserRole role,
  }) async {
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/register/');
    final body = {
      'email': email.trim(),
      'password': password,
      'password_confirm': passwordConfirm,
      'full_name': fullName.trim(),
      'phone_number': phone.trim().isNotEmpty ? phone.trim() : null,
      'role': role.apiValue,
    };
    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 400) {
      String errorMessage = 'Registration failed (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        if (response.statusCode == 400) {
          throw ApiException.validation(errorData);
        }
        if (errorData is Map && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData is Map && errorData.containsKey('non_field_errors')) {
          final nfe = errorData['non_field_errors'];
          errorMessage = nfe is List ? nfe.first.toString() : nfe.toString();
        } else {
          errorMessage = errorData.toString();
        }
      } catch (e) {
        if (e is ApiException) rethrow;
      }
      throw ApiException(statusCode: response.statusCode, message: errorMessage);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final response = await appApi.apiV1AuthForgotPasswordPost(
      body: ForgotPasswordRequest(email: email.trim()),
    );
    _handleError(response);
  }

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/verify-reset-otp/');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'otp': otp.trim(),
      }),
    );

    if (response.statusCode >= 400) {
      String errorMessage = 'Failed to verify OTP (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData is Map && errorData.containsKey('non_field_errors')) {
          final nfe = errorData['non_field_errors'];
          errorMessage = nfe is List ? nfe.first.toString() : nfe.toString();
        } else {
          errorMessage = errorData.toString();
        }
      } catch (_) {}
      throw ApiException(statusCode: response.statusCode, message: errorMessage);
    }

    try {
      final data = jsonDecode(response.body);
      return data['reset_token'] ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await appApi.apiV1AuthResetPasswordPost(
      body: ResetPasswordRequest(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
    _handleError(response);
  }

  @override
  Future<void> resendOtp({required String email}) async {
    final response = await appApi.apiV1AuthResendOtpPost(
      body: ResendOTPRequest(email: email.trim()),
    );
    _handleError(response);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await appApi.apiV1AuthChangePasswordPost(
      body: ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
    _handleError(response);
  }

  @override
  Future<UserModel> switchRole(UserRole newRole) async {
    if (_currentUser == null) throw Exception('Not authenticated');
    if (!_currentUser!.canSwitchTo(newRole)) {
      throw Exception('User does not have the $newRole role');
    }
    _currentUser = _currentUser!.copyWith(activeRole: newRole);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    try {
      await appApi.apiV1AuthLogoutPost();
    } catch (_) {}
    await tokenStorage.clearTokens();
    _currentUser = null;
  }

  @override
  Future<bool> hasSession() => tokenStorage.hasToken();

  @override
  Future<UserModel> updateProfile(PatchedUserProfileRequest request) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ApiException.unauthorized();

    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/me/');
    
    // Only send non-null and provided fields in PATCH payload to avoid overwriting with nulls
    final body = <String, dynamic>{};
    if (request.fullName != null && request.fullName!.trim().isNotEmpty) {
      body['full_name'] = request.fullName!.trim();
    }
    if (request.phoneNumber != null && request.phoneNumber!.trim().isNotEmpty) {
      String phone = request.phoneNumber!.trim().replaceAll(RegExp(r'[^\d]'), '');
      if (phone.startsWith('91') && phone.length == 12) {
        phone = phone.substring(2);
      } else if (phone.startsWith('0') && phone.length == 11) {
        phone = phone.substring(1);
      }
      body['phone_number'] = phone;
    }
    if (request.locationState != null && request.locationState!.trim().isNotEmpty) {
      body['location_state'] = request.locationState!.trim();
    }
    if (request.locationDistrict != null && request.locationDistrict!.trim().isNotEmpty) {
      body['location_district'] = request.locationDistrict!.trim();
    }
    if (request.farmingExperience != null) {
      body['farming_experience'] = request.farmingExperience;
    }
    if (request.areasOfInterest != null) {
      body['areas_of_interest'] = request.areasOfInterest;
    }

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 400) {
      String errorMessage = 'Failed to update profile (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map) {
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData.containsKey('non_field_errors')) {
            final nfe = errorData['non_field_errors'];
            errorMessage = nfe is List ? nfe.first.toString() : nfe.toString();
          } else if (errorData.isNotEmpty) {
            final firstKey = errorData.keys.first;
            final firstVal = errorData[firstKey];
            errorMessage = '$firstKey: ${firstVal is List ? firstVal.first : firstVal}';
          }
        }
      } catch (_) {}
      throw ApiException(statusCode: response.statusCode, message: errorMessage);
    }

    // Refresh profile from server to guarantee fully populated, synchronized state
    try {
      final meResponse = await appApi.apiV1AuthMeGet();
      final fullProfile = meResponse.body;
      if (fullProfile != null) {
        _currentUser = UserModel.fromApiProfile(fullProfile);
        return _currentUser!;
      }
    } catch (_) {}

    // Fallback: parse PATCH response body directly
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final profile = UserProfile.fromJson(data);
        _currentUser = UserModel.fromApiProfile(profile);
        return _currentUser!;
      }
    } catch (_) {}

    if (_currentUser != null) {
      return _currentUser!;
    }

    throw ApiException.server('Failed to fetch updated profile');
  }

  @override
  Future<UserModel> updateInstructorProfile(PatchedInstructorProfileRequest request) async {
    final response = await appApi.apiV1AuthInstructorProfilePatch(body: request);
    _handleError(response);
    
    // We need to fetch the full profile again because updateInstructorProfile 
    // only returns the InstructorProfile, not the full UserProfile.
    final meResponse = await appApi.apiV1AuthMeGet();
    _handleError(meResponse);
    final fullProfile = meResponse.body;
    if (fullProfile == null) throw ApiException.server('Failed to fetch full profile');
    
    _currentUser = UserModel.fromApiProfile(fullProfile);
    return _currentUser!;
  }

  @override
  Future<void> uploadAvatar(String imagePath) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ApiException.unauthorized();

    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/me/');
    final request = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('avatar', imagePath));

    final response = await request.send();
    if (response.statusCode >= 400) {
      throw ApiException.server('Failed to upload avatar: ${response.statusCode}');
    }

    // Refresh profile
    final meResponse = await appApi.apiV1AuthMeGet();
    _handleError(meResponse);
    final fullProfile = meResponse.body;
    if (fullProfile != null) {
      _currentUser = UserModel.fromApiProfile(fullProfile);
    }
  }

  @override
  Future<void> deleteAvatar() async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ApiException.unauthorized();

    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/me/');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'avatar': null}),
    );

    if (response.statusCode >= 400) {
      throw ApiException.server('Failed to delete avatar: ${response.statusCode}');
    }

    // Refresh profile
    final meResponse = await appApi.apiV1AuthMeGet();
    _handleError(meResponse);
    final fullProfile = meResponse.body;
    if (fullProfile != null) {
      _currentUser = UserModel.fromApiProfile(fullProfile);
    }
  }
}

