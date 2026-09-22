import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Course Player Responsive Screen Tests', () {
    testWidgets('Course Player TabBar renders without overflow on narrow 320px screen', (tester) async {
      // Simulate narrow 320px width device (e.g. small Android or iPhone SE)
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                    tabs: [
                      const Tab(text: 'Curriculum'),
                      const Tab(text: 'Q&A'),
                      const Tab(text: 'Notes & Bookmarks'),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Certificate'),
                            SizedBox(width: 4),
                            Icon(Icons.verified, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all 4 tabs are present without throwing RenderFlex overflow
      expect(find.text('Curriculum'), findsOneWidget);
      expect(find.text('Q&A'), findsOneWidget);
      expect(find.text('Notes & Bookmarks'), findsOneWidget);
      expect(find.text('Certificate'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Header lecture actions row renders without overflow on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Module 1: Introduction to Advanced Hydroponic Systems',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Course Overview & Syllabus Walkthrough for Students',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.check_circle, size: 15),
                        label: const Text('Completed', style: TextStyle(fontSize: 11)),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        icon: const Icon(Icons.skip_next, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
