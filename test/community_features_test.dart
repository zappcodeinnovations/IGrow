import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/community_models.dart';

void main() {
  group('Community Comments and Share Feature Tests', () {
    test('CommunityComment correctly parses JSON with nested author', () {
      final json = {
        'id': 'comment-1',
        'author': {
          'id': 'user-101',
          'full_name': 'Ramesh Patel',
          'is_expert': true,
          'avatar_url': 'https://example.com/avatar.jpg',
        },
        'content': 'Great crop rotation advice!',
        'created_at': '2026-03-15T10:30:00Z',
      };

      final comment = CommunityComment.fromJson(json);

      expect(comment.id, 'comment-1');
      expect(comment.author.fullName, 'Ramesh Patel');
      expect(comment.author.isExpert, true);
      expect(comment.content, 'Great crop rotation advice!');
    });

    test('CommunityComment correctly parses fallback flat author format', () {
      final json = {
        'id': 'comment-2',
        'author_id': 'user-202',
        'author_name': 'Suresh Kumar',
        'author_role': 'INSTRUCTOR',
        'author_avatar': null,
        'content': 'Check organic fertilizer dosage.',
        'created_at': '2026-03-16T12:00:00Z',
      };

      final comment = CommunityComment.fromJson(json);

      expect(comment.id, 'comment-2');
      expect(comment.author.id, 'user-202');
      expect(comment.author.fullName, 'Suresh Kumar');
      expect(comment.author.isExpert, true); // INSTRUCTOR is considered expert
      expect(comment.content, 'Check organic fertilizer dosage.');
    });

    test('CommunityComment safely handles int ID and alternative text field', () {
      final json = {
        'id': 99,
        'user': {
          'id': 42,
          'username': 'agri_expert_99',
          'role': 'ADMIN',
        },
        'comment': 'Organic neem oil spray works best for aphids.',
      };

      final comment = CommunityComment.fromJson(json);

      expect(comment.id, '99');
      expect(comment.author.id, '42');
      expect(comment.author.fullName, 'agri_expert_99');
      expect(comment.author.isExpert, true);
      expect(comment.content, 'Organic neem oil spray works best for aphids.');
    });

    test('CommunityPost copyWith increments comments count accurately', () {
      final post = CommunityPost(
        id: 'post-1',
        author: CommunityAuthor(id: 'author-1', fullName: 'Dr. Rao', isExpert: true),
        content: 'Tips for wheat harvesting',
        tag: 'GENERAL',
        likesCount: 5,
        commentsCount: 2,
        isLikedByMe: false,
        createdAt: DateTime.now(),
      );

      final updatedPost = post.copyWith(commentsCount: post.commentsCount + 1);

      expect(updatedPost.commentsCount, 3);
      expect(updatedPost.likesCount, 5);
      expect(updatedPost.id, post.id);
    });
  });
}
