import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/course_models.dart';
import 'package:krushi_siksha/features/home_instructor/screens/instructor_home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Instructor Live Course Manage Button Tests', () {
    testWidgets('Live/Approved course does NOT display Manage Course button', (tester) async {
      const liveCourse = ApiCourseList(
        id: 'course-101',
        title: 'Hydroponics Farming Masterclass',
        status: 'APPROVED',
        price: '1999',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Builder(
                builder: (context) {
                  // Testing via CourseCard UI in instructor home
                  return AgriLearnCourseCard(
                    course: liveCourse,
                    onManage: () {},
                    onViewLive: () {},
                    onDelete: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Manage Course'), findsNothing);
      expect(find.text('View Live'), findsOneWidget);
    });

    testWidgets('Draft course DOES display Manage Course button and no View Live button', (tester) async {
      const draftCourse = ApiCourseList(
        id: 'course-102',
        title: 'Draft Organic Farming',
        status: 'DRAFT',
        price: '999',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Builder(
                builder: (context) {
                  return AgriLearnCourseCard(
                    course: draftCourse,
                    onManage: () {},
                    onViewLive: () {},
                    onDelete: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Manage Course'), findsOneWidget);
      expect(find.text('View Live'), findsNothing);
    });
  });
}
