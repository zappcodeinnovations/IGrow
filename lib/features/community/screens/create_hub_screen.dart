import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
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
  final _rulesController = TextEditingController();

  final List<String> _districts = ['Pune'];
  final List<String> _topics = ['Precision Farming', 'Organic Cultivation'];
  bool _isSubmitting = false;

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
      );

      if (mounted) {
        ref.invalidate(communityHubsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community Hub created successfully!')),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EBE0), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hub Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _nameController,
                      label: 'Hub Name',
                      hint: 'e.g. Pune AgriTech Innovators',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter hub name' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _descController,
                      label: 'Description',
                      hint: 'Describe the purpose and goals of this hub...',
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'e.g. Maharashtra',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter state' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Districts Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EBE0), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Districts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _districtInputController,
                            label: 'District',
                            hint: 'e.g. Satara, Nashik',
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _districts.map((d) {
                        return Chip(
                          label: Text(d, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _districts.remove(d)),
                          backgroundColor: const Color(0xFFEAF5E7),
                          side: const BorderSide(color: Color(0xFFCCE4C5)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Farming Topics Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EBE0), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Farming Topics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _topicInputController,
                            label: 'Topic',
                            hint: 'e.g. Drip Irrigation, Sugarcane',
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _topics.map((t) {
                        return Chip(
                          label: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _topics.remove(t)),
                          backgroundColor: const Color(0xFFE3F2FD),
                          side: const BorderSide(color: Color(0xFFBBDEFB)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rules
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EBE0), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Community Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _rulesController,
                      label: 'Rules & Guidelines',
                      hint: '1. Keep discussions respectful.\n2. Share verified practices only.',
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter community rules' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Create Hub',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
