import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/kyc_restricted_view.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

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
  
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshUserSilent();
    });
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
                  color: (isPending ? AppColors.accentOrange : AppColors.error).withValues(alpha: 0.12),
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
                ? 'Your KYC documents have been submitted and are currently under review by our administration team.\n\nE-Book publishing will unlock automatically as soon as your profile is approved.'
                : 'As an AgriLearn instructor, you must complete your KYC verification (Government ID & Bank Account Details) before uploading and publishing e-books.',
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: AppColors.inkSoft,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.push(RouteNames.instructorKyc);
              },
              child: Text(isPending ? 'View KYC Status' : 'Complete KYC Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadEbook() async {
    print('═══════════════════════════════════════════════════════════');
    print('📚 [UPLOAD EBOOK] Submit E-Book triggered');
    print('   Title: "${_titleController.text.trim()}"');
    print('   Author: "${_authorController.text.trim()}"');
    print('   File: ${_selectedFile?.path ?? "None"}');

    if (!_formKey.currentState!.validate()) {
      print('⚠️ [UPLOAD EBOOK] Form validation failed.');
      return;
    }
    if (_selectedFile == null) {
      print('⚠️ [UPLOAD EBOOK] No file selected.');
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload'),
          duration: Duration(milliseconds: 1800),
        ),
      );
      return;
    }

    final currentUser = ref.read(authProvider).user;
    print('🔍 [UPLOAD EBOOK] Checking KYC status: verified=${currentUser?.isKycVerified}, pending=${currentUser?.isKycPending}');
    if (currentUser != null && !currentUser.isKycVerified) {
      print('⛔ [UPLOAD EBOOK] Blocked by KYC verification guard. Showing requirement dialog.');
      _showKycRequiredDialog(currentUser);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final repo = ref.read(instructorRepositoryProvider);
      
      print('🚀 [UPLOAD EBOOK] Sending createEBook request to backend...');
      final response = await repo.createEBook(
        {
          'title': _titleController.text,
          'author_name': _authorController.text,
          'description': _descriptionController.text,
          'price': '0.00', // Assuming free for now, can be updated later
        },
        filePath: _selectedFile!.path,
      );
      
      final ebookId = response['id'] as String;
      print('✅ [UPLOAD EBOOK] E-Book created with ID: $ebookId. Submitting for review...');
      
      // 2. Submit E-Book for review
      await repo.submitEBook(ebookId);
      print('✅ [UPLOAD EBOOK] E-Book submitted successfully for review!');
      print('═══════════════════════════════════════════════════════════');
      
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Ebook uploaded and submitted successfully!'),
            duration: Duration(milliseconds: 1800),
          ),
        );
        context.pop();
      }
    } catch (e) {
      print('❌ [UPLOAD EBOOK] Upload failed: $e');
      print('═══════════════════════════════════════════════════════════');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error uploading Ebook: $e'),
            duration: const Duration(milliseconds: 1800),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final isKycVerified = user?.isKycVerified == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Ebook'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshUserSilent();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: !isKycVerified
              ? const KycRestrictedView(featureName: 'E-Book Upload')
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ebook Details', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 30),
              Text('Document File', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? AppColors.cardDark : AppColors.bgLight,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile == null ? Icons.upload_file : Icons.insert_drive_file,
                        size: 48,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile == null
                            ? 'Tap to select PDF or Word document'
                            : _selectedFile!.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadEbook,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Upload Ebook', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}
