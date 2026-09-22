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
  Future<void> saveCoursePercentage(String courseSlugOrId, double percentage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('$_percentPrefix$courseSlugOrId', percentage.clamp(0.0, 100.0));
    } catch (_) {}
  }

  /// Retrieve the course completion percentage.
  Future<double?> getCoursePercentage(String courseSlugOrId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble('$_percentPrefix$courseSlugOrId');
    } catch (_) {
      return null;
    }
  }

  /// Save watched ratio (0.0 to 1.0) for a specific lecture video.
  Future<void> saveLectureWatchProgress(
    String courseSlugOrId,
    String lectureId,
    double ratio,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_watchedRatioPrefix${courseSlugOrId}_$lectureId';
      final current = prefs.getDouble(key) ?? 0.0;
      if (ratio > current) {
        await prefs.setDouble(key, ratio.clamp(0.0, 1.0));
      }
    } catch (_) {}
  }

  /// Get watched ratio for a specific lecture video.
  Future<double> getLectureWatchProgress(String courseSlugOrId, String lectureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_watchedRatioPrefix${courseSlugOrId}_$lectureId';
      return prefs.getDouble(key) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Compute course progress percentage based on completed lectures.
  /// If totalLectures is 0 or 1, and 1 lecture is completed, returns 100.0.
  Future<double> calculateAndSaveProgress(
    String courseSlugOrId, {
    required int totalLectures,
    Set<String>? currentCompletedLectures,
  }) async {
    final completed = currentCompletedLectures ?? await getCompletedLectures(courseSlugOrId);

    double percent = 0.0;
    if (totalLectures <= 1) {
      percent = completed.isNotEmpty ? 100.0 : 0.0;
    } else {
      percent = ((completed.length / totalLectures) * 100.0).clamp(0.0, 100.0);
    }

    await saveCoursePercentage(courseSlugOrId, percent);
    return percent;
  }
}
