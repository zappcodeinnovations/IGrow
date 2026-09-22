import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/widgets/logout_dialog.dart';

void main() {
  group('Logout Confirmation Flow Tests', () {
    testWidgets('Renders Logout confirmation dialog properly with Cancel and Log Out buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () => showLogoutConfirmationDialog(context, ref),
                    child: const Text('Open Logout Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Logout Dialog'));
      await tester.pumpAndSettle();

      // Verify Dialog contents
      expect(find.text('Confirm Logout'), findsOneWidget);
      expect(
        find.text('Are you sure you want to log out? You will need to sign in again to access your courses and account data.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog dismissed
      expect(find.text('Confirm Logout'), findsNothing);
    });
  });
}
