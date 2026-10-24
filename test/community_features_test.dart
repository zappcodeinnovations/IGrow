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

    test('CommunityPost correctly parses Course Announcement with embedded course object', () {
      final json = {
        'id': 'post-announcement-1',
        'post_type': 'ANNOUNCEMENT',
        'title': 'New Organic Farming Masterclass',
        'content': 'Join our new comprehensive course!',
        'course': {
          'id': 'course-uuid-999',
          'title': 'Advanced Hydroponics 101',
          'price': '499',
          'thumbnail': 'https://example.com/course.jpg',
        },
        'comments_count': 0,
        'created_at': '2026-10-24T12:00:00Z',
      };

      final post = CommunityPost.fromJson(json);

      expect(post.postType, 'ANNOUNCEMENT');
      expect(post.courseId, 'course-uuid-999');
      expect(post.courseName, 'Advanced Hydroponics 101');
      expect(post.courseEmbed != null, true);
      expect(post.courseEmbed!.price, '499');
      expect(post.courseEmbed!.thumbnail, 'https://example.com/course.jpg');
    });

    test('CommunityPost safely falls back to flat course_id and course_name fields', () {
      final json = {
        'id': 'post-announcement-2',
        'post_type': 'ANNOUNCEMENT',
        'title': 'Special Webinar Announcement',
        'content': 'Course discount available now.',
        'course_id': 'flat-course-555',
        'course_name': 'Organic Soil Preparation',
        'comments_count': 0,
        'created_at': '2026-10-24T12:00:00Z',
      };

      final post = CommunityPost.fromJson(json);

      expect(post.courseId, 'flat-course-555');
      expect(post.courseName, 'Organic Soil Preparation');
    });

    test('CommunityCourseEmbed safely extracts alternative UUID and title fields', () {
      final embed = CommunityCourseEmbed.fromJson({
        'uuid': 'uuid-custom-123',
        'name': 'Drip Irrigation Mastery',
        'cover_image': 'https://example.com/cover.png',
      });

      expect(embed.id, 'uuid-custom-123');
      expect(embed.title, 'Drip Irrigation Mastery');
      expect(embed.thumbnail, 'https://example.com/cover.png');
    });

    test('CommunityCourseEmbed correctly identifies Approved vs Draft / Review status', () {
      final approvedEmbed = CommunityCourseEmbed.fromJson({
        'id': 'c-1',
        'title': 'Organic Cotton Cultivation',
        'status': 'APPROVED',
      });
      final publishedEmbed = CommunityCourseEmbed.fromJson({
        'id': 'c-2',
        'title': 'Soil Chemistry',
        'status': 'PUBLISHED',
      });
      final draftEmbed = CommunityCourseEmbed.fromJson({
        'id': 'c-3',
        'title': 'Hydroponic Tomatoes',
        'status': 'DRAFT',
      });
      final pendingEmbed = CommunityCourseEmbed.fromJson({
        'id': 'c-4',
        'title': 'Drone Farming Tech',
        'course_status': 'PENDING_APPROVAL',
      });

      expect(approvedEmbed.isApproved, true);
      expect(publishedEmbed.isApproved, true);
      expect(draftEmbed.isApproved, false);
      expect(pendingEmbed.isApproved, false);
    });

    test('CommunityHub parses JSON and handles join / leave member count transitions', () {
      final json = {
        'id': 'hub-789',
        'name': 'Vidarbha Agri Innovators',
        'description': 'Hub for progressive cotton and citrus farmers',
        'instructor': {
          'id': 'inst-456',
          'full_name': 'Prof. Deshmukh',
          'avatar': 'https://example.com/inst.png',
        },
        'state': 'Maharashtra',
        'districts': ['Nagpur', 'Amravati', 'Wardha'],
        'farming_topics': ['Cotton', 'Citrus', 'Organic Farming'],
        'member_count': 12,
        'is_member': false,
        'created_at': '2026-01-10T08:00:00Z',
      };

      final hub = CommunityHub.fromJson(json);

      expect(hub.id, 'hub-789');
      expect(hub.name, 'Vidarbha Agri Innovators');
      expect(hub.instructorName, 'Prof. Deshmukh');
      expect(hub.districts.contains('Amravati'), true);
      expect(hub.isMember, false);
      expect(hub.memberCount, 12);

      // Simulate student joining community
      final joinedHub = hub.copyWith(
        isMember: true,
        memberCount: hub.memberCount + 1,
      );
      expect(joinedHub.isMember, true);
      expect(joinedHub.memberCount, 13);

      // Simulate student leaving community
      final leftHub = joinedHub.copyWith(
        isMember: false,
        memberCount: joinedHub.memberCount - 1,
      );
      expect(leftHub.isMember, false);
      expect(leftHub.memberCount, 12);
    });

    test('CommunityPost correctly parses Webinar and Offline Seminar post types', () {
      final webinarJson = {
        'id': 'post-webinar-1',
        'post_type': 'WEBINAR',
        'title': 'Live Q&A on Cotton Pink Bollworm',
        'content': 'Join our experts live this Saturday.',
        'link': 'https://meet.google.com/xyz-abc-def',
        'event_date': '2026-11-05T18:00:00Z',
        'comments_count': 4,
        'reactions_count': 18,
        'user_reaction': 'LIKE',
        'created_at': '2026-10-24T10:00:00Z',
      };

      final webinarPost = CommunityPost.fromJson(webinarJson);
      expect(webinarPost.postType, 'WEBINAR');
      expect(webinarPost.link, 'https://meet.google.com/xyz-abc-def');
      expect(webinarPost.eventDate != null, true);
      expect(webinarPost.userReaction, 'LIKE');
      expect(webinarPost.isLikedByMe, true);

      final seminarJson = {
        'id': 'post-seminar-1',
        'post_type': 'SEMINAR',
        'title': 'Hands-on Drip Irrigation Workshop',
        'content': 'Demonstration at Krishi Vigyan Kendra.',
        'venue_address': 'KVK Campus, Wardha Road, Nagpur',
        'event_date': '2026-11-12T10:00:00Z',
        'created_at': '2026-10-24T11:00:00Z',
      };

      final seminarPost = CommunityPost.fromJson(seminarJson);
      expect(seminarPost.postType, 'SEMINAR');
      expect(seminarPost.venueAddress, 'KVK Campus, Wardha Road, Nagpur');
      expect(seminarPost.formattedEventDateTime != null, true);
    });
  });
}

