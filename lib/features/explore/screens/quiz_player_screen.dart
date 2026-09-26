import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/quiz_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home_farmer/providers/student_provider.dart';

class QuizPlayerScreen extends ConsumerStatefulWidget {
  const QuizPlayerScreen({super.key, required this.sectionId});

  final String sectionId;

  @override
  ConsumerState<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends ConsumerState<QuizPlayerScreen> {
  final Map<String, int> _answers = {};
  bool _isSubmitting = false;
  Map<String, dynamic>? _results;
  bool _showReview = false;

  Future<void> _submitQuiz(String quizId, Map<String, dynamic> quizData) async {
    final questions = quizData['questions'] as List? ?? [];
    if (questions.isNotEmpty && _answers.length < questions.length) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unanswered Questions'),
          content: Text(
            'You have answered ${_answers.length} of ${questions.length} questions. Are you sure you want to submit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continue Quiz'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit Anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isSubmitting = true);
    try {
      final results = await ref.read(studentRepositoryProvider).submitQuiz(
        quizId,
        _answers,
        localQuizData: quizData,
      );
      setState(() => _results = results);

      final isPassed = results['passed'] == true || results['is_passed'] == true;
      if (isPassed) {
        await QuizService.setSectionQuizPassed(widget.sectionId, true);
        ref.invalidate(sectionQuizPassedProvider(widget.sectionId));
      }

      // Record in Quiz History for the farmer/student panel
      final title = quizData['title']?.toString() ?? 'Section Quiz';
      final scoreVal = results['score'] ?? 0;
      final totalVal = results['total_questions'] ?? questions.length;
      final numScore = scoreVal is num ? scoreVal.round() : (int.tryParse(scoreVal.toString()) ?? 0);
      final numTotal = totalVal is num ? totalVal.round() : (int.tryParse(totalVal.toString()) ?? questions.length);

      final scoreDisplay = scoreVal is num
          ? '${scoreVal.toStringAsFixed(1).replaceAll('.0', '')}%'
          : '$numScore / $numTotal';

      await QuizService.recordQuizCompletion(
        topic: title,
        scoreText: scoreDisplay,
        score: numScore,
        total: numTotal,
      );
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(milliseconds: 1800),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _retakeQuiz() {
    setState(() {
      _answers.clear();
      _results = null;
      _showReview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(sectionQuizProvider(widget.sectionId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Section Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Quiz',
            onPressed: () => ref.invalidate(sectionQuizProvider(widget.sectionId)),
          ),
        ],
      ),
      body: quizAsync.when(
        data: (quiz) {
          if (quiz == null || quiz.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: AppColors.inkSoft.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No quiz available for this section yet.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The instructor will attach knowledge questions for this section soon.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                      child: const Text('Back to Course Player'),
                    ),
                  ],
                ),
              ),
            );
          }

          final quizId = quiz['id']?.toString() ?? 'quiz_${widget.sectionId}';
          final title = quiz['title']?.toString() ?? 'Section Quiz';
          final description = quiz['description']?.toString() ?? '';
          final questions = quiz['questions'] as List? ?? [];
          final passingPercent = (quiz['passing_score'] is num)
              ? (quiz['passing_score'] as num).round()
              : (quiz['passing_percent'] is num
                  ? (quiz['passing_percent'] as num).round()
                  : int.tryParse(quiz['passing_score']?.toString() ?? '') ??
                      int.tryParse(quiz['passing_percent']?.toString() ?? '') ?? 70);

          if (_results != null) {
            // Show Results Screen
            final isPassed = _results!['passed'] == true || _results!['is_passed'] == true;
            final rawScore = _results!['score'] ?? 0;
            final passingRequired = _results!['passing_score'] ?? _results!['passing_percentage'] ?? passingPercent;
            final backendMessage = _results!['message']?.toString();
            final scoreString = rawScore is num
                ? rawScore.toStringAsFixed(1).replaceAll('.0', '')
                : rawScore.toString();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Icon(
                    isPassed ? Icons.emoji_events_rounded : Icons.psychology_alt_rounded,
                    color: isPassed ? Colors.amber.shade700 : AppColors.accentOrange,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'Congratulations!' : 'Quiz Completed!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    backendMessage ??
                        (isPassed
                            ? 'You have successfully passed this section assessment!'
                            : 'Review the material and try again to improve your score.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : AppColors.inkSoft),
                  ),
                  const SizedBox(height: 24),

                  // Score Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPassed ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Score: $scoreString% • Passing: $passingRequired%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPassed
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPassed ? 'STATUS: PASSED ✅' : 'STATUS: NEEDS IMPROVEMENT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isPassed ? const Color(0xFF166534) : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Minimum Passing Score: $passingRequired%',
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey.shade400 : AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Review Answers Toggle
                  TextButton.icon(
                    onPressed: () => setState(() => _showReview = !_showReview),
                    icon: Icon(_showReview ? Icons.visibility_off : Icons.visibility, size: 18),
                    label: Text(_showReview ? 'Hide Answer Review' : 'Review Questions & Answers'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                  ),

                  if (_showReview) ...[
                    const SizedBox(height: 12),
                    ...questions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final q = entry.value as Map<String, dynamic>;
                      final qId = q['id']?.toString() ?? 'q_${idx + 1}';
                      final questionText = q['question_text'] ?? q['question'] ?? 'Question ${idx + 1}';
                      final options = (q['options'] as List? ?? []).map((e) => e.toString()).toList();

                      final backendResults = (_results!['results'] as List?)
                              ?.whereType<Map<String, dynamic>>()
                              .toList() ??
                          [];
                      final backendItem = backendResults.firstWhere(
                        (r) => r['question_id']?.toString() == qId,
                        orElse: () => <String, dynamic>{},
                      );

                      final userIndex = _answers[qId];
                      final userAnswerText = (userIndex != null && userIndex >= 0 && userIndex < options.length)
                          ? options[userIndex]
                          : 'Not answered';

                      bool isCorrect = false;
                      String correctAnswerText = '';

                      if (backendItem.isNotEmpty) {
                        isCorrect = backendItem['correct'] == true;
                        final correctIdx = backendItem['correct_answer'] as int?;
                        if (correctIdx != null && correctIdx >= 0 && correctIdx < options.length) {
                          correctAnswerText = options[correctIdx];
                        }
                      } else {
                        final correctIdx = q['correct_option_index'] as int? ?? 0;
                        isCorrect = userIndex == correctIdx;
                        if (correctIdx >= 0 && correctIdx < options.length) {
                          correctAnswerText = options[correctIdx];
                        } else if (q['correct_answer'] != null) {
                          correctAnswerText = q['correct_answer'].toString();
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.bgDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${idx + 1}. $questionText',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your answer: $userAnswerText',
                              style: TextStyle(
                                fontSize: 12,
                                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                            if (!isCorrect && correctAnswerText.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Correct answer: $correctAnswerText',
                                style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _retakeQuiz,
                          child: const Text('Retake Quiz'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => context.pop(),
                          child: const Text('Back to Course'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Taking the Quiz
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passing Score: $passingPercent% • ${questions.length} Questions',
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(description, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index] as Map<String, dynamic>;
                    final questionId = q['id']?.toString() ?? 'q_${index + 1}';
                    final questionText = q['question_text'] ?? q['question'] ?? 'Question ${index + 1}';
                    final options = (q['options'] as List? ?? []).map((e) => e.toString()).toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark ? AppColors.lineDark : Colors.grey.shade300,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. $questionText',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            ...options.asMap().entries.map((optEntry) {
                              final optIndex = optEntry.key;
                              final optionText = optEntry.value.toString();
                              final isSelected = _answers[questionId] == optIndex;

                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() => _answers[questionId] = optIndex);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryGreen.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : (isDark ? AppColors.lineDark : Colors.grey.shade200),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: isSelected
                                            ? AppColors.primaryGreen
                                            : AppColors.inkSoft,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          optionText,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            color: isSelected ? AppColors.primaryGreen : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSubmitting ? null : () => _submitQuiz(quizId, quiz),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Submit Quiz (${_answers.length}/${questions.length} answered)'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error loading quiz'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(sectionQuizProvider(widget.sectionId)),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
