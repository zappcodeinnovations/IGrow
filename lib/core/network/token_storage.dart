import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores and retrieves JWT tokens using flutter_secure_storage.
///
/// Tokens are persisted across app restarts. On logout, both tokens are cleared.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );

  static const _accessKey = 'jwt_access_token';
  static const _refreshKey = 'jwt_refresh_token';

  // ── Session Expiry Notification ─────────────────────────────

  static final StreamController<String?> _sessionExpiredController =
      StreamController<String?>.broadcast();

  /// Broadcast stream emitting when user session is invalidated (e.g. 401 token expired or account deleted).
  static Stream<String?> get onSessionExpired => _sessionExpiredController.stream;

  static DateTime? _lastNotificationTime;

  /// Notify listeners that the user's session has expired and force a logout redirect.
  static void notifySessionExpired([String? reason]) {
    final now = DateTime.now();
    if (_lastNotificationTime != null &&
        now.difference(_lastNotificationTime!) < const Duration(seconds: 2)) {
      return;
    }
    _lastNotificationTime = now;
    debugPrint('🚨 [TokenStorage] notifySessionExpired triggered: $reason');

    unawaited(TokenStorage().clearTokens());

    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(
        reason ?? 'Your session has expired. Please log in again.',
      );
    }
  }

  /// Inspects HTTP status code and body to detect expired or invalid tokens.
  static void checkResponse(int statusCode, [String? body, String? path]) {
    if (path != null) {
      final p = path.toLowerCase();
      if (p.contains('/auth/login') ||
          p.contains('/auth/register') ||
          p.contains('/auth/refresh') ||
          p.contains('/auth/forgot-password') ||
          p.contains('/auth/verify-reset-otp') ||
          p.contains('/auth/reset-password')) {
        return;
      }
    }

    if (statusCode == 401) {
      notifySessionExpired();
      return;
    }

    if (body != null) {
      final b = body.toLowerCase();
      if (b.contains('token_not_valid') ||
          b.contains('token is invalid or expired') ||
          b.contains('given token not valid')) {
        notifySessionExpired();
      }
    }
  }

  // ── Access Token ──────────────────────────────────────────────

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessKey, aOptions: _androidOptions);
    } catch (e) {
      await clearTokens();
      return null;
    }
  }

  Future<void> setAccessToken(String token) async {
    try {
      await _storage.write(key: _accessKey, value: token, aOptions: _androidOptions);
    } catch (e) {
      await clearTokens();
      try {
        await _storage.write(key: _accessKey, value: token, aOptions: _androidOptions);
      } catch (_) {}
    }
  }

  // ── Refresh Token ─────────────────────────────────────────────

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshKey, aOptions: _androidOptions);
    } catch (e) {
      await clearTokens();
      return null;
    }
  }

  Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshKey, value: token, aOptions: _androidOptions);
    } catch (e) {
      await clearTokens();
      try {
        await _storage.write(key: _refreshKey, value: token, aOptions: _androidOptions);
      } catch (_) {}
    }
  }

  // ── Convenience ───────────────────────────────────────────────

  /// Store both tokens at once (after login/register).
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await setAccessToken(access);
    await setRefreshToken(refresh);
  }

  /// Clear all tokens (on logout).
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessKey, aOptions: _androidOptions),
        _storage.delete(key: _refreshKey, aOptions: _androidOptions),
      ]);
    } catch (_) {
      try {
        await _storage.deleteAll(aOptions: _androidOptions);
      } catch (_) {}
    }
  }

  /// Returns `true` if an access token is stored.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
