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

  // ── Factory helpers ───────────────────────────────────────────

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
      // Use the first field error as the message.
      final first = fieldErrors.entries.first;
      generalMessage = '${first.key}: ${first.value.first}';
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
        message: msg ?? 'Network error. Check your internet connection.',
      );

  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 400;
  bool get isServer => statusCode >= 500;
  bool get isNetwork => statusCode == 0;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
