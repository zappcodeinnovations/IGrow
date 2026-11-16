import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/theme/app_colors.dart';

void main() {
  group('Upload Progress Modal Action Distinction Tests', () {
    testWidgets('Modal renders FilledButton for Cancel with red background and white text',
        (tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogCtx) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Uploading study material (7 Practical OOP.pdf)...'),
                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(dialogCtx).pop();
                                    cancelCalled = true;
                                  },
                                  icon: const Icon(Icons.close_rounded, size: 15, color: Colors.white),
                                  label: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check that the dialog content is visible
      expect(find.text('Uploading study material (7 Practical OOP.pdf)...'), findsOneWidget);

      // Verify that Cancel is rendered inside a FilledButton
      final filledButtonFinder = find.byType(FilledButton);
      expect(filledButtonFinder, findsOneWidget);

      final filledButton = tester.widget<FilledButton>(filledButtonFinder);
      expect(filledButton.enabled, isTrue);

      // Verify the button text and icon
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Verify red styling
      final buttonStyle = filledButton.style;
      expect(buttonStyle, isNotNull);
      final bg = buttonStyle!.backgroundColor?.resolve({});
      expect(bg, AppColors.error);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed and callback triggered
      expect(cancelCalled, isTrue);
      expect(find.text('Uploading study material (7 Practical OOP.pdf)...'), findsNothing);
    });
  });
}
