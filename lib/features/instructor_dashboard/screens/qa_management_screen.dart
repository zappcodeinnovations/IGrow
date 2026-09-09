import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

class QaManagementScreen extends ConsumerStatefulWidget {
  const QaManagementScreen({super.key});

  @override
  ConsumerState<QaManagementScreen> createState() => _QaManagementScreenState();
}

class _QaManagementScreenState extends ConsumerState<QaManagementScreen> {
  final Map<String, TextEditingController> _answerControllers = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitAnswer(String questionId) async {
    final controller = _answerControllers[questionId];
    if (controller == null || controller.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(instructorRepositoryProvider);
      await repo.answerQuestion(questionId, controller.text.trim());

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Answer submitted successfully!'),
            duration: Duration(milliseconds: 1800),
          ),
        );
        controller.clear();
        ref.invalidate(instructorQaProvider);
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to submit answer: $e'),
            duration: const Duration(milliseconds: 1800),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qaState = ref.watch(instructorQaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Q&A'),
      ),
      body: qaState.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text(
                'No pending questions. Great job!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(instructorQaProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final q = questions[index];
                final qId = q['id']?.toString() ?? '';
                final courseName = q['course_title'] ?? 'Course';
                final studentName = q['student_name'] ?? 'Student';
                final questionText = q['question'] ?? 'No text';
                final isAnswered = q['is_answered'] == true;

                if (!_answerControllers.containsKey(qId)) {
                  _answerControllers[qId] = TextEditingController();
                }

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.skyBlue.withOpacity(0.2),
                            child: const Icon(Icons.person, size: 16, color: AppColors.skyBlue),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(studentName, style: Theme.of(context).textTheme.titleSmall),
                                Text(courseName, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkSoft)),
                              ],
                            ),
                          ),
                          if (isAnswered)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Answered', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Question
                      Text(
                        'Q: $questionText',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      // Answer Field (if not answered)
                      if (!isAnswered) ...[
                        TextField(
                          controller: _answerControllers[qId],
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Type your answer here...',
                            hintStyle: TextStyle(color: AppColors.inkSoft),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.lineLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.lineLight),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.bgDark 
                              : AppColors.bgLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 120,
                            child: AppButton(
                              label: 'Reply',
                              onPressed: _isSubmitting ? null : () => _submitAnswer(qId),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Already answered state
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lineLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'A: ${q['answer'] ?? ''}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => const ShimmerListTile(),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading questions: $err'),
        ),
      ),
    );
  }
}
