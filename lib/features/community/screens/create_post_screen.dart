import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/community_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _venueController = TextEditingController();
  final _linkController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _picker = ImagePicker();

  String _selectedPostType = 'GENERAL';
  String? _selectedHubId;
  String? _selectedTopicId;
  DateTime? _selectedEventDate;
  TimeOfDay? _selectedEventTime;
  File? _selectedImage;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _postTypes = [
    {'type': 'GENERAL', 'label': 'General', 'icon': Icons.chat_bubble_outline_rounded, 'color': Color(0xFF475569)},
    {'type': 'OFFLINE_SEMINAR', 'label': 'Seminar', 'icon': Icons.event_rounded, 'color': Color(0xFF2E7D32)},
    {'type': 'ONLINE_MEETING', 'label': 'Webinar', 'icon': Icons.videocam_rounded, 'color': Color(0xFF1565C0)},
    {'type': 'COURSE_LAUNCH', 'label': 'Course', 'icon': Icons.school_rounded, 'color': Color(0xFF7B1FA2)},
    {'type': 'ADVISORY', 'label': 'Advisory', 'icon': Icons.warning_amber_rounded, 'color': Color(0xFFE65100)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _venueController.dispose();
    _linkController.dispose();
    _courseNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attach Photo',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGreen),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryGreen),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedEventTime ?? const TimeOfDay(hour: 10, minute: 0),
      );

      setState(() {
        _selectedEventDate = pickedDate;
        _selectedEventTime = pickedTime;
      });
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      DateTime? fullEventDateTime;
      if (_selectedEventDate != null) {
        final time = _selectedEventTime ?? const TimeOfDay(hour: 10, minute: 0);
        fullEventDateTime = DateTime(
          _selectedEventDate!.year,
          _selectedEventDate!.month,
          _selectedEventDate!.day,
          time.hour,
          time.minute,
        );
      }

      await ref.read(communityPostsProvider.notifier).createPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            hubId: _selectedHubId,
            postType: _selectedPostType,
            topicId: _selectedTopicId,
            eventDate: fullEventDateTime,
            venueAddress: _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : null,
            link: _linkController.text.trim().isNotEmpty ? _linkController.text.trim() : null,
            imagePath: _selectedImage?.path,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post published successfully!'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(milliseconds: 2000),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish post: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(communityTopicsProvider);
    final hubsAsync = ref.watch(communityHubsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7FAF6),
      appBar: AppBar(
        title: const Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Post Type Chips ───────────────────────────────
                Text(
                  'Post Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _postTypes.map((item) {
                      final isSelected = _selectedPostType == item['type'];
                      final color = item['color'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedPostType = item['type'] as String;
                            });
                          },
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item['icon'] as IconData, size: 16, color: isSelected ? Colors.white : color),
                              const SizedBox(width: 6),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.inkDark),
                                ),
                              ),
                            ],
                          ),
                          selectedColor: color,
                          backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
                          side: BorderSide(
                            color: isSelected ? color : (isDark ? AppColors.lineDark : const Color(0xFFE2EBE0)),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // ─── Hub Selector (Optional) ───────────────────────
                hubsAsync.when(
                  data: (hubs) {
                    if (hubs.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2EBE0), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.hub_rounded, size: 16, color: AppColors.primaryGreen),
                              SizedBox(width: 6),
                              Text('Post in Hub (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: _selectedHubId,
                              hint: const Text('Global Feed (No specific hub)', style: TextStyle(fontSize: 13)),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Global Feed (All Farmers)'),
                                ),
                                ...hubs.map(
                                  (h) => DropdownMenuItem<String?>(
                                    value: h.id,
                                    child: Text(h.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _selectedHubId = val),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // ─── Topic Selector (Optional) ─────────────────────
                topicsAsync.when(
                  data: (topics) {
                    if (topics.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2EBE0), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.topic_rounded, size: 16, color: AppColors.primaryGreen),
                              SizedBox(width: 6),
                              Text('Discussion Topic (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: _selectedTopicId,
                              hint: const Text('General Farming Discussion', style: TextStyle(fontSize: 13)),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('General Discussion'),
                                ),
                                ...topics.map(
                                  (t) => DropdownMenuItem<String?>(
                                    value: t.id,
                                    child: Text(t.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _selectedTopicId = val),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // ─── Dynamic Post Type Specific Fields ─────────────
                if (_selectedPostType == 'OFFLINE_SEMINAR' || _selectedPostType == 'ONLINE_MEETING') ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : const Color(0xFFF4F9F1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD4E8CF), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedPostType == 'OFFLINE_SEMINAR' ? Icons.calendar_today_rounded : Icons.live_tv_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text('Event Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: _pickDateTime,
                              icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                              label: Text(_selectedEventDate == null ? 'Set Date & Time' : 'Change'),
                            ),
                          ],
                        ),
                        if (_selectedEventDate != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCCE4C5)),
                            ),
                            child: Text(
                              '📅 ${_selectedEventDate!.day}/${_selectedEventDate!.month}/${_selectedEventDate!.year} at ${_selectedEventTime?.format(context) ?? "10:00 AM"}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                        if (_selectedPostType == 'OFFLINE_SEMINAR') ...[
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _venueController,
                            hint: 'Venue (e.g. Krishi Vigyan Kendra, Baramati)',
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: _linkController,
                            hint: 'Google Maps Location Link (URL)',
                          ),
                        ],
                        if (_selectedPostType == 'ONLINE_MEETING') ...[
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _linkController,
                            hint: 'Meeting Link (Zoom / Google Meet URL)',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (_selectedPostType == 'COURSE_LAUNCH') ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : const Color(0xFFFAF3FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9D0F3), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school_rounded, color: Color(0xFF7B1FA2), size: 18),
                            SizedBox(width: 8),
                            Text('Course Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _courseNameController,
                          hint: 'Course Title / Description',
                        ),
                      ],
                    ),
                  ),
                ],

                // ─── Post Title ────────────────────────────────────
                Text(
                  'Post Title *',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _titleController,
                  hint: 'e.g. Smart Irrigation Workshop / Pest alert',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a post title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Content ───────────────────────────────────────
                Text(
                  'Content *',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _contentController,
                  hint: 'Write your thoughts, seminar agenda, or farming advice here...',
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write content for your post';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Photo Attachment ──────────────────────────────
                Text(
                  'Attach Photo (Optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedImage != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  InkWell(
                    onTap: _showImagePickerModal,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFCEE6C5),
                          width: 1.2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 34, color: AppColors.primaryGreen),
                          SizedBox(height: 6),
                          Text('Tap to upload photo (JPG / PNG)', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  label: 'Publish Post',
                  icon: Icons.send_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submitPost,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
