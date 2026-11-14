import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/image_crop_rotate_screen.dart';
import '../../auth/providers/auth_provider.dart';

/// Mapping of 4-letter IFSC prefixes to major Indian commercial and public banks.
const Map<String, String> kIfscBankPrefixes = {
  'KKBK': 'Kotak Mahindra Bank',
  'SBIN': 'State Bank of India',
  'HDFC': 'HDFC Bank',
  'ICIC': 'ICICI Bank',
  'UTIB': 'Axis Bank',
  'AXIS': 'Axis Bank',
  'PUNB': 'Punjab National Bank',
  'BARB': 'Bank of Baroda',
  'CNRB': 'Canara Bank',
  'UBIN': 'Union Bank of India',
  'BKID': 'Bank of India',
  'IOBA': 'Indian Overseas Bank',
  'IDIB': 'Indian Bank',
  'CBIN': 'Central Bank of India',
  'MAHB': 'Bank of Maharashtra',
  'PSIB': 'Punjab & Sind Bank',
  'UCBA': 'UCO Bank',
  'YESB': 'Yes Bank',
  'INDB': 'IndusInd Bank',
  'IDFB': 'IDFC FIRST Bank',
  'FDRL': 'Federal Bank',
  'KVBL': 'Karur Vysya Bank',
  'SIBL': 'South Indian Bank',
  'RBLN': 'RBL Bank',
  'CSBK': 'CSB Bank',
  'BDBL': 'Bandhan Bank',
  'AUBL': 'AU Small Finance Bank',
  'ESFB': 'Equitas Small Finance Bank',
  'UJVN': 'Ujjivan Small Finance Bank',
  'AIRP': 'Airtel Payments Bank',
  'PYTM': 'Paytm Payments Bank',
  'IPOS': 'India Post Payments Bank',
  'JAKA': 'Jammu & Kashmir Bank',
  'CORP': 'Corporation Bank',
  'ANDB': 'Andhra Bank',
  'SYNB': 'Syndicate Bank',
  'ALLA': 'Allahabad Bank',
  'VIJB': 'Vijaya Bank',
  'ORBC': 'Oriental Bank of Commerce',
};

/// Resolves a bank name from an IFSC code prefix instantly.
String? resolveIfscBankPrefix(String ifsc) {
  final clean = ifsc.trim().toUpperCase();
  if (clean.length < 4) return null;
  final prefix = clean.substring(0, 4);
  return kIfscBankPrefixes[prefix];
}

class InstructorKycScreen extends ConsumerStatefulWidget {
  final http.Client? httpClient;
  const InstructorKycScreen({super.key, this.httpClient});

  @override
  ConsumerState<InstructorKycScreen> createState() =>
      _InstructorKycScreenState();
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
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // IFSC Auto-fetch & validation state
  bool _isFetchingIfsc = false;
  bool?
  _isIfscValid; // true = valid, false = invalid (404/not found), null = unverified
  String? _ifscErrorText;
  String? _ifscHelperText;
  bool _bankNameManuallyEdited = false;

  // Toggle visibility of submitted masked data in Under Review state
  bool _showSubmittedDocNumber = false;
  bool _showSubmittedAccountNumber = false;
  String? _lastFetchedIfsc;

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

    _docNumberController = TextEditingController(
      text: user?.kycDocumentNumber ?? '',
    );
    _bankNameController = TextEditingController(text: user?.bankName ?? '');
    _accountNameController = TextEditingController(
      text: user?.bankAccountName ?? (user?.fullName ?? ''),
    );
    _accountNumberController = TextEditingController(
      text: user?.bankAccountNumber ?? '',
    );
    _confirmAccountController = TextEditingController(
      text: user?.bankAccountNumber ?? '',
    );
    _ifscController = TextEditingController(text: user?.bankIfscCode ?? '');

    if ((user?.bankName ?? '').isNotEmpty) {
      _bankNameManuallyEdited = true;
    } else if ((user?.bankIfscCode ?? '').isNotEmpty) {
      final prefillBank = resolveIfscBankPrefix(user!.bankIfscCode!);
      if (prefillBank != null) {
        _bankNameController.text = prefillBank;
      }
    }

