import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart'
    show CertificateTemplate;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../core/services/quiz_service.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

/// Module 1: Instructor Course Management (Curriculum Builder)
/// Full curriculum builder matching Agrilearn webapp (CourseManager.jsx):
/// - 3 Tabs: Curriculum, Certificates, Course Settings
/// - Real-time AI moderation status with auto-polling & locked read-only state
/// - Section & Lecture CRUD with Bunny Stream video & PDF study material uploads
/// - Pull-to-refresh & responsive state management
/// - Comprehensive emoji-tagged console logging
class ManageCourseScreen extends ConsumerStatefulWidget {
  const ManageCourseScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<ManageCourseScreen> createState() => _ManageCourseScreenState();
}

class _ManageCourseScreenState extends ConsumerState<ManageCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  Timer? _pollingTimer;

  // Track expanded state for sections so UI doesn't collapse on every refresh
  final Map<String, bool> _sectionExpanded = {};

  // Track quizzes configured per section
  final Map<String, _ManageQuizData> _sectionQuizzes = {};
  bool _quizzesChecked = false;

  Future<void> _checkAndLoadSectionQuizzes(List<ApiCourseSection> sections) async {
    if (_quizzesChecked) return;
    _quizzesChecked = true;
    for (final section in sections) {
      if (!_sectionQuizzes.containsKey(section.id)) {
        final saved = await QuizService.getSectionQuiz(section.id);
        if (saved != null && mounted) {
          final questionsRaw = saved['questions'] as List? ?? [];
          final loadedQuestions = questionsRaw.map((q) {
            final opts = (q['options'] as List? ?? []).map((e) => e.toString()).toList();
            return _ManageQuizQuestion(
              question: q['question_text']?.toString() ?? q['question']?.toString() ?? 'Question',
              options: opts.isNotEmpty ? opts : ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
              correctOptionIndex: q['correct_option_index'] as int? ?? 0,
            );
          }).toList();

          setState(() {
            _sectionQuizzes[section.id] = _ManageQuizData(
              quizTitle: saved['title']?.toString() ?? 'Module Quiz',
              quizPassingPercent: saved['passing_percent'] as int? ?? 70,
              questions: loadedQuestions,
            );
          });
        }
      }
    }
  }

  // Settings form
  final TextEditingController _settingsTitleController = TextEditingController();
  final TextEditingController _settingsPriceController = TextEditingController();
  bool _settingsInitialized = false;
  bool _isSavingSettings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    debugPrint('📚 [CURRICULUM BUILDER] Screen initialized: courseId=${widget.courseId}');
  }

  @override
  void dispose() {
    _stopPollingTimer();
    _tabController.dispose();
    _settingsTitleController.dispose();
    _settingsPriceController.dispose();
    _loadingDialogMessage.dispose();
    debugPrint('📚 [CURRICULUM BUILDER] Screen disposed: courseId=${widget.courseId}');
    super.dispose();
  }

  // ── Auto Polling for AI Moderation ──────────────────────────────────────────

  void _managePolling(String status) {
    if (status == 'PROCESSING') {
      if (_pollingTimer == null || !_pollingTimer!.isActive) {
        debugPrint('⏳ [CURRICULUM BUILDER] Status is PROCESSING: Starting 8s auto-poll timer');
        _pollingTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
          debugPrint('🔄 [CURRICULUM BUILDER] Auto-polling course status...');
          ref.invalidate(instructorCourseDetailProvider(widget.courseId));
        });
      }
    } else {
      _stopPollingTimer();
    }
  }

  void _stopPollingTimer() {
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      debugPrint('⏹️ [CURRICULUM BUILDER] Canceling auto-poll timer');
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  // ── Error Message Parser ────────────────────────────────────────────────────

  String _extractErrorMessage(dynamic e) {
    final raw = e.toString();
    debugPrint('⚠️ [CURRICULUM BUILDER] Parsing error: $raw');

    if (raw.contains('Bunny Stream') || raw.contains('Failed to initialize video')) {
      return 'Video service notice: Bunny Stream CDN is currently inactive or under maintenance. You can attach video later via ⚙️ Settings.';
    }
    if (raw.contains('TimeoutException') || raw.contains('timed out')) {
      return 'Upload timed out. Please check your internet connection and try again.';
    }
    if (raw.contains('SocketException') || raw.contains('Network connection failed')) {
      return 'Network connection error. Please check your internet connection.';
    }
    if (raw.contains('413')) {
      return 'File size is too large for the server. Please select a smaller or compressed file.';
    }

    try {
      if (raw.contains('{') && raw.contains('}')) {
        final startIndex = raw.indexOf('{');
        final endIndex = raw.lastIndexOf('}') + 1;
        final jsonStr = raw.substring(startIndex, endIndex);
        final decoded = jsonDecode(jsonStr);

        if (decoded is Map<String, dynamic>) {
          if (decoded['error'] != null) {
            final errStr = decoded['error'].toString();
            if (errStr.contains('Bunny Stream') || errStr.contains('Failed to initialize video')) {
              return 'Video service notice: Bunny Stream CDN is currently inactive or under maintenance. You can attach video later via ⚙️ Settings.';
            }
            return errStr;
          }
          if (decoded['detail'] != null) return decoded['detail'].toString();
          if (decoded['message'] != null) return decoded['message'].toString();
          if (decoded['non_field_errors'] is List) {
            return (decoded['non_field_errors'] as List).join(' ');
          }
          final values = decoded.values.map((v) => v is List ? v.join(' ') : v.toString()).toList();
          if (values.isNotEmpty) return values.join(' ');
        }
      }
    } catch (_) {}

    return raw.replaceAll('Exception:', '').replaceAll('Failed to', 'Unable to').trim();
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(milliseconds: isError ? 4000 : 2500),
      ),
    );
  }

  BuildContext? _loadingDialogContext;
  final ValueNotifier<String> _loadingDialogMessage = ValueNotifier<String>('');

  void _showLoadingDialog(String message, {VoidCallback? onCancel}) {
    _dismissLoadingDialog();
    _loadingDialogMessage.value = message;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogCtx) {
        _loadingDialogContext = dialogCtx;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: _loadingDialogMessage,
                          builder: (context, msg, _) => Text(
                            msg,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (onCancel != null) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          _dismissLoadingDialog();
                          onCancel();
                        },
                        icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                        label: const Text(
                          'Cancel / Finish Later',
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateLoadingMessage(String message) {
    _loadingDialogMessage.value = message;
  }

  void _dismissLoadingDialog() {
    if (_loadingDialogContext != null && _loadingDialogContext!.mounted) {
      Navigator.of(_loadingDialogContext!).pop();
      _loadingDialogContext = null;
    }
  }

  // ── Section Actions ─────────────────────────────────────────────────────────

  Future<void> _addSection(BuildContext parentContext, int currentSectionCount) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final res = await showDialog<bool>(
      context: parentContext,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Section', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g., Introduction to Soil Science',
                labelText: 'Section Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Brief summary of what this section covers',
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                _showFeedback('Section title is required.', isError: true);
                return;
              }
              Navigator.pop(c, true);
            },
            child: const Text('Add Section'),
          ),
        ],
      ),
    );

    if (res == true && titleController.text.trim().isNotEmpty) {
      debugPrint('➕ [CURRICULUM BUILDER] Adding section: title="${titleController.text.trim()}"');
      _showLoadingDialog('Adding section...');
      try {
        await ref.read(instructorRepositoryProvider).createSection(widget.courseId, {
          'title': titleController.text.trim(),
          'description': descController.text.trim(),
          'sort_order': currentSectionCount + 1,
        });
        if (!mounted) return;
        _dismissLoadingDialog(); // Close loading dialog safely
        _showFeedback('Section added successfully!');
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      } catch (e) {
        if (!mounted) return;
        _dismissLoadingDialog(); // Close loading dialog safely
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Add section failed: $errorMsg');
        _showFeedback('Failed to add section: $errorMsg', isError: true);
      }
    }
  }

  Future<void> _editSection(BuildContext parentContext, ApiCourseSection section) async {
    final titleController = TextEditingController(text: section.title);
    final descController = TextEditingController(text: section.description ?? '');

    final res = await showDialog<bool>(
      context: parentContext,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Section', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Section Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                _showFeedback('Section title is required.', isError: true);
                return;
              }
              Navigator.pop(c, true);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );

    if (res == true && titleController.text.trim().isNotEmpty) {
      debugPrint('✏️ [CURRICULUM BUILDER] Editing section: id=${section.id}');
      _showLoadingDialog('Saving section changes...');
      try {
        await ref.read(instructorRepositoryProvider).updateSection(
          widget.courseId,
          section.id,
          {
            'title': titleController.text.trim(),
            'description': descController.text.trim(),
            'sort_order': section.sortOrder ?? 0,
          },
        );
        if (!mounted) return;
        _dismissLoadingDialog(); // Close loading dialog safely
        _showFeedback('Section updated successfully!');
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      } catch (e) {
        if (!mounted) return;
        _dismissLoadingDialog(); // Close loading dialog safely
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Edit section failed: $errorMsg');
        _showFeedback('Failed to update section: $errorMsg', isError: true);
      }
    }
  }

  Future<void> _deleteSection(BuildContext parentContext, String sectionId) async {
    final confirmed = await showDialog<bool>(
      context: parentContext,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Section', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this section? All lectures and uploaded materials inside this section will be permanently deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      debugPrint('🗑️ [CURRICULUM BUILDER] Deleting section: id=$sectionId');
      _showLoadingDialog('Deleting section...');
      try {
        await ref.read(instructorRepositoryProvider).deleteSection(widget.courseId, sectionId);
        if (!mounted) return;
        _dismissLoadingDialog();
        _showFeedback('Section deleted successfully!');
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      } catch (e) {
        if (!mounted) return;
        _dismissLoadingDialog();
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Delete section failed: $errorMsg');
        _showFeedback('Failed to delete section: $errorMsg', isError: true);
      }
    }
  }

  // ── Lecture Actions & Bottom Sheet ──────────────────────────────────────────

  Future<void> _showLectureBottomSheet(
    BuildContext parentContext, {
    required String sectionId,
    ApiLecture? existingLecture,
  }) async {
    final isEditing = existingLecture != null;
    final titleController = TextEditingController(text: existingLecture?.title ?? '');
    final descController = TextEditingController(text: existingLecture?.description ?? '');
    final durationController = TextEditingController(
      text: existingLecture?.duration != null && existingLecture!.duration! > 0
          ? existingLecture.duration.toString()
          : '10',
    );
    bool isPreview = existingLecture?.isPreview ?? false;

    XFile? pickedVideo;
    String? pickedVideoSize;
    FilePickerResult? pickedResource;
    String? pickedResourceSize;

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GestureDetector(
              onTap: () => FocusScope.of(modalContext).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Lecture' : 'Add New Lecture',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Lecture Title *',
                        hintText: 'e.g., Understanding Soil pH & Nutrients',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Lecture Description (optional)',
                        hintText: 'Topics covered in this video lecture',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),

                    // Duration & Free Preview Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Duration (Minutes)',
                              suffixText: 'min',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Switch(
                                value: isPreview,
                                activeThumbColor: AppColors.primaryGreen,
                                onChanged: (val) => setModalState(() => isPreview = val),
                              ),
                              const Expanded(
                                child: Text(
                                  'Free Preview',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Video Upload Section
                    Text(
                      'Video Stream (Bunny Stream CDN)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isEditing && existingLecture.videoUrl != null && existingLecture.videoUrl!.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Active Video Attached (${existingLecture.bunnyStatus == 3 ? "Transcoded" : "Encoding / Ready"})',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          OutlinedButton.icon(
                            onPressed: () async {
                              FocusScope.of(modalContext).unfocus();
                              await Future.delayed(const Duration(milliseconds: 120));
                              final video = await _picker.pickVideo(source: ImageSource.gallery);
                              if (video != null) {
                                final length = await video.length();
                                final sizeMb = (length / (1024 * 1024)).toStringAsFixed(1);
                                setModalState(() {
                                  pickedVideo = video;
                                  pickedVideoSize = '$sizeMb MB';
                                });
                                debugPrint('🎬 [CURRICULUM BUILDER] Picked video: ${video.name} ($sizeMb MB), path=${video.path}');
                              }
                            },
                            icon: const Icon(Icons.video_collection_outlined),
                            label: Text(
                              pickedVideo != null
                                  ? 'Video Selected'
                                  : (isEditing && existingLecture.videoUrl != null && existingLecture.videoUrl!.isNotEmpty)
                                      ? 'Replace Video File'
                                      : 'Select Video from Gallery',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(color: AppColors.primaryGreen),
                            ),
                          ),
                          if (pickedVideo != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Selected: ${pickedVideo!.name} ($pickedVideoSize)',
                              style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Study Material (PDF / Document) Section
                    Text(
                      'Study Material (PDF, DOCX, XLSX)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isEditing && existingLecture.resources.isNotEmpty) ...[
                            ...existingLecture.resources.map(
                              (res) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf, color: AppColors.skyBlue, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        res.fileName,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          OutlinedButton.icon(
                            onPressed: () async {
                              FocusScope.of(modalContext).unfocus();
                              await Future.delayed(const Duration(milliseconds: 120));
                              final result = await FilePicker.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'docx', 'xlsx', 'doc', 'xls'],
                              );
                              if (result != null && result.files.single.path != null) {
                                final file = result.files.single;
                                final sizeStr = file.size > 1024 * 1024
                                    ? '${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB'
                                    : '${(file.size / 1024).toStringAsFixed(1)} KB';
                                setModalState(() {
                                  pickedResource = result;
                                  pickedResourceSize = sizeStr;
                                });
                                debugPrint('📄 [CURRICULUM BUILDER] Picked resource: ${file.name} ($sizeStr)');
                              }
                            },
                            icon: const Icon(Icons.attach_file),
                            label: Text(
                              pickedResource != null ? 'Resource Attached' : 'Attach PDF / Document',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.skyBlue,
                              side: const BorderSide(color: AppColors.skyBlue),
                            ),
                          ),
                          if (pickedResource != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Selected: ${pickedResource!.files.single.name} ($pickedResourceSize)',
                              style: const TextStyle(fontSize: 12, color: AppColors.skyBlue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            _showFeedback('Lecture title is required.', isError: true);
                            return;
                          }

                          final duration = int.tryParse(durationController.text.trim()) ?? 10;
                          Navigator.pop(modalContext); // Close sheet

                          _saveLectureWithMedia(
                            sectionId: sectionId,
                            existingLecture: existingLecture,
                            title: title,
                            description: descController.text.trim(),
                            duration: duration,
                            isPreview: isPreview,
                            pickedVideo: pickedVideo,
                            pickedResource: pickedResource,
                          );
                        },
                        child: Text(
                          isEditing ? 'Save Lecture Updates' : 'Add Lecture',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
  }

  Future<void> _saveLectureWithMedia({
    required String sectionId,
    ApiLecture? existingLecture,
    required String title,
    required String description,
    required int duration,
    required bool isPreview,
    XFile? pickedVideo,
    FilePickerResult? pickedResource,
  }) async {
    final isEditing = existingLecture != null;
    String? lectureId = existingLecture?.id;
    String? videoError;
    String? resourceError;
    bool videoUploaded = false;
    bool resourceUploaded = false;
    bool isCancelled = false;
    bool isNetworkChoked = false;
    final cancelableClient = http.Client();

    _showLoadingDialog(
      isEditing ? 'Updating lecture details...' : 'Creating lecture details...',
      onCancel: () {
        debugPrint('⏹️ [CURRICULUM BUILDER] User canceled upload');
        isCancelled = true;
        cancelableClient.close();
      },
    );

    try {
      // Step 1: Create or Update lecture basic details
      if (!isEditing) {
        debugPrint('➕ [CURRICULUM BUILDER] Creating lecture: title="$title", sectionId=$sectionId');
        final res = await ref.read(instructorRepositoryProvider).createLecture(
          widget.courseId,
          sectionId,
          {
            'title': title,
            'description': description,
            'duration': duration,
            'sort_order': 99,
            'is_preview': isPreview,
          },
        );
        lectureId = res['id']?.toString();
      } else {
        debugPrint('✏️ [CURRICULUM BUILDER] Updating lecture: id=$lectureId');
        await ref.read(instructorRepositoryProvider).updateLecture(
          widget.courseId,
          sectionId,
          lectureId!,
          {
            'title': title,
            'description': description,
            'duration': duration,
            'is_preview': isPreview,
          },
        );
      }

      if (lectureId == null || lectureId.isEmpty) {
        throw Exception('Server did not return a valid lecture ID.');
      }

      // Step 2: Upload Video if selected
      if (pickedVideo != null && !isCancelled) {
        debugPrint('📤 [CURRICULUM BUILDER] Uploading video for lecture: $lectureId');
        _updateLoadingMessage('Uploading video to Bunny Stream CDN... (Please wait)');
        try {
          await ref.read(instructorRepositoryProvider).uploadVideo(
            lectureId,
            pickedVideo.path,
            timeout: const Duration(minutes: 5),
            client: cancelableClient,
          );
          videoUploaded = true;
          debugPrint('✅ [CURRICULUM BUILDER] Video uploaded successfully!');
        } catch (vErr) {
          if (isCancelled) return;
          videoError = _extractErrorMessage(vErr);
          debugPrint('❌ [CURRICULUM BUILDER] Video upload error: $videoError');
          if (vErr is TimeoutException ||
              vErr.toString().contains('timed out') ||
              vErr.toString().contains('SocketException') ||
              vErr.toString().contains('Network connection failed')) {
            isNetworkChoked = true;
          }
        }
      }

      // Step 3: Upload Study Material if selected AND network is not choked
      if (pickedResource != null &&
          pickedResource.files.single.path != null &&
          !isCancelled &&
          !isNetworkChoked) {
        final fileName = pickedResource.files.single.name;
        debugPrint('📄 [CURRICULUM BUILDER] Uploading resource for lecture: $lectureId');
        _updateLoadingMessage('Uploading study material ($fileName)...');
        try {
          await ref.read(instructorRepositoryProvider).uploadResource(
            lectureId,
            pickedResource.files.single.path!,
            fileName: fileName,
            timeout: const Duration(seconds: 30),
            client: cancelableClient,
          );
          resourceUploaded = true;
          debugPrint('✅ [CURRICULUM BUILDER] Study material uploaded successfully!');
        } catch (rErr) {
          if (isCancelled) return;
          resourceError = _extractErrorMessage(rErr);
          debugPrint('❌ [CURRICULUM BUILDER] Resource upload error: $resourceError');
        }
      }
    } catch (e) {
      if (!isCancelled) {
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Lecture save failed: $errorMsg');
        _dismissLoadingDialog();
        if (mounted) {
          _showFeedback('Failed to save lecture: $errorMsg', isError: true);
        }
      }
      return;
    } finally {
      // GUARANTEE: Loader will always dismiss and never stay stuck!
      _dismissLoadingDialog();
      cancelableClient.close();
    }

    if (!mounted) return;

    // Refresh course data
    ref.invalidate(instructorCourseDetailProvider(widget.courseId));

    if (isCancelled) {
      _showFeedback('Upload canceled. Lecture was created; you can attach media later from ⚙️ Settings.');
      return;
    }

    // Show single, consolidated, user-friendly outcome summary
    if (isNetworkChoked) {
      _showFeedback(
        'Lecture saved, but upload timed out due to slow network. You can re-upload video anytime via ⚙️ Settings.',
        isError: true,
      );
    } else if (videoError != null && resourceError != null) {
      _showFeedback(
        'Lecture saved, but media uploads failed. You can re-attach them anytime via ⚙️ Settings.',
        isError: true,
      );
    } else if (videoError != null) {
      _showFeedback(
        'Lecture saved! Video notice: $videoError',
        isError: true,
      );
    } else if (resourceError != null) {
      _showFeedback(
        'Lecture saved! Study material note: $resourceError',
        isError: true,
      );
    } else {
      final buffer = StringBuffer();
      buffer.write(isEditing ? 'Lecture updated successfully!' : 'Lecture created successfully!');
      if (videoUploaded && resourceUploaded) {
        buffer.write(' (Video & study material attached)');
      } else if (videoUploaded) {
        buffer.write(' (Video attached)');
      } else if (resourceUploaded) {
        buffer.write(' (Study material attached)');
      }
      _showFeedback(buffer.toString());
    }
  }

  Future<void> _deleteLecture(BuildContext parentContext, String sectionId, String lectureId) async {
    final confirmed = await showDialog<bool>(
      context: parentContext,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lecture', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this lecture? Any video streams and study materials will be removed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      debugPrint('🗑️ [CURRICULUM BUILDER] Deleting lecture: id=$lectureId, sectionId=$sectionId');
      _showLoadingDialog('Deleting lecture...');
      try {
        await ref.read(instructorRepositoryProvider).deleteLecture(widget.courseId, sectionId, lectureId);
        if (!mounted) return;
        _dismissLoadingDialog();
        _showFeedback('Lecture deleted successfully!');
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      } catch (e) {
        if (!mounted) return;
        _dismissLoadingDialog();
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Delete lecture failed: $errorMsg');
        _showFeedback('Failed to delete lecture: $errorMsg', isError: true);
      }
    }
  }

  // ── Submit for Review Action ────────────────────────────────────────────────

  Future<void> _submitForReview(ApiCourseDetail course) async {
    if (course.sections.isEmpty) {
      _showFeedback('Please add at least one section before publishing.', isError: true);
      return;
    }

    final totalLectures = course.sections.fold<int>(0, (sum, s) => sum + s.lectures.length);
    if (totalLectures == 0) {
      _showFeedback('Please add at least one lecture before publishing.', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch, color: AppColors.primaryGreen),
            SizedBox(width: 10),
            Text('Submit for Review', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Your course will be submitted for automated AI safety review and administrator verification. Editing will be temporarily locked until the review completes.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Submit Now'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      debugPrint('🚀 [CURRICULUM BUILDER] Submitting course for AI review: id=${course.id}');
      _showLoadingDialog('Submitting course for AI review...');
      try {
        final res = await ref.read(instructorRepositoryProvider).publishCourse(course.id);
        if (!mounted) return;
        _dismissLoadingDialog(); // Close loading
        final message = res['message']?.toString() ?? 'Course submitted for AI review!';
        _showFeedback(message);
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      } catch (e) {
        if (!mounted) return;
        _dismissLoadingDialog(); // Close loading
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Submit for review failed: $errorMsg');
        _showFeedback(errorMsg, isError: true);
      }
    }
  }

  // ── Certificates Actions ────────────────────────────────────────────────────

  Future<void> _uploadCertificateTemplate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      debugPrint('🎓 [CURRICULUM BUILDER] Uploading certificate template: $filePath');
      _showLoadingDialog('Uploading certificate template...');
      try {
        await ref.read(instructorRepositoryProvider).uploadCertificateTemplate(
          widget.courseId,
          filePath,
        );
        if (!mounted) return;
        _dismissLoadingDialog();
        _showFeedback('Certificate template uploaded successfully!');
        ref.invalidate(instructorCourseCertificatesProvider(widget.courseId));
      } catch (e) {
        if (!mounted) return;
        _dismissLoadingDialog();
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Upload certificate failed: $errorMsg');
        _showFeedback('Failed to upload certificate: $errorMsg', isError: true);
      }
    }
  }

  Future<void> _deleteCertificateTemplate(String certId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Certificate Template', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this certificate template?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      debugPrint('🗑️ [CURRICULUM BUILDER] Deleting certificate template: $certId');
      _showLoadingDialog('Deleting certificate template...');
      try {
        await ref.read(instructorRepositoryProvider).deleteCertificate(widget.courseId, certId);
        if (!mounted) return;
        _dismissLoadingDialog();
        _showFeedback('Certificate template removed successfully.');
        ref.invalidate(instructorCourseCertificatesProvider(widget.courseId));
      } catch (e) {
        if (!mounted) return;
        _dismissLoadingDialog();
        final errorMsg = _extractErrorMessage(e);
        debugPrint('❌ [CURRICULUM BUILDER] Delete certificate failed: $errorMsg');
        _showFeedback('Failed to delete certificate: $errorMsg', isError: true);
      }
    }
  }

  // ── Settings Save Action ────────────────────────────────────────────────────

  Future<void> _saveSettings(ApiCourseDetail course) async {
    final title = _settingsTitleController.text.trim();
    final priceStr = _settingsPriceController.text.trim();

    if (title.isEmpty) {
      _showFeedback('Course title cannot be empty.', isError: true);
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null || price < 0) {
      _showFeedback('Price must be 0 or greater.', isError: true);
      return;
    }

    setState(() => _isSavingSettings = true);
    debugPrint('⚙️ [CURRICULUM BUILDER] Saving settings: title="$title", price=$price');

    try {
      FocusScope.of(context).unfocus();
      await ref.read(instructorRepositoryProvider).updateCourse(course.id, {
        'title': title,
        'price': priceStr,
      });
      _showFeedback('Course settings updated successfully!');
      ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      ref.invalidate(instructorCoursesProvider);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      debugPrint('❌ [CURRICULUM BUILDER] Save settings failed: $errorMsg');
      _showFeedback('Failed to update settings: $errorMsg', isError: true);
    } finally {
      if (mounted) setState(() => _isSavingSettings = false);
    }
  }

  // ── Build Method ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(instructorCourseDetailProvider(widget.courseId));

    // If we have course data, render it directly even during background reload
    final course = courseAsync.valueOrNull;
    if (course != null) {
      // Manage background polling based on status
      _managePolling(course.status ?? '');

      // Initialize settings once
      if (!_settingsInitialized) {
        _settingsTitleController.text = course.title;
        _settingsPriceController.text = course.price ?? '0';
        _settingsInitialized = true;
      }

      final isLocked = course.status == 'PROCESSING';

      return Scaffold(
        appBar: AppBar(
          title: Text(
            course.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Curriculum'),
              Tab(text: 'Certificates'),
              Tab(text: 'Settings'),
            ],
          ),
          actions: [
            if (course.status == 'APPROVED' || course.status == 'ACTIVE')
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: () => context.push('/course/${course.slug ?? course.id}'),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            if (!isLocked && (course.status == 'DRAFT' || course.status == 'REJECTED'))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _submitForReview(course),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('Submit for AI Review', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCurriculumTab(course, isLocked),
            _buildCertificatesTab(course, isLocked),
            _buildSettingsTab(course, isLocked),
          ],
        ),
        floatingActionButton: (!isLocked && _tabController.index == 0)
            ? FloatingActionButton.extended(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                onPressed: () => _addSection(context, course.sections.length),
                icon: const Icon(Icons.add),
                label: const Text('Add Section', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            : null,
      );
    }

    if (courseAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Course...')),
        body: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => const ShimmerListTile(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Course Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load course details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _extractErrorMessage(courseAsync.error),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                onPressed: () => ref.invalidate(instructorCourseDetailProvider(widget.courseId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Curriculum Tab ──────────────────────────────────────────────────────────

  Widget _buildCurriculumTab(ApiCourseDetail course, bool isLocked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        debugPrint('🔄 [CURRICULUM BUILDER] Manual pull-to-refresh triggered');
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Course Status & Summary Banner
          _buildStatusBanner(course),
          const SizedBox(height: 16),

          // Locked in AI Review Banner
          if (isLocked) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.warning.withValues(alpha: 0.12) : const Color(0xFFFFF8E1),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Moderation in Progress (Locked)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFFFB74D) : const Color(0xFF8A5B00),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Editing is disabled while our content safety engine reviews your course. This page automatically checks status and will refresh when the review completes.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Rejection Banner
          if (course.status == 'REJECTED') ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.error),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.report_problem, color: AppColors.error, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Content Moderation Flagged Issues: Some lectures require revision. Please update or replace the flagged videos, then re-submit for review.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Section Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sections & Lectures',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (!isLocked)
                TextButton.icon(
                  onPressed: () => _addSection(context, course.sections.length),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Section', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Restore saved quizzes from QuizService if any
          Builder(
            builder: (_) {
              _checkAndLoadSectionQuizzes(course.sections);
              return const SizedBox.shrink();
            },
          ),

          // Sections List
          if (course.sections.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.video_library_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No sections added yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Organize your curriculum into structured sections and attach video lectures & study materials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  if (!isLocked)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      onPressed: () => _addSection(context, 0),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Section'),
                    ),
                ],
              ),
            ),
          ] else ...[
            ...course.sections.asMap().entries.map((entry) {
              final sIdx = entry.key;
              final section = entry.value;
              return _buildSectionCard(section, sIdx + 1, isLocked);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ApiCourseDetail course) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (course.status) {
      case 'APPROVED':
        statusColor = AppColors.success;
        statusLabel = 'Approved & Live';
        statusIcon = Icons.check_circle;
        break;
      case 'PROCESSING':
        statusColor = AppColors.warning;
        statusLabel = 'AI Review in Progress';
        statusIcon = Icons.hourglass_top;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        statusLabel = 'Revision Required';
        statusIcon = Icons.cancel;
        break;
      case 'DRAFT':
      default:
        statusColor = Colors.grey.shade700;
        statusLabel = 'Draft';
        statusIcon = Icons.edit_note;
        break;
    }

    final totalLectures = course.sections.fold<int>(0, (sum, s) => sum + s.lectures.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  course.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildStatChip(Icons.folder_outlined, '${course.sections.length} Sections'),
              _buildStatChip(Icons.play_lesson_outlined, '$totalLectures Lectures'),
              if (course.price != null)
                _buildStatChip(Icons.currency_rupee, course.price == '0' || course.price == '0.00' ? 'Free' : '₹${course.price}'),
              if (course.status == 'APPROVED' || course.status == 'ACTIVE')
                InkWell(
                  onTap: () => context.push('/course/${course.slug ?? course.id}'),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_outlined, size: 13, color: AppColors.primaryGreen),
                        SizedBox(width: 4),
                        Text('View Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(ApiCourseSection section, int sectionIndex, bool isLocked) {
    final isExpanded = _sectionExpanded[section.id] ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          InkWell(
            borderRadius: BorderRadius.vertical(top: const Radius.circular(14), bottom: Radius.circular(isExpanded ? 0 : 14)),
            onTap: () {
              setState(() {
                _sectionExpanded[section.id] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                borderRadius: BorderRadius.vertical(top: const Radius.circular(14), bottom: Radius.circular(isExpanded ? 0 : 14)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'S$sectionIndex',
                      style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (section.description != null && section.description!.isNotEmpty)
                          Text(
                            section.description!,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${section.lectures.length} lec',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontWeight: FontWeight.w600),
                  ),
                  if (!isLocked) ...[
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey),
                      onSelected: (value) {
                        if (value == 'edit') _editSection(context, section);
                        if (value == 'delete') _deleteSection(context, section.id);
                        if (value == 'add_lecture') _showLectureBottomSheet(context, sectionId: section.id);
                      },
                      itemBuilder: (c) => [
                        const PopupMenuItem(value: 'add_lecture', child: Row(children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text('Add Lecture')])),
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit Section')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Delete Section', style: TextStyle(color: AppColors.error))])),
                      ],
                    ),
                  ],
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Section Content (Lectures)
          if (isExpanded) ...[
            Divider(height: 1, color: isDark ? AppColors.lineDark : Colors.grey.shade200),
            if (section.lectures.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'No lectures in this section yet.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      if (_sectionQuizzes[section.id] != null) ...[
                        const SizedBox(height: 12),
                        _buildSectionQuizCard(section.id, _sectionQuizzes[section.id]!, isLocked),
                      ],
                      if (!isLocked) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showLectureBottomSheet(context, sectionId: section.id),
                              icon: const Icon(Icons.add_circle_outline, size: 16),
                              label: const Text('Add Lecture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                            ),
                            if (_sectionQuizzes[section.id] == null) ...[
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: () => _showQuizBottomSheet(context, section.id),
                                icon: const Icon(Icons.quiz_outlined, size: 16, color: Color(0xFFD97706)),
                                label: const Text('+ Add Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFD97706))),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: section.lectures.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.lineDark : Colors.grey.shade100),
                itemBuilder: (context, lIdx) {
                  final lecture = section.lectures[lIdx];
                  return _buildLectureTile(section, lecture, lIdx + 1, isLocked);
                },
              ),
              if (_sectionQuizzes[section.id] != null) ...[
                _buildSectionQuizCard(section.id, _sectionQuizzes[section.id]!, isLocked),
              ],
              if (!isLocked) ...[
                Divider(height: 1, color: isDark ? AppColors.lineDark : Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => _showLectureBottomSheet(context, sectionId: section.id),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 16, color: AppColors.primaryGreen),
                              SizedBox(width: 4),
                              Text(
                                'Add Another Lecture',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_sectionQuizzes[section.id] == null) ...[
                        const SizedBox(width: 16),
                        Container(width: 1, height: 16, color: isDark ? AppColors.lineDark : Colors.grey.shade300),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () => _showQuizBottomSheet(context, section.id),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Row(
                              children: [
                                Icon(Icons.quiz_outlined, size: 16, color: Color(0xFFD97706)),
                                SizedBox(width: 4),
                                Text(
                                  '+ Add Quiz',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLectureTile(ApiCourseSection section, ApiLecture lecture, int lectureIndex, bool isLocked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasVideo = (lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty) ||
        (lecture.bunnyVideoId != null && lecture.bunnyVideoId!.isNotEmpty) ||
        (lecture.bunnyStatus != null && lecture.bunnyStatus! >= 1);
    final hasResources = lecture.resources.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Index Badge
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$lectureIndex',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Meta Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lecture.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lecture.isPreview)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.signalYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FREE',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB28700)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Video Status
                    Icon(
                      hasVideo ? Icons.play_circle_fill : Icons.videocam_off_outlined,
                      size: 13,
                      color: hasVideo ? AppColors.primaryGreen : AppColors.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasVideo ? 'Video Attached' : 'No Video',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: hasVideo ? AppColors.primaryGreen : AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Study Material Status
                    if (hasResources) ...[
                      const Icon(Icons.attach_file, size: 13, color: AppColors.skyBlue),
                      const SizedBox(width: 4),
                      Text(
                        '${lecture.resources.length} ${lecture.resources.length == 1 ? "File" : "Files"}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.skyBlue),
                      ),
                      const SizedBox(width: 10),
                    ],

                    // Duration
                    if (lecture.durationFormatted != null && lecture.durationFormatted!.isNotEmpty)
                      Text(
                        lecture.durationFormatted!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      )
                    else if (lecture.duration != null && lecture.duration! > 0)
                      Text(
                        '${lecture.duration} min',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (!isLocked) ...[
            IconButton(
              icon: const Icon(Icons.settings_outlined, size: 18, color: Colors.grey),
              tooltip: 'Edit Lecture & Attachments',
              onPressed: () => _showLectureBottomSheet(context, sectionId: section.id, existingLecture: lecture),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              tooltip: 'Delete Lecture',
              onPressed: () => _deleteLecture(context, section.id, lecture.id),
            ),
          ],
        ],
      ),
    );
  }

  // ── Certificates Tab ────────────────────────────────────────────────────────

  Widget _buildCertificatesTab(ApiCourseDetail course, bool isLocked) {
    final certificatesAsync = ref.watch(instructorCourseCertificatesProvider(widget.courseId));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Course Certificate Template',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Upload a certificate template that students will receive upon successfully completing this course. A certificate is recommended before publishing.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        certificatesAsync.when(
          data: (templates) {
            if (templates.isNotEmpty) {
              final dynamic template = templates.first;
              String certId = '';
              String title = 'Certificate of Completion';
              String createdAt = '';
              String? imageUrl;

              if (template is CertificateTemplate) {
                certId = template.id ?? '';
                title = (template.title != null && template.title!.isNotEmpty)
                    ? template.title!
                    : 'Certificate of Completion';
                createdAt = template.createdAt?.toIso8601String() ?? '';
                imageUrl = template.templateImage;
              } else if (template is Map) {
                certId = template['id']?.toString() ?? '';
                title = template['title']?.toString() ?? 'Certificate of Completion';
                createdAt = template['created_at']?.toString() ?? '';
                imageUrl = template['template_image']?.toString();
              } else {
                try {
                  certId = (template as dynamic).id?.toString() ?? '';
                  title = (template as dynamic).title?.toString() ?? 'Certificate of Completion';
                  createdAt = (template as dynamic).createdAt?.toString() ?? '';
                  imageUrl = (template as dynamic).templateImage?.toString();
                } catch (_) {}
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.05),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    if (imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        !imageUrl.toLowerCase().endsWith('.pdf'))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified, color: AppColors.primaryGreen, size: 26),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: AppColors.primaryGreen, size: 26),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (createdAt.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded: ${createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isLocked)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _deleteCertificateTemplate(certId),
                      ),
                  ],
                ),
              );
            }

            // No template uploaded yet
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.workspace_premium_outlined, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 14),
                  const Text(
                    'No Certificate Template Attached',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upload a PDF or high-resolution image template (Max 5MB).',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  if (!isLocked)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      onPressed: _uploadCertificateTemplate,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Template'),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          ),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ],
    );
  }

  // ── Settings Tab ────────────────────────────────────────────────────────────

  Widget _buildSettingsTab(ApiCourseDetail course, bool isLocked) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Course Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Update course title and pricing details.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _settingsTitleController,
          enabled: !isLocked,
          decoration: const InputDecoration(
            labelText: 'Course Title *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _settingsPriceController,
          enabled: !isLocked,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price (₹) *',
            prefixText: '₹ ',
            helperText: 'Enter 0 to make this course free for students.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),

        if (!isLocked)
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSavingSettings ? null : () => _saveSettings(course),
              icon: _isSavingSettings
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSavingSettings ? 'Saving Changes...' : 'Save Settings'),
            ),
          ),
      ],
    );
  }

  // ── Section Quiz Helpers & Bottom Sheet ──────────────────────────────────

  Widget _buildSectionQuizCard(String sectionId, _ManageQuizData quiz, bool isLocked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2E2413)
            : const Color(0xFFFEF3C7).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.military_tech_rounded, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quiz.quizTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${quiz.questions.length} Questions • Passing: ${quiz.quizPassingPercent}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.amber.shade200 : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          if (!isLocked) ...[
            TextButton(
              onPressed: () => _showQuizBottomSheet(context, sectionId),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remove Quiz',
              onPressed: () async {
                setState(() {
                  _sectionQuizzes.remove(sectionId);
                });
                await QuizService.deleteSectionQuiz(sectionId);
                _showFeedback('Quiz removed from section.');
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showQuizBottomSheet(BuildContext parentContext, String sectionId) {
    final existing = _sectionQuizzes[sectionId];
    final titleController = TextEditingController(text: existing?.quizTitle ?? 'Module Quiz');
    int passingPercent = existing?.quizPassingPercent ?? 70;
    final List<_ManageQuizQuestion> localQuestions = existing != null
        ? existing.questions
            .map((q) => _ManageQuizQuestion(
                  question: q.question,
                  options: List<String>.from(q.options),
                  correctOptionIndex: q.correctOptionIndex,
                ))
            .toList()
        : [
            _ManageQuizQuestion(
              question: 'Sample Question 1',
              options: ['Option A', 'Option B', 'Option C', 'Option D'],
              correctOptionIndex: 0,
            ),
          ];

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final isDark = Theme.of(modalCtx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.quiz_rounded, color: Color(0xFFD97706), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                existing != null ? 'Edit Section Quiz' : 'Add Section Quiz',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalCtx),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Body
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Quiz Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g., Chapter 1 Knowledge Assessment',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Passing Score
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Minimum Passing Score (%)',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$passingPercent%',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: passingPercent.toDouble(),
                                min: 40,
                                max: 100,
                                divisions: 12,
                                activeColor: AppColors.primaryGreen,
                                label: '$passingPercent%',
                                onChanged: (val) => setModalState(() => passingPercent = val.toInt()),
                              ),
                              const SizedBox(height: 20),

                              // Questions List
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quiz Questions (${localQuestions.length})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setModalState(() {
                                        localQuestions.add(
                                          _ManageQuizQuestion(
                                            question: 'Question ${localQuestions.length + 1}',
                                            options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
                                            correctOptionIndex: 0,
                                          ),
                                        );
                                      });
                                    },
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Question', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              ...localQuestions.asMap().entries.map((entry) {
                                final qIndex = entry.key;
                                final q = entry.value;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.2),
                                            child: Text(
                                              '${qIndex + 1}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: q.question,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter question text...',
                                                isDense: true,
                                                border: InputBorder.none,
                                              ),
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              onChanged: (val) => q.question = val,
                                            ),
                                          ),
                                          if (localQuestions.length > 1)
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                              onPressed: () => setModalState(() => localQuestions.removeAt(qIndex)),
                                            ),
                                        ],
                                      ),
                                      const Divider(),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Answer Choices (Select the correct option):',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 6),
                                      ...q.options.asMap().entries.map((optEntry) {
                                        final optIndex = optEntry.key;
                                        final isCorrect = q.correctOptionIndex == optIndex;

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: () => setModalState(() => q.correctOptionIndex = optIndex),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                                  child: Icon(
                                                    isCorrect ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                                    color: isCorrect ? AppColors.primaryGreen : Colors.grey,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: q.options[optIndex],
                                                  decoration: InputDecoration(
                                                    hintText: 'Option ${optIndex + 1}',
                                                    isDense: true,
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: BorderSide(
                                                        color: isCorrect ? AppColors.primaryGreen : Colors.grey.shade300,
                                                      ),
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                  onChanged: (val) => q.options[optIndex] = val,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      // Save Button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final quizData = _ManageQuizData(
                                quizTitle: titleController.text.trim().isNotEmpty
                                    ? titleController.text.trim()
                                    : 'Module Quiz',
                                quizPassingPercent: passingPercent,
                                questions: localQuestions,
                              );

                              setState(() {
                                _sectionQuizzes[sectionId] = quizData;
                              });

                              await QuizService.saveSectionQuiz(sectionId, {
                                'id': 'quiz_$sectionId',
                                'section_id': sectionId,
                                'title': quizData.quizTitle,
                                'passing_percent': quizData.quizPassingPercent,
                                'questions': localQuestions.asMap().entries.map((e) => {
                                  'id': 'q_${e.key + 1}',
                                  'question_text': e.value.question,
                                  'question': e.value.question,
                                  'options': e.value.options,
                                  'correct_option_index': e.value.correctOptionIndex,
                                  'correct_answer': e.value.options.isNotEmpty && e.value.correctOptionIndex < e.value.options.length
                                      ? e.value.options[e.value.correctOptionIndex]
                                      : (e.value.options.isNotEmpty ? e.value.options.first : ''),
                                }).toList(),
                              });

                              if (modalCtx.mounted) {
                                Navigator.pop(modalCtx);
                              }
                              _showFeedback('Quiz saved successfully and visible to students!');
                            },
                            child: const Text('Save Quiz Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ManageQuizData {
  String quizTitle;
  int quizPassingPercent;
  List<_ManageQuizQuestion> questions;

  _ManageQuizData({
    this.quizTitle = 'Module Quiz',
    this.quizPassingPercent = 70,
    required this.questions,
  });
}

class _ManageQuizQuestion {
  String question;
  List<String> options;
  int correctOptionIndex;

  _ManageQuizQuestion({
    required this.question,
    required this.options,
    this.correctOptionIndex = 0,
  });
}
