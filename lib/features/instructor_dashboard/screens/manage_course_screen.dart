import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

class ManageCourseScreen extends ConsumerStatefulWidget {
  const ManageCourseScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<ManageCourseScreen> createState() => _ManageCourseScreenState();
}

class _ManageCourseScreenState extends ConsumerState<ManageCourseScreen> {
  final _picker = ImagePicker();

  Future<void> _addSection(BuildContext context) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Section'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Section Title', labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Section Description', labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Add')),
        ],
      ),
    );

    if (res == true && titleController.text.isNotEmpty) {
      try {
        await ref.read(instructorRepositoryProvider).createSection(widget.courseId, {
          'title': titleController.text,
          'description': descController.text,
          'sort_order': 0, // Simplified for now
        });
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
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
      }
    }
  }

  Future<void> _editSection(BuildContext context, ApiCourseSection section) async {
    final titleController = TextEditingController(text: section.title);
    final descController = TextEditingController(text: section.description ?? '');
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit Section'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Section Title', labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Section Description', labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );

    if (res == true && titleController.text.isNotEmpty) {
      try {
        await ref.read(instructorRepositoryProvider).updateSection(widget.courseId, section.id, {
          'title': titleController.text,
          'description': descController.text,
        });
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
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
      }
    }
  }

  Future<void> _deleteSection(BuildContext context, String sectionId) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Section'),
        content: const Text('Are you sure you want to delete this section? All lectures inside it will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (res == true) {
      try {
        await ref.read(instructorRepositoryProvider).deleteSection(widget.courseId, sectionId);
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
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
      }
    }
  }

  Future<void> _addLecture(BuildContext context, String sectionId) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    XFile? pickedVideo;

    final res = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Lecture'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Lecture Title', labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(hintText: 'Lecture Description', labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final video = await _picker.pickVideo(source: ImageSource.gallery);
                    if (video != null) {
                      setState(() => pickedVideo = video);
                    }
                  },
                  icon: const Icon(Icons.video_library),
                  label: Text(pickedVideo == null ? 'Pick Video from Gallery' : 'Video Selected'),
                ),
                if (pickedVideo != null) ...[
                  const SizedBox(height: 8),
                  Text('Selected: ${pickedVideo!.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Add')),
            ],
          );
        },
      ),
    );

    if (res == true && titleController.text.isNotEmpty) {
      try {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Creating lecture...'),
              duration: Duration(milliseconds: 1800),
            ),
          );
        }
        
        final lectureData = await ref.read(instructorRepositoryProvider).createLecture(widget.courseId, sectionId, {
          'title': titleController.text,
          'description': descController.text,
          'sort_order': 0,
          'video_url': pickedVideo != null ? 'pending_upload' : '',
          'bunny_status': 0,
          'duration': 0,
          'is_preview': false,
        });

        if (pickedVideo != null && lectureData.containsKey('id')) {
          if (mounted) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Uploading video... Please wait.'),
                duration: Duration(milliseconds: 1800),
              ),
            );
          }
          await ref.read(instructorRepositoryProvider).uploadVideo(lectureData['id'].toString(), pickedVideo!.path);
          if (mounted) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Video uploaded successfully!'),
                duration: Duration(milliseconds: 1800),
              ),
            );
          }
        }
        
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
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
      }
    }
  }

  Future<void> _uploadVideo(BuildContext context, String lectureId) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Uploading video... Please wait.'),
          duration: Duration(milliseconds: 1800),
        ),
      );
      try {
        await ref.read(instructorRepositoryProvider).uploadVideo(lectureId, video.path);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully!'),
            duration: Duration(milliseconds: 1800),
          ),
        );
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
      } catch (e) {
        if (mounted) {
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              duration: const Duration(milliseconds: 1800),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteLecture(BuildContext context, String sectionId, String lectureId) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Lecture'),
        content: const Text('Are you sure you want to delete this lecture?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (res == true) {
      try {
        await ref.read(instructorRepositoryProvider).deleteLecture(widget.courseId, sectionId, lectureId);
        ref.invalidate(instructorCourseDetailProvider(widget.courseId));
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(instructorCourseDetailProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Course'),
      ),
      body: courseAsync.when(
        data: (course) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: AppColors.primaryGreen.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('${course.sections.length} Sections', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: course.sections.length,
                  itemBuilder: (context, index) {
                    final section = course.sections[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        initiallyExpanded: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editSection(context, section),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                              onPressed: () => _deleteSection(context, section.id),
                            ),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        children: [
                          ...section.lectures.map((lecture) {
                            final hasVideo = lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty;
                            return ListTile(
                              leading: Icon(
                                hasVideo ? Icons.play_circle_outline : Icons.warning_amber_rounded,
                                color: hasVideo ? AppColors.primaryGreen : AppColors.accentOrange,
                              ),
                              title: Text(lecture.title),
                              subtitle: hasVideo ? const Text('Video attached') : const Text('No video', style: TextStyle(color: AppColors.accentOrange)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.upload_file),
                                    tooltip: 'Upload Video',
                                    onPressed: () => _uploadVideo(context, lecture.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.error),
                                    onPressed: () => _deleteLecture(context, section.id, lecture.id),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
                            title: const Text('Add Lecture', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                            onTap: () => _addLecture(context, section.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => const ShimmerListTile(),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSection(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Section'),
      ),
    );
  }
}
