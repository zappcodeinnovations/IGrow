import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

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

  Widget _buildSwitchItem({
    required String title,
    required String description,
    required bool value,
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
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Privacy settings updated'),
                  duration: Duration(milliseconds: 1800),
                ),
              );
            },
            activeColor: AppColors.primaryGreen,
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
                    onChanged: (val) => _profileVisibility = val,
                  ),
                  _buildSwitchItem(
                    title: 'Show Activity Status',
                    description: 'Let others know when you are active on the app.',
                    value: _showActivityStatus,
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
                    onChanged: (val) => _shareDataForAnalytics = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Center(
              child: TextButton(
                onPressed: () {
                  // Show privacy policy
                },
                child: const Text(
                  'Read our full Privacy Policy',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
