import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/theme/app_colors.dart';

void main() {
  group('Upload Progress Modal Action Distinction Tests', () {
    testWidgets('Modal renders OutlinedButton for Cancel / Finish Later with defined border and high contrast',
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
                        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
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
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(dialogCtx).pop();
                                    cancelCalled = true;
                                  },
                                  icon: const Icon(Icons.close_rounded, size: 15, color: AppColors.error),
                                  label: Text(
                                    'Cancel / Finish Later',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : AppColors.inkDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? Colors.white : AppColors.inkDark,
                                    backgroundColor: isDark
                                        ? AppColors.cardDark
                                        : const Color(0xFFF9FAFB),
                                    side: BorderSide(
                                      color: isDark ? AppColors.lineDark : const Color(0xFFD1D5DB),
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    visualDensity: VisualDensity.compact,
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

      // Verify that Cancel / Finish Later is rendered inside an OutlinedButton (not a muted plain TextButton)
      final outlinedButtonFinder = find.byType(OutlinedButton);
      expect(outlinedButtonFinder, findsOneWidget);

      final outlinedButton = tester.widget<OutlinedButton>(outlinedButtonFinder);
      expect(outlinedButton.enabled, isTrue);

      // Verify the button text and icon
      expect(find.text('Cancel / Finish Later'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Verify border and background styling
      final buttonStyle = outlinedButton.style;
      expect(buttonStyle, isNotNull);
      final side = buttonStyle!.side?.resolve({});
      expect(side, isNotNull);
      expect(side!.width, 1.2);
      expect(side.color, const Color(0xFFD1D5DB));

      // Tap Cancel / Finish Later
      await tester.tap(find.text('Cancel / Finish Later'));
      await tester.pumpAndSettle();

      // Dialog dismissed and callback triggered
      expect(cancelCalled, isTrue);
      expect(find.text('Uploading study material (7 Practical OOP.pdf)...'), findsNothing);
    });
  });
}
