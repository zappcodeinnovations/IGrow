import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/user_role.dart';
import 'package:krushi_siksha/features/auth/providers/auth_provider.dart';
import 'package:krushi_siksha/data/models/user_model.dart';
import 'package:krushi_siksha/features/upload_course/screens/upload_ebook_screen.dart';

void main() {
  group('Upload Ebook Cover Image / Thumbnail UI Tests', () {
    testWidgets('UploadEbookScreen renders dedicated Cover Image / Thumbnail upload section',
        (tester) async {
      // Mock verified KYC instructor user so the form is rendered
      const mockVerifiedUser = UserModel(
        id: 'inst-1',
        email: 'instructor@agrilearn.com',
        fullName: 'Dr. Instructor',
        phone: '+919876543210',
        activeRole: UserRole.instructor,
        grantedRoles: [UserRole.instructor],
        kycVerified: true,
        verificationStatus: 'verified',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier(mockVerifiedUser)),
          ],
          child: const MaterialApp(
            home: UploadEbookScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify E-Book Information section exists
      expect(find.text('E-Book Information'), findsOneWidget);

      // Verify dedicated Cover Image / Thumbnail section exists
      expect(find.text('Cover Image / Thumbnail'), findsOneWidget);
      expect(
        find.text('Tap to upload Cover Image / Thumbnail'),
        findsOneWidget,
      );
      expect(
        find.text('JPEG, PNG, or WEBP (Max 5MB)'),
        findsOneWidget,
      );
      expect(
        find.text('Front cover or thumbnail (JPG, PNG, WebP)'),
        findsOneWidget,
      );

      // Verify Document File section still exists and is not affected
      expect(find.text('Document File'), findsOneWidget);
      expect(find.text('Tap to select PDF or DOCX file'), findsOneWidget);

      // Verify Submit Button exists
      expect(find.text('Upload & Submit E-Book'), findsOneWidget);
    });
  });
}

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier(UserModel user)
      : super(AuthState(status: AuthStatus.authenticated, user: user));

  @override
  Future<UserModel?> refreshUserSilent() async => state.user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
