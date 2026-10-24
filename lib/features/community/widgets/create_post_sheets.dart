import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';
import '../providers/community_provider.dart';

class CreatePostSheets {
  CreatePostSheets._();

  // ─────────────────────────────────────────────────────────────────
  // A. 📝 GENERAL POST BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────
  static void showGeneralPost(BuildContext context, WidgetRef ref, String hubId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GeneralPostModal(hubId: hubId),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // B. 📢 COURSE ANNOUNCEMENT BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────
  static void showAnnouncement(BuildContext context, WidgetRef ref, String hubId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AnnouncementModal(hubId: hubId),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // C. 💻 ONLINE WEBINAR BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────
  static void showWebinar(BuildContext context, WidgetRef ref, String hubId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WebinarModal(hubId: hubId),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // D. 🚜 OFFLINE SEMINAR BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────
  static void showSeminar(BuildContext context, WidgetRef ref, String hubId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SeminarModal(hubId: hubId),
    );
  }
}

// ───────────────────────────────────────────────────────────────────
// Modal Container Wrapper with Header
// ───────────────────────────────────────────────────────────────────
class _ModalWrapper extends StatelessWidget {
  const _ModalWrapper({
    required this.title,
    required this.icon,
    required this.badgeColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color badgeColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF18261E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C3E32) : const Color(0xFFE5EDE2);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: borderColor, width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: badgeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppColors.inkSoft),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────
// A. GENERAL POST MODAL
// ─────────────────────────────────────────────────────────────────
class _GeneralPostModal extends ConsumerStatefulWidget {
  const _GeneralPostModal({required this.hubId});
  final String hubId;

  @override
  ConsumerState<_GeneralPostModal> createState() => _GeneralPostModalState();
}

class _GeneralPostModalState extends ConsumerState<_GeneralPostModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1400, imageQuality: 85);
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter post content')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(communityPostsProvider.notifier).createPost(
        hubId: widget.hubId,
        postType: 'POST',
        title: _titleController.text.trim(),
        content: content,
        imagePath: _imageFile?.path,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _ModalWrapper(
      title: 'Create General Post',
      icon: Icons.edit_note_rounded,
      badgeColor: const Color(0xFF16A34A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Topic / Title (Optional)',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'e.g. Winter crop sowing tips',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentController,
            maxLines: 5,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Share advice, tips or updates with farmers *',
              alignLabelWithHint: true,
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'Write your agricultural guidance here...',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Image Preview or Attach Button
          if (_imageFile != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    _imageFile!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _imageFile = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.inkDark,
                      side: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF16A34A)),
                    label: const Text('Add Image'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.inkDark,
                      side: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFF16A34A)),
                    label: const Text('Take Photo'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Publish Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────
// B. COURSE ANNOUNCEMENT MODAL
// ─────────────────────────────────────────────────────────────────
class _AnnouncementModal extends ConsumerStatefulWidget {
  const _AnnouncementModal({required this.hubId});
  final String hubId;

  @override
  ConsumerState<_AnnouncementModal> createState() => _AnnouncementModalState();
}

class _AnnouncementModalState extends ConsumerState<_AnnouncementModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  ApiCourseList? _selectedCourse;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course to announce')),
      );
      return;
    }
    final courseStatus = _selectedCourse!.status?.toUpperCase();
    if (courseStatus != 'APPROVED' && courseStatus != 'PUBLISHED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only approved courses can be announced to students')),
      );
      return;
    }
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an announcement message')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'New Course: ${_selectedCourse!.title}';

      await ref.read(communityPostsProvider.notifier).createPost(
        hubId: widget.hubId,
        postType: 'ANNOUNCEMENT',
        title: title,
        content: content,
        courseId: _selectedCourse!.id,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course Announcement posted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish announcement: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coursesAsync = ref.watch(instructorCoursesProvider((search: '', ordering: '')));

    return _ModalWrapper(
      title: 'Publish Course Announcement',
      icon: Icons.campaign_rounded,
      badgeColor: const Color(0xFF9333EA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Selector Dropdown
          Text(
            'Select Live Course *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 6),
          coursesAsync.when(
            data: (courses) {
              final approvedCourses = courses.where((c) {
                final st = c.status?.toUpperCase();
                return st == 'APPROVED' || st == 'PUBLISHED';
              }).toList();

              if (approvedCourses.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          courses.isEmpty
                              ? 'No courses found. Please upload a course first.'
                              : 'No approved courses available. Courses in draft or under review cannot be announced until approved by Admin, so students don\'t encounter missing links.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : AppColors.inkSoft,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ApiCourseList>(
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF1D2B22) : Colors.white,
                    value: _selectedCourse,
                    hint: Text('Choose an approved course...', style: TextStyle(color: isDark ? Colors.white54 : AppColors.inkSoft)),
                    items: approvedCourses.map((course) {
                      return DropdownMenuItem<ApiCourseList>(
                        value: course,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'APPROVED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (course) => setState(() => _selectedCourse = course),
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error loading courses: $e'),
          ),
          const SizedBox(height: 14),

          // Course Card Live Embed Preview
          if (_selectedCourse != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF223528) : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF9333EA).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _selectedCourse!.thumbnail != null && _selectedCourse!.thumbnail!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _selectedCourse!.thumbnail!,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(color: Colors.grey, width: 54, height: 54),
                          )
                        : Container(color: Colors.grey, width: 54, height: 54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCourse!.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.inkDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedCourse!.price != null ? '₹${_selectedCourse!.price}' : 'Free',
                          style: const TextStyle(
                            color: Color(0xFF9333EA),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          TextField(
            controller: _titleController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Announcement Title (Optional)',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'e.g. Special Discount on Drip Irrigation Course!',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentController,
            maxLines: 4,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Announcement Message *',
              alignLabelWithHint: true,
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'e.g. Enroll today and learn precision soil care with practical video modules.',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Post Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────
// C. WEBINAR MODAL
// ─────────────────────────────────────────────────────────────────
class _WebinarModal extends ConsumerStatefulWidget {
  const _WebinarModal({required this.hubId});
  final String hubId;

  @override
  ConsumerState<_WebinarModal> createState() => _WebinarModalState();
}

class _WebinarModalState extends ConsumerState<_WebinarModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _linkController = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _eventTime ?? const TimeOfDay(hour: 11, minute: 0),
      );
      if (pickedTime != null && mounted) {
        setState(() {
          _eventDate = pickedDate;
          _eventTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final link = _linkController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter webinar title')));
      return;
    }
    if (_eventDate == null || _eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time')));
      return;
    }
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide Zoom/Meet link')));
      return;
    }

    final fullDateTime = DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      _eventTime!.hour,
      _eventTime!.minute,
    );

    setState(() => _isLoading = true);
    try {
      await ref.read(communityPostsProvider.notifier).createPost(
        hubId: widget.hubId,
        postType: 'WEBINAR',
        title: title,
        content: _contentController.text.trim(),
        eventDate: fullDateTime,
        link: link,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Webinar scheduled successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule webinar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _ModalWrapper(
      title: 'Schedule Online Webinar',
      icon: Icons.videocam_rounded,
      badgeColor: const Color(0xFF2563EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Webinar Topic / Title *',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'e.g. Live Q&A: Controlling Pink Bollworm in Cotton',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          // Date & Time Picker
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _eventDate != null && _eventTime != null
                          ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year} at ${_eventTime!.format(context)}'
                          : 'Select Scheduled Date & Time *',
                      style: TextStyle(
                        fontWeight: _eventDate != null ? FontWeight.bold : FontWeight.normal,
                        color: _eventDate != null
                            ? (isDark ? Colors.white : AppColors.inkDark)
                            : (isDark ? Colors.white54 : AppColors.inkSoft),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _linkController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Meeting Link (Zoom, Meet, YouTube Live) *',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'https://meet.google.com/xyz-abcd-efg',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentController,
            maxLines: 3,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Webinar Agenda & Details (Optional)',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'Join me live to discuss seasonal prevention techniques...',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Schedule Webinar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────
// D. OFFLINE SEMINAR MODAL
// ─────────────────────────────────────────────────────────────────
class _SeminarModal extends ConsumerStatefulWidget {
  const _SeminarModal({required this.hubId});
  final String hubId;

  @override
  ConsumerState<_SeminarModal> createState() => _SeminarModalState();
}

class _SeminarModalState extends ConsumerState<_SeminarModal> {
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _mapsLinkController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _mapsLinkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now.add(const Duration(days: 2)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _eventTime ?? const TimeOfDay(hour: 10, minute: 0),
      );
      if (pickedTime != null && mounted) {
        setState(() {
          _eventDate = pickedDate;
          _eventTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final venue = _venueController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter event title')));
      return;
    }
    if (_eventDate == null || _eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select event date and time')));
      return;
    }
    if (venue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter venue address')));
      return;
    }

    final fullDateTime = DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      _eventTime!.hour,
      _eventTime!.minute,
    );

    setState(() => _isLoading = true);
    try {
      await ref.read(communityPostsProvider.notifier).createPost(
        hubId: widget.hubId,
        postType: 'SEMINAR',
        title: title,
        content: _contentController.text.trim(),
        eventDate: fullDateTime,
        venueAddress: venue,
        link: _mapsLinkController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offline Seminar announced successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish seminar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _ModalWrapper(
      title: 'Host Offline Farmer Seminar',
      icon: Icons.groups_rounded,
      badgeColor: const Color(0xFFD97706),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Event Title *',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'e.g. District Krishi Melawa & Soil Testing Camp',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          // Date & Time Picker
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.lineDark : const Color(0xFFD8E4D5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, color: Color(0xFFD97706)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _eventDate != null && _eventTime != null
                          ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year} at ${_eventTime!.format(context)}'
                          : 'Select Event Date & Time *',
                      style: TextStyle(
                        fontWeight: _eventDate != null ? FontWeight.bold : FontWeight.normal,
                        color: _eventDate != null
                            ? (isDark ? Colors.white : AppColors.inkDark)
                            : (isDark ? Colors.white54 : AppColors.inkSoft),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _venueController,
            maxLines: 2,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Venue Name & Physical Address *',
              alignLabelWithHint: true,
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'e.g. APMC Mandi Hall, Market Yard, Nagpur Road',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _mapsLinkController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Google Maps Link / URL (Optional)',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'https://maps.google.com/?q=...',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentController,
            maxLines: 3,
            style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
            decoration: InputDecoration(
              labelText: 'Event Highlights & Instructions (Optional)',
              labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              hintText: 'Bring soil samples for complimentary pH testing...',
              filled: true,
              fillColor: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Publish Seminar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
