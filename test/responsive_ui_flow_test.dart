import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/utils/responsive_layout.dart';
import 'package:krushi_siksha/core/widgets/app_segmented_pill.dart';
import 'package:krushi_siksha/core/widgets/app_sticky_action_bar.dart';
import 'package:krushi_siksha/core/widgets/app_text_field.dart';

void main() {
  group('Responsive & Soft UI Design System Tests', () {
    testWidgets('ResponsiveLayout detects compact, medium and large viewports', (tester) async {
      // 1. Mobile Compact (< 600px)
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late BuildContext testContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (ctx) {
            testContext = ctx;
            return const SizedBox();
          }),
        ),
      );

      expect(ResponsiveLayout.isCompact(testContext), isTrue);
      expect(ResponsiveLayout.isMedium(testContext), isFalse);
      expect(ResponsiveLayout.isLarge(testContext), isFalse);

      // 2. Tablet Medium (768px)
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (ctx) {
            testContext = ctx;
            return const SizedBox();
          }),
        ),
      );

      expect(ResponsiveLayout.isCompact(testContext), isFalse);
      expect(ResponsiveLayout.isMedium(testContext), isTrue);
      expect(ResponsiveLayout.isLarge(testContext), isFalse);

      // 3. Large Desktop (> 1024px)
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (ctx) {
            testContext = ctx;
            return const SizedBox();
          }),
        ),
      );

      expect(ResponsiveLayout.isCompact(testContext), isFalse);
      expect(ResponsiveLayout.isMedium(testContext), isFalse);
      expect(ResponsiveLayout.isLarge(testContext), isTrue);
    });

    testWidgets('ResponsiveContentConstraint enforces max width on tablet without overflow', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContentConstraint(
              maxWidth: 600,
              child: Container(
                key: const Key('constrained_box'),
                height: 100,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final renderBox = tester.renderObject<RenderBox>(find.byKey(const Key('constrained_box')));
      expect(renderBox.size.width, lessThanOrEqualTo(600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppSegmentedPillGroup renders options and reacts to taps', (tester) async {
      String selected = 'Beginner';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppSegmentedPillGroup<String>(
                  options: const [
                    AppPillOption(value: 'Beginner', label: 'Beginner', emoji: '🌱'),
                    AppPillOption(value: 'Intermediate', label: 'Intermediate', emoji: '🌿'),
                    AppPillOption(value: 'Advanced', label: 'Advanced', emoji: '🌳'),
                  ],
                  selectedValue: selected,
                  onChanged: (val) {
                    setState(() => selected = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);

      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();
      expect(selected, 'Intermediate');
    });

    testWidgets('AppStickyActionBar renders responsive action buttons and triggers callbacks', (tester) async {
      bool primaryClicked = false;
      bool secondaryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppStickyActionBar(
              secondaryLabel: 'Back',
              onSecondaryPressed: () => secondaryClicked = true,
              primaryLabel: 'Continue',
              onPrimaryPressed: () => primaryClicked = true,
              statusText: 'Step 1 of 3: Details',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Step 1 of 3: Details'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      expect(primaryClicked, isTrue);

      await tester.tap(find.text('Back'));
      expect(secondaryClicked, isTrue);
    });

    testWidgets('AppTextField renders with soft input decoration without overflow', (tester) async {
      final controller = TextEditingController(text: 'Organic Farming');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: controller,
                label: 'Course Title',
                prefixIcon: const Icon(Icons.title),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Course Title'), findsOneWidget);
      expect(find.text('Organic Farming'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
