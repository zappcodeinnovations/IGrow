import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/delete_account_dialog.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _profileVisibility = true;
  bool _showActivityStatus = true;
  bool _allowDirectMessages = true;
  bool _shareDataForAnalytics = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _profileVisibility = prefs.getBool('privacy_profile_visibility') ?? true;
          _showActivityStatus = prefs.getBool('privacy_activity_status') ?? true;
          _allowDirectMessages = prefs.getBool('privacy_direct_messages') ?? true;
          _shareDataForAnalytics = prefs.getBool('privacy_share_analytics') ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  void _showPrivacyPolicyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.primaryGreen, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'IGrow Privacy Policy',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last Updated: September 2026',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '1. Information We Collect\n'
                    'We collect personal details such as your name, email, contact number, and regional farming preferences to provide tailored agricultural courses and advisory services.\n\n'
                    '2. How We Use Your Data\n'
                    'Your data is utilized solely for course enrollment, certificate generation, peer community networking, and app performance improvements. We never sell your personal information to third parties.\n\n'
                    '3. Payment Security\n'
                    'All transactions are processed through encrypted financial gateways conforming to PCI-DSS standards. We do not store credit card or bank account credentials on our servers.\n\n'
                    '4. Your Choices & Controls\n'
                    'You retain complete control over your public profile visibility, activity status, and direct messaging privileges through this Privacy Settings tab.',
                    style: TextStyle(fontSize: 13.5, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String description,
    required bool value,
    required String prefKey,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: (val) {
              setState(() {
                onChanged(val);
              });
              _savePreference(prefKey, val);
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Privacy preference saved'),
                  duration: Duration(milliseconds: 1400),
                ),
              );
            },
            activeThumbColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Manage Your Privacy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Control who sees your profile and how your data is used.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 24),
            
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Visibility',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 24),
                  _buildSwitchItem(
                    title: 'Public Profile',
                    description: 'Allow other users to find and view your profile.',
                    value: _profileVisibility,
                    prefKey: 'privacy_profile_visibility',
                    onChanged: (val) => _profileVisibility = val,
                  ),
                  _buildSwitchItem(
                    title: 'Show Activity Status',
                    description: 'Let others know when you are active on the app.',
                    value: _showActivityStatus,
                    prefKey: 'privacy_activity_status',
                    onChanged: (val) => _showActivityStatus = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Communications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 24),
                  _buildSwitchItem(
                    title: 'Allow Direct Messages',
                    description: 'Receive messages from anyone in the community.',
                    value: _allowDirectMessages,
                    prefKey: 'privacy_direct_messages',
                    onChanged: (val) => _allowDirectMessages = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data & Analytics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 24),
                  _buildSwitchItem(
                    title: 'Share Analytics',
                    description: 'Help us improve by sharing anonymous usage data.',
                    value: _shareDataForAnalytics,
                    prefKey: 'privacy_share_analytics',
                    onChanged: (val) => _shareDataForAnalytics = val,
                  ),
                ],
              ),
            ),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.delete_forever_outlined,
                        color: AppColors.error,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Account & Data Deletion',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    'You have full control over your personal data. Deleting your account will immediately and permanently erase all your personal information, profile records, enrolled courses, certificates, and app progress from IGrow.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSoft,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          showDeleteAccountConfirmationDialog(context, ref),
                      icon: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      label: const Text(
                        'Delete My Account',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Center(
              child: TextButton.icon(
                onPressed: () => _showPrivacyPolicyModal(context),
                icon: const Icon(Icons.description_outlined, size: 18, color: AppColors.primaryGreen),
                label: const Text(
                  'Read our full Privacy Policy',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
