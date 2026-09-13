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
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic info controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  late TextEditingController _experienceController;
  late TextEditingController _areasController;

  // Instructor info controllers
  late TextEditingController _bioController;
  late TextEditingController _expertiseController;
  late TextEditingController _websiteController;
  late TextEditingController _yearsExpController;
  late TextEditingController _cropsController;
  late TextEditingController _socialController;
  late TextEditingController _occupationController;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    
    _nameController = TextEditingController(text: user?.fullName);
    _phoneController = TextEditingController(text: user?.phone);
    _stateController = TextEditingController(text: user?.locationState);
    _districtController = TextEditingController(text: user?.locationDistrict);
    _experienceController = TextEditingController(text: _formatExperience(user?.farmingExperience));
    _areasController = TextEditingController(
      text: user?.areasOfInterest?.join(', ') ?? '',
    );

    _bioController = TextEditingController(text: user?.bio);
    _expertiseController = TextEditingController(text: user?.expertiseTags);
    _websiteController = TextEditingController(text: user?.website);
    _yearsExpController = TextEditingController(text: user?.yearsOfExperience?.toString());
    _cropsController = TextEditingController(text: user?.specialtyCrops);
    _socialController = TextEditingController(text: user?.socialLink);
    _occupationController = TextEditingController(text: user?.currentOccupation);
  }

  static const _experienceOptions = ['Beginner', 'Intermediate', 'Expert'];

  static String _formatExperience(String? exp) {
    if (exp == null || exp.trim().isEmpty) return '';
    final upper = exp.trim().toUpperCase();
    if (upper == 'BEGINNER') return 'Beginner';
    if (upper == 'INTERMEDIATE') return 'Intermediate';
    if (upper == 'EXPERT') return 'Expert';
    return exp.trim();
  }

  static String? _toApiExperience(String? exp) {
    if (exp == null || exp.trim().isEmpty) return null;
    final trimmed = exp.trim();
    final upper = trimmed.toUpperCase();
    if (upper == 'BEGINNER' || upper.contains('BEG')) return 'BEGINNER';
    if (upper == 'INTERMEDIATE' || upper.contains('INT')) return 'INTERMEDIATE';
    if (upper.contains('EXP') || upper == 'EXPERT') return 'EXPERT';
    // If it's a number, convert to String as required by backend
    return trimmed.toString();
  }

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
    _phoneController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _experienceController.dispose();
    _areasController.dispose();
    _bioController.dispose();
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> options) {
    final hasMatch = options.contains(controller.text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DropdownMenu<String>(
            controller: controller,
            initialSelection: hasMatch ? controller.text : null,
            width: constraints.maxWidth,
            label: Text(label),
            enableSearch: true,
            enableFilter: true,
            onSelected: (val) {
              if (val != null) {
                controller.text = val;
              }
            },
            dropdownMenuEntries: options.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          );
        }
      ),
    );
  }

  static const _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];

  static const _districts = [
    'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Bhandara', 'Buldhana',
    'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli', 'Jalgaon', 'Jalna',
    'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban', 'Nagpur', 'Nanded',
    'Nandurbar', 'Nashik', 'Osmanabad', 'Palghar', 'Parbhani', 'Pune', 'Raigad',
    'Ratnagiri', 'Sangli', 'Satara', 'Sindhudurg', 'Solapur', 'Thane', 'Wardha',
    'Washim', 'Yavatmal'
  ];

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
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
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
                  const SizedBox(height: 32),

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
                  _buildTextField(
                    'Phone Number',
                    _phoneController,
                    keyboardType: TextInputType.phone,
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
                  _buildDropdownField('State', _stateController, _states),
                  _buildDropdownField('District', _districtController, _districts),
                  _buildDropdownField('Farming Experience', _experienceController, _experienceOptions),
                  _buildTextField('Areas of Interest (comma separated)', _areasController, maxLines: true),

                  if (isInstructor) ...[
                    const SizedBox(height: 24),
                    Text('Instructor Details', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Bio *', 
                      _bioController, 
                      maxLines: true,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a short bio about yourself';
                        }
                        return null;
                      },
                    ),
                    _buildTextField('Expertise Tags (comma separated)', _expertiseController),
                    _buildTextField('Current Occupation', _occupationController),
                    _buildTextField(
                      'Website', 
                      _websiteController,
                      keyboardType: TextInputType.url,
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
                      'Years of Experience', 
                      _yearsExpController, 
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          if (int.tryParse(val.trim()) == null) {
                            return 'Please enter a valid number of years';
                          }
                        }
                        return null;
                      },
                    ),
                    _buildTextField('Specialty Crops', _cropsController),
                    _buildTextField(
                      'Social Link', 
                      _socialController,
                      keyboardType: TextInputType.url,
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
                          : const Text('Save Profile'),
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
