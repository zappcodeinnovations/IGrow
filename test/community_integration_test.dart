import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krushi_siksha/core/theme/app_colors.dart';
import 'package:krushi_siksha/data/models/api_models/community_models.dart';
import 'package:krushi_siksha/features/community/widgets/rich_post_card.dart';

void main() {
  group('Community Integration & Responsive Widget Tests', () {
    testWidgets('Header with long district name does not overflow on 360px mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const effectiveDistrict = 'Chhatrapati Sambhajinagar';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Community Hubs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Learn from regional farming instructors', style: TextStyle(fontSize: 12.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 135),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded, size: 14, color: AppColors.primaryGreen),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                effectiveDistrict,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure no flutter overflow errors occurred
      expect(tester.takeException(), isNull);
      expect(find.text('Community Hubs'), findsOneWidget);
      expect(find.text(effectiveDistrict), findsOneWidget);
    });

    testWidgets('RichPostCard renders PUBLISHED COURSE and View Course for approved announcement', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final post = CommunityPost(
        id: 'post-test-1',
        author: CommunityAuthor(id: 'author-1', fullName: 'Dr. Ramesh Patel', isExpert: true),
        postType: 'ANNOUNCEMENT',
        title: 'New Organic Farming Masterclass',
        content: 'Check out our newly approved course!',
        courseEmbed: CommunityCourseEmbed(
          id: 'course-101',
          title: 'Advanced Hydroponics 101',
          price: '499',
          status: 'APPROVED',
        ),
        tag: 'ANNOUNCEMENT',
        viewsCount: 15,
        reactionsCount: 3,
        commentsCount: 1,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RichPostCard(post: post),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('PUBLISHED COURSE'), findsOneWidget);
      expect(find.text('View Course'), findsOneWidget);
      expect(find.text('Advanced Hydroponics 101'), findsOneWidget);
    });

    testWidgets('RichPostCard renders COMING SOON badge and modal dialog for unapproved course', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final unapprovedPost = CommunityPost(
        id: 'post-test-2',
        author: CommunityAuthor(id: 'author-2', fullName: 'Instructor Suresh', isExpert: false),
        postType: 'ANNOUNCEMENT',
        title: 'Upcoming Masterclass',
        content: 'Coming soon to our hub!',
        courseEmbed: CommunityCourseEmbed(
          id: 'course-102',
          title: 'Future Agri Tech Course',
          price: '299',
          status: 'DRAFT',
        ),
        tag: 'ANNOUNCEMENT',
        viewsCount: 5,
        reactionsCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RichPostCard(post: unapprovedPost),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Verify safe badge and button labels
      expect(find.text('COMING SOON'), findsOneWidget);
      expect(find.text('Coming Soon'), findsOneWidget);

      // Tap on Coming Soon button
      await tester.tap(find.text('Coming Soon'));
      await tester.pumpAndSettle();

      // Verify friendly bottom sheet modal appeared instead of 404 crash
      expect(find.text('Course Under Review'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);
    });
  });
}
