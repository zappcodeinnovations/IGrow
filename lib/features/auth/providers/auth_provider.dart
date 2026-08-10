import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_client_legacy.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
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
      final user = await _repo.getCurrentUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
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
