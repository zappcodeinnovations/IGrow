import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/features/home_instructor/providers/instructor_home_provider.dart';
import 'package:krushi_siksha/features/instructor_dashboard/screens/instructor_transactions_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockTransactions = [
    {
      'id': 'TXN-901',
      'item': 'Organic Soil Science Course',
      'buyer': 'Ramesh Patil',
      'amount': '1499.00',
      'status': 'SUCCESS',
      'date': 'Nov 12, 2026',
      'payment_method': 'UPI / Razorpay',
    },
    {
      'id': 'TXN-902',
      'item': 'Drip Irrigation Guide E-Book',
      'buyer': 'Pooja Shinde',
      'amount': '499.00',
      'status': 'SUCCESS',
      'date': 'Nov 11, 2026',
      'payment_method': 'Net Banking',
    },
    {
      'id': 'TXN-903',
      'item': 'Greenhouse Farming Webinar',
      'buyer': 'Amit Deshmukh',
      'amount': '899.00',
      'status': 'PENDING',
      'date': 'Nov 10, 2026',
      'payment_method': 'UPI',
    },
  ];

  group('InstructorTransactionsScreen Widget Tests', () {
    testWidgets('renders all transactions, summary statistics, and search filtering correctly',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            instructorTransactionsProvider.overrideWith((ref) async => mockTransactions),
          ],
          child: const MaterialApp(
            home: InstructorTransactionsScreen(),
          ),
        ),
      );

      // Wait for future provider data to resolve
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify app bar title
      expect(find.text('All Transactions'), findsOneWidget);

      // Verify total summary card
      expect(find.text('Total Settled Earnings'), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // 3 orders
      expect(find.text('Successful'), findsOneWidget);

      // Verify transaction list items
      expect(find.text('Organic Soil Science Course'), findsOneWidget);
      expect(find.text('Drip Irrigation Guide E-Book'), findsOneWidget);
      expect(find.text('Greenhouse Farming Webinar'), findsOneWidget);
      expect(find.text('+₹1499.00'), findsOneWidget);
      expect(find.text('+₹499.00'), findsOneWidget);

      // Test Search functionality
      await tester.enterText(find.byType(TextField), 'Drip');
      await tester.pump(const Duration(milliseconds: 100));

      // Drip Irrigation should be visible, others filtered out
      expect(find.text('Drip Irrigation Guide E-Book'), findsOneWidget);
      expect(find.text('Organic Soil Science Course'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on a transaction card to open receipt modal
      await tester.tap(find.text('Organic Soil Science Course'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify modal content
      expect(find.text('Transaction Receipt'), findsOneWidget);
      expect(find.text('TXN-901'), findsOneWidget);
      expect(find.text('Amount Credited'), findsOneWidget);
    });

    testWidgets('displays empty state when no transactions exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            instructorTransactionsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: InstructorTransactionsScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No Transactions Yet'), findsOneWidget);
    });
  });
}

