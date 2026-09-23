import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:krushi_siksha/core/widgets/app_text_field.dart';
import 'package:krushi_siksha/features/instructor_dashboard/screens/instructor_kyc_screen.dart';

void main() {
  group('IFSC Lookup & Auto-fetch Unit Tests', () {
    test('resolveIfscBankPrefix resolves kkbk0001849 to Kotak Mahindra Bank regardless of case', () {
      expect(resolveIfscBankPrefix('kkbk0001849'), 'Kotak Mahindra Bank');
      expect(resolveIfscBankPrefix('KKBK0001849'), 'Kotak Mahindra Bank');
      expect(resolveIfscBankPrefix('kkbk'), 'Kotak Mahindra Bank');
    });

    test('resolveIfscBankPrefix resolves common Indian commercial & public banks', () {
      expect(resolveIfscBankPrefix('SBIN0001234'), 'State Bank of India');
      expect(resolveIfscBankPrefix('HDFC0000001'), 'HDFC Bank');
      expect(resolveIfscBankPrefix('ICIC0000002'), 'ICICI Bank');
      expect(resolveIfscBankPrefix('UTIB0000003'), 'Axis Bank');
      expect(resolveIfscBankPrefix('AXIS0000003'), 'Axis Bank');
      expect(resolveIfscBankPrefix('BARB0000004'), 'Bank of Baroda');
      expect(resolveIfscBankPrefix('PUNB0000005'), 'Punjab National Bank');
      expect(resolveIfscBankPrefix('CNRB0000006'), 'Canara Bank');
      expect(resolveIfscBankPrefix('UBIN0000007'), 'Union Bank of India');
      expect(resolveIfscBankPrefix('YESB0000008'), 'Yes Bank');
    });

    test('resolveIfscBankPrefix handles short, empty or unknown codes gracefully', () {
      expect(resolveIfscBankPrefix(''), isNull);
      expect(resolveIfscBankPrefix('KKB'), isNull);
      expect(resolveIfscBankPrefix('ZZZZ0000000'), isNull);
    });
  });

  group('Instructor KYC Screen IFSC Auto-fill Widget Tests', () {
    testWidgets('Entering kkbk0001849 auto-populates Bank Name with Kotak Mahindra Bank', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Mock client responding 404 to kkbk0001849 (synthetic/dummy branch code)
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('KKBK0001849')) {
          return http.Response('Not Found', 404);
        }
        return http.Response(
          jsonEncode({
            'BANK': 'Kotak Mahindra Bank',
            'BRANCH': 'CENTRAL',
            'CITY': 'MUMBAI',
          }),
          200,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InstructorKycScreen(httpClient: mockClient),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find IFSC and Bank Name fields
      final ifscFinder = find.byWidgetPredicate(
        (w) => w is AppTextField && w.label == 'IFSC Code *',
      );
      final bankNameFinder = find.byWidgetPredicate(
        (w) => w is AppTextField && w.label == 'Bank Name *',
      );

      expect(ifscFinder, findsOneWidget);
      expect(bankNameFinder, findsOneWidget);

      final ifscTextField = tester.widget<AppTextField>(ifscFinder);
      final bankNameTextField = tester.widget<AppTextField>(bankNameFinder);

      // Initially Bank Name is empty
      expect(bankNameTextField.controller?.text, '');

      // Tester enters kkbk0001849
      await tester.enterText(ifscFinder, 'kkbk0001849');
      await tester.pumpAndSettle();

      // Bank Name should immediately be auto-filled with Kotak Mahindra Bank
      expect(bankNameTextField.controller?.text, 'Kotak Mahindra Bank');

      // IFSC text field should be formatted to uppercase
      expect(ifscTextField.controller?.text, 'KKBK0001849');
    });

    testWidgets('Live branch resolution auto-populates branch helper text when API returns 200', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'BANK': 'State Bank of India',
            'BRANCH': 'KOTHRUD',
            'CITY': 'PUNE',
          }),
          200,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InstructorKycScreen(httpClient: mockClient),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ifscFinder = find.byWidgetPredicate(
        (w) => w is AppTextField && w.label == 'IFSC Code *',
      );
      final bankNameFinder = find.byWidgetPredicate(
        (w) => w is AppTextField && w.label == 'Bank Name *',
      );

      final bankNameTextField = tester.widget<AppTextField>(bankNameFinder);

      await tester.enterText(ifscFinder, 'SBIN0001234');
      await tester.pumpAndSettle();

      // Bank name populated
      expect(bankNameTextField.controller?.text, 'State Bank of India');

      // Helper text shows branch info
      final ifscWidgetAfter = tester.widget<AppTextField>(ifscFinder);
      expect(ifscWidgetAfter.helperText, 'Branch: KOTHRUD, PUNE');
    });

    testWidgets('Manual Bank Name editing is preserved and not overwritten by IFSC code change', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InstructorKycScreen(httpClient: mockClient),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ifscFinder = find.byWidgetPredicate(
        (w) => w is AppTextField && w.label == 'IFSC Code *',
      );
      final bankNameFinder = find.byWidgetPredicate(
        (w) => w is AppTextField && w.label == 'Bank Name *',
      );

      final bankNameTextField = tester.widget<AppTextField>(bankNameFinder);

      // User manually enters a custom bank name
      await tester.enterText(bankNameFinder, 'My Custom Cooperative Bank');
      await tester.pumpAndSettle();
      expect(bankNameTextField.controller?.text, 'My Custom Cooperative Bank');

      // Now user enters IFSC
      await tester.enterText(ifscFinder, 'HDFC0000001');
      await tester.pumpAndSettle();

      // Bank Name remains user's manually typed name
      expect(bankNameTextField.controller?.text, 'My Custom Cooperative Bank');
    });
  });
}
