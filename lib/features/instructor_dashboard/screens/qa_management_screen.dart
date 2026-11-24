import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

class QaManagementScreen extends ConsumerStatefulWidget {
  const QaManagementScreen({super.key});

  @override
  ConsumerState<QaManagementScreen> createState() => _QaManagementScreenState();
}

class _QaManagementScreenState extends ConsumerState<QaManagementScreen> {
  String _selectedStatus = 'UNRESOLVED'; // 'UNRESOLVED' | 'RESOLVED' | 'ALL'
  String _selectedCourseId = 'ALL';

  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, bool> _openReplyBoxes = {};
  final Map<String, bool> _submittingMap = {};

  String? _editingAnswerId;
  final TextEditingController _editAnswerController = TextEditingController();

  @override
  void dispose() {
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _editAnswerController.dispose();
    super.dispose();
  }

  String _getRelativeTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  InstructorQaQuery get _currentQuery => (
        status: _selectedStatus,
        courseId: _selectedCourseId,
      );

  Future<void> _submitAnswer(String questionId) async {
    final controller = _replyControllers[questionId];
    final text = controller?.text.trim() ?? '';
    if (text.isEmpty) return;

    setState(() => _submittingMap[questionId] = true);
    try {
      final repo = ref.read(instructorRepositoryProvider);
      await repo.answerQuestion(questionId, text);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Answer posted successfully!'),
            duration: Duration(milliseconds: 1800),
          ),
        );
        controller?.clear();
        setState(() {
          _openReplyBoxes[questionId] = false;
        });
        ref.invalidate(instructorQaFilteredProvider(_currentQuery));
        ref.invalidate(instructorQaProvider);
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to submit answer: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submittingMap[questionId] = false);
    }
  }

  Future<void> _saveEditAnswer(String answerId) async {
    final text = _editAnswerController.text.trim();
    if (text.isEmpty) return;

    try {
      final repo = ref.read(instructorRepositoryProvider);
      await repo.updateInstructorAnswer(answerId, text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply updated!')),
        );
        setState(() {
          _editingAnswerId = null;
          _editAnswerController.clear();
        });
        ref.invalidate(instructorQaFilteredProvider(_currentQuery));
        ref.invalidate(instructorQaProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update reply: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAnswer(String answerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(instructorRepositoryProvider);
      await repo.deleteInstructorAnswer(answerId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply deleted')),
        );
        ref.invalidate(instructorQaFilteredProvider(_currentQuery));
        ref.invalidate(instructorQaProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete reply: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.instructorHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qaState = ref.watch(instructorQaFilteredProvider(_currentQuery));
    final coursesAsync = ref.watch(instructorCoursesProvider((search: '', ordering: '')));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
        appBar: AppBar(
          title: Text(
            tr(ref, 'Q&A Forum'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.editorialOnSurface,
            ),
          ),
          backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.editorialOnSurface,
            ),
            onPressed: () => _handleBack(context),
          ),
        ),
      body: Column(
        children: [
          // Filter Toolbar (Matching Web InstructorQA)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Status Filter Pills
                Row(
                  children: [
                    _buildFilterPill('UNRESOLVED', 'Unresolved', isDark),
                    const SizedBox(width: 8),
                    _buildFilterPill('RESOLVED', 'Resolved', isDark),
                    const SizedBox(width: 8),
                    _buildFilterPill('ALL', 'All Questions', isDark),
                  ],
                ),
                const SizedBox(height: 8),
                // Course Dropdown Selector
                coursesAsync.when(
                  data: (coursesList) {
                    if (coursesList.isEmpty) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCourseId,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text('All Courses (${coursesList.length})'),
                            ),
                            ...coursesList.map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCourseId = val);
                            }
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),

          // Question Feed
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async {
                ref.invalidate(instructorQaFilteredProvider(_currentQuery));
                ref.invalidate(instructorQaProvider);
              },
              child: qaState.when(
                data: (questions) {
                  if (questions.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : AppColors.editorialSurfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.forum_outlined,
                                    size: 32,
                                    color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedStatus == 'UNRESOLVED'
                                      ? 'No Unresolved Questions'
                                      : 'No Questions Found',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _selectedStatus == 'UNRESOLVED'
                                      ? 'Great job! You have answered all student questions.'
                                      : 'Questions asked by learners in your courses will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      final qId = q['id']?.toString() ?? '';
                      final courseName = q['course_title'] ?? 'Course';
                      final lectureTitle = q['lecture_title']?.toString() ?? '';
                      final studentName = q['user_name'] ?? q['student_name'] ?? 'Student';
                      final questionText = q['question_text'] ?? q['question'] ?? '';
                      final createdAt = _getRelativeTime(q['created_at']?.toString());
                      final answersRaw = q['answers'];
                      final answers = (answersRaw is List)
                          ? answersRaw.whereType<Map<String, dynamic>>().toList()
                          : <Map<String, dynamic>>[];
                      final isResolved = q['is_resolved'] == true || answers.isNotEmpty;

                      if (!_replyControllers.containsKey(qId)) {
                        _replyControllers[qId] = TextEditingController();
                      }

                      final isReplying = _openReplyBoxes[qId] == true;
                      final isSubmitting = _submittingMap[qId] == true;

                      return AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                                  child: Text(
                                    studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$createdAt • $courseName${lectureTitle.isNotEmpty ? ' ($lectureTitle)' : ''}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isResolved
                                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                        : const Color(0xFFEF4444).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isResolved ? 'Resolved' : 'Needs Answer',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isResolved ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Question Content
                            Text(
                              questionText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Answers list (if any)
                            if (answers.isNotEmpty) ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black12 : AppColors.editorialSurfaceContainerLow.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: answers.map((ans) {
                                    final ansId = ans['id']?.toString() ?? '';
                                    final ansUser = ans['user_name'] ?? (ans['is_instructor_answer'] == true ? 'Instructor' : 'Student');
                                    final ansText = ans['answer_text']?.toString() ?? '';
                                    final ansTime = _getRelativeTime(ans['created_at']?.toString());
                                    final isInstructor = ans['is_instructor_answer'] == true;
                                    final isEditingThis = _editingAnswerId == ansId;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isInstructor
                                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5))
                                            : (isDark ? AppColors.cardDark : Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isInstructor
                                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                              : (isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.2)),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ansUser,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                                    ),
                                                  ),
                                                  if (isInstructor) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primaryGreen,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text(
                                                        'Guide',
                                                        style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '• $ansTime',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (isInstructor)
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _editingAnswerId = ansId;
                                                          _editAnswerController.text = ansText;
                                                        });
                                                      },
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4),
                                                        child: Icon(Icons.edit_outlined, size: 15, color: Colors.grey),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    InkWell(
                                                      onTap: () => _deleteAnswer(ansId),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4),
                                                        child: Icon(Icons.delete_outline_rounded, size: 15, color: Colors.redAccent),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          if (isEditingThis) ...[
                                            TextField(
                                              controller: _editAnswerController,
                                              maxLines: 2,
                                              style: const TextStyle(fontSize: 12.5),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () => setState(() => _editingAnswerId = null),
                                                  child: const Text('Cancel', style: TextStyle(fontSize: 11)),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primaryGreen,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  ),
                                                  onPressed: () => _saveEditAnswer(ansId),
                                                  child: const Text('Save', style: TextStyle(fontSize: 11)),
                                                ),
                                              ],
                                            ),
                                          ] else ...[
                                            Text(
                                              ansText,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: isDark ? Colors.white70 : AppColors.editorialOnSurface,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Reply bar / Toggle
                            if (!isReplying) ...[
                              InkWell(
                                onTap: () => setState(() => _openReplyBoxes[qId] = true),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.reply_rounded, size: 16, color: AppColors.primaryGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        tr(ref, 'Type a reply...'),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              TextField(
                                controller: _replyControllers[qId],
                                maxLines: 3,
                                minLines: 2,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                  fontSize: 13.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: tr(ref, 'Type your answer here...'),
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryGreen,
                                      width: 1.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF162319) : Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: BorderSide(
                                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                                      ),
                                    ),
                                    onPressed: isSubmitting
                                        ? null
                                        : () => setState(() => _openReplyBoxes[qId] = false),
                                    child: Text(
                                      tr(ref, 'Cancel'),
                                      style: TextStyle(
                                        color: isDark ? Colors.grey.shade300 : AppColors.editorialOnSurface,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: isSubmitting ? null : () => _submitAnswer(qId),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            tr(ref, 'Post Answer'),
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, __) => const ShimmerListTile(),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          'Failed to load Q&A: $err',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppColors.inkSoft,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(instructorQaFilteredProvider(_currentQuery)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildFilterPill(String status, String label, bool isDark) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryGreen
                  : (isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          child: Text(
            tr(ref, label),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.editorialOnSurface),
            ),
          ),
        ),
      ),
    );
  }
}
