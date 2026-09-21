import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'app_card.dart';

/// Reusable full-screen guard shown to Instructors who have not completed
/// KYC verification before uploading courses or e-books.
class KycRestrictedView extends ConsumerWidget {
  const KycRestrictedView({
    super.key,
    this.featureName = 'Course & E-Book Upload',
  });

  final String featureName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPending = user?.isKycPending == true;

    final Color statusColor = isPending ? AppColors.accentOrange : AppColors.error;
    final IconData statusIcon =
        isPending ? Icons.hourglass_top_rounded : Icons.verified_user_outlined;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon glow container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                statusIcon,
                size: 48,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 24),

            // Status Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPending ? Icons.sync : Icons.lock_outline_rounded,
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPending ? 'VERIFICATION UNDER REVIEW' : 'KYC REQUIRED',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isPending
                  ? 'KYC Approval Pending'
                  : 'Complete KYC to Access $featureName',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
            ),
            const SizedBox(height: 12),

            // Description Body
            Text(
              isPending
                  ? 'Your KYC documents and bank details have been submitted and are currently under review by our team. Content upload features will unlock automatically once approved.'
                  : 'As per AgriLearn instructor policies, Government ID verification and Bank Account details are required before creating courses or publishing e-books.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 28),

            // Checklist Card
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructor Requirements:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildCheckItem(
                    context,
                    title: 'Government ID Verification',
                    subtitle: 'Aadhaar / PAN Card upload',
                    isDone: user?.kycDocumentNumber != null && user!.kycDocumentNumber!.isNotEmpty,
                    isPending: isPending,
                  ),
                  const Divider(height: 20),
                  _buildCheckItem(
                    context,
                    title: 'Bank Account & Payout Details',
                    subtitle: 'For receiving course sales payouts',
                    isDone: user?.bankAccountNumber != null && user!.bankAccountNumber!.isNotEmpty,
                    isPending: isPending,
                  ),
                  const Divider(height: 20),
                  _buildCheckItem(
                    context,
                    title: 'Admin Verification Approval',
                    subtitle: 'Review takes 24-48 business hours',
                    isDone: user?.isKycVerified == true,
                    isPending: isPending,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // CTA Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending ? AppColors.accentOrange : AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  context.push(RouteNames.instructorKyc);
                },
                icon: Icon(isPending ? Icons.remove_red_eye_outlined : Icons.shield_outlined),
                label: Text(
                  isPending ? 'Check KYC Status' : 'Complete KYC Verification Now',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.instructorHome);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to Dashboard'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isPending,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconColor;
    IconData icon;

    if (isDone) {
      iconColor = AppColors.primaryGreen;
      icon = Icons.check_circle_rounded;
    } else if (isPending) {
      iconColor = AppColors.accentOrange;
      icon = Icons.hourglass_bottom_rounded;
    } else {
      iconColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
