import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing persistent course section quizzes and student quiz completion history.
class QuizService {
  static const String _quizPrefix = 'section_quiz_';
  static const String _historyKey = 'student_quiz_history';

  /// Save a quiz created by an instructor for a specific section.
  static Future<void> saveSectionQuiz(String sectionId, Map<String, dynamic> quizData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_quizPrefix$sectionId', jsonEncode(quizData));
    } catch (_) {}
  }

  /// Retrieve a quiz configured for a specific section.
  static Future<Map<String, dynamic>?> getSectionQuiz(String sectionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_quizPrefix$sectionId');
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  /// Delete a quiz for a specific section.
  static Future<void> deleteSectionQuiz(String sectionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_quizPrefix$sectionId');
    } catch (_) {}
  }

  /// Check if a section has a saved quiz.
  static Future<bool> hasSectionQuiz(String sectionId) async {
    final quiz = await getSectionQuiz(sectionId);
    return quiz != null && quiz.isNotEmpty;
  }

  /// Record a completed quiz in the student's quiz history.
  static Future<void> recordQuizCompletion({
    required String topic,
    required String scoreText,
    required int score,
    required int total,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getQuizHistory();
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      history.insert(0, {
        'topic': topic,
        'date': dateStr,
        'score': scoreText,
        'numeric_score': score,
        'total': total,
        'timestamp': now.millisecondsSinceEpoch,
      });

      await prefs.setString(_historyKey, jsonEncode(history));
    } catch (_) {}
  }

  /// Retrieve the student's quiz history list.
  static Future<List<Map<String, dynamic>>> getQuizHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
