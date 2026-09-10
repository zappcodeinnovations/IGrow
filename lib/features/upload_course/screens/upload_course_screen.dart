import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

/// Screen to create a new course shell.
class UploadCourseScreen extends ConsumerStatefulWidget {
  const UploadCourseScreen({super.key});

  @override
  ConsumerState<UploadCourseScreen> createState() => _UploadCourseScreenState();
}

class _UploadCourseScreenState extends ConsumerState<UploadCourseScreen> {
  bool _isLoading = false;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(text: '0.00');
  final _priceFocusNode = FocusNode();
  String _selectedCategory = 'Organic Farming';

  final List<String> _categories = [
    'Organic Farming',
    'Dairy Farming',
    'Agribusiness',
    'Livestock'
  ];

  @override
  void initState() {
    super.initState();
    _priceFocusNode.addListener(() {
      if (_priceFocusNode.hasFocus) {
        if (_priceController.text == '0.00' || _priceController.text == '0') {
          _priceController.clear();
        }
      } else {
        if (_priceController.text.trim().isEmpty) {
          _priceController.text = '0.00';
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _coverImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking cover image: $e');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverImage = null;
    });
  }

  Future<void> _submitCourse() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          duration: Duration(milliseconds: 1800),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(instructorRepositoryProvider);
      
      final courseResponse = await repo.createCourse({
        'title': _titleController.text,
        'description': _descController.text,
        'category': _selectedCategory.toLowerCase().replaceAll(' ', '_'),
        'price': _priceController.text.isEmpty ? '0.00' : _priceController.text,
        'level': 'beginner',
        'short_description': '',
        'preview_video_url': '',
        'language': 'English',
        'what_you_learn': '',
        'requirements': '',
        'tags': '',
      }, imagePath: _coverImage?.path);
      final courseId = courseResponse['id'] as String;

      ref.invalidate(instructorCoursesProvider);
      ref.invalidate(instructorStatsProvider);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Course Created! Redirecting...'),
            duration: Duration(milliseconds: 1800),
          ),
        );
        context.pushReplacement('/instructor/manage-course/$courseId');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: Failed to create course:', '').trim();
        if (errorMsg.contains('{"detail":"')) {
          final start = errorMsg.indexOf('{"detail":"') + 11;
          final end = errorMsg.indexOf('"', start);
          if (end != -1) {
            errorMsg = errorMsg.substring(start, end);
          }
        }
        
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(milliseconds: 1800),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course Details', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Text(
                    'Cover Image (Thumbnail)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_coverImage == null)
                    InkWell(
                      onTap: _pickCoverImage,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.bgLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.lineDark
                                : AppColors.primaryGreen.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 30,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Upload Cover Image',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.inkDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PNG, JPG up to 5MB (16:9 recommended)',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _coverImage!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Material(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _pickCoverImage,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit,
                                            size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Change',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _removeCoverImage,
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _titleController,
                    label: 'Course Title',
                    hint: 'e.g. Advanced Farming Techniques',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _descController,
                    label: 'Description',
                    hint: 'What is this course about?',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _priceController,
                    focusNode: _priceFocusNode,
                    label: 'Price (₹)',
                    hint: '0.00 for free',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'Create Course Shell',
                      onPressed: _submitCourse,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
