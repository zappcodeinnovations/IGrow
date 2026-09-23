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
                    tabs: const [
                      Tab(text: 'Curriculum'),
                      Tab(text: 'Q&A'),
                      Tab(text: 'Notes & Bookmarks'),
                      Tab(text: 'Reviews'),
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
      expect(find.text('Reviews'), findsOneWidget);
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

    testWidgets('Course Player keyboard open does not overflow with keyboard insets', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final isKeyboardOpen = View.of(context).viewInsets.bottom > 0;
                return Column(
                  children: [
                    Visibility(
                      visible: !isKeyboardOpen,
                      maintainState: true,
                      child: Container(
                        width: double.infinity,
                        height: 230,
                        color: Colors.black,
                      ),
                    ),
                    if (!isKeyboardOpen)
                      Container(height: 50, color: Colors.grey),
                    Expanded(
                      child: DefaultTabController(
                        length: 4,
                        child: Column(
                          children: [
                            const TabBar(
                              isScrollable: true,
                              tabs: [
                                Tab(text: 'Curriculum'),
                                Tab(text: 'Q&A'),
                                Tab(text: 'Notes & Bookmarks'),
                                Tab(text: 'Reviews'),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(child: ListView()),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    child: const TextField(
                                      decoration: InputDecoration(hintText: 'Ask a question...'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Notes & Bookmarks horizontal filter bar renders without overflow on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('All'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Notes 📝'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Bookmarks 🔖'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bookmark_add_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Bookmark 00:20'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Notes 📝'), findsOneWidget);
      expect(find.text('Bookmarks 🔖'), findsOneWidget);
      expect(find.text('Bookmark 00:20'), findsOneWidget);
    });

    testWidgets('Reviews tab star selector renders without overflow on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 4,
                children: [
                  ...List.generate(
                    5,
                    (index) => const Icon(Icons.star_rounded, size: 30),
                  ),
                  const SizedBox(width: 8),
                  const Text('Excellent (5/5)'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Excellent (5/5)'), findsOneWidget);
    });
  });
}
