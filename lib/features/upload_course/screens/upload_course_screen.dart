import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
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
                await repo.uploadVideo(lectureId, lec.videoFile!.path);
              } catch (vErr) {
                debugPrint('⚠️ Video upload skipped/failed: $vErr');
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
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

                    const SizedBox(height: 40),
                  ],
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
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Title
          _buildFieldLabel('Course Title *'),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Advanced Hydroponics for Urban Farmers',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),

          // Short Description
          _buildFieldLabel('Short Description'),
          TextField(
            controller: _shortDescController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'A brief 1-2 sentence overview of the course...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),

          // Full Description
          _buildFieldLabel('Full Description *'),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Provide a detailed description of what students will learn...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Course Thumbnail Upload
          _buildFieldLabel('Course Thumbnail'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.lineDark : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Colors.black26 : Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_coverImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.file(
                          _coverImage!,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () => setState(() => _coverImage = null),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickCoverImage,
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: Text(_coverImage != null ? 'Change Thumbnail' : 'Upload Thumbnail'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '16:9 (1280x720), JPG/PNG',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Category
          _buildFieldLabel('Category'),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedCategory,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _categories.map((c) {
              return DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 18),

          // Level
          _buildFieldLabel('Course Level'),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedLevel,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _levels.map((l) {
              return DropdownMenuItem(value: l, child: Text(l));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedLevel = val);
            },
          ),
          const SizedBox(height: 18),

          // Price & Language
          _buildFieldLabel('Price (₹)'),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'e.g., 1499 (0 for Free)',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),

          _buildFieldLabel('Language'),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedLanguage,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _languages.map((l) {
              return DropdownMenuItem(value: l, child: Text(l));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedLanguage = val);
            },
          ),
          const SizedBox(height: 30),

          // Actions
          Row(
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: () {
                    if (_validateStep1()) {
                      setState(() => _currentStep = 2);
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
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

                      // Add Lecture Button
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _addLecture(module.id),
                            icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primaryGreen),
                            label: const Text('Add Lecture', style: TextStyle(color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.bold)),
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
    
  });

  final int id;
  String title;
  final List<_WizardLecture> lectures;
  String? attachedEbookId;
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
