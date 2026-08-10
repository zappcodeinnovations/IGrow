import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/growth_ring_progress.dart';
import '../../../core/widgets/app_card.dart';

/// Placeholder Instructor Analytics screen. Full build in Phase 5.
class InstructorAnalyticsScreen extends StatelessWidget {
  const InstructorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Track your course performance and revenue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 24),
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹1.24L',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primaryGreen,),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Revenue',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft,),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1,247',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.skyBlue,),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Students',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft,),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Chart placeholder
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Earnings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 48,
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chart coming in Phase 5',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft,),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Engagement ring
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const GrowthRingProgress(
                      percent: 0.78,
                      size: 90,
                      strokeWidth: 9,
                      label: '78%',
                      sublabel: 'Engagement',
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Engagement',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _StatRow('Avg Watch Time', '12m 34s'),
                          _StatRow('Completion Rate', '78%'),
                          _StatRow('Certificates Issued', '156'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
          Text(value, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
