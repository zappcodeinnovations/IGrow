import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krushi_siksha/core/services/course_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Video & Course Progress Tracking Tests', () {
    test('10% and 20% video watch on single-lecture course reflects exact percentage', () async {
      final service = CourseProgressService.instance;
      const courseSlug = 'organic-farming-101';
      const lectureId = 'lec-1';
      final allLectureIds = ['lec-1'];

      // When user watches 10% (0.10)
      final percent10 = await service.updateLectureWatchAndRecalculate(
        courseSlugOrId: courseSlug,
        lectureId: lectureId,
        watchRatio: 0.10,
        positionSeconds: 60,
        allLectureIds: allLectureIds,
      );
      expect(percent10, closeTo(10.0, 0.01));

      final cached10 = await service.getCoursePercentage(courseSlug);
      expect(cached10, closeTo(10.0, 0.01));

      // When user continues to watch 20% (0.20)
      final percent20 = await service.updateLectureWatchAndRecalculate(
        courseSlugOrId: courseSlug,
        lectureId: lectureId,
        watchRatio: 0.20,
        positionSeconds: 120,
        allLectureIds: allLectureIds,
      );
      expect(percent20, closeTo(20.0, 0.01));

      final cached20 = await service.getCoursePercentage(courseSlug);
      expect(cached20, closeTo(20.0, 0.01));
    });

    test('Multi-lecture course calculates weighted granular progress accurately', () async {
      final service = CourseProgressService.instance;
      const courseSlug = 'hydroponics-mastery';
      final allLectureIds = ['lec-1', 'lec-2', 'lec-3', 'lec-4', 'lec-5'];

      // Lecture 1 is 100% completed
      await service.saveCompletedLectures(courseSlug, {'lec-1'});

      // Lecture 2 is 20% watched (0.20)
      final percent = await service.updateLectureWatchAndRecalculate(
        courseSlugOrId: courseSlug,
        lectureId: 'lec-2',
        watchRatio: 0.20,
        positionSeconds: 120,
        allLectureIds: allLectureIds,
      );

      // Total units: 1.0 (lec-1) + 0.20 (lec-2) = 1.20 / 5 = 24.0%
      expect(percent, closeTo(24.0, 0.01));
    });

    test('Video resume position in seconds is persisted and retrieved properly', () async {
      final service = CourseProgressService.instance;
      const courseSlug = 'soil-science';
      const lectureId = 'lec-soil-1';

      await service.saveLectureWatchProgress(
        courseSlug,
        lectureId,
        0.25,
        positionSeconds: 150,
      );

      final ratio = await service.getLectureWatchProgress(courseSlug, lectureId);
      final seconds = await service.getLectureWatchPositionSeconds(courseSlug, lectureId);

      expect(ratio, closeTo(0.25, 0.001));
      expect(seconds, equals(150));
    });

    test('Dual-key persistence ensures lookup by slug and id both succeed', () async {
      final service = CourseProgressService.instance;
      const courseSlug = 'drip-irrigation';
      const courseId = 'uuid-987-xyz';

      await service.updateLectureWatchAndRecalculate(
        courseSlugOrId: courseSlug,
        secondaryKey: courseId,
        lectureId: 'lec-drip-1',
        watchRatio: 0.15,
        allLectureIds: ['lec-drip-1'],
      );

      // Lookup by slug
      final bySlug = await service.getCoursePercentage(courseSlug, secondaryKey: courseId);
      expect(bySlug, closeTo(15.0, 0.01));

      // Lookup by ID
      final byId = await service.getCoursePercentage(courseId, secondaryKey: courseSlug);
      expect(byId, closeTo(15.0, 0.01));
    });
  });
}
