import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_segmented_pill.dart';
import '../../../core/widgets/app_sticky_action_bar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/kyc_restricted_view.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

/// Module: 3-Step Course Creation Wizard
/// Matching AgriLearn Web (CourseUploadWizard.jsx):
/// - Step 1: Create a New Course (Basic Info, Categories, Price, Thumbnail)
/// - Step 2: Build Curriculum (Modules, Lectures with Video & Study Material, E-Book link)
/// - Step 3: Course Certificate (Signature upload, Certificate template selection)
/// - Sequential submission pipeline with upload progress ticker
class UploadCourseScreen extends ConsumerStatefulWidget {
  const UploadCourseScreen({super.key});

  @override
  ConsumerState<UploadCourseScreen> createState() => _UploadCourseScreenState();
}

class _UploadCourseScreenState extends ConsumerState<UploadCourseScreen> {
  int _currentStep = 1; // 1, 2, or 3
  final ImagePicker _picker = ImagePicker();

  // ── Step 1: Basic Info State ──────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _priceFocusNode = FocusNode();
  File? _coverImage;

  String _selectedCategory = 'Organic Farming';
  final List<String> _categories = [
    'Organic Farming',
    'Dairy Farming',
    'Agribusiness',
    'Livestock',
    'Hydroponics & Aquaponics',
    'Soil Management',
    'Crop Protection',
    'Horticulture',
  ];

  String _selectedLevel = 'Beginner';
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  String _selectedLanguage = 'English';
  final List<String> _languages = [
    'English',
    'Hindi',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Telugu',
    'Tamil',
  ];

  // ── Step 2: Curriculum State ──────────────────────────────────────────────
  final List<_WizardModule> _curriculum = [
    _WizardModule(
      id: 1,
      title: 'Module 1: Introduction',
      lectures: [
        _WizardLecture(
          id: 101,
          title: 'Course Overview',
        ),
      ],
    ),
  ];

  // ── Step 3: Certificate State ─────────────────────────────────────────────
  bool _issueCertificate = true;
  File? _signatureImage;
  String _selectedTemplate = 'modern'; // 'modern' or 'classic'

  // ── Submission State ──────────────────────────────────────────────────────
  bool _isSubmitting = false;
  String _submissionProgressText = '';
  double _submissionPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _priceFocusNode.addListener(() {
      if (_priceFocusNode.hasFocus) {
        if (_priceController.text.trim() == '0') {
          _priceController.clear();
        }
      } else {
        if (_priceController.text.trim().isEmpty) {
          _priceController.text = '0';
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshUserSilent();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _priceFocusNode.dispose();
    for (final m in _curriculum) {
      for (final l in m.lectures) {
        l.dispose();
      }
    }
    super.dispose();
  }

  // ── Step 1 Helpers ────────────────────────────────────────────────────────

  Future<void> _pickCoverImage() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _coverImage = File(picked.path));
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick cover image: $e');
    }
  }

