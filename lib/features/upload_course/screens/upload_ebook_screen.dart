import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/image_crop_rotate_screen.dart';
import '../../../core/widgets/kyc_restricted_view.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';
import '../../../core/services/app_config_service.dart';

class UploadEbookScreen extends ConsumerStatefulWidget {
  const UploadEbookScreen({super.key});

  @override
  ConsumerState<UploadEbookScreen> createState() => _UploadEbookScreenState();
}

class _UploadEbookScreenState extends ConsumerState<UploadEbookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '0');

  PlatformFile? _selectedFile;
  File? _coverImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage = false;
  bool _isPickingFile = false;
  bool _isSavingDraft = false;
  bool _isSubmittingReview = false;
  bool get _isUploading => _isSavingDraft || _isSubmittingReview;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showKycRequiredDialog(UserModel? user) {
    final bool isPending = user?.isKycPending == true;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  isPending
                      ? Icons.hourglass_top_rounded
                      : Icons.verified_user_outlined,
                  color: isPending ? AppColors.accentOrange : AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPending ? tr(ref, 'Verification Under Review') : tr(ref, 'KYC Required'),
                  style: Theme.of(dialogContext).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            isPending
                ? tr(ref, 'Your KYC documents have been submitted and are under review. E-book upload will unlock once approved.')
                : tr(ref, 'As an AgriLearn instructor, you must complete your KYC verification before uploading and publishing e-books.'),
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: AppColors.inkSoft,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(tr(ref, 'Cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isPending
                    ? AppColors.accentOrange
                    : AppColors.primaryGreen,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(RouteNames.instructorKyc);
              },
              child: Text(isPending ? tr(ref, 'Check KYC Status') : tr(ref, 'Complete KYC Now')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickCoverImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 90,
      );
      if (picked != null && mounted) {
        final original = File(picked.path);
        final edited = await ImageCropRotateScreen.cropAndRotate(
          context,
          imageFile: original,
          title: 'Crop & Rotate E-Book Cover',
          allowFreeCrop: true,
        );
        if (mounted) {
          setState(() {
            _coverImage = edited ?? original;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        // Ignore duplicate active picker invocation error cleanly
        if (!errorStr.contains('already_active')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error selecting cover image: $e')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _cropAndRotateCurrentCover() async {
    if (_coverImage == null) return;
    final edited = await ImageCropRotateScreen.cropAndRotate(
      context,
      imageFile: _coverImage!,
      title: 'Crop & Rotate E-Book Cover',
      allowFreeCrop: true,
    );
    if (edited != null && mounted) {
      setState(() => _coverImage = edited);
    }
  }

  Future<void> _pickFile() async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        if (!errorStr.contains('already_active')) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  Future<void> _uploadEbook({bool submitForReview = true}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedFile == null) {
      AppToast.showWarning(context, 'Please select a file to upload');
      return;
    }

    final currentUser = ref.read(authProvider).user;
    if (currentUser != null && !currentUser.isKycVerified) {
      _showKycRequiredDialog(currentUser);
      return;
    }

    setState(() {
      if (submitForReview) {
        _isSubmittingReview = true;
      } else {
        _isSavingDraft = true;
      }
    });

    try {
      final repo = ref.read(instructorRepositoryProvider);

      final priceNum = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final response = await repo.createEBook(
        {
          'title': _titleController.text.trim(),
          'author_name': _authorController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': priceNum.toStringAsFixed(2),
        },
        filePath: _selectedFile!.path,
        coverImagePath: _coverImage?.path,
      );

      final ebookId = response['id'] as String;

      if (submitForReview) {
        // Submit E-Book for admin review
        await repo.submitEBook(ebookId);
      }

      // Invalidate instructor ebooks provider so uploads list and home reflect latest state
      ref.invalidate(instructorEbooksProvider);

      if (mounted) {
        AppToast.showSuccess(
          context,
          submitForReview
              ? 'E-Book uploaded and submitted for Admin review!'
              : 'E-Book saved as Draft successfully! You can submit it anytime from My Uploads.',
          duration: const Duration(seconds: 3),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String cleanError = e.toString();
        if (cleanError.startsWith('Exception: ')) {
          cleanError = cleanError.substring('Exception: '.length);
        }
        final lower = cleanError.toLowerCase();
        if (lower.contains('socketexception') ||
            lower.contains('clientexception') ||
            lower.contains('connection abort') ||
            lower.contains('connection refused') ||
            lower.contains('connection reset') ||
            lower.contains('connection closed') ||
            lower.contains('failed host lookup') ||
            lower.contains('network is unreachable') ||
            lower.contains('handshake') ||
            lower.contains('timed out') ||
            lower.contains('timeoutexception') ||
            lower.contains('network error') ||
            lower.contains('no internet')) {
          cleanError = 'No internet connection. Please check your network and try again.';
        }

        AppToast.showError(
          context,
          cleanError,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
          _isSubmittingReview = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final isKycVerified = user?.isKycVerified == true;

    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'Upload E-Book'))),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshUserSilent();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: !isKycVerified
              ? const KycRestrictedView(featureName: 'E-Book Upload')
              : ResponsiveContentConstraint(
                  maxWidth: 680,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      color: AppColors.primaryGreen.withValues(
                                        alpha: 0.12,
                                      ),
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
                                    tr(ref, 'E-Book Information'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.inkDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              AppTextField(
                                controller: _titleController,
                                label: tr(ref, 'E-Book Title *'),
                                hint: 'e.g. Modern Drip Irrigation Handbook',
                                prefixIcon: const Icon(
                                  Icons.title_rounded,
                                  color: AppColors.primaryGreen,
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                    ? 'Title is required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _authorController,
                                label: tr(ref, 'Author Name *'),
                                hint: 'e.g. Dr. Rajesh Patel',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.primaryGreen,
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                    ? 'Author name is required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _descriptionController,
                                label: tr(ref, 'Description *'),
                                hint:
                                    'Provide a comprehensive overview of topics covered...',
                                maxLines: 4,
                                prefixIcon: const Icon(
                                  Icons.notes_rounded,
                                  color: AppColors.primaryGreen,
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                    ? 'Description is required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Builder(
                                builder: (context) {
                                  final config = ref.watch(appConfigProvider);
                                  final allowsCustomPrice = config.allowsCustomCoursePrice;

                                  if (allowsCustomPrice) {
                                    return AppTextField(
                                      controller: _priceController,
                                      label: tr(ref, 'Price (₹)'),
                                      hint: '0 for free, or enter amount (e.g. 199)',
                                      helperText: tr(ref, 'Enter 0 to offer this e-book for free.'),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      prefixIcon: const Icon(
                                        Icons.currency_rupee_rounded,
                                        color: AppColors.primaryGreen,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Price is required';
                                        }
                                        final numVal = double.tryParse(val.trim());
                                        if (numVal == null) {
                                          return 'Please enter a valid price';
                                        }
                                        if (numVal < 0) {
                                          return 'Price cannot be negative';
                                        }
                                        return null;
                                      },
                                    );
                                  }

                                  return DropdownButtonFormField<String>(
                                    initialValue: const ['0', '249', '499', '999', '1499'].contains(_priceController.text.trim())
                                        ? _priceController.text.trim()
                                        : '0',
                                    decoration: InputDecoration(
                                      labelText: tr(ref, 'E-Book Price Tier *'),
                                      helperText: tr(ref, 'Select one of the standard price tiers.'),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                    items: [
                                      DropdownMenuItem(value: '0', child: Text(tr(ref, 'Free (₹0)'))),
                                      DropdownMenuItem(
                                        value: '249',
                                        child: Text('₹${formatNum(ref, '249')} — ${tr(ref, 'Tier 1')}'),
                                      ),
                                      DropdownMenuItem(
                                        value: '499',
                                        child: Text('₹${formatNum(ref, '499')} — ${tr(ref, 'Tier 1.5')}'),
                                      ),
                                      DropdownMenuItem(
                                        value: '999',
                                        child: Text('₹${formatNum(ref, '999')} — ${tr(ref, 'Tier 2')}'),
                                      ),
                                      DropdownMenuItem(
                                        value: '1499',
                                        child: Text('₹${formatNum(ref, '1,499')} — ${tr(ref, 'Tier 3')}'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _priceController.text = val);
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Dedicated Cover Image / Thumbnail Card ──
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
                                      color: AppColors.skyBlue.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: AppColors.skyBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tr(ref, 'Cover Image / Thumbnail'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.inkDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tr(ref, 'Front cover or thumbnail (JPG, PNG, WebP)'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.white60
                                                : AppColors.inkSoft,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              if (_coverImage != null) ...[
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.lineDark
                                          : AppColors.lineLight,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          _coverImage!,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.black54,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              tooltip: 'Remove cover image',
                                              onPressed: () => setState(
                                                () => _coverImage = null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _cropAndRotateCurrentCover,
                                      icon: const Icon(
                                        Icons.crop_rotate_rounded,
                                        size: 16,
                                      ),
                                      label: Text(tr(ref, 'Crop & Rotate')),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        foregroundColor: AppColors.primaryGreen,
                                        side: const BorderSide(color: AppColors.primaryGreen),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton.icon(
                                      onPressed: _isPickingImage ? null : _pickCoverImage,
                                      icon: _isPickingImage
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(
                                              Icons.photo_library_outlined,
                                              size: 16,
                                            ),
                                      label: Text(_isPickingImage ? tr(ref, 'Selecting...') : tr(ref, 'Change Cover Image')),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                InkWell(
                                  onTap: _isPickingImage ? null : _pickCoverImage,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.lineDark
                                            : const Color(0xFFDCE4D8),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      color: isDark
                                          ? Colors.black26
                                          : const Color(0xFFF3F6F1),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.skyBlue.withValues(
                                              alpha: 0.12,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: _isPickingImage
                                              ? const SizedBox(
                                                  width: 34,
                                                  height: 34,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: AppColors.skyBlue,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.add_photo_alternate_outlined,
                                                  size: 34,
                                                  color: AppColors.skyBlue,
                                                ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _isPickingImage
                                              ? tr(ref, 'Opening Gallery...')
                                              : tr(ref, 'Tap to upload Cover Image / Thumbnail'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.inkDark,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tr(ref, 'JPEG, PNG, or WEBP (Max 5MB)'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white60
                                                : AppColors.inkSoft,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                      color: AppColors.accentOrange.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.file_upload_outlined,
                                      color: AppColors.accentOrange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    tr(ref, 'Document File'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.inkDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              InkWell(
                                onTap: _isPickingFile ? null : _pickFile,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedFile != null
                                          ? AppColors.primaryGreen
                                          : (isDark
                                                ? AppColors.lineDark
                                                : const Color(0xFFDCE4D8)),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    color: isDark
                                        ? Colors.black26
                                        : const Color(0xFFF3F6F1),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen
                                              .withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _selectedFile == null
                                              ? Icons.upload_file_rounded
                                              : Icons.check_circle_rounded,
                                          size: 36,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _selectedFile == null
                                            ? tr(ref, 'Tap to select PDF or DOCX file')
                                            : _selectedFile!.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.inkDark,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedFile == null
                                            ? tr(ref, 'Maximum file size: 50MB')
                                            : '${formatNum(ref, (_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2))} MB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white60
                                              : AppColors.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 420;
                            final draftButton = SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _isUploading
                                    ? null
                                    : () => _uploadEbook(submitForReview: false),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryGreen,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSavingDraft
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryGreen,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.bookmark_border_rounded,
                                            size: 18,
                                            color: AppColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            tr(ref, 'Save as Draft'),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );

                            final submitButton = SizedBox(
                              height: 52,
                              child: FilledButton(
                                onPressed: _isUploading
                                    ? null
                                    : () => _uploadEbook(submitForReview: true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSubmittingReview
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.cloud_upload_rounded,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              tr(ref, 'Upload & Submit E-Book'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );

                            if (isNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  submitButton,
                                  const SizedBox(height: 12),
                                  draftButton,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: draftButton),
                                const SizedBox(width: 12),
                                Expanded(child: submitButton),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
