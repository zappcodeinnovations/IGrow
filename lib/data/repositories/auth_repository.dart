import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/token_storage.dart';
import '../../core/services/notification_service.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser({bool forceRefresh = false});
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> socialLogin({
    required String provider,
    required String idToken,
    String? fullName,
    String? fcmToken,
  });
  Future<void> syncFcmToken();
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
  Future<void> deleteAccount();
  Future<bool> hasSession();
  
  Future<UserModel> updateProfile(PatchedUserProfileRequest request);
  Future<UserModel> updateInstructorProfile(PatchedInstructorProfileRequest request);
  Future<UserModel> submitKycProfile({
    required String docType,
    required String docNumber,
    String? docImagePath,
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String ifscCode,
  });
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

  @visibleForTesting
  void testSetCurrentUser(UserModel user) => _currentUser = user;

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
  Future<UserModel?> getCurrentUser({bool forceRefresh = false}) async {
    if (!forceRefresh && _currentUser != null) return _currentUser;
    final hasToken = await tokenStorage.hasToken();
    if (!hasToken) {
      print('ℹ️ [AUTH REPO] getCurrentUser: No active token found in storage.');
      return null;
    }

    try {
      final response = await appApi.apiV1AuthMeGet();
      _handleError(response);
      final profile = response.body;
      if (profile == null) {
        print('⚠️ [AUTH REPO] getCurrentUser: Empty profile body returned from /auth/me/');
        return null;
      }
      _currentUser = UserModel.fromApiProfile(profile);
      print('👤 [AUTH REPO] getCurrentUser loaded: email=${_currentUser?.email}, role=${_currentUser?.activeRole.name}, verificationStatus=${_currentUser?.verificationStatus}, kycVerified=${_currentUser?.kycVerified}');
      return _currentUser;
    } on ApiException catch (e) {
      print('❌ [AUTH REPO] getCurrentUser ApiException: ${e.message} (status: ${e.statusCode})');
      if (e.isUnauthorized) {
        await tokenStorage.clearTokens();
        return null;
      }
      rethrow;
    } catch (e) {
      print('❌ [AUTH REPO] getCurrentUser unexpected error: $e');
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

    // Safely register existing FCM token in background without blocking login
    // NOTE: Do NOT use forceRefresh:true here — it deletes the token, triggers
    // onTokenRefresh, and causes a race condition with backend registration.
    unawaited(
      NotificationService.instance.registerFCMToken(
        data['access'] as String,
        forceRefresh: false,
      ),
    );

    final meResponse = await appApi.apiV1AuthMeGet();
    _handleError(meResponse);
    final profile = meResponse.body;
    if (profile == null) throw ApiException.server('Failed to fetch profile');
    
    _currentUser = UserModel.fromApiProfile(profile);
    return _currentUser!;
  }

  @override
  Future<UserModel> socialLogin({
    required String provider,
    required String idToken,
    String? fullName,
    String? fcmToken,
  }) async {
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/social-login/');
    final body = <String, dynamic>{
      'provider': provider,
      'id_token': idToken,
    };
    if (fullName != null && fullName.trim().isNotEmpty) {
      body['full_name'] = fullName.trim();
    }
    if (fcmToken != null && fcmToken.trim().isNotEmpty) {
      body['fcm_token'] = fcmToken.trim();
    }

    print('\n🌐 [AUTH_REPO] POST /api/v1/auth/social-login/ with provider: $provider');
    print('📦 [AUTH_REPO] Payload: id_token length=${idToken.length}, full_name=$fullName, fcm_token=${fcmToken != null}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('⬅️ [AUTH_REPO] Response status: ${response.statusCode}');
    print('📄 [AUTH_REPO] Response body: ${response.body}');

    if (response.statusCode >= 400) {
      String errorMessage = 'Social sign-in failed (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        if (response.statusCode == 400 && errorData is Map<String, dynamic>) {
          if (errorData.containsKey('errors') && errorData['errors'] is Map) {
            final errs = errorData['errors'] as Map;
            final firstKey = errs.keys.first;
            final firstVal = errs[firstKey];
            errorMessage = firstVal is List ? firstVal.first.toString() : firstVal.toString();
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            throw ApiException.validation(errorData);
          }
        } else if (response.statusCode == 401) {
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = 'Invalid or expired social token signature.';
          }
        } else if (errorData is Map && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        }
      } catch (e) {
        if (e is ApiException) rethrow;
      }
      throw ApiException(statusCode: response.statusCode, message: errorMessage);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>?;
    final access = tokens?['access'] as String?;
    final refresh = tokens?['refresh'] as String?;

    if (access == null || access.isEmpty) {
      throw ApiException.server('Invalid social login response: Missing access token');
    }

    await tokenStorage.saveTokens(
      access: access,
      refresh: refresh ?? '',
    );

    // Safely register FCM token in background
    unawaited(
      NotificationService.instance.registerFCMToken(
        access,
        forceRefresh: false,
      ),
    );

    // Fetch the canonical current user profile
    final meResponse = await appApi.apiV1AuthMeGet();
    _handleError(meResponse);
    final profile = meResponse.body;
    if (profile == null) throw ApiException.server('Failed to fetch profile after social login');

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
    final updatedGranted = List<UserRole>.from(_currentUser!.grantedRoles);
    if (!updatedGranted.contains(newRole)) {
      updatedGranted.add(newRole);
    }
    _currentUser = _currentUser!.copyWith(
      activeRole: newRole,
      grantedRoles: updatedGranted,
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    try {
      final fcmToken = await NotificationService.instance
          .getFcmToken(maxRetries: 1)
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
      final refreshToken = await tokenStorage.getRefreshToken();
      final accessToken = await tokenStorage.getAccessToken();

      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/logout/');
      await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              if (refreshToken != null) 'refresh': refreshToken,
              if (fcmToken != null) 'fcm_token': fcmToken,
            }),
          )
          .timeout(const Duration(seconds: 5), onTimeout: () => http.Response('{}', 408));
    } catch (_) {
      try {
        await appApi.apiV1AuthLogoutPost();
      } catch (_) {}
    }

    // Unregister / delete FCM token so this device receives no further notifications for this user
    try {
      await NotificationService.instance
          .deleteFcmToken()
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
    } catch (_) {}

    await tokenStorage.clearTokens();
    _currentUser = null;
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/delete-account/');
      await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 6), onTimeout: () => http.Response('{}', 408));
    } catch (_) {}

    await logout();
  }

  @override
  Future<bool> hasSession() => tokenStorage.hasToken();

  @override
  Future<void> syncFcmToken() async {
    try {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // forceRefresh:false — use existing token; avoid deleteToken() which triggers
        // onTokenRefresh and causes race conditions with backend registration.
        await NotificationService.instance.registerFCMToken(
          token,
          forceRefresh: false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [AUTH REPO] Failed to sync FCM token: $e');
      }
    }
  }

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
      body['farming_experience'] = request.farmingExperience.toString().trim();
    }
    if (request.areasOfInterest != null) {
      body['areas_of_interest'] = request.areasOfInterest;
    }

    final http.Response response;
    try {
      response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }

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
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ApiException.unauthorized();

    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/instructor-profile/');
    final body = <String, dynamic>{};

    final json = request.toJson();
    json.forEach((key, value) {
      if (value != null) {
        body[key] = value;
      }
    });

    final http.Response response;
    try {
      response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }

    if (response.statusCode >= 400) {
      Map<String, dynamic>? errorData;
      try {
        errorData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
      if (errorData != null) {
        throw ApiException.validation(errorData);
      }
      throw ApiException.server('Failed to update instructor profile (${response.statusCode})');
    }

    // Refresh profile
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

  @override
  Future<UserModel> submitKycProfile({
    required String docType,
    required String docNumber,
    String? docImagePath,
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) {
      print('❌ [KYC REPO] submitKycProfile: Unauthorized - No JWT token found');
      throw ApiException.unauthorized();
    }

    print('═══════════════════════════════════════════════════════════');
    print('🚀 [KYC REPO] Submitting KYC profile to PATCH /api/v1/auth/instructor-profile/');
    print('📋 Details: docType=$docType, docNumber=$docNumber, bank=$bankName, accountName=$accountName, accountNum=$accountNumber, ifsc=$ifscCode');
    print('📷 Photo attached: ${docImagePath != null && docImagePath.isNotEmpty ? docImagePath : "None"}');

    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/instructor-profile/');
    final request = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['kyc_document_type'] = docType
      ..fields['kyc_document_number'] = docNumber
      ..fields['bank_name'] = bankName
      ..fields['bank_account_name'] = accountName
      ..fields['bank_account_number'] = accountNumber
      ..fields['bank_ifsc_code'] = ifscCode;

    if (docImagePath != null && docImagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('kyc_document_image', docImagePath));
    }

    final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send();
    } on SocketException {
      print('❌ [KYC REPO] Network connection failed during KYC upload');
      throw ApiException.network();
    } on http.ClientException catch (e) {
      print('❌ [KYC REPO] Client exception during KYC upload: $e');
      throw ApiException.network();
    }

    final response = await http.Response.fromStream(streamedResponse);
    print('📥 [KYC REPO] KYC Response Status: ${response.statusCode}');
    print('📦 [KYC REPO] Response Body: ${response.body}');

    if (response.statusCode >= 400) {
      Map<String, dynamic>? errorData;
      try {
        errorData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
      print('❌ [KYC REPO] KYC Submission rejected: $errorData');
      if (errorData != null) {
        throw ApiException.validation(errorData);
      }
      throw ApiException.server('Failed to submit KYC details (${response.statusCode})');
    }

    // Refresh profile
    final meResponse = await appApi.apiV1AuthMeGet();
    _handleError(meResponse);
    final fullProfile = meResponse.body;
    if (fullProfile == null) throw ApiException.server('Failed to fetch full profile');

    _currentUser = UserModel.fromApiProfile(fullProfile);
    print('✅ [KYC REPO] KYC Submission SUCCESS! Updated state -> verificationStatus: ${_currentUser?.verificationStatus}, kycVerified: ${_currentUser?.kycVerified}');
    print('═══════════════════════════════════════════════════════════');
    return _currentUser!;
  }
}

