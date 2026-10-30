import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'notification_service.dart';

/// Service managing client-side Google and Apple Sign-In credential flows.
class SocialAuthService {
  SocialAuthService._();
  static final SocialAuthService instance = SocialAuthService._();

  GoogleSignIn? _googleSignIn;

  /// Web Client ID from Google Cloud Console expected by the backend
  static const String googleServerClientId =
      '744016784564-uadkduueepk8ktffa7kg9124nnappatv.apps.googleusercontent.com';

  /// iOS Client ID from Google Cloud Console
  static const String googleIosClientId =
      '744016784564-sr68f36ofb4mekg78mqa0alco7kav30d.apps.googleusercontent.com';

  GoogleSignIn _getGoogleSignIn() {
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: googleServerClientId,
      clientId: Platform.isIOS ? googleIosClientId : null,
    );
    return _googleSignIn!;
  }

  /// Triggers simple native Google Sign-In and returns:
  /// - `id_token`: The JWT identity token from Google
  /// - `full_name`: User's display name
  /// - `fcm_token`: Current device FCM token (optional)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final googleSignIn = _getGoogleSignIn();

      // Sign out first to let the user pick any account on their phone
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      print('\n🚀 [SOCIAL_AUTH] Calling googleSignIn.signIn()...');
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        print('⚠️ [SOCIAL_AUTH] Google Sign-In cancelled by user.');
        return null;
      }

      print('✅ [SOCIAL_AUTH] Account selected: ${account.email}, Name: ${account.displayName}');
      
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      print('🔑 [SOCIAL_AUTH] Google idToken: ${idToken != null ? "${idToken.substring(0, 15)}... (Length: ${idToken.length})" : "NULL"}');

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google Sign-In succeeded for ${account.email} but no ID token was returned.',
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
    } catch (e, st) {
      print('❌ [SOCIAL_AUTH] Google Sign-In error: $e\n$st');
      rethrow;
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