  bool _validateStep1() {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter course title.');
      return false;
    }
    if (_descController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter full course description.');
      return false;
    }
    return true;
  }

  // ── Step 2 Helpers ────────────────────────────────────────────────────────

  void _addModule() {
    setState(() {
      final newIndex = _curriculum.length + 1;
      _curriculum.add(
        _WizardModule(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Module $newIndex: New Topic',
          lectures: [
            _WizardLecture(
              id: DateTime.now().millisecondsSinceEpoch + 1,
              title: 'Lecture 1',
            ),
          ],
        ),
      );
    });
  }

  void _deleteModule(int moduleId) {
    if (_curriculum.length <= 1) {
      _showErrorSnackbar('Course must have at least one module.');
      return;
    }
    setState(() {
      _curriculum.removeWhere((m) => m.id == moduleId);
    });
  }

  void _addLecture(int moduleId) {
    setState(() {
      final mod = _curriculum.firstWhere((m) => m.id == moduleId);
      final newLecIdx = mod.lectures.length + 1;
      mod.lectures.add(
        _WizardLecture(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Lecture $newLecIdx',
        ),
      );
    });
  }

  void _deleteLecture(int moduleId, int lectureId) {
    setState(() {
      final mod = _curriculum.firstWhere((m) => m.id == moduleId);
      if (mod.lectures.length <= 1) {
        _showErrorSnackbar('Each module must have at least one lecture.');
        return;
      }
      mod.lectures.removeWhere((l) => l.id == lectureId);
    });
  }

  void _showEditQuizBottomSheet(_WizardModule module) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final titleController = TextEditingController(text: module.quizTitle);
        int passingPercent = module.quizPassingPercent;
        final List<_WizardQuizQuestion> localQuestions = module.quizQuestions
            .map((q) => _WizardQuizQuestion(
                  question: q.question,
                  options: List<String>.from(q.options),
                  correctOptionIndex: q.correctOptionIndex,
                ))
            .toList();

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
                                'Edit Module Quiz',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
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
                              // Quiz Title Field
                              Text(
                                'Quiz Title',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey.shade300 : AppColors.inkDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Chapter 1 Knowledge Check',
                                  filled: true,
                                  fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: isDark ? AppColors.lineDark : Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Passing Criteria
                              Text(
                                'Passing Criteria',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey.shade300 : AppColors.inkDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [50, 60, 70, 80, 90].map((score) {
                                  final isSelected = passingPercent == score;
                                  return ChoiceChip(
                                    label: Text('$score% to pass'),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                    labelStyle: TextStyle(
                                      color: isSelected ? const Color(0xFFB45309) : null,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      if (val) setModalState(() => passingPercent = score);
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 22),

                              // Questions List
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quiz Questions (${localQuestions.length})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.grey.shade300 : AppColors.inkDark,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setModalState(() {
                                        localQuestions.add(
                                          _WizardQuizQuestion(
                                            question: 'New Question ${localQuestions.length + 1}',
                                            options: ['Option A', 'Option B', 'Option C', 'Option D'],
                                            correctOptionIndex: 0,
                                          ),
                                        );
                                      });
                                    },
                                    icon: const Icon(Icons.add_rounded, size: 16),
                                    label: const Text('Add Question', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              ...localQuestions.asMap().entries.map((entry) {
                                final qIndex = entry.key;
                                final question = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark ? AppColors.lineDark : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 11,
                                            backgroundColor: const Color(0xFFF59E0B),
                                            child: Text('${qIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: question.question,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                              decoration: const InputDecoration(
                                                hintText: 'Enter question text...',
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (val) => question.question = val,
                                            ),
                                          ),
                                          if (localQuestions.length > 1)
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                              onPressed: () {
                                                setModalState(() {
                                                  localQuestions.removeAt(qIndex);
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Options (tap circle to mark correct answer):',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 6),
                                      ...question.options.asMap().entries.map((optEntry) {
                                        final optIndex = optEntry.key;
                                        final isCorrect = question.correctOptionIndex == optIndex;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setModalState(() {
                                                    question.correctOptionIndex = optIndex;
                                                  });
                                                },
                                                child: Icon(
                                                  isCorrect ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                                  color: isCorrect ? AppColors.primaryGreen : Colors.grey,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: optEntry.value,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                                                  ),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    filled: true,
                                                    fillColor: isCorrect
                                                        ? AppColors.primaryGreen.withValues(alpha: 0.08)
                                                        : (isDark ? AppColors.cardDark : Colors.white),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: BorderSide(
                                                        color: isCorrect ? AppColors.primaryGreen : (isDark ? AppColors.lineDark : Colors.grey.shade300),
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (val) => question.options[optIndex] = val,
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

                      // Action Button
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
                            onPressed: () {
                              setState(() {
                                module.quizTitle = titleController.text.trim().isNotEmpty
                                    ? titleController.text.trim()
                                    : 'Module Quiz';
                                module.quizPassingPercent = passingPercent;
                                module.quizQuestions = localQuestions;
                              });
                              Navigator.pop(context);
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

  Future<void> _pickLectureVideo(_WizardLecture lecture) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          lecture.videoFile = File(picked.path);
          lecture.videoName = picked.name;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick video: $e');
    }
  }

  Future<void> _pickLectureResource(_WizardLecture lecture) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          lecture.resourceFile = File(result.files.single.path!);
          lecture.resourceName = result.files.single.name;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick document: $e');
    }
  }

  bool _validateStep2() {
    if (_curriculum.isEmpty) {
      _showErrorSnackbar('Please add at least one module.');
      return false;
    }
    for (int i = 0; i < _curriculum.length; i++) {
      final mod = _curriculum[i];
      if (mod.title.trim().isEmpty) {
        _showErrorSnackbar('Module ${i + 1} needs a title.');
        return false;
      }
      if (mod.lectures.isEmpty) {
        _showErrorSnackbar('Module "${mod.title}" must have at least one lecture.');
        return false;
      }
      for (int j = 0; j < mod.lectures.length; j++) {
        final lec = mod.lectures[j];
        if (lec.titleController.text.trim().isEmpty) {
          _showErrorSnackbar('Lecture ${j + 1} in "${mod.title}" needs a title.');
          return false;
        }
      }
    }
    return true;
  }

  // ── Step 3 Helpers ────────────────────────────────────────────────────────

  Future<void> _pickSignatureImage() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() => _signatureImage = File(picked.path));
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick signature image: $e');
    }
  }

  // ── Final Submission (Create Course Draft Pipeline) ────────────────────────

  Future<void> _submitCreateCourseDraft() async {
    final user = ref.read(authProvider).user;
    if (user != null && !user.isKycVerified) {
      _showKycRequiredDialog(user);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionPercent = 0.05;
      _submissionProgressText = 'Creating Course Draft record...';
    });

    try {
      final repo = ref.read(instructorRepositoryProvider);

      // 1. Create Base Course Draft
      final priceNum = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final courseRes = await repo.createCourse(
        {
          'title': _titleController.text.trim(),
          'short_description': _shortDescController.text.trim(),
          'description': _descController.text.trim(),
          'category': _selectedCategory.toLowerCase().replaceAll(' ', '_'),
          'level': _selectedLevel.toLowerCase(),
          'price': priceNum.toStringAsFixed(2),
          'language': _selectedLanguage,
        },
        imagePath: _coverImage?.path,
      );

      final courseId = courseRes['id']?.toString() ?? '';
      if (courseId.isEmpty) {
        throw Exception('Server did not return a valid course ID.');
      }

      setState(() {
        _submissionPercent = 0.25;
        _submissionProgressText = 'Creating Curriculum Modules & Lectures...';
      });

      // Calculate total files to upload for progress calculation
      int totalVideos = 0;
      int totalPdfs = 0;
      for (final m in _curriculum) {
        for (final l in m.lectures) {
          if (l.videoFile != null) totalVideos++;
          if (l.resourceFile != null) totalPdfs++;
        }
      }
      final totalMedia = totalVideos + totalPdfs;
      int mediaUploaded = 0;
      final List<String> uploadWarnings = [];

      // 2. Create Sections & Lectures
      for (int sIdx = 0; sIdx < _curriculum.length; sIdx++) {
        final mod = _curriculum[sIdx];
        final sectionRes = await repo.createSection(courseId, {
          'title': mod.title.trim(),
          'description': '',
          'sort_order': sIdx + 1,
        });
        final sectionId = sectionRes['id']?.toString() ?? '';

        if (sectionId.isNotEmpty && mod.lectures.isNotEmpty) {
          for (int lIdx = 0; lIdx < mod.lectures.length; lIdx++) {
            final lec = mod.lectures[lIdx];
            final lecRes = await repo.createLecture(courseId, sectionId, {
              'title': lec.titleController.text.trim(),
              'description': lec.descController.text.trim(),
              'duration': 10,
              'sort_order': lIdx + 1,
              'is_preview': lIdx == 0,
            });
            final lectureId = lecRes['id']?.toString() ?? '';

            // 3. Upload Video if selected
            if (lectureId.isNotEmpty && lec.videoFile != null) {
              mediaUploaded++;
              setState(() {
                _submissionPercent = 0.3 + ((mediaUploaded / (totalMedia + 1)) * 0.55);
                _submissionProgressText =
                    'Uploading Video $mediaUploaded/$totalMedia: ${lec.titleController.text.trim()}...';
              });
              try {
                await repo.uploadVideo(
                  lectureId,
                  lec.videoFile!.path,
                  timeout: const Duration(minutes: 5),
                );
              } catch (vErr) {
                debugPrint('⚠️ Video upload skipped/failed: $vErr');
                uploadWarnings.add('"${lec.titleController.text.trim()}"');
              }
            }

            // 4. Upload Study Material (PDF) if selected
            if (lectureId.isNotEmpty && lec.resourceFile != null) {
              mediaUploaded++;
              setState(() {
                _submissionPercent = 0.3 + ((mediaUploaded / (totalMedia + 1)) * 0.55);
                _submissionProgressText =
                    'Attaching Study Material: ${lec.resourceName ?? "PDF"}...';
              });
              try {
                await repo.uploadResource(
                  lectureId,
                  lec.resourceFile!.path,
                  fileName: lec.resourceName ?? 'Study Material',
                );
              } catch (rErr) {
                debugPrint('⚠️ Study material upload skipped/failed: $rErr');
              }
            }
          }
        }
      }

      // 5. Upload Certificate Signature if provided
      if (_signatureImage != null) {
        setState(() {
          _submissionPercent = 0.95;
          _submissionProgressText = 'Attaching Certificate Digital Signature...';
        });
        try {
          await repo.uploadCertificateTemplate(courseId, _signatureImage!.path);
        } catch (cErr) {
          debugPrint('⚠️ Certificate signature upload warning: $cErr');
        }
      }

      setState(() {
        _submissionPercent = 1.0;
        _submissionProgressText = 'Course Draft Created Successfully!';
      });

      // Invalidate providers
      ref.invalidate(instructorCoursesProvider);
      ref.invalidate(instructorStatsProvider);

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() => _isSubmitting = false);
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        if (uploadWarnings.isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Course Draft Created, but ${uploadWarnings.length} video(s) failed to upload (${uploadWarnings.join(", ")}). You can re-upload them in Course Manager.',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade800,
              duration: const Duration(seconds: 6),
            ),
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Course Draft Created! Review it on your dashboard.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 3),
            ),
          );
        }
        context.go(RouteNames.instructorHome);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showErrorSnackbar('Failed to create course draft: $e');
      }
    }
  }

  void _showErrorSnackbar(String msg) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showKycRequiredDialog(UserModel? user) {
    final bool isPending = user?.isKycPending == true;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPending ? AppColors.accentOrange : AppColors.error)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPending ? Icons.hourglass_top_rounded : Icons.verified_user_outlined,
                  color: isPending ? AppColors.accentOrange : AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPending ? 'Verification Under Review' : 'KYC Required',
                  style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          content: Text(
            isPending
                ? 'Your KYC documents have been submitted and are under review. Course creation will unlock once approved.'
                : 'As an AgriLearn instructor, you must complete your KYC verification before creating and publishing courses.',
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: AppColors.inkSoft,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isPending ? AppColors.accentOrange : AppColors.primaryGreen,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(RouteNames.instructorKyc);
              },
              child: Text(isPending ? 'Check KYC Status' : 'Complete KYC Now'),
            ),
          ],
        );
      },
    );
  }

  // ── Build Method ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    // Check KYC restriction
    if (user != null && !user.isKycVerified) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Create a New Course',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const KycRestrictedView(featureName: 'Course Creation'),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            _currentStep == 1
                ? 'Create a New Course'
                : _currentStep == 2
                    ? 'Build Curriculum'
                    : 'Course Certificate',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 1) {
                setState(() => _currentStep--);
              } else {
                context.pop();
              }
            },
          ),
        ),
        bottomNavigationBar: AppStickyActionBar(
          isLoading: _isSubmitting,
          secondaryLabel: _currentStep > 1 ? 'Back' : null,
          onSecondaryPressed: _currentStep > 1
              ? () => setState(() => _currentStep--)
              : null,
          primaryLabel: _currentStep == 1
              ? 'Continue to Curriculum'
              : _currentStep == 2
                  ? 'Continue to Certificate'
                  : 'Create Course Draft',
          primaryIcon: _currentStep == 3
              ? Icons.cloud_done_rounded
              : Icons.arrow_forward_rounded,
          statusText: 'Step $_currentStep of 3: ${_currentStep == 1 ? "Details" : _currentStep == 2 ? "Curriculum" : "Certificate"}',
          onPrimaryPressed: () {
            if (_currentStep == 1) {
              if (_validateStep1()) {
                setState(() => _currentStep = 2);
              }
            } else if (_currentStep == 2) {
              if (_validateStep2()) {
                setState(() => _currentStep = 3);
              }
            } else {
              _submitCreateCourseDraft();
            }
          },
        ),
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: ResponsiveContentConstraint(
                maxWidth: 820,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Subtitle
                      Text(
                        _currentStep == 1
                            ? 'Fill out the basic details of your agricultural course.'
                            : _currentStep == 2
                                ? 'Add your video lectures, chapters, and quizzes.'
                                : 'Upload your signature to issue valid certificates upon completion.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Wizard Stepper Indicator (1 - 2 - 3)
                      _buildStepperIndicator(),
                      const SizedBox(height: 24),

                      // Step Content
                      if (_currentStep == 1) _buildStep1BasicDetails(isDark),
                      if (_currentStep == 2) _buildStep2Curriculum(isDark),
                      if (_currentStep == 3) _buildStep3Certificate(isDark),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // Submitting Overlay Dialog
            if (_isSubmitting)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Saving Course Draft...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _submissionProgressText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _submissionPercent,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_submissionPercent * 100).toInt()}% Completed',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Stepper Indicator ─────────────────────────────────────────────────────

  Widget _buildStepperIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1),
        _buildStepLine(1),
        _buildStepCircle(2),
        _buildStepLine(2),
        _buildStepCircle(3),
      ],
    );
  }

  Widget _buildStepCircle(int step) {
    final isCompleted = _currentStep > step;
    final isActive = _currentStep == step;

    Color bgColor = Colors.grey.shade300;
    Color textColor = Colors.grey.shade700;

    if (isCompleted || isActive) {
      bgColor = AppColors.primaryGreen;
      textColor = Colors.white;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, size: 20, color: Colors.white)
          : Text(
              '$step',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
    );
  }

  Widget _buildStepLine(int leftStep) {
    final isPassed = _currentStep > leftStep;
    return Container(
      width: 50,
      height: 3,
      color: isPassed ? AppColors.primaryGreen : Colors.grey.shade300,
    );
  }

  // ── Step 1: Basic Details View ────────────────────────────────────────────

  Widget _buildStep1BasicDetails(bool isDark) {
    const categoryEmojis = {
      'Organic Farming': '🌾',
      'Dairy Farming': '🥛',
      'Agribusiness': '💼',
      'Livestock': '🐄',
      'Hydroponics & Aquaponics': '💧',
      'Soil Management': '🪴',
      'Crop Protection': '🛡️',
      'Horticulture': '🍎',
    };

    final pricePresets = [0, 299, 499, 999, 1499];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card 1: Course Identity ──────────────────────────────
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Course Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _titleController,
                label: 'Course Title *',
                hint: 'e.g., Advanced Hydroponics for Urban Farmers',
                prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _shortDescController,
                label: 'Short Overview',
                hint: 'A quick 1-2 sentence hook describing your course...',
                maxLines: 2,
                prefixIcon: const Icon(Icons.short_text_rounded, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descController,
                label: 'Full Description *',
                hint: 'Detailed curriculum topics, who this course is for, and outcomes...',
                maxLines: 4,
                prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primaryGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Card 2: Classification & Target Audience ──────────────
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: AppColors.accentOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Category & Experience Level',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Level Selector via AppSegmentedPillGroup
              _buildFieldLabel('Experience Level'),
              AppSegmentedPillGroup<String>(
                isExpanded: true,
                options: _levels.map((lvl) {
                  final emoji = lvl == 'Beginner' ? '🌱' : lvl == 'Intermediate' ? '🌿' : '🌳';
                  return AppPillOption(value: lvl, label: lvl, emoji: emoji);
                }).toList(),
                selectedValue: _selectedLevel,
                onChanged: (val) => setState(() => _selectedLevel = val),
              ),
              const SizedBox(height: 20),

              // Category Selector with Visual Chips
              _buildFieldLabel('Farming Category'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final isSelected = _selectedCategory == c;
                  final emoji = categoryEmojis[c] ?? '🌱';
                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedCategory = c);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isDark ? AppColors.cardDark : const Color(0xFFF3F6F1)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : (isDark ? AppColors.lineDark : const Color(0xFFE2E8DE)),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            c,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : AppColors.inkDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Language Selector with Pills
              _buildFieldLabel('Instruction Language'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _languages.map((l) {
                  final isSelected = _selectedLanguage == l;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedLanguage = l);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.greenDark
                            : (isDark ? AppColors.bgDark : const Color(0xFFF3F6F1)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : (isDark ? AppColors.lineDark : const Color(0xFFE2E8DE)),
                        ),
                      ),
                      child: Text(
                        l,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.inkDark),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Card 3: Pricing & Media Cover ─────────────────────────
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.currency_rupee_rounded,
                      color: AppColors.skyBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pricing & Thumbnail',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Price Presets
              _buildFieldLabel('Quick Price Preset'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pricePresets.map((p) {
                  final textVal = p == 0 ? '0' : '$p';
                  final isSelected = _priceController.text.trim() == textVal;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _priceController.text = textVal;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isDark ? AppColors.cardDark : const Color(0xFFF3F6F1)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : (isDark ? AppColors.lineDark : const Color(0xFFE2E8DE)),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        p == 0 ? 'Free (₹0)' : '₹$p',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.inkDark),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Price Input Field
              AppTextField(
                controller: _priceController,
                focusNode: _priceFocusNode,
                label: 'Course Price (₹)',
                hint: '0 for free or enter custom amount',
                prefixIcon: const Icon(Icons.sell_outlined, color: AppColors.primaryGreen),
                prefixText: '₹ ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  if (val.length > 1 && val.startsWith('0') && !val.startsWith('0.')) {
                    final cleaned = val.replaceFirst(RegExp(r'^0+'), '');
                    final target = cleaned.isEmpty ? '0' : cleaned;
                    _priceController.value = TextEditingValue(
                      text: target,
                      selection: TextSelection.collapsed(offset: target.length),
                    );
                  }
                  setState(() {});
                },
              ),
              const SizedBox(height: 22),

              // Modern Studio Cover Upload Dropzone
              _buildFieldLabel('Course Cover Banner'),
              InkWell(
                onTap: _pickCoverImage,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : const Color(0xFFF3F6F1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.lineDark : const Color(0xFFDCE4D8),
                      width: 1.5,
                    ),
                  ),
                  child: _coverImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Stack(
                            children: [
                              Image.file(
                                _coverImage!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () => setState(() => _coverImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.72),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Change Banner',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppColors.primaryGreen,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Upload Course Cover Image',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recommended 16:9 banner (1280x720) in JPG or PNG',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: Curriculum View ───────────────────────────────────────────────

  Widget _buildStep2Curriculum(bool isDark) {
    final ebooksAsync = ref.watch(instructorEbooksProvider);

    return Column(
      children: [
        // Info Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Organize your course into Modules (Chapters). Each module can contain multiple video lectures and study materials.',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Modules List
        ..._curriculum.map((module) {
          // module item
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.lineDark : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Module Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.lineDark : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          module.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _deleteModule(module.id),
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                        label: const Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                // Lectures Inside Module
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...module.lectures.map((lecture) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.lineDark : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Lecture Title & Remove button
                              Row(
                                children: [
                                  const Icon(Icons.play_circle_outline, color: AppColors.primaryGreen, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: lecture.titleController,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      decoration: const InputDecoration(
                                        hintText: 'Lecture Title',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    onPressed: () => _deleteLecture(module.id, lecture.id),
                                    tooltip: 'Remove',
                                  ),
                                ],
                              ),

                              // Lecture Notes/Description
                              const SizedBox(height: 6),
                              TextField(
                                controller: lecture.descController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Add a short description or notes for this video...',
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Video & Study Material Attachments (Responsive Wrap)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (lecture.videoFile != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                          const SizedBox(width: 6),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 120),
                                            child: Text(
                                              lecture.videoName ?? 'Video attached',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green.shade900),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => setState(() {
                                              lecture.videoFile = null;
                                              lecture.videoName = null;
                                            }),
                                            child: const Icon(Icons.close, size: 14, color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => _pickLectureVideo(lecture),
                                      icon: const Icon(Icons.video_call_outlined, size: 15, color: AppColors.primaryGreen),
                                      label: const Text('Upload Video', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                    ),

                                  if (lecture.resourceFile != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.picture_as_pdf, color: Colors.blue, size: 14),
                                          const SizedBox(width: 6),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 120),
                                            child: Text(
                                              lecture.resourceName ?? 'Document attached',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => setState(() {
                                              lecture.resourceFile = null;
                                              lecture.resourceName = null;
                                            }),
                                            child: const Icon(Icons.close, size: 14, color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => _pickLectureResource(lecture),
                                      icon: const Icon(Icons.attach_file, size: 14, color: Colors.blue),
                                      label: const Text('Attach PDF Notes', style: TextStyle(fontSize: 11, color: Colors.blue)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      // Attach E-Book Dropdown (Optional, Full-width responsive)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 6, bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book, size: 16, color: Colors.purple),
                                const SizedBox(width: 6),
                                Text(
                                  'Attach E-Book to this Module (Optional):',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey.shade300 : AppColors.inkDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ebooksAsync.when(
                              data: (ebooks) {
                                return DropdownButtonFormField<String>(
                                  initialValue: module.attachedEbookId,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  hint: const Text('-- No E-Book Attached --', style: TextStyle(fontSize: 12)),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('-- No E-Book Attached --', style: TextStyle(fontSize: 12))),
                                    ...ebooks.map((eb) {
                                      return DropdownMenuItem(
                                        value: eb.id,
                                        child: Text(
                                          eb.title ?? 'E-Book',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) => setState(() => module.attachedEbookId = val),
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const Text('Could not load e-books', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),

                      // Quiz Card (if module has quiz enabled)
                      if (module.hasQuiz)
                        Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E2413)
                                : const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFFFDE68A),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.military_tech_rounded,
                                  color: Color(0xFFD97706),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      module.quizTitle.isNotEmpty ? module.quizTitle : 'Module Quiz',
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
                                      '${module.quizQuestions.length} Questions • Passing: ${module.quizPassingPercent}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.amber.shade200 : const Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                onPressed: () => _showEditQuizBottomSheet(module),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFB45309),
                                  side: const BorderSide(color: Color(0xFFD97706)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Edit Quiz',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                tooltip: 'Remove Quiz',
                                onPressed: () {
                                  setState(() {
                                    module.hasQuiz = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                      // Action buttons: Add Lecture & Add Quiz (Responsive Wrap)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton.icon(
                            onPressed: () => _addLecture(module.id),
                            icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primaryGreen),
                            label: const Text('Add Lecture', style: TextStyle(color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          if (!module.hasQuiz)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  module.hasQuiz = true;
                                });
                                _showEditQuizBottomSheet(module);
                              },
                              icon: const Icon(Icons.quiz_outlined, size: 16, color: Color(0xFFD97706)),
                              label: const Text('+ Add Quiz', style: TextStyle(color: Color(0xFFD97706), fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // Add New Module Dashed Button
        InkWell(
          onTap: _addModule,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryGreen,
                style: BorderStyle.solid,
                width: 1.5,
              ),
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: AppColors.primaryGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add New Module',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Actions
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _currentStep = 1),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onPressed: () {
                  if (_validateStep2()) {
                    setState(() => _currentStep = 3);
                  }
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Certificate View ──────────────────────────────────────────────

  Widget _buildStep3Certificate(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.card_membership_rounded, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'iAgrow automatically issues certificates to students who complete 100% of the lectures and pass all quizzes in your course.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Issue Certificate Checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primaryGreen.withValues(alpha: 0.04),
            ),
            child: CheckboxListTile(
              value: _issueCertificate,
              activeColor: AppColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Issue Certificate of Completion for this Course',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onChanged: (val) => setState(() => _issueCertificate = val ?? true),
            ),
          ),
          const SizedBox(height: 24),

          // Digital Signature Upload
          _buildFieldLabel('Your Digital Signature'),
          Text(
            'Upload an image of your signature with a transparent background (.png) to be printed on the certificate.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 10),

          InkWell(
            onTap: _pickSignatureImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppColors.lineDark : Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isDark ? Colors.black26 : Colors.grey.shade50,
              ),
              alignment: Alignment.center,
              child: _signatureImage != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(_signatureImage!, fit: BoxFit.contain, height: 100),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () => setState(() => _signatureImage = null),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.draw_rounded, size: 32, color: Colors.grey.shade500),
                        const SizedBox(height: 6),
                        const Text(
                          'Click to upload signature',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PNG, max 2MB',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Certificate Template Style
          _buildFieldLabel('Certificate Template Style'),
          Row(
            children: [
              Expanded(
                child: _buildTemplateCard(
                  title: 'Modern Professional',
                  templateKey: 'modern',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTemplateCard(
                  title: 'Classic Academic',
                  templateKey: 'classic',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 2),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: _submitCreateCourseDraft,
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: const Text(
                    'Create Course Draft',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard({
    required String title,
    required String templateKey,
    required bool isDark,
  }) {
    final isSelected = _selectedTemplate == templateKey;

    return InkWell(
      onTap: () => setState(() => _selectedTemplate = templateKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : (isDark ? AppColors.lineDark : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primaryGreen.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Column(
          children: [
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.black38 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                templateKey == 'modern' ? Icons.workspace_premium_outlined : Icons.military_tech_outlined,
                color: isSelected ? AppColors.primaryGreen : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryGreen : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

// ── Supporting Data Structures ──────────────────────────────────────────────

class _WizardModule {
  _WizardModule({
    required this.id,
    required this.title,
    required this.lectures,
  }) : quizQuestions = [
          _WizardQuizQuestion(
            question: 'What is the primary concept explained in this module?',
            options: [
              'Core fundamentals and best practices',
              'Advanced heavy machinery only',
              'Marketing and exports exclusively',
              'None of the above',
            ],
            correctOptionIndex: 0,
          ),
          _WizardQuizQuestion(
            question: 'Which technique is recommended for higher crop yield?',
            options: [
              'Improper seed spacing',
              'Soil testing and balanced nutrients',
              'Excessive pesticide spraying',
              'Overwatering without drainage',
            ],
            correctOptionIndex: 1,
          ),
        ];

  final int id;
  String title;
  final List<_WizardLecture> lectures;
  String? attachedEbookId;
  bool hasQuiz = false;
  String quizTitle = 'Module Quiz';
  int quizPassingPercent = 70;
  List<_WizardQuizQuestion> quizQuestions;
}

class _WizardQuizQuestion {
  _WizardQuizQuestion({
    required this.question,
    required this.options,
    this.correctOptionIndex = 0,
  });

  String question;
  List<String> options;
  int correctOptionIndex;
}

class _WizardLecture {
  _WizardLecture({
    required this.id,
    required String title,
    String description = '',
  })  : titleController = TextEditingController(text: title),
        descController = TextEditingController(text: description);

  final int id;
  final TextEditingController titleController;
  final TextEditingController descController;
  File? videoFile;
  String? videoName;
  File? resourceFile;
  String? resourceName;

  void dispose() {
    titleController.dispose();
    descController.dispose();
  }
}
