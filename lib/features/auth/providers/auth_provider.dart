import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_client_legacy.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/auth_repository.dart';

// ─── Core Infrastructure Providers ─────────────────────────────────

/// Provides the token storage instance.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Provides the API client (depends on token storage).
final appApiProvider = Provider<AppApi>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return buildAppApi(tokenStorage);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

// ─── Repository Provider ───────────────────────────────────────────

/// Provides the [AuthRepository] implementation.
/// Now uses [ApiAuthRepository] to talk to the real backend.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final appApi = ref.watch(appApiProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiAuthRepository(
    appApi: appApi,
    tokenStorage: tokenStorage,
  );
});

// ─── Auth State ────────────────────────────────────────────────────

/// Possible states for the auth flow.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Holds authentication state: status, user, and error message.
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  /// Convenience getters.
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  UserRole? get activeRole => user?.activeRole;
}

// ─── Auth Notifier ─────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());

  final AuthRepository _repo;
  Timer? _profileSyncTimer;

  void _startPeriodicSync() {
    _profileSyncTimer?.cancel();
    // Periodically sync profile from backend (15s if pending KYC/verification, 2m if already verified) to avoid flooding console and network
    final isFullyVerified = state.user?.isKycVerified == true &&
        state.user?.verificationStatus?.toUpperCase() == 'VERIFIED';
    final interval = isFullyVerified ? const Duration(minutes: 2) : const Duration(seconds: 15);
    _profileSyncTimer = Timer.periodic(interval, (_) {
      refreshUserSilent();
    });
  }

  void _stopPeriodicSync() {
    _profileSyncTimer?.cancel();
    _profileSyncTimer = null;
  }

  @override
  void dispose() {
    _stopPeriodicSync();
    super.dispose();
  }

  /// Silently refresh the current user from backend without full-screen loading spinner.
  /// Guarantees that all profile fields (name, phone, state, district, experience, bio, etc.)
  /// are refreshed and state is updated. Returns the fresh UserModel if successful.
  Future<UserModel?> refreshUserSilent() async {
    if (!state.isAuthenticated) return null;
    try {
      final user = await _repo.getCurrentUser(forceRefresh: true);
      if (user != null) {
        state = state.copyWith(user: user);
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [AUTH PROVIDER] refreshUserSilent skipped: $e');
      return null;
    }
  }

  /// Check for an existing session on app start.
  /// Reads JWT from secure storage and fetches /auth/me/.
  Future<void> checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasSession = await _repo.hasSession();
      if (!hasSession) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      final user = await _repo.getCurrentUser(forceRefresh: true);
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        _startPeriodicSync();
        // Safely sync FCM token with backend in background without delaying session check
        unawaited(_repo.syncFcmToken());
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.login(
        email: email,
        password: password,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      _startPeriodicSync();
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.message);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  /// Register a new account.
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required UserRole role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repo.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirm: passwordConfirm,
        role: role,
      );
      // Registration successful. Keep status as unauthenticated so user can login manually.
      state = const AuthState(status: AuthStatus.unauthenticated);
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.message);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  /// Forgot password (Step 1): Send OTP to email.
  Future<bool> forgotPassword({required String email}) async {
    try {
      await _repo.forgotPassword(email: email);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Verify OTP (Step 2): Returns reset_token on success.
  Future<String?> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final token = await _repo.verifyResetOtp(email: email, otp: otp);
      return token;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Reset password (Step 3): Set new password using reset_token.
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _repo.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Resend OTP.
  Future<bool> resendOtp({required String email}) async {
    try {
      await _repo.resendOtp(email: email);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Switch active role.
  Future<void> switchRole(UserRole newRole) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.switchRole(newRole);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: e.toString());
    }
  }

  /// Logout.
  Future<void> logout() async {
    _stopPeriodicSync();
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Update Basic Profile.
  Future<void> updateProfile(PatchedUserProfileRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.updateProfile(request);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: e.toString());
      rethrow;
    }
  }

  /// Update Instructor Profile.
  Future<void> updateInstructorProfile(PatchedInstructorProfileRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.updateInstructorProfile(request);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: e.toString());
      rethrow;
    }
  }

  /// Submit KYC & Bank Profile for Instructor.
  Future<void> submitKycProfile({
    required String docType,
    required String docNumber,
    String? docImagePath,
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    print('🚀 [AUTH PROVIDER] submitKycProfile requested: docType=$docType, docNumber=$docNumber');
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.submitKycProfile(
        docType: docType,
        docNumber: docNumber,
        docImagePath: docImagePath,
        bankName: bankName,
        accountName: accountName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
      );
      print('✅ [AUTH PROVIDER] submitKycProfile successful. Updated user: ${user.fullName}, verified: ${user.kycVerified}');
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      print('❌ [AUTH PROVIDER] submitKycProfile failed: $e');
      state = state.copyWith(status: AuthStatus.authenticated, error: e.toString());
      rethrow;
    }
  }

  /// Upload Avatar.
  Future<void> uploadAvatar(String imagePath) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repo.uploadAvatar(imagePath);
      // Fetch full profile again to reflect the new avatar
      final user = await _repo.getCurrentUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: e.toString());
      rethrow;
    }
  }

  /// Delete Avatar.
  Future<void> deleteAvatar() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repo.deleteAvatar();
      // Fetch full profile again to reflect the removed avatar
      final user = await _repo.getCurrentUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: e.toString());
      rethrow;
    }
  }

  /// Set role during onboarding (before full registration).
  void setOnboardingRole(UserRole role) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(activeRole: role),
      );
    }
  }

  /// Clear any error message.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ─── Providers ─────────────────────────────────────────────────────

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

/// Convenience: current active role (nullable if unauthenticated).
final activeRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).activeRole;
});

/// Convenience: whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
