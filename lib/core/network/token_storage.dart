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
