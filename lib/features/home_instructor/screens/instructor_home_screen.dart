import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/api_models/course_models.dart';
import '../providers/instructor_home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../auth/providers/auth_provider.dart';
import '../../explore/providers/explore_provider.dart';
import '../../home_farmer/providers/farmer_home_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../instructor_dashboard/widgets/my_students_sheet.dart';

class InstructorHomeScreen extends ConsumerStatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  ConsumerState<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends ConsumerState<InstructorHomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _ordering = '';
  int _selectedDashboardTab = 0; // 0 for Recent Courses, 1 for My E-Books

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshUserSilent();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStudentsBottomSheet(BuildContext context, Map<String, dynamic> stats) {
    final transactionsAsync = ref.read(instructorTransactionsProvider);
    final txs = transactionsAsync.value ?? [];
    final distinctProfiles = InstructorStudentProfile.groupTransactions(txs);
    final totalStudents = distinctProfiles.isNotEmpty
        ? distinctProfiles.length
        : (stats['total_students'] ?? 0);
    final totalEnrollments = txs.isNotEmpty
        ? txs.length
        : (stats['total_enrollments'] ?? totalStudents);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Theme.of(sheetContext).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: MyStudentsSheet(
                transactions: txs,
                totalStudents: totalStudents,
                totalEnrollments: totalEnrollments,
                scrollController: scrollController,
                onOpenLedger: () {
                  Navigator.pop(sheetContext);
                  context.push(RouteNames.instructorAnalytics);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showReviewsBottomSheet(BuildContext context, Map<String, dynamic> stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Consumer(
          builder: (context, ref, _) {
            final reviewsAsync = ref.watch(instructorReviewsProvider);
            final liveReviews = reviewsAsync.value ?? [];
            final totalReviews = liveReviews.isNotEmpty
                ? liveReviews.length
                : ((stats['total_reviews'] as num?)?.toInt() ?? 0);
            final double avgRating = liveReviews.isNotEmpty
                ? (liveReviews.map((r) => (r['rating'] as num?)?.toInt() ?? 5).reduce((a, b) => a + b) / liveReviews.length)
                : ((stats['average_rating'] as num?)?.toDouble() ?? 5.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.signalYellow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.star_rounded, color: AppColors.signalYellow, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Reviews & Ratings',
                                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '⭐ ${avgRating.toStringAsFixed(1)} average rating • $totalReviews student reviews',
                                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < avgRating.floor() ? Icons.star_rounded : (i < avgRating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                                    color: AppColors.signalYellow,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Based on $totalReviews verified enrolled student ratings',
                                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.signalYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.rate_review_outlined, color: AppColors.signalYellow, size: 20),
                    ),
                    title: const Text('Manage Reviews & Replies', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('See all $totalReviews ratings and reply to students', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push(RouteNames.instructorReviews);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.question_answer_outlined, color: AppColors.primaryGreen, size: 20),
                    ),
                    title: const Text('Student Q&A & Inquiries', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Manage student discussions and doubts', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/instructor/qa');
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTransactionDetailsModal(BuildContext context, Map<String, dynamic> txn) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = txn['id']?.toString() ?? txn['transaction_id']?.toString() ?? 'TXN-000';
    final item = txn['item']?.toString() ?? txn['course_title']?.toString() ?? txn['description']?.toString() ?? 'Course Purchase';
    final buyer = txn['buyer']?.toString() ?? txn['student_name']?.toString() ?? 'Student';
    final date = txn['date']?.toString() ?? txn['created_at']?.toString() ?? 'Recently';
    final amount = txn['amount'] != null ? '₹${txn['amount']}' : '₹0.00';
    final status = txn['status']?.toString() ?? 'SUCCESS';
    final paymentMethod = txn['payment_method']?.toString() ?? txn['payment_mode']?.toString() ?? 'Online Payment';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryGreen, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(ref, 'Transaction Receipt'),
                              style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              id,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : AppColors.inkSoft,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.lineLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr(ref, 'Amount Credited'), style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                          Text(
                            formatNum(ref, amount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr(ref, 'Status'), style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: status.toUpperCase().contains('FAIL')
                                  ? Colors.red.withValues(alpha: 0.12)
                                  : Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tr(ref, status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: status.toUpperCase().contains('FAIL') ? Colors.red : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr(ref, 'Item / Course'), style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                          Flexible(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.end,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr(ref, 'Enrolled Student'), style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                          Text(buyer, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr(ref, 'Date & Time'), style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                          Text(formatNum(ref, date), style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr(ref, 'Payment Method'), style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                          Text(tr(ref, paymentMethod), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primaryGreen),
                      foregroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: Text(tr(ref, 'View Full Financial Ledger'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      context.push(RouteNames.instructorAnalytics);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deactivateCourse(ApiCourseList course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr(ref, 'Deactivate Course'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '${tr(ref, 'Are you sure you want to deactivate')} "${course.title}"?\n\n'
          '${tr(ref, 'The course will be moved to Draft status and hidden from the public marketplace. You can review and manage it anytime.')}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr(ref, 'Cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr(ref, 'Deactivate')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(instructorRepositoryProvider).updateCourse(course.id, {
          'status': 'DRAFT',
        });
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(tr(ref, 'Course deactivated and moved to Drafts')),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorCoursesProvider);
        ref.invalidate(instructorCourseDetailProvider(course.id));
        unawaited(ref.refresh(instructorCoursesProvider((search: _searchQuery, ordering: _ordering)).future));
        ref.invalidate(studentCatalogProvider);
        ref.invalidate(featuredCoursesProvider);
        ref.invalidate(exploreCoursesProvider);
      } catch (e) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${tr(ref, 'Failed to deactivate course:')} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteCourse(ApiCourseList course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr(ref, 'Delete Course')),
        content: Text('${tr(ref, 'Are you sure you want to permanently delete')} "${course.title}"? ${tr(ref, 'This action cannot be undone.')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr(ref, 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr(ref, 'Delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(instructorRepositoryProvider).deleteCourse(course.id);
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(tr(ref, 'Course deleted successfully')),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorCoursesProvider);
        ref.invalidate(instructorCourseDetailProvider(course.id));
        unawaited(ref.refresh(instructorCoursesProvider((search: _searchQuery, ordering: _ordering)).future));
        ref.invalidate(studentCatalogProvider);
        ref.invalidate(featuredCoursesProvider);
        ref.invalidate(exploreCoursesProvider);
      } catch (e) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final userName = (user != null && user.fullName.isNotEmpty) ? user.fullName : 'Ravi Kumar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        toolbarHeight: 70,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${tr(ref, 'Welcome')} 👨‍🏫',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkSoft,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      if (user?.isKycVerified == true) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.primaryGreen,
                          size: 22,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                final unreadCount = ref.watch(unreadNotificationsCountProvider);
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(RouteNames.notifications),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: isDark ? AppColors.white : AppColors.inkDark,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accentOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(authProvider.notifier).refreshUserSilent(),
              Future.microtask(() => ref.invalidate(instructorStatsProvider)),
              Future.microtask(() => ref.invalidate(instructorCoursesProvider)),
              Future.microtask(() => ref.invalidate(instructorEbooksProvider)),
              Future.microtask(() => ref.invalidate(instructorTransactionsProvider)),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                tr(ref, 'Manage your courses, revenue, and AI moderation status.'),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 14),

              // Quick Action Buttons matching Screenshot 1 & 5
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push(RouteNames.uploadCourse),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: Text(
                        tr(ref, 'Create a New Course'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF9333EA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push(RouteNames.uploadEbook),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: Text(
                      tr(ref, 'New E-Book'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // KYC Alert / Banner if not verified
              if (user?.isKycVerified != true) ...[
                _KycPromptBanner(
                  isPending: user?.isKycPending == true,
                  onTap: () => context.push(RouteNames.instructorKyc),
                ),
                const SizedBox(height: 16),
              ],

              // Stats Row
              ref.watch(instructorStatsProvider).when(
                data: (stats) {
                  final transactionsAsync = ref.watch(instructorTransactionsProvider);
                  final txs = transactionsAsync.value ?? [];
                  final distinctProfiles = InstructorStudentProfile.groupTransactions(txs);
                  final distinctStudentCount = distinctProfiles.isNotEmpty
                      ? distinctProfiles.length
                      : (stats['total_students'] ?? 0);

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_alt_rounded,
                          label: tr(ref, 'Students'),
                          value: formatNum(ref, distinctStudentCount),
                          color: AppColors.skyBlue,
                          onTap: () => _showStudentsBottomSheet(context, stats),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.play_lesson_rounded,
                          label: tr(ref, 'Courses'),
                          value: formatNum(ref, stats['total_courses'] ?? 0),
                          color: AppColors.primaryGreen,
                          onTap: () => context.push(RouteNames.instructorUploads),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final ebooksAsync = ref.watch(instructorEbooksProvider);
                            final totalEbooks = ebooksAsync.value?.length ??
                                (stats['total_ebooks'] as num?)?.toInt() ??
                                0;
                            return _StatCard(
                              icon: Icons.menu_book_rounded,
                              label: tr(ref, 'E-Books'),
                              value: formatNum(ref, totalEbooks),
                              color: AppColors.accentOrange,
                              onTap: () => context.push('${RouteNames.instructorUploads}?tab=1'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final reviewsAsync = ref.watch(instructorReviewsProvider);
                            final liveReviews = reviewsAsync.value;
                            final liveCount = liveReviews?.length;
                            final totalReviewsCount = (liveCount != null && liveCount > 0)
                                ? liveCount
                                : ((stats['total_reviews'] as num?)?.toInt() ?? 0);

                            return _StatCard(
                              icon: Icons.star_rounded,
                              label: tr(ref, 'Reviews'),
                              value: formatNum(ref, totalReviewsCount),
                              color: AppColors.signalYellow,
                              onTap: () => _showReviewsBottomSheet(context, stats),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Row(
                  children: [
                    Expanded(child: ShimmerCard(height: 100)),
                    const SizedBox(width: 8),
                    Expanded(child: ShimmerCard(height: 100)),
                    const SizedBox(width: 8),
                    Expanded(child: ShimmerCard(height: 100)),
                    const SizedBox(width: 8),
                    Expanded(child: ShimmerCard(height: 100)),
                  ],
                ),
                error: (err, _) => const SizedBox(),
              ),
              const SizedBox(height: 24),

              // Upload Guide Chatbot Banner
              AppCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  context.push(RouteNames.uploadGuide);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background Image
                      // Positioned.fill(
                      //   child: Image.asset(
                      //     'assets/images/igrow_teacher_bot.png',
                      //     fit: BoxFit.cover,
                      //     alignment: Alignment.topCenter,
                      //   ),
                      // ),
                      // Blur overlay
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white.withValues(alpha: 0.8), width: 2),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/igrow_teacher_bot.png'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr(ref, 'Instructor Guide'),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.white, 
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tr(ref, 'Learn how to upload courses and ebooks with our AI assistant.'),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Tab Header: Recent Courses & My E-Books (Matching Screenshot 1 & 5)
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _selectedDashboardTab = 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(ref, 'Recent Courses'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedDashboardTab == 0
                                ? AppColors.primaryGreen
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        ),
                        if (_selectedDashboardTab == 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 3,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  InkWell(
                    onTap: () => setState(() => _selectedDashboardTab = 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(ref, 'My E-Books'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedDashboardTab == 1
                                ? AppColors.primaryGreen
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        ),
                        if (_selectedDashboardTab == 1)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 3,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      final tabParam = _selectedDashboardTab == 1 ? '?tab=1' : '';
                      context.push('${RouteNames.instructorUploads}$tabParam');
                    },
                    child: Text(tr(ref, 'See All')),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_selectedDashboardTab == 0)
                ref.watch(instructorCoursesProvider((search: _searchQuery, ordering: _ordering))).when(
                  data: (courses) {
                    final isSearching = _searchQuery.trim().isNotEmpty;
                    if (courses.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSearching ? Icons.search_off_rounded : Icons.video_library_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isSearching
                                    ? '${tr(ref, 'No courses found matching')} "$_searchQuery"'
                                    : tr(ref, 'No courses created yet.'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (isSearching)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  label: Text(tr(ref, 'Clear Search')),
                                )
                              else
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.accentOrange),
                                  onPressed: () => context.push(RouteNames.uploadCourse),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(tr(ref, 'Create First Course')),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: courses.take(5).map((course) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AgriLearnCourseCard(
                            course: course,
                            onManage: () => context.push('/instructor/manage-course/${course.id}'),
                            onViewLive: () {
                              final target = (course.slug != null && course.slug!.isNotEmpty) ? course.slug! : course.id;
                              if (target.isNotEmpty) {
                                context.push('/course/$target');
                              }
                            },
                            onDeactivate: () => _deactivateCourse(course),
                            onDelete: () => _deleteCourse(course),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => Column(
                    children: List.generate(3, (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerCard(height: 80),
                    )),
                  ),
                  error: (err, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 36, color: Colors.orange),
                            const SizedBox(height: 8),
                            Text(
                              tr(ref, 'Unable to load courses. Please check your connection.'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(instructorCoursesProvider),
                              icon: const Icon(Icons.refresh, size: 16, color: AppColors.primaryGreen),
                              label: Text(
                                tr(ref, 'Retry'),
                                style: const TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                ref.watch(instructorEbooksProvider).when(
                  data: (ebooks) {
                    final isSearching = _searchQuery.trim().isNotEmpty;
                    final filteredEbooks = isSearching
                        ? ebooks.where((e) {
                            final title = (e.title ?? e['title'] ?? '').toString().toLowerCase();
                            final desc = (e.description ?? e['description'] ?? '').toString().toLowerCase();
                            final q = _searchQuery.trim().toLowerCase();
                            return title.contains(q) || desc.contains(q);
                          }).toList()
                        : ebooks;

                    if (filteredEbooks.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSearching ? Icons.search_off_rounded : Icons.menu_book_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isSearching
                                    ? '${tr(ref, 'No e-books found matching')} "$_searchQuery"'
                                    : tr(ref, 'No e-books uploaded yet.'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (isSearching)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  label: Text(tr(ref, 'Clear Search')),
                                )
                              else
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9333EA)),
                                  onPressed: () => context.push(RouteNames.uploadEbook),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(tr(ref, 'Create First E-Book')),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: filteredEbooks.take(5).map((ebook) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AgriLearnEbookCard(
                            ebook: ebook,
                            onTap: () {
                              if (ebook.id != null && ebook.id!.isNotEmpty) {
                                context.push('/farmer/ebook/${ebook.id}');
                              } else {
                                context.push('${RouteNames.instructorUploads}?tab=1');
                              }
                            },
                            onViewLive: () {
                              if (ebook.id != null && ebook.id!.isNotEmpty) {
                                context.push('/farmer/ebook/${ebook.id}');
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => Column(
                    children: List.generate(3, (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerCard(height: 80),
                    )),
                  ),
                  error: (err, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 36, color: Colors.orange),
                            const SizedBox(height: 8),
                            Text(
                              tr(ref, 'Unable to load e-books. Please check your connection.'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(instructorEbooksProvider),
                              icon: const Icon(Icons.refresh, size: 16, color: AppColors.primaryGreen),
                              label: Text(
                                tr(ref, 'Retry'),
                                style: const TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 28),

              // Recent Activity (Transactions)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(tr(ref, 'Recent Transactions'), style: Theme.of(context).textTheme.headlineSmall),
                  TextButton.icon(
                    onPressed: () => context.push(RouteNames.instructorTransactions),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(
                      tr(ref, 'View All'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ref.watch(instructorTransactionsProvider).when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(tr(ref, 'No recent transactions.')),
                    );
                  }
                  return Column(
                    children: [
                      ...transactions.take(5).map((txn) {
                        final amount = txn['amount'] ?? '0';
                        final desc = txn['description'] ?? txn['item'] ?? txn['course_title'] ?? 'Transaction';
                        final date = txn['date'] ?? 'Recently';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ActivityItem(
                            icon: Icons.payment_rounded,
                            color: AppColors.primaryGreen,
                            title: '₹$amount',
                            subtitle: desc,
                            time: date,
                            onTap: () => _showTransactionDetailsModal(context, txn),
                          ),
                        );
                      }),
                      if (transactions.length > 5) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push(RouteNames.instructorTransactions),
                            icon: const Icon(Icons.receipt_long_rounded, size: 16),
                            label: Text('View All ${transactions.length} Transactions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(color: AppColors.primaryGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => Column(
                  children: List.generate(5, (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShimmerCard(height: 70),
                  )),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 36, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          tr(ref, 'Unable to load transactions. Please check your connection.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => ref.invalidate(instructorTransactionsProvider),
                          icon: const Icon(Icons.refresh, size: 16, color: AppColors.primaryGreen),
                          label: Text(
                            tr(ref, 'Retry'),
                            style: const TextStyle(color: AppColors.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSoft,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}


typedef _AgriLearnCourseCard = AgriLearnCourseCard;

class AgriLearnCourseCard extends ConsumerWidget {
  const AgriLearnCourseCard({
    super.key,
    required this.course,
    required this.onManage,
    this.onViewLive,
    this.onDeactivate,
    this.onDelete,
  });

  final ApiCourseList course;
  final VoidCallback onManage;
  final VoidCallback? onViewLive;
  final VoidCallback? onDeactivate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = (course.status ?? 'DRAFT').toUpperCase();

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    final isLive = status == 'APPROVED' ||
        status == 'LIVE' ||
        status == 'PUBLISHED' ||
        status == 'ACTIVE';

    if (isLive) {
      badgeBg = Colors.green.shade50;
      badgeText = Colors.green.shade700;
      badgeLabel = tr(ref, '• Live');
    } else if (status == 'PROCESSING') {
      badgeBg = Colors.amber.shade50;
      badgeText = Colors.amber.shade800;
      badgeLabel = tr(ref, '• Processing');
    } else if (status == 'REJECTED') {
      badgeBg = Colors.red.shade50;
      badgeText = Colors.red.shade800;
      badgeLabel = tr(ref, '• Rejected');
    } else {
      badgeBg = isDark ? Colors.white10 : Colors.grey.shade100;
      badgeText = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
      badgeLabel = tr(ref, '• Draft');
    }

    final effectiveOnTap = onViewLive ?? onManage;

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: effectiveOnTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 68,
                  height: 56,
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                      ? Image.network(
                          course.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.play_lesson_rounded,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Icons.play_lesson_rounded,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: badgeText.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          (course.price == null ||
                                  course.price == '0' ||
                                  course.price == '0.00' ||
                                  course.price == '0.0')
                              ? 'Free'
                              : '₹${course.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          '${course.enrollmentCount ?? 0} ${tr(ref, 'Students')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons: [Manage Course] [View Live] [Deactivate]
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: AppColors.primaryGreen),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onManage,
                      icon: const Icon(Icons.settings_outlined, size: 14, color: AppColors.primaryGreen),
                      label: Text(
                        tr(ref, 'Manage Course'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    if (isLive && onViewLive != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: BorderSide(color: Colors.teal.shade400),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onViewLive,
                        icon: Icon(Icons.visibility_outlined, size: 14, color: Colors.teal.shade700),
                        label: Text(
                          tr(ref, 'View Live'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                    if (isLive && onDeactivate != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onDeactivate,
                        icon: const Icon(Icons.pause_circle_outline, size: 14, color: Color(0xFFD97706)),
                        label: Text(
                          tr(ref, 'Deactivate'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    if (!isLive && onDelete != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                        label: Text(
                          tr(ref, 'Delete'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgriLearnEbookCard extends ConsumerWidget {
  const _AgriLearnEbookCard({
    required this.ebook,
    this.onTap,
    this.onViewLive,
  });

  final dynamic ebook;
  final VoidCallback? onTap;
  final VoidCallback? onViewLive;

  String _resolveStatus(dynamic statusObj) {
    if (statusObj == null) return 'DRAFT';
    final s = statusObj.toString().toUpperCase();
    if (s.contains('APPROV') || s.contains('LIVE')) return 'APPROVED';
    if (s.contains('REVIEW')) return 'REVIEW';
    if (s.contains('REJECT')) return 'REJECTED';
    return 'DRAFT';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCover = ebook.coverImage != null && ebook.coverImage.toString().trim().isNotEmpty;
    final status = _resolveStatus(ebook.status);
    final isLive = status == 'APPROVED';

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    switch (status) {
      case 'APPROVED':
        badgeBg = isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade50;
        badgeText = isDark ? Colors.greenAccent : Colors.green.shade700;
        badgeLabel = tr(ref, '• Live');
        break;
      case 'REVIEW':
        badgeBg = isDark ? Colors.amber.withValues(alpha: 0.2) : Colors.amber.shade50;
        badgeText = isDark ? Colors.amberAccent : Colors.amber.shade900;
        badgeLabel = tr(ref, '• Under Review');
        break;
      case 'REJECTED':
        badgeBg = isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50;
        badgeText = isDark ? Colors.redAccent : Colors.red.shade800;
        badgeLabel = tr(ref, '• Rejected');
        break;
      case 'DRAFT':
      default:
        badgeBg = isDark ? Colors.white12 : Colors.grey.shade100;
        badgeText = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
        badgeLabel = tr(ref, '• Draft');
        break;
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Thumbnail or Fallback Icon
              Container(
                width: 60,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  image: hasCover
                      ? DecorationImage(
                          image: NetworkImage(ebook.coverImage.toString()),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasCover
                    ? Icon(
                        Icons.picture_as_pdf_rounded,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        size: 32,
                      )
                    : null,
              ),
              const SizedBox(width: 14),

              // Title, Author, Status Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ebook.title ?? 'Untitled E-Book',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: badgeText.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ebook.authorName != null && ebook.authorName.toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By ${ebook.authorName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                              fontSize: 12,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (ebook.price == null || ebook.price == '0' || ebook.price == '0.00' || ebook.price == '0.0')
                                ? AppColors.primaryGreen.withValues(alpha: 0.12)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                size: 10,
                                color: (ebook.price == null || ebook.price == '0' || ebook.price == '0.00' || ebook.price == '0.0')
                                    ? AppColors.primaryGreen
                                    : const Color(0xFFD97706),
                              ),
                              Text(
                                (ebook.price == null || ebook.price == '0' || ebook.price == '0.00' || ebook.price == '0.0')
                                    ? 'FREE'
                                    : '${ebook.price}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: (ebook.price == null || ebook.price == '0' || ebook.price == '0.00' || ebook.price == '0.0')
                                      ? AppColors.primaryGreen
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action Button: [View in Library]
          if (isLive && onViewLive != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                side: BorderSide(color: Colors.teal.shade400),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onViewLive,
              icon: Icon(Icons.visibility_outlined, size: 14, color: Colors.teal.shade700),
              label: Text(
                tr(ref, 'View in Library'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _KycPromptBanner extends StatelessWidget {
  const _KycPromptBanner({
    required this.isPending,
    required this.onTap,
  });

  final bool isPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isPending ? AppColors.accentOrange : AppColors.primaryGreen)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? Icons.hourglass_top_rounded : Icons.verified_user_outlined,
              color: isPending ? AppColors.accentOrange : AppColors.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending ? 'KYC Verification Under Review' : 'Complete KYC & Payout Profile',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPending
                      ? 'Admin is reviewing your documents (24-48 hrs)'
                      : 'Required to receive earnings & publish courses',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSoft,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isPending ? AppColors.accentOrange : AppColors.primaryGreen)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPending ? 'Status' : 'Verify',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isPending ? AppColors.accentOrange : AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
