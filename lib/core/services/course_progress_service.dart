import 'package:shared_preferences/shared_preferences.dart';

/// Persistent storage and calculation engine for student course progress.
/// Ensures that lecture completions and video watch progress are remembered
/// locally and accurately reflected on dashboards (0% to 100%).
class CourseProgressService {
  static final CourseProgressService instance = CourseProgressService._();
  CourseProgressService._();

  static const String _lecturesPrefix = 'course_completed_lectures_';
  static const String _percentPrefix = 'course_progress_percent_';
  static const String _watchedRatioPrefix = 'lecture_watch_ratio_';
  static const String _watchedSecondsPrefix = 'lecture_watch_sec_';

  /// Save the set of completed lecture IDs for a course.
  Future<void> saveCompletedLectures(String courseSlugOrId, Set<String> lectureIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('$_lecturesPrefix$courseSlugOrId', lectureIds.toList());
    } catch (_) {}
  }

  /// Retrieve the set of completed lecture IDs for a course.
  Future<Set<String>> getCompletedLectures(String courseSlugOrId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('$_lecturesPrefix$courseSlugOrId') ?? [];
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Save the calculated course completion percentage (0.0 to 100.0).
  Future<void> saveCoursePercentage(
    String courseSlugOrId,
    double percentage, {
    String? secondaryKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = percentage.clamp(0.0, 100.0);
      await prefs.setDouble('$_percentPrefix$courseSlugOrId', val);
      if (secondaryKey != null && secondaryKey.isNotEmpty && secondaryKey != courseSlugOrId) {
        await prefs.setDouble('$_percentPrefix$secondaryKey', val);
      }
    } catch (_) {}
  }

  /// Retrieve the course completion percentage.
  Future<double?> getCoursePercentage(
    String courseSlugOrId, {
    String? secondaryKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val1 = prefs.getDouble('$_percentPrefix$courseSlugOrId');
      if (val1 != null && val1 > 0.0) return val1;
      if (secondaryKey != null && secondaryKey.isNotEmpty && secondaryKey != courseSlugOrId) {
        final val2 = prefs.getDouble('$_percentPrefix$secondaryKey');
        if (val2 != null && val2 > 0.0) return val2;
      }
      return val1;
    } catch (_) {
      return null;
    }
  }

  /// Save watched ratio (0.0 to 1.0) and optional position in seconds for a specific lecture video.
  Future<void> saveLectureWatchProgress(
    String courseSlugOrId,
    String lectureId,
    double ratio, {
    int? positionSeconds,
    String? secondaryKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_watchedRatioPrefix${courseSlugOrId}_$lectureId';
      final current = prefs.getDouble(key) ?? 0.0;
      if (ratio > current) {
        await prefs.setDouble(key, ratio.clamp(0.0, 1.0));
      }
      if (positionSeconds != null && positionSeconds > 0) {
        await prefs.setInt('$_watchedSecondsPrefix${courseSlugOrId}_$lectureId', positionSeconds);
      }
      if (secondaryKey != null && secondaryKey.isNotEmpty && secondaryKey != courseSlugOrId) {
        final secKey = '$_watchedRatioPrefix${secondaryKey}_$lectureId';
        final secCurrent = prefs.getDouble(secKey) ?? 0.0;
        if (ratio > secCurrent) {
          await prefs.setDouble(secKey, ratio.clamp(0.0, 1.0));
        }
        if (positionSeconds != null && positionSeconds > 0) {
          await prefs.setInt('$_watchedSecondsPrefix${secondaryKey}_$lectureId', positionSeconds);
        }
      }
    } catch (_) {}
  }

  /// Get watched ratio for a specific lecture video.
  Future<double> getLectureWatchProgress(
    String courseSlugOrId,
    String lectureId, {
    String? secondaryKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val1 = prefs.getDouble('$_watchedRatioPrefix${courseSlugOrId}_$lectureId') ?? 0.0;
      if (val1 > 0.0) return val1;
      if (secondaryKey != null && secondaryKey.isNotEmpty) {
        final val2 = prefs.getDouble('$_watchedRatioPrefix${secondaryKey}_$lectureId') ?? 0.0;
        if (val2 > 0.0) return val2;
      }
      return val1;
    } catch (_) {
      return 0.0;
    }
  }

  /// Get last watched position in seconds for a specific lecture video.
  Future<int> getLectureWatchPositionSeconds(
    String courseSlugOrId,
    String lectureId, {
    String? secondaryKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val1 = prefs.getInt('$_watchedSecondsPrefix${courseSlugOrId}_$lectureId') ?? 0;
      if (val1 > 0) return val1;
      if (secondaryKey != null && secondaryKey.isNotEmpty) {
        final val2 = prefs.getInt('$_watchedSecondsPrefix${secondaryKey}_$lectureId') ?? 0;
        if (val2 > 0) return val2;
      }
      return val1;
    } catch (_) {
      return 0;
    }
  }

  /// Updates watched progress for a lecture and computes overall granular course progress percentage.
  Future<double> updateLectureWatchAndRecalculate({
    required String courseSlugOrId,
    String? secondaryKey,
    required String lectureId,
    required double watchRatio,
    int? positionSeconds,
    required List<String> allLectureIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratioKey = '$_watchedRatioPrefix${courseSlugOrId}_$lectureId';
      final current = prefs.getDouble(ratioKey) ?? 0.0;
      if (watchRatio > current) {
        await prefs.setDouble(ratioKey, watchRatio.clamp(0.0, 1.0));
      }
      if (positionSeconds != null && positionSeconds > 0) {
        await prefs.setInt('$_watchedSecondsPrefix${courseSlugOrId}_$lectureId', positionSeconds);
      }

      if (secondaryKey != null && secondaryKey.isNotEmpty && secondaryKey != courseSlugOrId) {
        final secRatioKey = '$_watchedRatioPrefix${secondaryKey}_$lectureId';
        final secCurrent = prefs.getDouble(secRatioKey) ?? 0.0;
        if (watchRatio > secCurrent) {
          await prefs.setDouble(secRatioKey, watchRatio.clamp(0.0, 1.0));
        }
        if (positionSeconds != null && positionSeconds > 0) {
          await prefs.setInt('$_watchedSecondsPrefix${secondaryKey}_$lectureId', positionSeconds);
        }
      }

      final completed1 = await getCompletedLectures(courseSlugOrId);
      final completed2 = (secondaryKey != null && secondaryKey.isNotEmpty)
          ? await getCompletedLectures(secondaryKey)
          : <String>{};
      final completed = completed1.union(completed2);

      final effectiveLectures = allLectureIds.isNotEmpty ? allLectureIds : [lectureId];

      double totalUnits = 0.0;
      for (final id in effectiveLectures) {
        if (completed.contains(id)) {
          totalUnits += 1.0;
        } else {
          final r1 = (id == lectureId && watchRatio > current)
              ? watchRatio
              : (prefs.getDouble('$_watchedRatioPrefix${courseSlugOrId}_$id') ?? 0.0);
          final r2 = (secondaryKey != null && secondaryKey.isNotEmpty)
              ? (prefs.getDouble('$_watchedRatioPrefix${secondaryKey}_$id') ?? 0.0)
              : 0.0;
          final r = r1 > r2 ? r1 : r2;
          totalUnits += r.clamp(0.0, 1.0);
        }
      }

      final percent = ((totalUnits / effectiveLectures.length) * 100.0).clamp(0.0, 100.0);
      await saveCoursePercentage(courseSlugOrId, percent, secondaryKey: secondaryKey);
      return percent;
    } catch (_) {
      return 0.0;
    }
  }

  /// Compute course progress percentage based on completed lectures and partial watch progress.
  Future<double> calculateAndSaveProgress(
    String courseSlugOrId, {
    required int totalLectures,
    Set<String>? currentCompletedLectures,
    List<String>? allLectureIds,
  }) async {
    final completed = currentCompletedLectures ?? await getCompletedLectures(courseSlugOrId);

    double percent = 0.0;
    if (allLectureIds != null && allLectureIds.isNotEmpty) {
      double totalUnits = 0.0;
      for (final id in allLectureIds) {
        if (completed.contains(id)) {
          totalUnits += 1.0;
        } else {
          final r = await getLectureWatchProgress(courseSlugOrId, id);
          totalUnits += r.clamp(0.0, 1.0);
        }
      }
      percent = ((totalUnits / allLectureIds.length) * 100.0).clamp(0.0, 100.0);
    } else {
      if (totalLectures <= 1) {
        percent = completed.isNotEmpty ? 100.0 : 0.0;
      } else {
        percent = ((completed.length / totalLectures) * 100.0).clamp(0.0, 100.0);
      }
    }

    await saveCoursePercentage(courseSlugOrId, percent);
    return percent;
  }
}
