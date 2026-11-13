/// Global standard user-friendly message when internet connection is lost.
const String kNoInternetMessage = 'No internet connection. Please try again later.';

/// Structured API error with status code and optional field-level errors.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors,
  });

  /// HTTP status code (0 if network/timeout error).
  final int statusCode;

  /// Human-readable error message.
  final String message;

  /// Per-field validation errors from the backend (e.g. `{"email": ["This field is required."]}`).
  final Map<String, List<String>>? fieldErrors;

  /// 403 Forbidden / Role mismatch.
  factory ApiException.roleMismatch(String msg) => ApiException(
        statusCode: 403,
        message: msg,
      );

  /// 401 Unauthorized — token expired or invalid.
  factory ApiException.unauthorized([String? msg]) => ApiException(
        statusCode: 401,
        message: msg ?? 'Session expired. Please login again.',
      );

  /// 400 Bad Request — validation error from the backend.
  factory ApiException.validation(Map<String, dynamic> body) {
    final fieldErrors = <String, List<String>>{};
    String generalMessage = 'Validation error';

    body.forEach((key, value) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        if (key == 'detail' || key == 'non_field_errors') {
          generalMessage = value;
        } else {
          fieldErrors[key] = [value];
        }
      }
    });

    // If there's a 'detail' key, use it as the main message.
    if (body.containsKey('detail')) {
      generalMessage = body['detail'].toString();
    } else if (body.containsKey('non_field_errors')) {
      final nfe = body['non_field_errors'];
      generalMessage = nfe is List ? nfe.first.toString() : nfe.toString();
    } else if (fieldErrors.isNotEmpty) {
      // User-friendly mapping for common validation errors
      final first = fieldErrors.entries.first;
      final fieldName = first.key;
      final rawError = first.value.first;
      final lowerRaw = rawError.toLowerCase();

      if (fieldName == 'email' &&
          (lowerRaw.contains('already exists') ||
           lowerRaw.contains('unique') ||
           lowerRaw.contains('already registered') ||
           lowerRaw.contains('taken'))) {
        generalMessage = 'Email already used for an account.';
      } else if (fieldName == 'phone_number' &&
          (lowerRaw.contains('already exists') ||
           lowerRaw.contains('unique') ||
           lowerRaw.contains('taken'))) {
        generalMessage = 'Phone number already used for an account.';
      } else {
        generalMessage = '$fieldName: $rawError';
      }
    }

    return ApiException(
      statusCode: 400,
      message: generalMessage,
      fieldErrors: fieldErrors.isEmpty ? null : fieldErrors,
    );
  }

  /// 500+ Server Error.
  factory ApiException.server([String? msg]) => ApiException(
        statusCode: 500,
        message: msg ?? 'Server error. Please try again later.',
      );

  /// Network error (no internet, timeout, DNS failure, etc.).
  factory ApiException.network([String? msg]) => ApiException(
        statusCode: 0,
        message: msg ?? kNoInternetMessage,
      );

  /// Wrap any dynamic exception into a friendly ApiException.
  factory ApiException.from(dynamic error) {
    if (error is ApiException) return error;
    final s = error.toString().toLowerCase();
    if (s.contains('socket') ||
        s.contains('handshake') ||
        s.contains('network') ||
        s.contains('connection') ||
        s.contains('offline') ||
        s.contains('timeout') ||
        s.contains('host lookup') ||
        s.contains('clientexception') ||
        s.contains('failed host') ||
        s.contains('no address associated with hostname') ||
        s.contains('network is unreachable') ||
        s.contains('connection refused') ||
        s.contains('errno = 7')) {
      if (s.contains('timeout')) {
        return ApiException.network(
          'Connection timed out. Please check your internet connection and try again.',
        );
      }
      return ApiException.network();
    }
    if (s.contains('500') ||
        s.contains('502') ||
        s.contains('503') ||
        s.contains('internal server error') ||
        s.contains('bad gateway')) {
      return ApiException.server();
    }
    var clean = error
        .toString()
        .replaceFirst(RegExp(r'^(Exception|ApiException(\(\d+\))?|ClientException|SocketException|HttpException|FormatException):\s*', caseSensitive: false), '')
        .trim();
    clean = clean.replaceAll(RegExp(r',?\s*uri\s*=\s*https?://\S+', caseSensitive: false), '').trim();
    return ApiException(
      statusCode: 0,
      message: clean.isNotEmpty ? clean : 'Something went wrong. Please try again.',
    );
  }

  /// Get a clean, user-friendly message string directly from any error.
  static String userFriendlyMessage(dynamic error, {String fallback = 'Something went wrong. Please try again.'}) {
    if (error == null) return fallback;
    return ApiException.from(error).message;
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 400;
  bool get isServer => statusCode >= 500;
  bool get isNetwork => statusCode == 0;

  @override
  String toString() => message;
}
