import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:krushi_siksha/core/network/api_exception.dart';
import 'package:krushi_siksha/core/widgets/app_error_state.dart';

void main() {
  group('User-Friendly Error Sanitizer Tests', () {
    test('SocketException with DNS lookup failure maps to user-friendly offline message', () {
      final rawError = 'ClientException with SocketException: Failed host lookup: \'iagrow.zappcode.in\' (OS Error: No address associated with hostname, errno = 7), uri=https://iagrow.zappcode.in/api/v1/auth/register/';
      
      expect(isOfflineOrNetworkError(rawError), isTrue);
      final friendly = getUserFriendlyErrorMessage(rawError);
      expect(friendly, equals(kNoInternetMessage));
      expect(friendly.contains('SocketException'), isFalse);
      expect(friendly.contains('errno = 7'), isFalse);
      expect(friendly.contains('iagrow.zappcode.in'), isFalse);
    });

    test('ApiException.from with network error maps cleanly', () {
      final clientEx = http.ClientException(
        "SocketException: Failed host lookup: 'iagrow.zappcode.in' (OS Error: No address associated with hostname, errno = 7)",
        Uri.parse('https://iagrow.zappcode.in/api/v1/auth/register/'),
      );

      final apiEx = ApiException.from(clientEx);
      expect(apiEx.isNetwork, isTrue);
      expect(apiEx.message, equals(kNoInternetMessage));
    });

    test('Timeout error maps to connection timed out message', () {
      final timeoutStr = 'TimeoutException after 0:00:15.000000: Future not completed';
      expect(isOfflineOrNetworkError(timeoutStr), isTrue);
      final friendly = getUserFriendlyErrorMessage(timeoutStr);
      expect(friendly, contains('timed out'));
    });

    test('Internal Server Error 500 maps to polite temporary server issue', () {
      final serverError = 'Server error (500): Internal Server Error at /api/v1/auth/register/';
      final friendly = getUserFriendlyErrorMessage(serverError);
      expect(friendly, equals('Our server is temporarily unavailable. Please try again shortly.'));
    });

    test('Normal validation error passes cleanly without Exception prefix', () {
      final validationError = 'Exception: Email already used for an account.';
      final friendly = getUserFriendlyErrorMessage(validationError);
      expect(friendly, equals('Email already used for an account.'));
    });

    test('Raw JSON detail string extracts user-facing message', () {
      final jsonError = '{"detail": "Invalid credentials provided."}';
      final friendly = getUserFriendlyErrorMessage(jsonError);
      expect(friendly, equals('Invalid credentials provided.'));
    });
  });
}

