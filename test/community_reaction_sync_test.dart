import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/community_models.dart';
import 'package:krushi_siksha/data/repositories/community_repository.dart';
import 'package:krushi_siksha/features/community/providers/community_provider.dart';
import 'package:krushi_siksha/features/community/widgets/rich_post_card.dart';

class MockCommunityRepository extends Fake implements CommunityRepository {
  String? lastReactedPostId;
  String? lastReactionSent;

  @override
  Future<List<CommunityPost>> getPosts({
    String? hubId,
    String? topicId,
    String? search,
    String? ordering,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> incrementPostView(String postId) async {
    return {'views_count': 1};
  }

  @override
  Future<Map<String, dynamic>> reactToPost(String postId, String reaction) async {
    lastReactedPostId = postId;
    lastReactionSent = reaction;
    return {
      'reactions_count': 2,
      'user_reaction': reaction,
    };
  }
}

class TestCommunityPostsNotifier extends CommunityPostsNotifier {
  TestCommunityPostsNotifier(super.repo, super.ref, {required CommunityPost initialPost}) {
    state = AsyncValue.data([initialPost]);
  }

  @override
  Future<void> fetchPosts({String? search, String? ordering}) async {}
}

void main() {
  group('Community Emoji Reactions and Real-time State Synchronization', () {
    test('CommunityPost models parse userReaction and reaction breakdown correctly', () {
      final json = {
        'id': 'post-101',
        'author_name': 'Kajal Nawghare',
        'author_role': 'INSTRUCTOR',
        'content': 'Check organic farming methods',
        'reactions_count': 3,
        'user_reaction': 'HELPFUL',
        'reactions_breakdown': {'HELPFUL': 1, 'FARM': 2},
      };

      final post = CommunityPost.fromJson(json);
      expect(post.userReaction, equals('HELPFUL'));
      expect(post.reactionsCount, equals(3));
      expect(post.isLikedByMe, isTrue);
    });

    testWidgets('RichPostCard displays correct emoji icon for HELPFUL and LIKE', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      final testPostHelpful = CommunityPost(
        id: 'post-1',
        author: CommunityAuthor(
          id: 'author-1',
          fullName: 'Kajal',
          role: 'INSTRUCTOR',
          isExpert: true,
        ),
        tag: 'GENERAL',
        title: 'New Organic Farming Post',
        content: 'Helpful content',
        reactionsCount: 5,
        userReaction: 'HELPFUL',
        commentsCount: 2,
        createdAt: DateTime.now(),
      );

      final mockRepo = MockCommunityRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                communityRepositoryProvider.overrideWithValue(mockRepo),
                communityPostsProvider.overrideWith(
                  (ref) => TestCommunityPostsNotifier(mockRepo, ref, initialPost: testPostHelpful),
                ),
              ],
              child: SingleChildScrollView(
                child: RichPostCard(post: testPostHelpful),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Lightbulb emoji '💡' must be rendered for HELPFUL
      expect(find.text('💡'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Tapping lightbulb sends HELPFUL and tapping leaf sends LIKE without revert', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      final mockRepo = MockCommunityRepository();

      final initialPost = CommunityPost(
        id: 'post-test-123',
        author: CommunityAuthor(
          id: 'author-1',
          fullName: 'Kajal',
          role: 'INSTRUCTOR',
          isExpert: true,
        ),
        tag: 'GENERAL',
        title: 'Fruit Farming Course',
        content: 'Check out the new fruit farming course!',
        reactionsCount: 1,
        userReaction: 'FARM',
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                communityRepositoryProvider.overrideWithValue(mockRepo),
                communityPostsProvider.overrideWith(
                  (ref) => TestCommunityPostsNotifier(mockRepo, ref, initialPost: initialPost),
                ),
              ],
              child: SingleChildScrollView(
                child: Consumer(
                  builder: (context, ref, _) {
                    final posts = ref.watch(communityPostsProvider).value ?? [initialPost];
                    return RichPostCard(post: posts.first);
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial active reaction is 🌾 Farm (count 1)
      expect(find.text('🌾'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Open emoji picker by tapping on the reaction counter button
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Verify all 5 emojis are shown in the reaction bar: 🌾, 🌱, ❤️, 👏, 💡
      expect(find.text('🌾'), findsWidgets);
      expect(find.text('🌱'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('👏'), findsOneWidget);
      expect(find.text('💡'), findsOneWidget);

      // Tap on Lightbulb 💡 (Helpful)
      await tester.tap(find.text('💡'));
      await tester.pumpAndSettle();

      // Verify repository received canonical 'HELPFUL' instead of 'IDEA'
      expect(mockRepo.lastReactionSent, equals('HELPFUL'));
      expect(mockRepo.lastReactedPostId, equals('post-test-123'));

      // Re-open emoji picker
      await tester.tap(find.text('💡'));
      await tester.pumpAndSettle();

      // Tap on Leaf 🌱 (Grow / Like)
      await tester.tap(find.text('🌱'));
      await tester.pumpAndSettle();

      // Verify repository received canonical 'LIKE' instead of 'GROW'
      expect(mockRepo.lastReactionSent, equals('LIKE'));
    });
  });
}