    if ((user?.bankIfscCode ?? '').isNotEmpty) {
      final ifsc = user!.bankIfscCode!.trim().toUpperCase();
      if (ifsc.length == 11 &&
          RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fetchIfscDetails(ifsc);
        });
      }
    }

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

  void _onIfscChanged(String val) {
    final clean = val.trim().toUpperCase();

    // Auto-capitalize field content smoothly without resetting cursor position
    if (val != clean) {
      final currentOffset = _ifscController.selection.baseOffset;
      _ifscController.value = TextEditingValue(
        text: clean,
        selection: TextSelection.collapsed(
          offset: currentOffset.clamp(0, clean.length),
        ),
      );
    }

    // Reset validation and helper states when IFSC is modified
    if (clean != _lastFetchedIfsc) {
      setState(() {
        _isIfscValid = null;
        _ifscErrorText = null;
        _ifscHelperText = null;
      });
    }

    // Instant bank name prefix matching (e.g. KKBK -> Kotak Mahindra Bank)
    if (clean.length >= 4) {
      final mappedBank = resolveIfscBankPrefix(clean);
      if (mappedBank != null && !_bankNameManuallyEdited) {
        if (_bankNameController.text.trim().isEmpty ||
            _bankNameController.text.trim() != mappedBank) {
          _bankNameController.text = mappedBank;
        }
      }
    } else if (clean.isEmpty && !_bankNameManuallyEdited) {
      _bankNameController.clear();
      setState(() {
        _isIfscValid = null;
        _ifscErrorText = null;
        _ifscHelperText = null;
      });
    }

    // When full 11-character code is entered, validate format and perform online lookup
    if (clean.length == 11) {
      if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(clean)) {
        setState(() {
          _isIfscValid = false;
          _ifscErrorText = '5th character must be zero "0" (e.g. SBIN0001234)';
          _ifscHelperText = null;
        });
        _formKey.currentState?.validate();
      } else if (clean != _lastFetchedIfsc) {
        _fetchIfscDetails(clean);
      }
    } else if (clean.length > 11) {
      setState(() {
        _isIfscValid = false;
        _ifscErrorText = 'IFSC code must be exactly 11 characters';
        _ifscHelperText = null;
      });
      _formKey.currentState?.validate();
    }
  }

  Future<void> _fetchIfscDetails(String ifsc) async {
    setState(() {
      _isFetchingIfsc = true;
      _lastFetchedIfsc = ifsc;
      _isIfscValid = null;
      _ifscErrorText = null;
    });

    try {
      final uri = Uri.parse('https://ifsc.razorpay.com/$ifsc');
      final client = widget.httpClient ?? http.Client();
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 4));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final bank = data['BANK']?.toString();
        final branch = data['BRANCH']?.toString();
        final city = data['CITY']?.toString();

        if (bank != null &&
            bank.trim().isNotEmpty &&
            !_bankNameManuallyEdited) {
          _bankNameController.text = bank.trim();
        }

        setState(() {
          _isIfscValid = true;
          _ifscErrorText = null;
          if (branch != null && branch.trim().isNotEmpty) {
            _ifscHelperText =
                'Branch: ${branch.trim()}${city != null ? ', ${city.trim()}' : ''}';
          } else if (bank != null) {
            _ifscHelperText = 'Bank: $bank';
          }
        });
        _formKey.currentState?.validate();
      } else if (response.statusCode == 404) {
        // Invalid or non-existent IFSC code
        setState(() {
          _isIfscValid = false;
          _ifscErrorText = 'Invalid IFSC code. Branch does not exist.';
          _ifscHelperText = null;
        });
        _formKey.currentState?.validate();
      } else {
        setState(() {
          _isIfscValid = null;
          _ifscErrorText = null;
          _ifscHelperText =
              'Unable to verify branch online (${response.statusCode})';
        });
      }
    } catch (_) {
      // Network timeout or connectivity issue
      if (!mounted) return;
      setState(() {
        _isIfscValid = null;
        _ifscErrorText = null;
        _ifscHelperText =
            'Could not verify IFSC online. Check network connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingIfsc = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 92,
      );
      if (pickedFile != null && mounted) {
        final original = File(pickedFile.path);
        final edited = await ImageCropRotateScreen.cropAndRotate(
          context,
          imageFile: original,
          title: 'Crop & Rotate ID Document',
          allowFreeCrop: true,
        );
        if (edited != null && mounted) {
          setState(() {
            _selectedDocImage = edited;
          });
        } else if (mounted && _selectedDocImage == null) {
          // If cancelled without crop, keep the original picked photo
          setState(() {
            _selectedDocImage = original;
          });
        }
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

  Future<void> _cropAndRotateCurrentDoc() async {
    if (_selectedDocImage == null) return;
    final edited = await ImageCropRotateScreen.cropAndRotate(
      context,
      imageFile: _selectedDocImage!,
      title: 'Crop & Rotate ID Document',
      allowFreeCrop: true,
    );
    if (edited != null && mounted) {
      setState(() {
        _selectedDocImage = edited;
      });
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
                  tr(ref, 'Upload ID Document Photo'),
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
                            const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primaryGreen,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr(ref, 'Camera'),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
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
                            const Icon(
                              Icons.photo_library_rounded,
                              color: AppColors.primaryGreen,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr(ref, 'Gallery'),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
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

    final ifscClean = _ifscController.text.trim().toUpperCase();

    // Check if IFSC verification is currently in progress
    if (_isFetchingIfsc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while IFSC code is being verified.'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check if IFSC code has been marked invalid
    if (_isIfscValid == false) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _formKey.currentState!.validate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ifscErrorText != null
                ? tr(ref, _ifscErrorText!)
                : tr(ref, 'Invalid IFSC code. Please enter a valid IFSC.'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // If IFSC was entered/pasted but not yet verified, run verification now
    if (_isIfscValid == null &&
        ifscClean.length == 11 &&
        RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscClean)) {
      await _fetchIfscDetails(ifscClean);
      if (_isIfscValid == false) {
        setState(() {
          _autovalidateMode = AutovalidateMode.onUserInteraction;
        });
        _formKey.currentState!.validate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _ifscErrorText != null
                  ? tr(ref, _ifscErrorText!)
                  : tr(ref, 'Invalid IFSC code. Branch does not exist.'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      print(
        '⚠️ [INSTRUCTOR KYC SCREEN] Form validation failed. Check highlighted fields.',
      );
      return;
    }

    final user = ref.read(authProvider).user;
    final hasExistingImage =
        user?.kycDocumentImage != null && user!.kycDocumentImage!.isNotEmpty;
    if (_selectedDocImage == null && !hasExistingImage) {
      print(
        '⚠️ [INSTRUCTOR KYC SCREEN] Validation failed: ID document photo is missing.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(ref, 'Please upload a photo of your ID document.')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print('📋 [INSTRUCTOR KYC SCREEN] Validated fields:');
    print('   Doc Type: $_selectedDocType');
    print(
      '   Doc Number: ${_docNumberController.text.trim().replaceAll(' ', '')}',
    );
    print('   Bank Name: ${_bankNameController.text.trim()}');
    print('   Account Name: ${_accountNameController.text.trim()}');
    print('   Account Number: ${_accountNumberController.text.trim()}');
    print('   IFSC Code: ${_ifscController.text.trim().toUpperCase()}');
    print(
      '   Photo Path: ${_selectedDocImage?.path ?? (hasExistingImage ? "Using existing photo" : "None")}',
    );

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .submitKycProfile(
            docType: _selectedDocType,
            docNumber: _docNumberController.text.trim().replaceAll(' ', ''),
            docImagePath: _selectedDocImage?.path,
            bankName: _bankNameController.text.trim(),
            accountName: _accountNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            ifscCode: _ifscController.text.trim().toUpperCase(),
          );

      print(
        '✅ [INSTRUCTOR KYC SCREEN] KYC Profile submitted successfully to backend!',
      );
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
                child: Text(
                  'KYC and Bank details submitted successfully for review!',
                ),
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
    final isRejected =
        !isVerified && !isPending && (user?.hasSubmittedKyc == true);

    final showReadOnly = (isVerified || isPending) && !_isEditingExisting;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'KYC & Payout Verification')),
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
                        label: Text(tr(ref, 'Update / Edit Submitted Details')),
                      ),
                    ),
                ] else ...[
                  // Editable Form
                  Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Government Identity
                        Text(
                          tr(ref, '1. Identity Document'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.inkDark,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(ref, 'Choose a government ID for identity verification.'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.inkSoft),
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
                              ? tr(ref, '12-digit Aadhaar Number *')
                              : tr(ref, '10-character PAN Number *'),
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
                              return _selectedDocType == 'AADHAAR'
                                  ? tr(ref, 'Please enter your Aadhaar number')
                                  : tr(ref, 'Please enter your PAN number');
                            }
                            final clean = val.trim().replaceAll(' ', '');
                            if (_selectedDocType == 'AADHAAR') {
                              if (!RegExp(r'^\d{12}$').hasMatch(clean)) {
                                return tr(ref, 'Aadhaar must be exactly 12 digits');
                              }
                            } else {
                              if (!RegExp(
                                r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
                                caseSensitive: false,
                              ).hasMatch(clean)) {
                                return tr(ref, 'Please enter a valid 10-character PAN (e.g. ABCDE1234F)');
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
                          tr(ref, '2. Bank Account (For Payouts)'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.inkDark,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(ref, 'Course & ebook earnings will be credited to this account on the 1st of every month.'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.inkSoft),
                        ),
                        const SizedBox(height: 14),

                        // Account Holder Name
                        AppTextField(
                          controller: _accountNameController,
                          label: tr(ref, 'Account Holder Name *'),
                          hint: tr(ref, 'Name as per bank passbook / statement'),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primaryGreen,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Please enter the account holder name');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Bank Name
                        AppTextField(
                          controller: _bankNameController,
                          label: tr(ref, 'Bank Name *'),
                          hint: tr(ref, 'e.g. State Bank of India, HDFC, ICICI'),
                          prefixIcon: const Icon(
                            Icons.account_balance_rounded,
                            color: AppColors.primaryGreen,
                          ),
                          onChanged: (val) {
                            _bankNameManuallyEdited = true;
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Please enter bank name');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Bank Account Number
                        AppTextField(
                          controller: _accountNumberController,
                          label: tr(ref, 'Bank Account Number *'),
                          hint: tr(ref, 'Enter account number (9 to 18 digits)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(18),
                          ],
                          prefixIcon: const Icon(
                            Icons.pin_rounded,
                            color: AppColors.primaryGreen,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Please enter account number');
                            }
                            final digits = val.trim();
                            if (digits.length < 9) {
                              return tr(ref, 'Account number must be at least 9 digits');
                            }
                            if (digits.length > 18) {
                              return tr(ref, 'Account number cannot exceed 18 digits');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Confirm Account Number
                        AppTextField(
                          controller: _confirmAccountController,
                          label: tr(ref, 'Confirm Account Number *'),
                          hint: tr(ref, 'Re-enter account number'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(18),
                          ],
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.primaryGreen,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Please re-enter account number');
                            }
                            if (val.trim() !=
                                _accountNumberController.text.trim()) {
                              return tr(ref, 'Account numbers do not match');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // IFSC Code
                        AppTextField(
                          controller: _ifscController,
                          label: tr(ref, 'IFSC Code *'),
                          hint: 'e.g. SBIN0001234',
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(11),
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                          ],
                          prefixIcon: const Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.primaryGreen,
                          ),
                          suffixIcon: _isFetchingIfsc
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                )
                              : (_isIfscValid == true
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primaryGreen,
                                        size: 20,
                                      )
                                    : (_isIfscValid == false
                                          ? const Icon(
                                              Icons.cancel_rounded,
                                              color: AppColors.error,
                                              size: 20,
                                            )
                                          : null)),
                          helperText: _ifscHelperText,
                          onChanged: _onIfscChanged,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Please enter IFSC code');
                            }
                            final clean = val.trim().toUpperCase();
                            if (!RegExp(
                              r'^[A-Z]{4}0[A-Z0-9]{6}$',
                            ).hasMatch(clean)) {
                              return tr(ref, 'Enter a valid 11-character IFSC code (e.g. SBIN0001234)');
                            }
                            if (_isIfscValid == false) {
                              return _ifscErrorText != null
                                  ? tr(ref, _ifscErrorText!)
                                  : tr(ref, 'Invalid IFSC code. Branch does not exist.');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Disclaimer / Security Note
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.security_rounded,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tr(ref, 'Your personal and banking information is 256-bit encrypted and exclusively used for instructor compliance and payout transfers.'),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.white.withValues(
                                                alpha: 0.8,
                                              )
                                            : AppColors.inkDark,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primaryGreen
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _submitKyc,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isLoading
                                  ? tr(ref, 'Please wait...')
                                  : tr(ref, 'Submit for Verification'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_isEditingExisting) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() => _isEditingExisting = false);
                              },
                              child: Text(tr(ref, 'Cancel Edit')),
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
      title = tr(ref, 'KYC Verified Guide 🛡️');
      message =
          tr(ref, 'Your identity and bank account are fully verified. You can publish courses, ebooks, and receive monthly payouts.');
    } else if (isPending) {
      bgGradientStart = AppColors.accentOrange;
      bgGradientEnd = const Color(0xFFD97706);
      icon = Icons.hourglass_top_rounded;
      title = tr(ref, 'Verification Under Review ⏳');
      message =
          tr(ref, 'Your KYC documents have been submitted to the admin team for review. Approval usually takes 24 to 48 hours.');
    } else if (isRejected) {
      bgGradientStart = AppColors.error;
      bgGradientEnd = const Color(0xFF991B1B);
      icon = Icons.warning_amber_rounded;
      title = tr(ref, 'Verification Action Required ⚠️');
      message =
          tr(ref, 'Your previous submission could not be verified. Please review your details, attach a clear photo of your ID, and resubmit.');
    } else {
      bgGradientStart = AppColors.skyBlue;
      bgGradientEnd = const Color(0xFF1D4ED8);
      icon = Icons.assignment_outlined;
      title = tr(ref, 'Complete KYC Profile 📋');
      message =
          tr(ref, 'Government ID & bank verification are required to activate course payouts and instructor badges.');
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
              color: isSelected
                  ? AppColors.primaryGreen
                  : (isDark ? Colors.white70 : AppColors.inkSoft),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                tr(ref, label),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isDark ? Colors.white : AppColors.inkDark),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
              const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedDocType == 'AADHAAR'
                    ? tr(ref, 'Upload Aadhaar Front Photo *')
                    : tr(ref, 'Upload PAN Front Photo *'),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tr(ref, 'Ensure your full name, photo, and number are clearly visible.'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
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
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _selectedDocImage = null);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _cropAndRotateCurrentDoc,
                  icon: const Icon(Icons.crop_rotate_rounded, size: 16),
                  label: Text(tr(ref, 'Crop & Rotate')),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _showImagePickerSheet,
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: Text(tr(ref, 'Change Photo')),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
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
                      child: Text(tr(ref, 'Attached ID on File')),
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
                label: Text(tr(ref, 'Upload New Photo')),
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
                      child: const Icon(
                        Icons.upload_file_rounded,
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr(ref, 'Tap to Take Photo or Browse'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(ref, 'Supports JPG, PNG up to 5MB'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
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
                      tr(ref, 'Identity Details'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isVerified
                                  ? AppColors.primaryGreen
                                  : AppColors.accentOrange)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isVerified
                          ? tr(ref, 'VERIFIED')
                          : tr(ref, 'PENDING REVIEW'),
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
                tr(ref, 'Document Type'),
                user?.kycDocumentType == 'PAN'
                    ? tr(ref, 'PAN Card')
                    : tr(ref, 'Aadhaar Card'),
              ),
              _buildSummaryRow(
                tr(ref, 'Document Number'),
                _showSubmittedDocNumber
                    ? (user?.kycDocumentNumber ?? tr(ref, 'Not provided'))
                    : _maskNumber(user?.kycDocumentNumber),
                onToggleVisibility:
                    (user?.kycDocumentNumber != null &&
                        user!.kycDocumentNumber!.isNotEmpty)
                    ? () => setState(
                        () =>
                            _showSubmittedDocNumber = !_showSubmittedDocNumber,
                      )
                    : null,
                isMasked: !_showSubmittedDocNumber,
              ),
              if (user?.kycDocumentImage != null &&
                  user!.kycDocumentImage!.isNotEmpty) ...[
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
                tr(ref, 'Registered Bank Account'),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                tr(ref, 'Bank Name'),
                user?.bankName ?? tr(ref, 'Not specified'),
              ),
              _buildSummaryRow(
                tr(ref, 'Account Holder'),
                user?.bankAccountName ?? user?.fullName ?? '',
              ),
              _buildSummaryRow(
                tr(ref, 'Account Number'),
                _showSubmittedAccountNumber
                    ? (user?.bankAccountNumber ?? tr(ref, 'Not provided'))
                    : _maskNumber(user?.bankAccountNumber),
                onToggleVisibility:
                    (user?.bankAccountNumber != null &&
                        user!.bankAccountNumber!.isNotEmpty)
                    ? () => setState(
                        () => _showSubmittedAccountNumber =
                            !_showSubmittedAccountNumber,
                      )
                    : null,
                isMasked: !_showSubmittedAccountNumber,
              ),
              _buildSummaryRow(tr(ref, 'IFSC Code'), user?.bankIfscCode ?? '••••'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    VoidCallback? onToggleVisibility,
    bool isMasked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: isMasked ? 1.5 : 0.2,
                    ),
                  ),
                ),
                if (onToggleVisibility != null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onToggleVisibility,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isMasked
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
