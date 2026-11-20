import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';
import '../widgets/my_students_sheet.dart';

class InstructorAnalyticsScreen extends ConsumerWidget {
  const InstructorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(instructorStatsProvider);
    final transactionsAsync = ref.watch(instructorTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(ref, 'Analytics & Payouts'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: tr(ref, 'Retry'),
            onPressed: () {
              ref.invalidate(instructorStatsProvider);
              ref.invalidate(instructorTransactionsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async {
          ref.invalidate(instructorStatsProvider);
          ref.invalidate(instructorTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Summary Header ──
              Text(
                tr(ref, 'Financial Performance'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                tr(
                  ref,
                  'Track your real-time earnings, sales ledger, and course enrollments.',
                ),
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
              ),
              const SizedBox(height: 18),

              // ── Key Metrics Cards ──
              statsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Error loading stats: $err',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
                data: (stats) {
                  final totalEarnings =
                      (stats['total_earnings'] as num?)?.toDouble() ?? 0.0;
                  final totalRevenue =
                      (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
                  final totalStudents = stats['total_students'] ?? 0;
                  final totalEnrollments = stats['total_enrollments'] ?? 0;
                  final activeCourses = stats['active_courses'] ?? 0;
                  final totalCourses = stats['total_courses'] ?? 0;
                  final avgRating =
                      (stats['average_rating'] as num?)?.toDouble() ?? 4.8;

                  return Column(
                    children: [
                      // Net Earnings Hero Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primaryGreen, Color(0xFF1B5E20)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr(ref, 'NET INSTRUCTOR EARNINGS'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tr(ref, '70% Split'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '₹${formatNum(ref, totalEarnings.toStringAsFixed(2))}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${tr(ref, 'Gross Sales Revenue')}: ₹${formatNum(ref, totalRevenue.toStringAsFixed(2))}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      final user = ref.read(authProvider).user;
                                      final isVerified = user?.isKycVerified == true || user?.isAdmin == true;
                                      if (!isVerified) {
                                        _showKycPayoutRequiredDialog(context, ref);
                                      } else {
                                        AppToast.show(
                                          context,
                                          tr(ref, 'Payouts are processed automatically on the 1st of every month to your verified bank account.'),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.account_balance_wallet_rounded,
                                            size: 14,
                                            color: AppColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            tr(ref, 'Get Payout'),
                                            style: const TextStyle(
                                              color: AppColors.primaryGreen,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Metric Grid (4 Cards: Students, Courses, E-Books, Reviews)
                      Builder(
                        builder: (context) {
                          final txs = transactionsAsync.value ?? [];
                          final distinctProfiles =
                              InstructorStudentProfile.groupTransactions(txs);
                          final distinctStudentCount =
                              distinctProfiles.isNotEmpty
                              ? distinctProfiles.length
                              : totalStudents;

                          final ebooksAsync = ref.watch(
                            instructorEbooksProvider,
                          );
                          final totalEbooks =
                              ebooksAsync.value?.length ??
                              (stats['total_ebooks'] as num?)?.toInt() ??
                              0;

                          final reviewsAsync = ref.watch(
                            instructorReviewsProvider,
                          );
                          final liveReviews = reviewsAsync.value;
                          final liveCount = liveReviews?.length;
                          final totalReviewsCount =
                              (liveCount != null && liveCount > 0)
                              ? liveCount
                              : ((stats['total_reviews'] as num?)?.toInt() ??
                                    0);

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricTile(
                                      icon: Icons.people_alt_rounded,
                                      iconColor: AppColors.skyBlue,
                                      label: tr(ref, 'Students'),
                                      value: formatNum(
                                        ref,
                                        distinctStudentCount,
                                      ),
                                      subtext:
                                          '${formatNum(ref, totalEnrollments)} ${tr(ref, 'enrollments')}',
                                      isDark: isDark,
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                          ),
                                          builder: (sheetContext) {
                                            return DraggableScrollableSheet(
                                              initialChildSize: 0.72,
                                              minChildSize: 0.45,
                                              maxChildSize: 0.95,
                                              expand: false,
                                              builder: (_, scrollController) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      sheetContext,
                                                    ).scaffoldBackgroundColor,
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            24,
                                                          ),
                                                        ),
                                                  ),
                                                  child: MyStudentsSheet(
                                                    transactions: txs,
                                                    totalStudents:
                                                        totalStudents,
                                                    totalEnrollments:
                                                        totalEnrollments,
                                                    scrollController:
                                                        scrollController,
                                                    onOpenLedger: () {
                                                      Navigator.pop(
                                                        sheetContext,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _MetricTile(
                                      icon: Icons.play_lesson_rounded,
                                      iconColor: AppColors.primaryGreen,
                                      label: tr(ref, 'Courses'),
                                      value:
                                          '${formatNum(ref, activeCourses)} / ${formatNum(ref, totalCourses)}',
                                      subtext: tr(ref, 'Published courses'),
                                      isDark: isDark,
                                      onTap: () => context.push(
                                        RouteNames.instructorUploads,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricTile(
                                      icon: Icons.menu_book_rounded,
                                      iconColor: AppColors.accentOrange,
                                      label: tr(ref, 'E-Books'),
                                      value: formatNum(ref, totalEbooks),
                                      subtext: tr(ref, 'Published e-books'),
                                      isDark: isDark,
                                      onTap: () => context.push(
                                        '${RouteNames.instructorUploads}?tab=1',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _MetricTile(
                                      icon: Icons.star_rounded,
                                      iconColor: AppColors.signalYellow,
                                      label: tr(ref, 'Reviews'),
                                      value: formatNum(ref, totalReviewsCount),
                                      subtext:
                                          '⭐ ${formatNum(ref, avgRating.toStringAsFixed(1))} ${tr(ref, 'rating')}',
                                      isDark: isDark,
                                      onTap: () => context.push(
                                        RouteNames.instructorReviews,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // ── Sales Transactions Ledger Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(ref, 'Recent Sales Ledger'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  transactionsAsync.maybeWhen(
                    data: (txs) => Text(
                      '${formatNum(ref, txs.length)} ${tr(ref, 'transactions')}',
                      style: const TextStyle(
                        color: AppColors.inkSoft,
                        fontSize: 13,
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Transactions List ──
              transactionsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Unable to load transaction history: $err'),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: tr(ref, 'No Sales Transactions Recorded Yet'),
                        subtitle: tr(
                          ref,
                          'When students enroll in and purchase your courses, their verified payments will appear in this ledger.',
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final id = tx['id']?.toString() ?? 'TXN-000';
                      final item = tx['item']?.toString() ?? 'Course Purchase';
                      final buyer = tx['buyer']?.toString() ?? 'Student';
                      final date = tx['date']?.toString() ?? '';
                      final rawAmount = tx['amount'] != null
                          ? '${tx['amount']}'
                          : '0.00';
                      final amount = '₹${formatNum(ref, rawAmount)}';
                      final status = tx['status']?.toString() ?? 'SUCCESS';

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E231F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : AppColors.lineLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_rounded,
                                color: AppColors.primaryGreen,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr(ref, item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${tr(ref, 'Buyer')}: $buyer • ${formatNum(ref, date)}',
                                    style: const TextStyle(
                                      color: AppColors.inkSoft,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    id,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  amount,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: status == 'SUCCESS'
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tr(ref, status),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: status == 'SUCCESS'
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKycPayoutRequiredDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    final isPending = user?.isKycPending == true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPending ? AppColors.accentOrange : AppColors.error).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPending ? Icons.hourglass_top_rounded : Icons.verified_user_outlined,
                  color: isPending ? AppColors.accentOrange : AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr(ref, isPending ? 'KYC Under Review' : 'KYC Required for Payouts'),
                  style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            tr(
              ref,
              isPending
                  ? 'Your KYC and bank details have been submitted and are under review. Once approved, monthly revenue payouts will transfer automatically.'
                  : 'To receive payouts for your courses and e-books into your bank account, government KYC and bank verification is required.',
            ),
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(height: 1.5, color: AppColors.inkSoft),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(tr(ref, 'Close')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isPending ? AppColors.accentOrange : AppColors.primaryGreen,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(RouteNames.instructorKyc);
              },
              child: Text(tr(ref, isPending ? 'Check KYC Status' : 'Complete KYC Now')),
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtext,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtext;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E231F) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white10 : AppColors.lineLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
