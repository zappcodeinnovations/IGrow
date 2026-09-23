import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/course_models.dart';
import 'package:krushi_siksha/features/cart/providers/cart_provider.dart';
import 'package:krushi_siksha/features/cart/screens/checkout_screen.dart';
import 'package:krushi_siksha/features/explore/providers/explore_provider.dart';

void main() {
  group('Checkout Coupon Validation & Error Wrapping Tests', () {
    const mockCourse = ApiCourseDetail(
      id: 'course-101',
      title: 'Organic Farming Fundamentals',
      price: '500.00',
    );

    Widget createTestCheckoutWidget() {
      return ProviderScope(
        overrides: [
          courseDetailProvider('course-101')
              .overrideWith((ref) => Future.value(mockCourse)),
          appliedCouponProvider.overrideWith((ref) => null),
        ],
        child: const MaterialApp(
          home: CheckoutScreen(directCourseId: 'course-101'),
        ),
      );
    }

    testWidgets(
        'Invalid coupon code shows full validation message and configures errorMaxLines: 3 for multi-line wrapping',
        (tester) async {
      await tester.pumpWidget(createTestCheckoutWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Locate coupon code input field and Apply button
      final couponFieldFinder = find.byType(TextField);
      expect(couponFieldFinder, findsOneWidget);

      final applyButtonFinder = find.widgetWithText(ElevatedButton, 'Apply');
      expect(applyButtonFinder, findsOneWidget);

      // Enter an invalid coupon code
      await tester.enterText(couponFieldFinder, 'BADPROMO');
      await tester.tap(applyButtonFinder);
      await tester.pump();

      // Verify the full validation error message is displayed
      const expectedError = 'Invalid coupon code. Try AGRI10 or KISAN50';
      expect(find.text(expectedError), findsOneWidget);

      // Verify that the TextField's InputDecoration has errorMaxLines set to 3 to support multi-line wrapping
      final textField = tester.widget<TextField>(couponFieldFinder);
      expect(textField.decoration?.errorMaxLines, 3);
      expect(textField.decoration?.errorText, expectedError);

      // Verify that typing in the field clears the error message
      await tester.enterText(couponFieldFinder, 'A');
      await tester.pump();
      expect(find.text(expectedError), findsNothing);
    });

    testWidgets('Empty coupon submission shows empty validation message',
        (tester) async {
      await tester.pumpWidget(createTestCheckoutWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final couponFieldFinder = find.byType(TextField);
      final applyButtonFinder = find.widgetWithText(ElevatedButton, 'Apply');

      // Tap apply without entering anything
      await tester.tap(applyButtonFinder);
      await tester.pump();

      expect(find.text('Please enter a coupon code'), findsOneWidget);

      final textField = tester.widget<TextField>(couponFieldFinder);
      expect(textField.decoration?.errorMaxLines, 3);
    });

    testWidgets('Applying AG10 or AGRI10 applies coupon successfully',
        (tester) async {
      await tester.pumpWidget(createTestCheckoutWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final couponFieldFinder = find.byType(TextField);
      final applyButtonFinder = find.widgetWithText(ElevatedButton, 'Apply');

      // Test AG10 (from website reference)
      await tester.enterText(couponFieldFinder, 'AG10');
      await tester.tap(applyButtonFinder);
      await tester.pump();

      expect(find.text('Coupon "AG10" Applied!'), findsOneWidget);
      expect(find.textContaining('Saved ₹50.00 (10%)'), findsOneWidget);
    });

    testWidgets('Applying KISAN50 applies 50% discount coupon',
        (tester) async {
      await tester.pumpWidget(createTestCheckoutWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final couponFieldFinder = find.byType(TextField);
      final applyButtonFinder = find.widgetWithText(ElevatedButton, 'Apply');

      await tester.enterText(couponFieldFinder, 'KISAN50');
      await tester.tap(applyButtonFinder);
      await tester.pump();

      expect(find.text('Coupon "KISAN50" Applied!'), findsOneWidget);
      expect(find.textContaining('Saved ₹250.00 (50%)'), findsOneWidget);
    });
  });
}
