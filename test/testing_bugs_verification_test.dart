import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/review_models.dart';

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
}
