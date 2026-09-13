import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({required this.tokenStorage, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final TokenStorage tokenStorage;
  final http.Client _http;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    print('🌐 [HTTP GET] $uri');
    final headers = await _headers(authenticated: authenticated);
    return _sendWithRetry(
      () => _http.get(uri, headers: headers),
      authenticated,
      method: 'GET',
      url: uri.toString(),
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path);
    print('🌐 [HTTP POST] $uri');
    if (body != null) print('📦 [PAYLOAD] ${jsonEncode(body)}');
    final headers = await _headers(authenticated: authenticated);
    return _sendWithRetry(
      () => _http.post(uri, headers: headers, body: jsonEncode(body ?? {})),
      authenticated,
      method: 'POST',
      url: uri.toString(),
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path);
    print('🌐 [HTTP PATCH] $uri');
    if (body != null) print('📦 [PAYLOAD] ${jsonEncode(body)}');
    final headers = await _headers(authenticated: authenticated);
    return _sendWithRetry(
      () => _http.patch(uri, headers: headers, body: jsonEncode(body ?? {})),
      authenticated,
      method: 'PATCH',
      url: uri.toString(),
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path);
    print('🌐 [HTTP PUT] $uri');
    if (body != null) print('📦 [PAYLOAD] ${jsonEncode(body)}');
    final headers = await _headers(authenticated: authenticated);
    return _sendWithRetry(
      () => _http.put(uri, headers: headers, body: jsonEncode(body ?? {})),
      authenticated,
      method: 'PUT',
      url: uri.toString(),
    );
  }

  Future<dynamic> delete(
    String path, {
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path);
    print('🌐 [HTTP DELETE] $uri');
    final headers = await _headers(authenticated: authenticated);
    return _sendWithRetry(
      () => _http.delete(uri, headers: headers),
      authenticated,
      method: 'DELETE',
      url: uri.toString(),
    );
  }

  Future<dynamic> multipart(
    String path, {
    required Map<String, String> fields,
    Map<String, String>? files,
    String method = 'POST',
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path);
    print('🌐 [HTTP MULTIPART $method] $uri');
    print('📋 [FIELDS] $fields');
    if (files != null) print('📎 [FILES] $files');

    final request = http.MultipartRequest(method, uri);

    if (authenticated) {
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.fields.addAll(fields);

    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }
    }

    try {
      final streamed = await request.send().timeout(
            const Duration(seconds: 15),
          );
      final response = await http.Response.fromStream(streamed);
      print('📥 [HTTP MULTIPART RESPONSE] Status: ${response.statusCode} for $uri');
      if (response.body.isNotEmpty) {
        final preview = response.body.length > 500 ? '${response.body.substring(0, 500)}... [truncated]' : response.body;
        print('📦 [BODY] $preview');
      }
      return _processResponse(response, method: method, url: uri.toString());
    } on SocketException {
      print('❌ [HTTP MULTIPART NETWORK ERROR] No internet connection for $uri');
      throw ApiException.network();
    } on TimeoutException {
      print('❌ [HTTP MULTIPART TIMEOUT] Request timed out for $uri');
      throw ApiException.network('Request timed out');
    }
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final fullUrl = 'https://iagrow.zappcode.in$path';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<Map<String, String>> _headers({bool authenticated = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> _sendWithRetry(
    Future<http.Response> Function() request,
    bool authenticated, {
    String? method,
    String? url,
  }) async {
    try {
      final response = await request().timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 401 && authenticated) {
        print('🔄 [AUTH] Received 401. Attempting token refresh...');
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          print('✅ [AUTH] Token refreshed successfully. Retrying request $method $url');
          final retryResponse = await request().timeout(
            const Duration(seconds: 15),
          );
          return _processResponse(retryResponse, method: method, url: url);
        } else {
          print('❌ [AUTH] Token refresh failed. Logging out...');
          throw ApiException.unauthorized();
        }
      }

      return _processResponse(response, method: method, url: url);
    } on ApiException {
      rethrow;
    } on SocketException {
      print('❌ [HTTP NETWORK ERROR] Failed to connect: $method $url');
      throw ApiException.network();
    } on TimeoutException {
      print('❌ [HTTP TIMEOUT] Request timed out: $method $url');
      throw ApiException.network('Request timed out');
    } catch (e) {
      print('❌ [HTTP UNEXPECTED ERROR] $e for $method $url');
      throw ApiException.network(e.toString());
    }
  }

  dynamic _processResponse(http.Response response, {String? method, String? url}) {
    final statusCode = response.statusCode;

    print('📥 [HTTP RESPONSE] ${method ?? ""} ${url ?? ""} -> Status: $statusCode');
    if (response.body.isNotEmpty) {
      final preview = response.body.length > 500 ? '${response.body.substring(0, 500)}... [truncated]' : response.body;
      print('📦 [BODY] $preview');
    }

    if (statusCode == 204) return null;

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    print('⚠️ [HTTP ERROR STATUS] $statusCode for ${method ?? ""} ${url ?? ""}');

    if (statusCode == 401) {
      throw ApiException.unauthorized(
        body is Map && body.containsKey('detail')
            ? body['detail'].toString()
            : null,
      );
    }

    if (statusCode == 400 && body is Map<String, dynamic>) {
      throw ApiException.validation(body);
    }

    if (statusCode >= 500) {
      throw ApiException.server();
    }

    throw ApiException(
      statusCode: statusCode,
      message: body is Map && body.containsKey('detail')
          ? body['detail'].toString()
          : 'Request failed with status $statusCode',
    );
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

      final uri = _buildUri('/api/v1/auth/refresh/');
      final response = await _http.post(
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
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      await tokenStorage.clearTokens();
      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      await tokenStorage.clearTokens();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  void dispose() => _http.close();
}
