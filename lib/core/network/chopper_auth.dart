import 'dart:async';
import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class TokenInterceptor implements Interceptor {
  TokenInterceptor(this.tokenStorage);
  final TokenStorage tokenStorage;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final request = chain.request.copyWith(headers: {
        ...chain.request.headers,
        'Authorization': 'Bearer $token',
      });
      return chain.proceed(request);
    }
    return chain.proceed(chain.request);
  }
}

class TokenAuthenticator extends Authenticator {
  TokenAuthenticator(this.tokenStorage);
  final TokenStorage tokenStorage;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  @override
  AuthenticationCallback? get onAuthenticationFailed => null;

  @override
  AuthenticationCallback? get onAuthenticationSuccessful => null;

  @override
  FutureOr<Request?> authenticate(Request request, Response response, [Request? originalRequest]) async {
    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final token = await tokenStorage.getAccessToken();
        if (token != null) {
          return request.copyWith(headers: {
            ...request.headers,
            'Authorization': 'Bearer $token',
          });
        }
      }
    }
    return null;
  }

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing && _refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/refresh/');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'] as String?;
        if (newAccess != null) {
          await tokenStorage.setAccessToken(newAccess);
          final newRefresh = data['refresh'] as String?;
          if (newRefresh != null && newRefresh.isNotEmpty) {
            await tokenStorage.setRefreshToken(newRefresh);
          }
          _refreshCompleter!.complete(true);
          return true;
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Only clear tokens if the refresh token is actually rejected (e.g., 401)
        await tokenStorage.clearTokens();
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      // Don't clear tokens on SocketException or TimeoutException
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
