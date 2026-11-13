import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/features/instructor_dashboard/widgets/my_students_sheet.dart';

void main() {
  group('InstructorStudentProfile Grouping & Metrics Tests', () {
    final mockTransactions = [
      {
        'buyer': 'kajal nawghare',
        'email': 'nawgharekajal01@gmail.com',
        'course_title': 'हळद शेती आधुनिक तंत्रज्ञान',
        'amount': 599.0,
        'date': '02/11/2026 16:57',
        'transaction_id': 'TXN-001',
      },
      {
        'buyer': 'Rashmi Joshi',
        'email': 'rashmi@gmail.com',
        'course_title': 'चंदन लागवड आधुनिक तंत्रज्ञान',
        'amount': 1499.0,
        'date': '02/11/2026 12:31',
        'transaction_id': 'TXN-002',
      },
      {
        'buyer': 'Rashmi Joshi',
        'email': 'rashmi@gmail.com',
        'course_title': 'सेंद्रिय खत निर्मिती',
        'amount': 499.0,
        'date': '02/11/2026 11:31',
        'transaction_id': 'TXN-003',
      },
      {
        'buyer': 'Rashmi Joshi',
        'email': 'rashmi@gmail.com',
        'course_title': 'ड्रिप इरिगेशन गाईड',
        'amount': 299.0,
        'date': '02/11/2026 10:33',
        'transaction_id': 'TXN-004',
      },
      {
        'buyer': 'Rashmi Joshi',
        'email': 'rashmi@gmail.com',
        'course_title': 'पॉलीहाऊस शेती',
        'amount': 999.0,
        'date': '31/10/2026 18:55',
        'transaction_id': 'TXN-005',
      },
      {
        'buyer': 'kajal nawghare',
        'email': 'nawgharekajal01@gmail.com',
        'course_title': 'आधुनिक फळबागा',
        'amount': 499.0,
        'date': '02/11/2026 17:18',
        'transaction_id': 'TXN-006',
      },
      {
        'buyer': 'Rashmi Joshi',
        'email': 'rashmi@gmail.com',
        'course_title': 'हायड्रोपोनिक्स मार्गदर्शक',
        'amount': 899.0,
        'date': '02/11/2026 11:34',
        'transaction_id': 'TXN-007',
      },
    ];

    test('groupTransactions correctly deduplicates 7 enrollments into 2 distinct student profiles', () {
      final profiles = InstructorStudentProfile.groupTransactions(mockTransactions);

      expect(profiles.length, equals(2));

      // Sorted by courses count descending by default
      expect(profiles[0].name, equals('Rashmi Joshi'));
      expect(profiles[0].coursesCount, equals(5));
      expect(profiles[0].totalSpent, equals(1499.0 + 499.0 + 299.0 + 999.0 + 899.0));

      expect(profiles[1].name, equals('kajal nawghare'));
      expect(profiles[1].coursesCount, equals(2));
      expect(profiles[1].totalSpent, equals(599.0 + 499.0));
    });

    testWidgets('MyStudentsSheet renders distinct student cards and allows drilling into details', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyStudentsSheet(
              transactions: mockTransactions,
              totalStudents: 2,
              totalEnrollments: 7,
              scrollController: ScrollController(),
              onOpenLedger: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header counts
      expect(find.text('My Students'), findsOneWidget);
      expect(find.text('2 total students • 7 enrollments'), findsOneWidget);

      // Check distinct student names are present
      expect(find.text('Rashmi Joshi'), findsOneWidget);
      expect(find.text('kajal nawghare'), findsOneWidget);

      // Verify that individual raw course items are not shown in this student list view
      expect(find.text('चंदन लागवड आधुनिक तंत्रज्ञान'), findsNothing);

      // Tap on Kajal Nawghare to open detailed view
      await tester.tap(find.text('kajal nawghare'));
      await tester.pumpAndSettle();

      // In StudentDetailsSheet
      expect(find.text('Active Enrolled Student'), findsOneWidget);
      expect(find.text('nawgharekajal01@gmail.com'), findsOneWidget);
      expect(find.text('Enrolled Courses (2)'), findsOneWidget);
      expect(find.text('हळद शेती आधुनिक तंत्रज्ञान'), findsOneWidget);
      expect(find.text('आधुनिक फळबागा'), findsOneWidget);
      expect(find.text('Student Activity Timeline'), findsOneWidget);

      // Close the details sheet
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();

      // Filter by search
      await tester.enterText(find.byType(TextField), 'Rashmi');
      await tester.pumpAndSettle();

      expect(find.text('Rashmi Joshi'), findsOneWidget);
      expect(find.text('kajal nawghare'), findsNothing);
    });
  });
}
