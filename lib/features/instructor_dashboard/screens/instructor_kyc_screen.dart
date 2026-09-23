import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class InstructorKycScreen extends ConsumerStatefulWidget {
  const InstructorKycScreen({super.key});

  @override
  ConsumerState<InstructorKycScreen> createState() => _InstructorKycScreenState();
}

class _InstructorKycScreenState extends ConsumerState<InstructorKycScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _docNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _confirmAccountController;
  late TextEditingController _ifscController;

  String _selectedDocType = 'AADHAAR'; // 'AADHAAR' | 'PAN'
  File? _selectedDocImage;
  bool _isLoading = false;
  bool _isEditingExisting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;

    final existingDocType = user?.kycDocumentType?.toUpperCase();
    if (existingDocType == 'PAN') {
      _selectedDocType = 'PAN';
    } else {
      _selectedDocType = 'AADHAAR';
    }

    _docNumberController = TextEditingController(text: user?.kycDocumentNumber ?? '');
    _bankNameController = TextEditingController(text: user?.bankName ?? '');
    _accountNameController = TextEditingController(text: user?.bankAccountName ?? (user?.fullName ?? ''));
    _accountNumberController = TextEditingController(text: user?.bankAccountNumber ?? '');
    _confirmAccountController = TextEditingController(text: user?.bankAccountNumber ?? '');
    _ifscController = TextEditingController(text: user?.bankIfscCode ?? '');

    // Refresh profile on open to capture any immediate admin changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshUserSilent();
    });
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedDocImage = File(pickedFile.path);
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

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Upload ID Document Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded,
                                color: AppColors.primaryGreen, size: 36),
                            const SizedBox(height: 8),
                            Text('Camera',
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_rounded,
                                color: AppColors.primaryGreen, size: 36),
                            const SizedBox(height: 8),
                            Text('Gallery',
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  String _cleanErrorMessage(dynamic e) {
    if (e is ApiException) {
      if (e.isNetwork) {
        return 'No internet connection. Please check your network and try again.';
      }
      if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
        final firstKey = e.fieldErrors!.keys.first;
        final firstVal = e.fieldErrors![firstKey];
        if (firstVal != null && firstVal.isNotEmpty) {
          return '$firstKey: ${firstVal.first}';
        }
        return '$firstKey: $firstVal';
      }
      return e.message;
    }
    return e.toString().replaceAll('Exception:', '').trim();
  }

  Future<void> _submitKyc() async {
    print('====================================================');
    print('📝 [INSTRUCTOR KYC SCREEN] Form submission triggered');
    if (!_formKey.currentState!.validate()) {
      print('⚠️ [INSTRUCTOR KYC SCREEN] Form validation failed. Check highlighted fields.');
      return;
    }

    final user = ref.read(authProvider).user;
    final hasExistingImage = user?.kycDocumentImage != null && user!.kycDocumentImage!.isNotEmpty;
    if (_selectedDocImage == null && !hasExistingImage) {
      print('⚠️ [INSTRUCTOR KYC SCREEN] Validation failed: ID document photo is missing.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo of your ID document.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print('📋 [INSTRUCTOR KYC SCREEN] Validated fields:');
    print('   Doc Type: $_selectedDocType');
    print('   Doc Number: ${_docNumberController.text.trim().replaceAll(' ', '')}');
    print('   Bank Name: ${_bankNameController.text.trim()}');
    print('   Account Name: ${_accountNameController.text.trim()}');
    print('   Account Number: ${_accountNumberController.text.trim()}');
    print('   IFSC Code: ${_ifscController.text.trim().toUpperCase()}');
    print('   Photo Path: ${_selectedDocImage?.path ?? (hasExistingImage ? "Using existing photo" : "None")}');

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).submitKycProfile(
            docType: _selectedDocType,
            docNumber: _docNumberController.text.trim().replaceAll(' ', ''),
            docImagePath: _selectedDocImage?.path,
            bankName: _bankNameController.text.trim(),
            accountName: _accountNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            ifscCode: _ifscController.text.trim().toUpperCase(),
          );

      print('✅ [INSTRUCTOR KYC SCREEN] KYC Profile submitted successfully to backend!');
      print('====================================================');

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isEditingExisting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('KYC and Bank details submitted successfully for review!'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('❌ [INSTRUCTOR KYC SCREEN] Submission Error: $e');
      print('====================================================');
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(e)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _maskNumber(String? number, {int visibleEndChars = 4}) {
    if (number == null || number.isEmpty) return '••••';
    if (number.length <= visibleEndChars) return number;
    final maskedLength = number.length - visibleEndChars;
    return '${'•' * maskedLength}${number.substring(maskedLength)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    final isVerified = user?.isKycVerified == true;
    final isPending = user?.isKycPending == true;
    final isRejected = !isVerified && !isPending && (user?.hasSubmittedKyc == true);

    final showReadOnly = (isVerified || isPending) && !_isEditingExisting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC & Payout Verification'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ResponsiveContentConstraint(
          maxWidth: 720,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(
                isVerified: isVerified,
                isPending: isPending,
                isRejected: isRejected,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Read-only view when verified or pending
              if (showReadOnly) ...[
                _buildReadOnlySummary(user, isDark, isVerified),
                const SizedBox(height: 24),
                if (!isVerified)
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _isEditingExisting = true);
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Update / Edit Submitted Details'),
                    ),
                  ),
              ] else ...[
                // Editable Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Government Identity
                      Text(
                        '1. Identity Document',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.inkDark,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a government ID for identity verification.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.inkSoft,
                            ),
                      ),
                      const SizedBox(height: 14),

                      // Document Type Selector Chips
                      Row(
                        children: [
                          Expanded(
                            child: _buildDocTypeChip(
                              label: 'Aadhaar Card',
                              value: 'AADHAAR',
                              icon: Icons.badge_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDocTypeChip(
                              label: 'PAN Card',
                              value: 'PAN',
                              icon: Icons.credit_card_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Document Number Input
                      AppTextField(
                        controller: _docNumberController,
                        label: _selectedDocType == 'AADHAAR'
                            ? '12-digit Aadhaar Number *'
                            : '10-character PAN Number *',
                        hint: _selectedDocType == 'AADHAAR'
                            ? 'e.g. 123456789012'
                            : 'e.g. ABCDE1234F',
                        keyboardType: _selectedDocType == 'AADHAAR'
                            ? TextInputType.number
                            : TextInputType.text,
                        prefixIcon: Icon(
                          _selectedDocType == 'AADHAAR'
                              ? Icons.fingerprint_rounded
                              : Icons.credit_card_rounded,
                          color: AppColors.primaryGreen,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your ${_selectedDocType == 'AADHAAR' ? 'Aadhaar' : 'PAN'} number';
                          }
                          final clean = val.trim().replaceAll(' ', '');
                          if (_selectedDocType == 'AADHAAR') {
                            if (!RegExp(r'^\d{12}$').hasMatch(clean)) {
                              return 'Aadhaar must be exactly 12 digits';
                            }
                          } else {
                            if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$', caseSensitive: false).hasMatch(clean)) {
                              return 'Please enter a valid 10-character PAN (e.g. ABCDE1234F)';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Document Image Upload Card
                      _buildDocumentUploadCard(user, isDark),
                      const SizedBox(height: 28),

                      // Section 2: Bank Payout Details
                      Text(
                        '2. Bank Account (For Payouts)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.inkDark,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Course & ebook earnings will be credited to this account on the 1st of every month.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.inkSoft,
                            ),
                      ),
                      const SizedBox(height: 14),

                      // Account Holder Name
                      AppTextField(
                        controller: _accountNameController,
                        label: 'Account Holder Name *',
                        hint: 'Name as per bank passbook / statement',
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            color: AppColors.primaryGreen),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter the account holder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Bank Name
                      AppTextField(
                        controller: _bankNameController,
                        label: 'Bank Name *',
                        hint: 'e.g. State Bank of India, HDFC, ICICI',
                        prefixIcon: const Icon(Icons.account_balance_rounded,
                            color: AppColors.primaryGreen),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter bank name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Bank Account Number
                      AppTextField(
                        controller: _accountNumberController,
                        label: 'Bank Account Number *',
                        hint: 'Enter account number',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.pin_rounded,
                            color: AppColors.primaryGreen),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter account number';
                          }
                          if (val.trim().length < 8) {
                            return 'Account number must be at least 8 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm Account Number
                      AppTextField(
                        controller: _confirmAccountController,
                        label: 'Confirm Account Number *',
                        hint: 'Re-enter account number',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.primaryGreen),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please re-enter account number';
                          }
                          if (val.trim() != _accountNumberController.text.trim()) {
                            return 'Account numbers do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // IFSC Code
                      AppTextField(
                        controller: _ifscController,
                        label: 'IFSC Code *',
                        hint: 'e.g. SBIN0001234',
                        keyboardType: TextInputType.text,
                        prefixIcon: const Icon(Icons.qr_code_2_rounded,
                            color: AppColors.primaryGreen),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter IFSC code';
                          }
                          final clean = val.trim().toUpperCase();
                          if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(clean)) {
                            return 'Enter a valid 11-character IFSC code (e.g. SBIN0001234)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Disclaimer / Security Note
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.security_rounded,
                                color: AppColors.primaryGreen, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your personal and banking information is 256-bit encrypted and exclusively used for instructor compliance and payout transfers.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.white.withValues(alpha: 0.8)
                                          : AppColors.inkDark,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      AppButton(
                        label: 'Submit for Verification',
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: _isLoading,
                        onPressed: _submitKyc,
                      ),
                      if (_isEditingExisting) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() => _isEditingExisting = false);
                            },
                            child: const Text('Cancel Edit'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatusCard({
    required bool isVerified,
    required bool isPending,
    required bool isRejected,
    required bool isDark,
  }) {
    Color bgGradientStart;
    Color bgGradientEnd;
    IconData icon;
    String title;
    String message;

    if (isVerified) {
      bgGradientStart = AppColors.primaryGreen;
      bgGradientEnd = AppColors.greenDark;
      icon = Icons.verified_user_rounded;
      title = 'KYC Verified Guide 🛡️';
      message =
          'Your identity and bank account are fully verified. You can publish courses, ebooks, and receive monthly payouts.';
    } else if (isPending) {
      bgGradientStart = AppColors.accentOrange;
      bgGradientEnd = const Color(0xFFD97706);
      icon = Icons.hourglass_top_rounded;
      title = 'Verification Under Review ⏳';
      message =
          'Your KYC documents have been submitted to the admin team for review. Approval usually takes 24 to 48 hours.';
    } else if (isRejected) {
      bgGradientStart = AppColors.error;
      bgGradientEnd = const Color(0xFF991B1B);
      icon = Icons.warning_amber_rounded;
      title = 'Verification Action Required ⚠️';
      message =
          'Your previous submission could not be verified. Please review your details, attach a clear photo of your ID, and resubmit.';
    } else {
      bgGradientStart = AppColors.skyBlue;
      bgGradientEnd = const Color(0xFF1D4ED8);
      icon = Icons.assignment_outlined;
      title = 'Complete KYC Profile 📋';
      message =
          'Government ID & bank verification are required to activate course payouts and instructor badges.';
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgGradientStart, bgGradientEnd],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocTypeChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedDocType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDocType = value;
          _docNumberController.clear();
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.12)
              : (isDark ? AppColors.cardDark : AppColors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 1.8 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primaryGreen : AppColors.inkSoft,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected ? AppColors.primaryGreen : AppColors.inkDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard(dynamic user, bool isDark) {
    final existingUrl = user?.kycDocumentImage;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Upload ${_selectedDocType == 'AADHAAR' ? 'Aadhaar' : 'PAN'} Front Photo *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ensure your full name, photo, and number are clearly visible.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 14),

          if (_selectedDocImage != null) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedDocImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        setState(() => _selectedDocImage = null);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: _showImagePickerSheet,
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: const Text('Change Photo'),
              ),
            ),
          ] else if (existingUrl != null && existingUrl.isNotEmpty) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    existingUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: const Text('Attached ID on File'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: _showImagePickerSheet,
                icon: const Icon(Icons.photo_camera_rounded, size: 18),
                label: const Text('Upload New Photo'),
              ),
            ),
          ] else ...[
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _showImagePickerSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDark : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.lineDark : AppColors.lineLight,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.upload_file_rounded,
                          color: AppColors.primaryGreen, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to Take Photo or Browse',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports JPG, PNG up to 5MB',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlySummary(dynamic user, bool isDark, bool isVerified) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Identity Details',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isVerified ? AppColors.primaryGreen : AppColors.accentOrange)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isVerified ? 'VERIFIED' : 'PENDING REVIEW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isVerified
                                ? AppColors.primaryGreen
                                : AppColors.accentOrange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                'Document Type',
                user?.kycDocumentType == 'PAN' ? 'PAN Card' : 'Aadhaar Card',
              ),
              _buildSummaryRow(
                'Document Number',
                _maskNumber(user?.kycDocumentNumber),
              ),
              if (user?.kycDocumentImage != null && user!.kycDocumentImage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    user.kycDocumentImage!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registered Bank Account',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(height: 24),
              _buildSummaryRow('Bank Name', user?.bankName ?? 'Not specified'),
              _buildSummaryRow('Account Holder', user?.bankAccountName ?? user?.fullName ?? ''),
              _buildSummaryRow(
                'Account Number',
                _maskNumber(user?.bankAccountNumber),
              ),
              _buildSummaryRow('IFSC Code', user?.bankIfscCode ?? '••••'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.inkSoft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
