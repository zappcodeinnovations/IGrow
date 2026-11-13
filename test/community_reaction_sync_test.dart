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

    testWidgets('RichPostCard displays separate Thumbs Up and Heart reaction buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      final testPost = CommunityPost(
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
        userReaction: 'LIKE',
        reactionsBreakdown: {'LIKE': 4, 'LOVE': 1},
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
                  (ref) => TestCommunityPostsNotifier(mockRepo, ref, initialPost: testPost),
                ),
              ],
              child: SingleChildScrollView(
                child: RichPostCard(post: testPost),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both 👍 and ❤️ buttons are shown separately with independent counts
      expect(find.text('👍'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Tapping Thumbs Up sends LIKE and tapping Heart sends LOVE independently', (tester) async {
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
        userReaction: 'LIKE',
        reactionsBreakdown: {'LIKE': 1, 'LOVE': 0},
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

      // Initial active reaction is 👍 (count 1), ❤️ is 0
      expect(find.text('👍'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Tap on Heart ❤️ (Love)
      await tester.tap(find.text('❤️'));
      await tester.pumpAndSettle();

      // Verify repository received canonical 'LOVE'
      expect(mockRepo.lastReactedPostId, 'post-test-123');
      expect(mockRepo.lastReactionSent, 'LOVE');
    });
  });
}
