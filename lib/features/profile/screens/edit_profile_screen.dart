import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_role.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic & Account info controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;

  // Student specific controllers
  late TextEditingController _experienceController;
  late TextEditingController _areasController;

  // Instructor specific controllers
  late TextEditingController _bioController;
  late TextEditingController _qualificationsController;
  late TextEditingController _expertiseController;
  late TextEditingController _websiteController;
  late TextEditingController _yearsExpController;
  late TextEditingController _cropsController;
  late TextEditingController _socialController;
  late TextEditingController _occupationController;

  File? _selectedImage;
  bool _isLoading = false;
  bool _isFetchingFresh = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _stateController = TextEditingController(text: user?.locationState ?? '');
    _districtController = TextEditingController(text: user?.locationDistrict ?? '');
    _experienceController = TextEditingController(text: _formatExperience(user?.farmingExperience));
    _areasController = TextEditingController(
      text: user?.areasOfInterest?.join(', ') ?? '',
    );

    _bioController = TextEditingController(text: user?.bio ?? '');
    _qualificationsController = TextEditingController(text: user?.qualifications ?? '');
    _expertiseController = TextEditingController(text: user?.expertiseTags ?? '');
    _websiteController = TextEditingController(text: user?.website ?? '');
    _yearsExpController = TextEditingController(text: user?.yearsOfExperience?.toString() ?? '');
    _cropsController = TextEditingController(text: user?.specialtyCrops ?? '');
    _socialController = TextEditingController(text: user?.socialLink ?? '');
    _occupationController = TextEditingController(text: user?.currentOccupation ?? '');

    // Synchronize latest profile data from server on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLatestProfile();
    });
  }

  Future<void> _loadLatestProfile() async {
    if (!mounted) return;
    setState(() => _isFetchingFresh = true);
    try {
      final freshUser = await ref.read(authProvider.notifier).refreshUserSilent();
      if (freshUser != null && mounted) {
        setState(() {
          _populateControllers(freshUser);
        });
      }
    } catch (e) {
      debugPrint('⚠️ [EditProfileScreen] Error refreshing profile: $e');
    } finally {
      if (mounted) setState(() => _isFetchingFresh = false);
    }
  }

  void _populateControllers(UserModel user) {
    if (_nameController.text.isEmpty || _nameController.text != user.fullName) {
      _nameController.text = user.fullName;
    }
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _stateController.text = user.locationState ?? '';
    _districtController.text = user.locationDistrict ?? '';
    _experienceController.text = _formatExperience(user.farmingExperience);
    _areasController.text = user.areasOfInterest?.join(', ') ?? '';

    _bioController.text = user.bio ?? '';
    _qualificationsController.text = user.qualifications ?? '';
    _expertiseController.text = user.expertiseTags ?? '';
    _websiteController.text = user.website ?? '';
    _yearsExpController.text = user.yearsOfExperience?.toString() ?? '';
    _cropsController.text = user.specialtyCrops ?? '';
    _socialController.text = user.socialLink ?? '';
    _occupationController.text = user.currentOccupation ?? '';
  }

  static const _experienceOptions = ['Beginner', 'Intermediate', 'Expert'];

  static const _popularInterests = [
    'Organic Farming',
    'Dairy Farming',
    'Agribusiness',
    'Hydroponics & Aquaponics',
    'Soil Management',
    'Crop Protection',
    'Horticulture',
    'Livestock',
    'Farm Equipment & Tech',
  ];

  static const _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi'
  ];

  static const _districts = [
    'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Bhandara', 'Buldhana',
    'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli', 'Jalgaon', 'Jalna',
    'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban', 'Nagpur', 'Nanded',
    'Nandurbar', 'Nashik', 'Osmanabad', 'Palghar', 'Parbhani', 'Pune', 'Raigad',
    'Ratnagiri', 'Sangli', 'Satara', 'Sindhudurg', 'Solapur', 'Thane', 'Wardha',
    'Washim', 'Yavatmal'
  ];

  static String _formatExperience(String? exp) {
    if (exp == null || exp.trim().isEmpty) return '';
    final trimmed = exp.trim();
    final upper = trimmed.toUpperCase();
    if (upper == 'BEGINNER' || upper.contains('BEG')) return 'Beginner';
    if (upper == 'INTERMEDIATE' || upper.contains('INT')) return 'Intermediate';
    if (upper == 'EXPERT' || upper.contains('EXP')) return 'Expert';

    // If a number was entered or saved (e.g. "10", "10 years")
    final numYears = int.tryParse(trimmed.replaceAll(RegExp(r'[^\d]'), ''));
    if (numYears != null) {
      if (numYears <= 2) return 'Beginner';
      if (numYears <= 6) return 'Intermediate';
      return 'Expert';
    }
    return 'Beginner';
  }

  static String? _toApiExperience(String? exp) => formatFarmingExperienceForApi(exp);

  static String? _formatPhone(String input) {
    String clean = input.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return null;
    if (clean.startsWith('91') && clean.length == 12) {
      clean = clean.substring(2);
    } else if (clean.startsWith('0') && clean.length == 11) {
      clean = clean.substring(1);
    }
    return clean;
  }

  static String? _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    String clean = url.trim();
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      clean = 'https://$clean';
    }
    return clean;
  }

  String _getFriendlyErrorMessage(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('socket') ||
        str.contains('failed host lookup') ||
        str.contains('clientexception') ||
        str.contains('network') ||
        str.contains('no address associated with hostname') ||
        str.contains('connection refused') ||
        str.contains('connection reset') ||
        str.contains('timed out') ||
        str.contains('timeout')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (e is ApiException) {
      if (e.isNetwork) {
        return 'No internet connection. Please check your network and try again.';
      }
      if (e.isServer) {
        return 'Server error. Please try again later.';
      }
      if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
        final messages = <String>[];
        e.fieldErrors!.forEach((field, errors) {
          final fieldName = _formatFieldName(field);
          for (final err in errors) {
            messages.add(_formatFieldError(fieldName, err));
          }
        });
        if (messages.isNotEmpty) {
          return messages.first;
        }
      }
      return _cleanErrorMessage(e.message);
    }
    return _cleanErrorMessage(e.toString());
  }

  String _formatFieldName(String field) {
    switch (field) {
      case 'bio':
        return 'Bio';
      case 'expertise_tags':
        return 'Expertise Tags';
      case 'website':
        return 'Website';
      case 'years_of_experience':
        return 'Years of Experience';
      case 'specialty_crops':
        return 'Specialty Crops';
      case 'social_link':
        return 'Social Link';
      case 'current_occupation':
        return 'Current Occupation';
      case 'qualifications':
        return 'Qualifications';
      case 'farming_experience':
        return 'Farming Experience';
      case 'full_name':
        return 'Full Name';
      case 'phone_number':
        return 'Phone Number';
      case 'location_state':
        return 'State';
      case 'location_district':
        return 'District';
      case 'areas_of_interest':
        return 'Areas of Interest';
      default:
        return field.replaceAll('_', ' ');
    }
  }

  String _formatFieldError(String fieldName, String error) {
    final lower = error.toLowerCase();
    if (lower.contains('not be null') || lower.contains('required') || lower.contains('not be blank')) {
      return 'Please fill in the $fieldName field.';
    }
    if (lower.contains('valid url') || lower.contains('valid uri')) {
      return 'Please enter a valid link for $fieldName (e.g., https://instagram.com/yourname)';
    }
    if (lower.contains('valid choice')) {
      return 'Please select a valid option for $fieldName.';
    }
    if (lower.contains('valid integer') || lower.contains('valid number')) {
      return 'Please enter a valid number for $fieldName.';
    }
    return '$fieldName: ${error.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '')}';
  }

  String _cleanErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socket') ||
        lower.contains('failed host lookup') ||
        lower.contains('clientexception') ||
        lower.contains('no address associated with hostname')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }
    if (lower.contains('not be null') || lower.contains('required')) {
      return 'Please fill in all required profile fields.';
    }
    String clean = raw
        .replaceAll(RegExp(r'ApiException\(\d+\):\s*'), '')
        .replaceAll('ClientException with SocketException:', '')
        .replaceAll('ClientException:', '')
        .replaceAll('SocketException:', '')
        .replaceAll('Exception:', '')
        .replaceAll(RegExp(r'\(OS Error:[^)]+\)'), '')
        .replaceAll(RegExp(r'uri=https?://[^\s]+'), '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .trim();
    return clean.isNotEmpty ? clean : 'Unable to update profile. Please check your inputs.';
  }

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (context.canPop()) {
      context.pop();
    } else {
      final role = ref.read(authProvider).user?.activeRole;
      if (role == UserRole.instructor) {
        context.go(RouteNames.instructorProfile);
      } else {
        context.go(RouteNames.farmerProfile);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _experienceController.dispose();
    _areasController.dispose();
    _bioController.dispose();
    _qualificationsController.dispose();
    _expertiseController.dispose();
    _websiteController.dispose();
    _yearsExpController.dispose();
    _cropsController.dispose();
    _socialController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please fill in all required fields marked with *',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(milliseconds: 2500),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authProvider).user;
      final authNotifier = ref.read(authProvider.notifier);

      // Upload image if selected
      if (_selectedImage != null) {
        await authNotifier.uploadAvatar(_selectedImage!.path);
      }

      // Update Basic Profile
      final areas = _areasController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final basicRequest = PatchedUserProfileRequest(
        fullName: _nameController.text.trim(),
        phoneNumber: _formatPhone(_phoneController.text),
        locationState: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
        locationDistrict: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
        farmingExperience: _toApiExperience(_experienceController.text),
        areasOfInterest: areas.isNotEmpty ? areas : null,
      );

      await authNotifier.updateProfile(basicRequest);

      // Update Instructor Profile if applicable
      if (user != null && user.grantedRoles.contains(UserRole.instructor)) {
        final instructorRequest = PatchedInstructorProfileRequest(
          bio: _bioController.text.isNotEmpty ? _bioController.text : null,
          expertiseTags: _expertiseController.text.isNotEmpty ? _expertiseController.text : null,
          website: _formatUrl(_websiteController.text),
          yearsOfExperience: int.tryParse(_yearsExpController.text.trim()),
          specialtyCrops: _cropsController.text.isNotEmpty ? _cropsController.text : null,
          socialLink: _formatUrl(_socialController.text),
          qualifications: _qualificationsController.text.isNotEmpty ? _qualificationsController.text.trim() : null,
          currentOccupation: _occupationController.text.isNotEmpty ? _occupationController.text : null,
        );
        
        await authNotifier.updateInstructorProfile(instructorRequest);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(milliseconds: 1800),
        ),
      );

      final role = ref.read(authProvider).user?.activeRole;
      if (role == UserRole.instructor) {
        context.go(RouteNames.instructorProfile);
      } else {
        context.go(RouteNames.farmerProfile);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final friendlyError = _getFriendlyErrorMessage(e);
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
                  friendlyError,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(milliseconds: 3000),
        ),
      );
    }
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    bool maxLines = false,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines ? 3 : 1,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
    );
  }

  void _showSearchableSelectionSheet(
    String label,
    TextEditingController controller,
    List<String> suggestions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredSuggestions = suggestions.where((item) {
              return item.toLowerCase().contains(searchQuery.toLowerCase().trim());
            }).toList();

            final hasCustomQuery = searchQuery.trim().isNotEmpty &&
                !suggestions.any((s) => s.toLowerCase() == searchQuery.trim().toLowerCase());

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2620) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select $label',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.inkDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Search Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Search $label...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setModalState(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                    ),

                    const Divider(height: 16),

                    // Options List
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          if (hasCustomQuery)
                            ListTile(
                              leading: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
                              title: Text(
                                'Use "$searchQuery"',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                              ),
                              onTap: () {
                                setState(() {
                                  controller.text = searchQuery.trim();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          if (filteredSuggestions.isEmpty && !hasCustomQuery)
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text('No matching options found'),
                              ),
                            )
                          else
                            ...filteredSuggestions.map((item) {
                              final isSelected = controller.text.trim().toLowerCase() == item.toLowerCase();
                              return ListTile(
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : (isDark ? Colors.white : AppColors.inkDark),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    controller.text = item;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectableTextField(
    String label,
    TextEditingController controller,
    List<String> suggestions, {
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showSearchableSelectionSheet(label, controller, suggestions),
        borderRadius: BorderRadius.circular(12),
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              suffixIcon: const Icon(Icons.arrow_drop_down, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyEmailField(String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _emailController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Email Address (Registered Login ID)',
          prefixIcon: const Icon(Icons.email_outlined),
          suffixIcon: const Tooltip(
            message: 'Email cannot be changed (primary login identifier)',
            child: Icon(Icons.lock_outline, size: 20, color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserModel? user) {
    final role = user?.activeRole ?? UserRole.farmer;
    final isInstructor = role == UserRole.instructor;
    final status = user?.verificationStatus ?? 'PENDING';
    final isVerified = user?.isKycVerified == true || status == 'VERIFIED';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isInstructor
            ? (isVerified ? AppColors.primaryGreen.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1))
            : AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isInstructor
              ? (isVerified ? AppColors.primaryGreen.withValues(alpha: 0.3) : Colors.amber.shade600)
              : AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isInstructor ? Icons.school_rounded : Icons.agriculture_rounded,
            color: isInstructor
                ? (isVerified ? AppColors.primaryGreen : Colors.amber.shade800)
                : AppColors.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInstructor ? 'Instructor Account' : 'Student / Farmer Account',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                if (isInstructor)
                  Text(
                    isVerified ? '✓ Verified Instructor' : '⏳ Verification Status: Pending Review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isVerified ? AppColors.primaryGreen : Colors.amber.shade900,
                    ),
                  )
                else
                  Text(
                    user?.location != null && user!.location!.isNotEmpty
                        ? '📍 ${user.location}'
                        : '🌱 AgriLearn Farmer Community',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkSoft,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farming Experience Level',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _experienceOptions.map((exp) {
              final isSelected = _experienceController.text.trim().toLowerCase() == exp.toLowerCase();
              return ChoiceChip(
                label: Text(exp),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                backgroundColor: isDark ? AppColors.cardDark : Colors.grey.shade100,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isDark ? AppColors.lineDark : Colors.grey.shade300),
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.inkDark),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _experienceController.text = exp;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAreasOfInterestSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentList = _areasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Areas of Interest',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap tags to add/remove or type custom topics below:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _popularInterests.map((tag) {
              final isSelected = currentList.any((e) => e.toLowerCase() == tag.toLowerCase());
              return FilterChip(
                label: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.inkDark),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                backgroundColor: isDark ? AppColors.cardDark : Colors.grey.shade100,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isDark ? AppColors.lineDark : Colors.grey.shade300),
                ),
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (!isSelected) currentList.add(tag);
                    } else {
                      currentList.removeWhere((e) => e.toLowerCase() == tag.toLowerCase());
                    }
                    _areasController.text = currentList.join(', ');
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _areasController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Selected Interests (comma-separated)',
              hintText: 'e.g. Organic Farming, Drip Irrigation, Crop Protection',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isInstructor = user?.grantedRoles.contains(UserRole.instructor) == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _navigateBack,
        ),
        actions: [
          if (_isFetchingFresh)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Picker
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                                backgroundImage: _selectedImage != null 
                                  ? FileImage(_selectedImage!) 
                                  : (user?.avatarUrl != null 
                                      ? NetworkImage(user!.avatarUrl!) as ImageProvider
                                      : null),
                                child: (_selectedImage == null && user?.avatarUrl == null)
                                    ? Text(
                                        user?.fullName.isNotEmpty == true
                                            ? user!.fullName[0].toUpperCase()
                                            : 'U',
                                        style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primaryGreen),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedImage != null || user?.avatarUrl != null)
                          TextButton(
                            onPressed: () async {
                              if (_selectedImage != null) {
                                setState(() {
                                  _selectedImage = null;
                                });
                              } else if (user?.avatarUrl != null) {
                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _isLoading = true);
                                try {
                                  await ref.read(authProvider.notifier).deleteAvatar();
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Avatar removed.'),
                                      duration: Duration(milliseconds: 1800),
                                    ),
                                  );
                                } catch (e) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error removing avatar: $e'),
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(milliseconds: 1800),
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              }
                            },
                            child: const Text(
                              'Remove Photo',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role & Verification Info Badge
                  _buildRoleBadge(user),

                  // Section 1: Basic & Personal Info
                  Text('Basic Information', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Full Name *', 
                    _nameController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  _buildReadOnlyEmailField(_emailController.text),
                  _buildTextField(
                    'Phone Number',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                    hintText: 'e.g. 9876543210',
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final digits = val.trim().replaceAll(RegExp(r'[^\d]'), '');
                        if (digits.length != 10 && !(digits.startsWith('91') && digits.length == 12)) {
                          return 'Mobile number must be exactly 10 digits';
                        }
                      }
                      return null;
                    },
                  ),
                  _buildSelectableTextField('State / Region', _stateController, _states, hintText: 'Select or type state'),
                  _buildSelectableTextField('District / City', _districtController, _districts, hintText: 'Select or type district'),

                  // Section 2: Student Specific Fields
                  if (!isInstructor) ...[
                    const SizedBox(height: 16),
                    Text('Farming Profile', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildExperienceSelector(),
                    _buildAreasOfInterestSelector(),
                  ],

                  // Section 3: Instructor Specific Fields
                  if (isInstructor) ...[
                    const SizedBox(height: 20),
                    Text('Instructor Professional Details', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Bio / About Me *', 
                      _bioController, 
                      maxLines: true,
                      hintText: 'Tell students about your practical background, passion, and teaching focus...',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a short bio about yourself';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      'Educational / Practical Qualifications', 
                      _qualificationsController,
                      hintText: 'e.g. M.Sc. Agronomy, Organic Certification, 15 yrs Farm Head',
                    ),
                    _buildTextField(
                      'Expertise Tags (comma-separated)', 
                      _expertiseController,
                      hintText: 'e.g. Soil Science, Organic Farming, Pest Management',
                    ),
                    _buildTextField(
                      'Years of Practical Experience', 
                      _yearsExpController, 
                      keyboardType: TextInputType.number,
                      hintText: 'e.g. 5',
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          if (int.tryParse(val.trim()) == null) {
                            return 'Please enter a valid number of years';
                          }
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      'Specialty Crops / Focus Areas', 
                      _cropsController,
                      hintText: 'e.g. Wheat, Sugarcane, Cotton, Drip Horticulture',
                    ),
                    _buildTextField(
                      'Current Occupation / Role', 
                      _occupationController,
                      hintText: 'e.g. Agricultural Officer, Progressive Farmer, Crop Consultant',
                    ),
                    _buildTextField(
                      'Website / Portfolio Link', 
                      _websiteController,
                      keyboardType: TextInputType.url,
                      hintText: 'https://yourwebsite.com',
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final text = val.trim();
                          if (!text.contains('.') || text.length < 4) {
                            return 'Please enter a valid website link (e.g. https://example.com)';
                          }
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      'Social Media Link', 
                      _socialController,
                      keyboardType: TextInputType.url,
                      hintText: 'https://youtube.com/@channel or https://linkedin.com/in/profile',
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final text = val.trim();
                          if (!text.contains('.') || text.length < 4) {
                            return 'Please enter a valid social link (e.g. https://instagram.com/yourname)';
                          }
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper function to normalize any farming experience input (e.g., '10', '10 years', 'Expert')
/// into valid backend ChoiceField strings ('BEGINNER', 'INTERMEDIATE', 'EXPERT').
String? formatFarmingExperienceForApi(String? exp) {
  if (exp == null || exp.trim().isEmpty) return null;
  final trimmed = exp.trim();
  final upper = trimmed.toUpperCase();
  if (upper == 'BEGINNER' || upper.contains('BEG')) return 'BEGINNER';
  if (upper == 'INTERMEDIATE' || upper.contains('INT')) return 'INTERMEDIATE';
  if (upper == 'EXPERT' || upper.contains('EXP')) return 'EXPERT';

  // Convert numeric inputs (e.g. "10", "10 years", "5") to valid Django choice strings
  final numYears = int.tryParse(trimmed.replaceAll(RegExp(r'[^\d]'), ''));
  if (numYears != null) {
    if (numYears <= 2) return 'BEGINNER';
    if (numYears <= 6) return 'INTERMEDIATE';
    return 'EXPERT';
  }

  // Always fallback to a valid backend choice enum string rather than an arbitrary value
  return 'BEGINNER';
}
