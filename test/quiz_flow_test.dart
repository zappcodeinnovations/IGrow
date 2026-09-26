import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krushi_siksha/core/services/quiz_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Instructor to Student Quiz Flow Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('QuizService saves and retrieves instructor-created section quiz', () async {
      const sectionId = 'sec-101';
      final quizData = {
        'id': 'quiz_$sectionId',
        'section_id': sectionId,
        'title': 'Soil Chemistry Assessment',
        'passing_percent': 80,
        'questions': [
          {
            'id': 'q_1',
            'question_text': 'What is the optimal pH for wheat cultivation?',
            'options': ['4.0 - 5.0', '6.0 - 7.5', '8.5 - 9.5', '10.0+'],
            'correct_option_index': 1,
            'correct_answer': '6.0 - 7.5',
          },
          {
            'id': 'q_2',
            'question_text': 'Which primary nutrient promotes root development?',
            'options': ['Nitrogen', 'Phosphorus', 'Potassium', 'Sulfur'],
            'correct_option_index': 1,
            'correct_answer': 'Phosphorus',
          },
        ],
      };

      // 1. Instructor saves quiz
      await QuizService.saveSectionQuiz(sectionId, quizData);

      // 2. Student retrieves quiz
      final retrieved = await QuizService.getSectionQuiz(sectionId);

      expect(retrieved, isNotNull);
      expect(retrieved!['title'], 'Soil Chemistry Assessment');
      expect(retrieved['passing_percent'], 80);
      final questions = retrieved['questions'] as List;
      expect(questions.length, 2);
      expect(questions[0]['question_text'], 'What is the optimal pH for wheat cultivation?');
      expect(questions[0]['correct_answer'], '6.0 - 7.5');
    });

    test('Local quiz evaluation grades student answers and passing status accurately', () {
      final quizData = {
        'title': 'Crop Protection Quiz',
        'passing_percent': 70,
        'questions': [
          {
            'id': 'q_1',
            'question_text': 'Neem oil is primarily used as what?',
            'options': ['Organic Pesticide', 'Synthetic Herbicide', 'Fungus', 'Weed'],
            'correct_option_index': 0,
            'correct_answer': 'Organic Pesticide',
          },
          {
            'id': 'q_2',
            'question_text': 'Drip irrigation saves what percentage of water?',
            'options': ['10%', '30-50%', '95%', '0%'],
            'correct_option_index': 1,
            'correct_answer': '30-50%',
          },
        ],
      };

      // Student submits 1 correct and 1 wrong answer (50% score -> fails 70% passing requirement)
      final studentAnswers = {
        'q_1': 'Organic Pesticide',
        'q_2': '10%',
      };

      final questions = quizData['questions'] as List;
      int correctCount = 0;
      for (int i = 0; i < questions.length; i++) {
        final q = questions[i] as Map<String, dynamic>;
        final qId = q['id']?.toString() ?? 'q_${i + 1}';
        final selected = studentAnswers[qId]?.trim().toLowerCase();
        final correct = q['correct_answer']?.toString().trim().toLowerCase();
        if (selected != null && selected == correct) {
          correctCount++;
        }
      }

      final total = questions.length;
      final percentage = ((correctCount / total) * 100).round();
      final isPassed = percentage >= (quizData['passing_percent'] as int);

      expect(correctCount, 1);
      expect(total, 2);
      expect(percentage, 50);
      expect(isPassed, false);
    });

    test('Quiz completion records in student history and updates count', () async {
      await QuizService.recordQuizCompletion(
        topic: 'Soil Chemistry Assessment',
        scoreText: '2 / 2',
        score: 2,
        total: 2,
      );

      final history = await QuizService.getQuizHistory();

      expect(history.length, 1);
      expect(history[0]['topic'], 'Soil Chemistry Assessment');
      expect(history[0]['score'], '2 / 2');
      expect(history[0]['numeric_score'], 2);
    });

    test('Removing quiz by instructor deletes it from student access', () async {
      const sectionId = 'sec-999';
      await QuizService.saveSectionQuiz(sectionId, {'title': 'Temporary Quiz'});
      expect(await QuizService.hasSectionQuiz(sectionId), true);

      await QuizService.deleteSectionQuiz(sectionId);
      expect(await QuizService.hasSectionQuiz(sectionId), false);
    });

    test('Section quiz passed status can be persisted and verified', () async {
      const sectionId = 'sec-passed-123';
      expect(await QuizService.isSectionQuizPassed(sectionId), false);

      await QuizService.setSectionQuizPassed(sectionId, true);
      expect(await QuizService.isSectionQuizPassed(sectionId), true);
    });
  });
}
