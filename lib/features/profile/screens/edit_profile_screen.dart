import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

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
    _experienceController = TextEditingController(text: user?.farmingExperience);
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authProvider).user;
      final authNotifier = ref.read(authProvider.notifier);

      // Upload image if selected
      if (_selectedImage != null) {
        await authNotifier.uploadAvatar(_selectedImage!.path);
      }

      // Update Basic Profile
      final basicRequest = PatchedUserProfileRequest(
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        locationState: _stateController.text,
        locationDistrict: _districtController.text,
        farmingExperience: int.tryParse(_experienceController.text) ?? 0,
        areasOfInterest: _areasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      );

      await authNotifier.updateProfile(basicRequest);

      // Update Instructor Profile if applicable
      if (user != null && user.grantedRoles.contains(UserRole.instructor)) {
        final instructorRequest = PatchedInstructorProfileRequest(
          bio: _bioController.text,
          expertiseTags: _expertiseController.text,
        ).copyWith(
          currentOccupation: _occupationController.text,
        );
        
        await authNotifier.updateInstructorProfile(instructorRequest);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool maxLines = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines ? 3 : 1,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DropdownMenu<String>(
            controller: controller,
            width: constraints.maxWidth,
            label: Text(label),
            enableSearch: true,
            enableFilter: true,
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
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
                                setState(() => _isLoading = true);
                                try {
                                  await ref.read(authProvider.notifier).deleteAvatar();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Avatar removed.')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error removing avatar: $e')),
                                    );
                                  }
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
                  _buildTextField('Full Name', _nameController),
                  _buildTextField('Phone Number', _phoneController),
                  _buildDropdownField('State', _stateController, _states),
                  _buildDropdownField('District', _districtController, _districts),
                  _buildTextField('Farming Experience (Years)', _experienceController),
                  _buildTextField('Areas of Interest (comma separated)', _areasController, maxLines: true),

                  if (isInstructor) ...[
                    const SizedBox(height: 24),
                    Text('Instructor Details', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildTextField('Bio', _bioController, maxLines: true),
                    _buildTextField('Expertise Tags (comma separated)', _expertiseController),
                    _buildTextField('Current Occupation', _occupationController),
                    _buildTextField('Website', _websiteController),
                    _buildTextField('Years of Experience', _yearsExpController),
                    _buildTextField('Specialty Crops', _cropsController),
                    _buildTextField('Social Link', _socialController),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Profile'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }
}
