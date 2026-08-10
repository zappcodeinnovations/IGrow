import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../home_farmer/providers/student_provider.dart';

class QuizPlayerScreen extends ConsumerStatefulWidget {
  const QuizPlayerScreen({super.key, required this.sectionId});

  final String sectionId;

  @override
  ConsumerState<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends ConsumerState<QuizPlayerScreen> {
  final Map<String, String> _answers = {};
  bool _isSubmitting = false;
  Map<String, dynamic>? _results;

  Future<void> _submitQuiz(String quizId) async {
    setState(() => _isSubmitting = true);
    try {
      final results = await ref.read(studentRepositoryProvider).submitQuiz(quizId, _answers);
      setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(sectionQuizProvider(widget.sectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: quizAsync.when(
        data: (quiz) {
          if (quiz == null || quiz.isEmpty) {
            return const Center(child: Text('No quiz available for this section.'));
          }

          if (_results != null) {
            // Show Results
            final score = _results!['score'] ?? 0;
            final total = _results!['total_questions'] ?? 0;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
                  const SizedBox(height: 16),
                  Text('Quiz Completed!', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Score: $score / $total', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Course'),
                  ),
                ],
              ),
            );
          }

          final quizId = quiz['id']?.toString() ?? '';
          final title = quiz['title'] ?? 'Quiz';
          final description = quiz['description'] ?? '';
          final questions = quiz['questions'] as List? ?? [];

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: AppColors.primaryGreen.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(description, style: Theme.of(context).textTheme.bodyMedium),
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
                    final questionId = q['id'].toString();
                    final options = q['options'] as List? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${q['question_text'] ?? ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            ...options.map((option) {
                              final optionText = option.toString();
                              return RadioListTile<String>(
                                title: Text(optionText),
                                value: optionText,
                                groupValue: _answers[questionId],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _answers[questionId] = val);
                                  }
                                },
                                activeColor: AppColors.primaryGreen,
                                contentPadding: EdgeInsets.zero,
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submitQuiz(quizId),
                      child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit Quiz'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading quiz: $err')),
      ),
    );
  }
}
