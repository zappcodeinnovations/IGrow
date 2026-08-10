import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores and retrieves JWT tokens using flutter_secure_storage.
///
/// Tokens are persisted across app restarts. On logout, both tokens are cleared.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'jwt_access_token';
  static const _refreshKey = 'jwt_refresh_token';

  // ── Access Token ──────────────────────────────────────────────

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  Future<void> setAccessToken(String token) =>
      _storage.write(key: _accessKey, value: token);

  // ── Refresh Token ─────────────────────────────────────────────

  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> setRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  // ── Convenience ───────────────────────────────────────────────

  /// Store both tokens at once (after login/register).
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      setAccessToken(access),
      setRefreshToken(refresh),
    ]);
  }

  /// Clear all tokens (on logout).
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  /// Returns `true` if an access token is stored.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
