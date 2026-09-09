import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(text: '0.00');
  String _selectedCategory = 'Organic Farming';

  final List<String> _categories = [
    'Organic Farming',
    'Dairy Farming',
    'Agribusiness',
    'Livestock'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
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
      });
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
                    label: 'Price (₹)',
                    hint: '0.00 for free',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
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
