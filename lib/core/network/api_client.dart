import 'dart:async';
import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'chopper_auth.dart';
import 'token_storage.dart';
import 'swagger_generated/app_api.swagger.dart';

export 'swagger_generated/app_api.swagger.dart';

class TimeoutClient extends http.BaseClient {
  TimeoutClient({required this.timeout, http.Client? inner})
      : _inner = inner ?? http.Client();

  final Duration timeout;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(timeout);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class DebugLoggingInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final request = chain.request;
    print('╔════════════════════════════════════════════════════════════════');
    print('║ 🚀 REQUEST: ${request.method} ${request.url}');
    if (request.body != null) {
      print('║ 📦 BODY: ${request.body}');
    }
    
    try {
      final response = await chain.proceed(request);
      print('║ ⬅️ RESPONSE: ${response.statusCode} ${request.url}');
      if (response.bodyString.isNotEmpty) {
        print('║ 📄 DATA: ${response.bodyString}');
      } else if (response.body != null) {
        print('║ 📄 DATA: ${response.body}');
      }
      print('╚════════════════════════════════════════════════════════════════');
      return response;
    } catch (e) {
      print('║ ❌ ERROR: $e');
      print('╚════════════════════════════════════════════════════════════════');
      rethrow;
    }
  }
}

class SafeJsonConverter implements Converter {
  final Converter _inner;

  SafeJsonConverter(this._inner);

  @override
  FutureOr<Request> convertRequest(Request request) {
    return _inner.convertRequest(request);
  }

  @override
  FutureOr<Response<ResultType>> convertResponse<ResultType, Item>(Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.bodyString.isNotEmpty) {
        try {
          final decoded = json.decode(response.bodyString);
          final fixed = _recursivelyFixTypes(decoded);
          final newBodyString = json.encode(fixed);
          final newBase = http.Response(
            newBodyString,
            response.statusCode,
            headers: (response.base as http.Response).headers,
            isRedirect: (response.base as http.Response).isRedirect,
            persistentConnection: (response.base as http.Response).persistentConnection,
            reasonPhrase: (response.base as http.Response).reasonPhrase,
            request: response.base.request,
          );
          final modifiedResponse = response.copyWith(base: newBase, body: newBodyString);
          return await _inner.convertResponse<ResultType, Item>(modifiedResponse);
        } catch (e, stack) {
          print('║ ⚠️ SafeJsonConverter failed: $e');
          print('║ $stack');
        }
      }
    }
    return _inner.convertResponse<ResultType, Item>(response);
  }

  dynamic _recursivelyFixTypes(dynamic data) {
    if (data is Map) {
      final newMap = <String, dynamic>{};
      data.forEach((key, value) {
        if (value is num) {
          if ([
            'id', 'price', 'rating', 'course', 'instructor', 
            'total_duration', 'enrollment_count', 'total_lectures',
            'item_count', 'lecture_count', 'total'
          ].contains(key)) {
            newMap[key.toString()] = value.toString();
            print('║ 🔧 Fixed key: $key ($value -> ${value.toString()})');
          } else {
            newMap[key.toString()] = value;
          }
        } else if (value is bool) {
          if (['is_enrolled'].contains(key)) {
            newMap[key.toString()] = value.toString();
            print('║ 🔧 Fixed key: $key ($value -> ${value.toString()})');
          } else {
            newMap[key.toString()] = value;
          }
        } else {
          newMap[key.toString()] = _recursivelyFixTypes(value);
        }
      });
      return newMap;
    } else if (data is List) {
      return data.map((e) => _recursivelyFixTypes(e)).toList();
    }
    return data;
  }
}

/// Creates the Swagger-generated AppApi Chopper Client.
AppApi buildAppApi(TokenStorage tokenStorage) {
  return AppApi.create(
    baseUrl: Uri.parse('https://iagrow.zappcode.in'),
    httpClient: TimeoutClient(
      timeout: const Duration(seconds: 15),
    ),
    converter: SafeJsonConverter($JsonSerializableConverter()),
    interceptors: [
      TokenInterceptor(tokenStorage),
      DebugLoggingInterceptor(),
      HttpLoggingInterceptor(),
    ],
    authenticator: TokenAuthenticator(tokenStorage),
  );
}
