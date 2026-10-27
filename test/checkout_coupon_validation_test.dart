import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/course_models.dart';
import 'package:krushi_siksha/features/cart/providers/cart_provider.dart';
import 'package:krushi_siksha/features/cart/screens/checkout_screen.dart';
import 'package:krushi_siksha/features/explore/providers/explore_provider.dart';
import 'package:krushi_siksha/core/services/app_config_service.dart';

import 'package:krushi_siksha/data/repositories/cart_repository.dart';

class MockAppConfigNotifier extends AppConfigNotifier {
  MockAppConfigNotifier() {
    state = const AppConfig(
      enablePaymentGateway: true,
      enableCoupons: true,
      showPayments: true,
      showCoupons: true,
    );
  }
}

class FakeCartRepository extends Fake implements CartRepository {
  @override
  Future<Map<String, dynamic>> applyCoupon(String code, {String? courseId}) async {
    final upper = code.trim().toUpperCase();
    if (upper == 'AG10' || upper == 'AGRI10') {
      return {
        'code': 'AG10',
        'discount_amount': 50.0,
        'discount_percent': 10.0,
        'new_total': 450.0,
        'message': 'Coupon "AG10" Applied!',
      };
    }
    if (upper == 'KISAN50') {
      return {
        'code': 'KISAN50',
        'discount_amount': 250.0,
        'discount_percent': 50.0,
        'new_total': 250.0,
        'message': 'Coupon "KISAN50" Applied!',
      };
    }
    throw Exception('Invalid coupon code. Try AGRI10 or KISAN50');
  }
}

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
          appConfigProvider.overrideWith((ref) => MockAppConfigNotifier()),
          cartRepositoryProvider.overrideWithValue(FakeCartRepository()),
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

      expect(find.text('Coupon "AG10" Applied!'), findsWidgets);
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

      expect(find.text('Coupon "KISAN50" Applied!'), findsWidgets);
      expect(find.textContaining('Saved ₹250.00 (50%)'), findsOneWidget);
    });
  });
}
