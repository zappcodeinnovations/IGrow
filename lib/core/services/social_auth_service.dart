import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'notification_service.dart';

/// Service managing client-side Google and Apple Sign-In credential flows.
class SocialAuthService {
  SocialAuthService._();
  static final SocialAuthService instance = SocialAuthService._();

  bool _initialized = false;

  /// Web Client ID from Google Cloud Console (required on Android to obtain an idToken)
  static const String googleServerClientId =
      '744016784564-uadkduueepk8ktffa7kg9124nnappatv.apps.googleusercontent.com';

  /// iOS Client ID (if needed explicitly for iOS sign-in without reverse client id)
  static const String googleIosClientId =
      '744016784564-17296ad47ab763a51a7be1.apps.googleusercontent.com';

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: googleServerClientId,
        clientId: Platform.isIOS ? googleIosClientId : null,
      );
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [SocialAuthService] GoogleSignIn initialize error: $e');
      }
      _initialized = true;
    }
  }

  /// Triggers native Google Sign-In and returns a map with:
  /// - `id_token`: The JWT identity token from Google
  /// - `full_name`: User's display name
  /// - `fcm_token`: Current device FCM token (optional)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // Sign out first to allow account switching if desired
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      print('\n🚀 [SOCIAL_AUTH] Calling GoogleSignIn.instance.authenticate()...');
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
      print('✅ [SOCIAL_AUTH] Google Auth SUCCESS: ${account.email}, id: ${account.id}');
      
      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;
      print('🔑 [SOCIAL_AUTH] Google idToken: ${idToken != null ? "${idToken.substring(0, 15)}... (Length: ${idToken.length})" : "NULL"}');

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google Sign-In succeeded but no ID token was returned. '
          'Please ensure the Google Cloud Web Client ID and SHA-1 fingerprints are registered.',
        );
      }

      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getFcmToken(maxRetries: 1);
      } catch (_) {}

      return {
        'provider': 'google',
        'id_token': idToken,
        'full_name': account.displayName,
        'fcm_token': fcmToken,
      };
    } on GoogleSignInException catch (e) {
      print('⚠️ [SOCIAL_AUTH] GoogleSignInException: code=${e.code}, description="${e.description}"');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User voluntarily cancelled the prompt
        return null;
      }
      rethrow;
    } catch (e, st) {
      print('❌ [SOCIAL_AUTH] Google Sign-In generic error: $e\n$st');
      rethrow;
    }
    }
  }

  /// Triggers Apple Sign-In on iOS (or returns null if unsupported) and returns:
  /// - `id_token`: The JWT identity token from Apple
  /// - `full_name`: Combined givenName and familyName (Apple sends this only on first sign-in)
  /// - `fcm_token`: Current device FCM token (optional)
  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw Exception('Apple Sign-In is only natively supported on iOS devices.');
      }

      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Sign in with Apple is not available on this device.');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('Apple Sign-In succeeded but no identity token was received.');
      }

      // Combine given and family names if present (Apple only sends them on first login)
      String? fullName;
      final givenName = credential.givenName?.trim();
      final familyName = credential.familyName?.trim();
      if ((givenName != null && givenName.isNotEmpty) ||
          (familyName != null && familyName.isNotEmpty)) {
        fullName = [givenName, familyName].where((s) => s != null && s.isNotEmpty).join(' ');
      }

      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getFcmToken(maxRetries: 1);
      } catch (_) {}

      return {
        'provider': 'apple',
        'id_token': identityToken,
        'full_name': fullName,
        'fcm_token': fcmToken,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SocialAuthService] Apple Sign-In error: $e');
      }
      rethrow;
    }
  }
}
