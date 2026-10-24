import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/community_provider.dart';

class CreateHubScreen extends ConsumerStatefulWidget {
  const CreateHubScreen({super.key});

  @override
  ConsumerState<CreateHubScreen> createState() => _CreateHubScreenState();
}

class _CreateHubScreenState extends ConsumerState<CreateHubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _stateController = TextEditingController(text: 'Maharashtra');
  final _districtInputController = TextEditingController();
  final _topicInputController = TextEditingController();
  final _rulesController = TextEditingController(
    text: '1. Respect all farmers and experts.\n2. No spam or commercial ads.\n3. Share verified agricultural knowledge only.',
  );

  final List<String> _districts = ['Nagpur'];
  final List<String> _topics = ['Cotton', 'Citrus', 'Organic Farming'];
  File? _selectedLogo;
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  static const _commonCrops = [
    'Cotton', 'Citrus', 'Soybean', 'Organic Farming', 'Dairy', 'Sugarcane', 'Wheat', 'Vegetables', 'Pulses'
  ];

  static const _commonDistricts = [
    'Nagpur', 'Wardha', 'Amravati', 'Pune', 'Nashik', 'Chhatrapati Sambhajinagar', 'Kolhapur', 'Solapur', 'Akola'
  ];

  static const _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi'
  ];

  void _showStatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _states.where((s) {
              return s.toLowerCase().contains(searchQuery.toLowerCase().trim());
            }).toList();

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
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select State',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search state...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: isDark ? Colors.black26 : const Color(0xFFF0FDF4),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFCCE4C5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFCCE4C5)),
                          ),
                        ),
                        onChanged: (val) => setModalState(() => searchQuery = val),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: isDark ? AppColors.lineDark : Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final stateName = filtered[index];
                          final isSelected = _stateController.text.trim().toLowerCase() == stateName.toLowerCase();
                          return ListTile(
                            title: Text(
                              stateName,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.primaryGreen : null,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20)
                                : null,
                            onTap: () {
                              setState(() {
                                _stateController.text = stateName;
                              });
                              Navigator.pop(bottomSheetContext);
                            },
                          );
                        },
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

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stateController.dispose();
    _districtInputController.dispose();
    _topicInputController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  void _addDistrict() {
    final text = _districtInputController.text.trim();
    if (text.isNotEmpty && !_districts.contains(text)) {
      setState(() {
        _districts.add(text);
        _districtInputController.clear();
      });
    }
  }

  void _addTopic() {
    final text = _topicInputController.text.trim();
    if (text.isNotEmpty && !_topics.contains(text)) {
      setState(() {
        _topics.add(text);
        _topicInputController.clear();
      });
    }
  }

  Future<void> _pickLogo(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1000, imageQuality: 85);
      if (picked != null) {
        setState(() => _selectedLogo = File(picked.path));
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_districts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one district.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.createHub(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        state: _stateController.text.trim(),
        districts: _districts,
        farmingTopics: _topics,
        rules: _rulesController.text.trim(),
        logoPath: _selectedLogo?.path,
      );

      if (mounted) {
        ref.invalidate(myInstructorHubProvider);
        ref.invalidate(communityHubsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community Hub launched successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create hub: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBorder = isDark ? AppColors.lineDark : const Color(0xFFE2EBE0);
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7FAF6),
      appBar: AppBar(
        title: const Text('Create Regional Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo / Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Logo / Banner',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add an attractive logo or regional farming photo for your community hub.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_selectedLogo != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _selectedLogo!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedLogo = null),
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
                                side: BorderSide(color: cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _pickLogo(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined, size: 18, color: AppColors.primaryGreen),
                              label: const Text('From Gallery'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? Colors.white : AppColors.inkDark,
                                side: BorderSide(color: cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _pickLogo(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.primaryGreen),
                              label: const Text('Take Photo'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hub Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hub Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _nameController,
                      label: 'Community Name',
                      hint: 'e.g. Nagpur Citrus & Cotton Farmers',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter community name' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _descController,
                      label: 'Description',
                      hint: 'Local agricultural network for Vidarbha & regional farmers...',
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _showStatePicker,
                      borderRadius: BorderRadius.circular(12),
                      child: IgnorePointer(
                        child: AppTextField(
                          controller: _stateController,
                          label: 'State',
                          hint: 'Select State',
                          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGreen),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter state' : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Districts Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Districts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quick Add Districts:',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.inkSoft),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _commonDistricts.map((d) {
                        final isSelected = _districts.contains(d);
                        return FilterChip(
                          label: Text(d),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.greenDark)
                                : (isDark ? Colors.white70 : AppColors.inkDark),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (!_districts.contains(d)) _districts.add(d);
                              } else {
                                _districts.remove(d);
                              }
                            });
                          },
                          backgroundColor: isDark ? Colors.black26 : const Color(0xFFF0FDF4),
                          selectedColor: isDark ? const Color(0xFF263B2B) : const Color(0xFFDCFCE7),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryGreen : cardBorder,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _districtInputController,
                            label: 'Other District',
                            hint: 'Type custom district...',
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addDistrict,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                    if (_districts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _districts.map((d) {
                          return Chip(
                            label: Text(
                              d,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isDark ? Colors.white : AppColors.inkDark,
                              ),
                            ),
                            deleteIcon: Icon(Icons.close, size: 16, color: isDark ? Colors.white70 : AppColors.inkSoft),
                            onDeleted: () => setState(() => _districts.remove(d)),
                            backgroundColor: isDark ? const Color(0xFF243629) : const Color(0xFFEAF5E7),
                            side: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFCCE4C5)),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Farming Topics Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farming Topics / Crops',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add key topics & crops:',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.inkSoft),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _commonCrops.map((c) {
                        final isSelected = _topics.contains(c);
                        return FilterChip(
                          label: Text(c),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.greenDark)
                                : (isDark ? Colors.white70 : AppColors.inkDark),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (!_topics.contains(c)) _topics.add(c);
                              } else {
                                _topics.remove(c);
                              }
                            });
                          },
                          backgroundColor: isDark ? Colors.black26 : const Color(0xFFEFF6FF),
                          selectedColor: isDark ? const Color(0xFF1D324F) : const Color(0xFFDBEAFE),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF2563EB) : cardBorder,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _topicInputController,
                            label: 'Other Topic / Crop',
                            hint: 'e.g. Soil Science, Floriculture',
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addTopic,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                    if (_topics.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _topics.map((t) {
                          return Chip(
                            label: Text(
                              t,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isDark ? Colors.white : AppColors.inkDark,
                              ),
                            ),
                            deleteIcon: Icon(Icons.close, size: 16, color: isDark ? Colors.white70 : AppColors.inkSoft),
                            onDeleted: () => setState(() => _topics.remove(t)),
                            backgroundColor: isDark ? const Color(0xFF1A3047) : const Color(0xFFE3F2FD),
                            side: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFBBDEFB)),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rules
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Rules / Guidelines',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _rulesController,
                      label: 'Guidelines for learners',
                      hint: '1. Respect all farmers.\n2. No spam.\n3. Agricultural queries only.',
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter community rules' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.lineDark : const Color(0xFFE2EBE0),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : AppColors.inkSoft,
                      side: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFCCE4C5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Create Hub',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
