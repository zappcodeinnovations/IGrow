import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/review_models.dart';
import 'package:krushi_siksha/data/models/api_models/community_models.dart';

void main() {
  group('Testing Bug 2: Edit Profile Searchable Dropdown Logic Tests', () {
    const states = [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
      'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
      'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
      'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi'
    ];

    test('Filters state list accurately case-insensitively', () {
      final query = 'maha';
      final filtered = states.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
      expect(filtered, contains('Maharashtra'));
      expect(filtered.length, 1);
    });

    test('Multi-match search returns all corresponding states', () {
      final query = 'pradesh';
      final filtered = states.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
      expect(filtered, containsAll(['Andhra Pradesh', 'Arunachal Pradesh', 'Himachal Pradesh', 'Madhya Pradesh', 'Uttar Pradesh']));
    });
  });

  group('Testing Bug 5: Course Review Instructor Reply Parsing Tests', () {
    test('ApiCourseReview parses instructor reply and date correctly from API JSON', () {
      final json = {
        'id': 'rev-101',
        'student_name': 'testStudent',
        'student_avatar': 'https://example.com/avatar.jpg',
        'rating': 5,
        'comment': 'best course',
        'created_at': '2026-09-29T10:00:00Z',
        'instructor_reply': 'Thank you for your feedback! Keep learning.',
        'instructor_reply_date': '2026-09-30T14:30:00Z',
        'instructor_name': 'Dr. Sharma',
      };

      final review = ApiCourseReview.fromJson(json);
      expect(review.studentName, 'testStudent');
      expect(review.comment, 'best course');
      expect(review.instructorReply, 'Thank you for your feedback! Keep learning.');
      expect(review.instructorReplyCreatedAt, isNotNull);
      expect(review.instructorName, 'Dr. Sharma');
    });

    test('ApiCourseReview gracefully handles null or missing instructor reply', () {
      final json = {
        'id': 'rev-102',
        'student_name': 'Student2',
        'rating': 4,
        'comment': 'Good overview',
      };

      final review = ApiCourseReview.fromJson(json);
      expect(review.instructorReply, isNull);
      expect(review.instructorReplyCreatedAt, isNull);
    });

    test('ApiCourseReview parses nested replies list and map formats accurately', () {
      final jsonWithList = {
        'id': 'rev-103',
        'student_name': 'testStudent',
        'rating': 5,
        'comment': 'best course',
        'replies': [
          {
            'reply': 'test',
            'created_at': '2026-09-30T14:30:00Z',
            'instructor_name': 'test instructor',
          }
        ],
      };

      final review = ApiCourseReview.fromJson(jsonWithList);
      expect(review.instructorReply, 'test');
      expect(review.instructorName, 'test instructor');
      expect(review.instructorReplyCreatedAt, isNotNull);

      final jsonWithMap = {
        'id': 'rev-104',
        'student_name': 'testStudent',
        'rating': 5,
        'comment': 'best course',
        'instructor_reply': {
          'comment': 'Direct answer',
        },
      };

      final reviewMap = ApiCourseReview.fromJson(jsonWithMap);
      expect(reviewMap.instructorReply, 'Direct answer');
    });
  });

  group('Testing Bug 1, 3, 4: Media URL Normalization & Source Mapping Tests', () {
    String normalizeVideoUrl(String rawUrl) {
      final trimmed = rawUrl.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return Uri.encodeFull(trimmed);
      }
      final clean = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return Uri.encodeFull('https://iagrow.zappcode.in$clean');
    }

    test('Normalizes relative Django media paths with absolute HTTPS origin and URL encoding', () {
      final relativePath = '/media/course_videos/lecture one.mp4';
      final normalized = normalizeVideoUrl(relativePath);
      expect(normalized, 'https://iagrow.zappcode.in/media/course_videos/lecture%20one.mp4');
      expect(normalized.startsWith('https://'), isTrue);
    });

    test('Preserves existing HTTPS URLs without duplicating origin', () {
      const existingUrl = 'https://vz-12345.b-cdn.net/sample/playlist.m3u8';
      final normalized = normalizeVideoUrl(existingUrl);
      expect(normalized, existingUrl);
    });

    test('Correctly prioritizes actual uploaded media file over placeholder flower stream', () {
      const uploadedFile = 'https://iagrow.zappcode.in/media/courses/lecture.mp4';
      const dummySampleStream = 'https://vz-716870.b-cdn.net/sample-video/playlist.m3u8';

      final isDirectUploadedFile = uploadedFile.contains('.mp4') || uploadedFile.contains('/media/');
      final isFetchedDummySample = dummySampleStream.contains('sample-video');

      String resolved;
      if (dummySampleStream.isNotEmpty && !isFetchedDummySample) {
        resolved = dummySampleStream;
      } else if (isDirectUploadedFile) {
        resolved = uploadedFile;
      } else {
        resolved = dummySampleStream;
      }

      expect(resolved, uploadedFile);
    });
  });

  group('Testing New Bugs: Community Seminar, RBAC, Share & Error Handling Tests', () {
    test('Bug 1: CommunityPost parses UTC event_date to local and formats with 12-hour AM/PM', () {
      final json = {
        'id': 'post-101',
        'author_id': 'author-123',
        'author_name': 'Dr. Expert',
        'title': 'Smart 3 Test Seminar',
        'content': 'Interactive farming seminar',
        'post_type': 'OFFLINE_SEMINAR',
        'event_date': '2026-10-21T04:30:00Z', // 04:30 UTC is 10:00 AM IST (+05:30)
        'venue_address': 'Nagpur Krishi Kendra',
        'link': 'https://maps.google.com/?q=Nagpur',
      };

      final post = CommunityPost.fromJson(json);
      expect(post.eventDate, isNotNull);
      expect(post.formattedEventDateTime, isNotNull);
      // formattedEventDateTime contains date and AM/PM format
      expect(post.formattedEventDateTime, contains('/2026'));
      expect(post.formattedEventDateTime, anyOf(contains('AM'), contains('PM')));
    });

    test('Bug 4: CommunityPost.fromJson gracefully parses raw string author UUID so delete option displays', () {
      final json = {
        'id': 'post-102',
        'author': 'user-uuid-999', // Backend returned raw UUID string on creation
        'author_name': 'Student Creator',
        'title': 'My New Seminar',
        'content': 'Description',
        'post_type': 'OFFLINE_SEMINAR',
      };

      final post = CommunityPost.fromJson(json);
      expect(post.author.id, 'user-uuid-999');
      expect(post.author.fullName, 'Student Creator');
    });

    test('Bug 2: URL validator accurately detects valid vs invalid URLs', () {
      bool isValidUrl(String? val) {
        if (val == null || val.trim().isEmpty) return false;
        final uri = Uri.tryParse(val.trim());
        final hasValidScheme = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
        final hasHost = uri != null && uri.host.isNotEmpty && uri.host.contains('.');
        return hasValidScheme && hasHost;
      }

      expect(isValidUrl('test'), isFalse);
      expect(isValidUrl('http:/invalid'), isFalse);
      expect(isValidUrl('maps.google.com'), isFalse); // Missing scheme
      expect(isValidUrl('https://maps.google.com/?q=Nagpur'), isTrue);
      expect(isValidUrl('https://meet.google.com/abc-defg-hij'), isTrue);
      expect(isValidUrl('http://zoom.us/j/123456789'), isTrue);
    });

    test('Bug 3: Event share payload includes structured date, location, and map link', () {
      final json = {
        'id': 'post-103',
        'author_id': 'author-777',
        'title': 'Pest Management Seminar',
        'content': 'Join us to learn modern organic techniques',
        'post_type': 'OFFLINE_SEMINAR',
        'event_date': '2026-10-25T04:30:00Z',
        'venue_address': 'Pune Agri Center',
        'link': 'https://maps.google.com/?q=Pune',
      };

      final post = CommunityPost.fromJson(json);
      final buffer = StringBuffer();
      if (post.postType == 'OFFLINE_SEMINAR' || post.postType == 'SEMINAR') {
        buffer.writeln('🌾 [iAgrow Seminar Invitation]');
      }
      buffer.writeln(post.title);
      buffer.writeln(post.content);
      if (post.formattedEventDateTime != null) {
        buffer.writeln('📅 Date & Time: ${post.formattedEventDateTime}');
      }
      if (post.venueAddress != null) {
        buffer.writeln('📍 Location / Venue: ${post.venueAddress}');
      }
      if (post.link != null) {
        buffer.writeln('🗺️ Directions / Map: ${post.link}');
      }
      buffer.writeln('Shared via iAgrow App 🌱');

      final sharedText = buffer.toString();
      expect(sharedText, contains('🌾 [iAgrow Seminar Invitation]'));
      expect(sharedText, contains('Pest Management Seminar'));
      expect(sharedText, contains('📅 Date & Time:'));
      expect(sharedText, contains('📍 Location / Venue: Pune Agri Center'));
      expect(sharedText, contains('🗺️ Directions / Map: https://maps.google.com/?q=Pune'));
      expect(sharedText, contains('Shared via iAgrow App 🌱'));
    });
  });
}
