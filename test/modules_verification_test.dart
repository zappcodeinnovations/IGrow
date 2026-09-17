import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/review_models.dart';
import 'package:krushi_siksha/data/models/api_models/wishlist_model.dart';
import 'package:krushi_siksha/data/models/api_models/notification_models.dart';
import 'package:krushi_siksha/data/models/api_models/course_models.dart';

void main() {
  group('Wishlist Models Test', () {
    test('ApiWishlistItem correctly parses Course JSON and sets helpers', () {
      final json = {
        'id': 'w-101',
        'target_id': 'c-202',
        'type': 'course',
        'title': 'Organic Farming 101',
        'slug': 'organic-farming-101',
        'thumbnail': 'https://example.com/thumb.jpg',
        'price': '499.00',
        'category': 'Horticulture',
        'rating': 4.9,
        'added_at': '2026-09-17T12:00:00Z',
      };

      final item = ApiWishlistItem.fromJson(json);

      expect(item.id, 'w-101');
      expect(item.targetId, 'c-202');
      expect(item.isCourse, true);
      expect(item.isEbook, false);
      expect(item.title, 'Organic Farming 101');
      expect(item.displayImage, 'https://example.com/thumb.jpg');
      expect(item.price, '499.00');
      expect(item.category, 'Horticulture');
      expect(item.rating, 4.9);
      expect(item.addedAt, isNotNull);
    });

    test('ApiWishlistItem correctly parses EBook JSON with cover and missing fields', () {
      final json = {
        'id': 'w-102',
        'target_id': 'e-303',
        'type': 'ebook',
        'title': 'Pest Management Handbook',
        'slug': 'pest-management-handbook',
        'cover': 'https://example.com/cover.jpg',
        'price': '0.00',
      };

      final item = ApiWishlistItem.fromJson(json);

      expect(item.isCourse, false);
      expect(item.isEbook, true);
      expect(item.displayImage, 'https://example.com/cover.jpg');
      expect(item.category, 'General'); // default fallback
      expect(item.rating, 4.8); // default fallback
    });

    test('WishlistToggleResult parses added and removed responses', () {
      final addedJson = {
        'in_wishlist': true,
        'message': 'Added to wishlist!',
        'id': 'uuid-123',
      };
      final added = WishlistToggleResult.fromJson(addedJson);
      expect(added.inWishlist, true);
      expect(added.message, 'Added to wishlist!');
      expect(added.id, 'uuid-123');

      final removedJson = {
        'in_wishlist': false,
        'message': 'Removed from wishlist.',
      };
      final removed = WishlistToggleResult.fromJson(removedJson);
      expect(removed.inWishlist, false);
      expect(removed.id, isNull);
    });
  });

  group('Course Review Models Test', () {
    test('ApiCourseReview parses valid and boundary rating', () {
      final json = {
        'id': 'rev-1',
        'student_name': 'Ramesh Kumar',
        'student_avatar': 'https://example.com/avatar.png',
        'rating': 5,
        'comment': 'Exceptional course on modern drip irrigation techniques.',
        'created_at': '2026-09-17T10:30:00Z',
      };

      final review = ApiCourseReview.fromJson(json);
      expect(review.id, 'rev-1');
      expect(review.studentName, 'Ramesh Kumar');
      expect(review.rating, 5);
      expect(review.comment, contains('drip irrigation'));
      expect(review.createdAt, isNotNull);
    });

    test('ApiCourseReview clamps invalid rating outside 1..5', () {
      final jsonHigh = {
        'id': 'rev-2',
        'student_name': 'Tester',
        'rating': 10,
        'comment': 'Too high',
      };
      expect(ApiCourseReview.fromJson(jsonHigh).rating, 5);

      final jsonLow = {
        'id': 'rev-3',
        'student_name': 'Tester',
        'rating': 0,
        'comment': 'Too low',
      };
      expect(ApiCourseReview.fromJson(jsonLow).rating, 1);
    });
  });

  group('Notifications Model Test', () {
    test('ApiNotification copyWith works cleanly', () {
      const notif = ApiNotification(
        id: 'n-1',
        notificationType: 'WELCOME',
        title: 'Welcome to IGrow',
        message: 'Get started with courses',
        isRead: false,
      );

      expect(notif.isRead, false);
      final readNotif = notif.copyWith(isRead: true);
      expect(readNotif.isRead, true);
      expect(readNotif.title, 'Welcome to IGrow');
    });
  });

  group('Enrollment and Certificates Logic Test', () {
    test('ApiEnrollment completion calculation', () {
      final json = {
        'id': 'enr-1',
        'course': 'c-1',
        'course_title': 'Soil Science',
        'completed': true,
        'completion_percentage': 100.0,
      };

      final enrollment = ApiEnrollment.fromJson(json);
      expect(enrollment.completed, true);
      expect(enrollment.completionPercentage, 100.0);
    });
  });
}
