import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
import '../../certificates/providers/certificates_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../core/services/app_config_service.dart';
import '../../../data/models/user_role.dart';

class InstructorHomeScreen extends ConsumerStatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  ConsumerState<InstructorHomeScreen> createState() =>
      _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends ConsumerState<InstructorHomeScreen> {
  void _showSwitchToStudentDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF14241A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.swap_horiz_rounded, color: Color(0xFF16A34A), size: 28),
            SizedBox(width: 10),
            Text(
              'Switch Mode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'You are switching to Student Mode. You will be able to browse courses, read eBooks, and learn farming techniques.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              // Switch role in AuthProvider and navigate to Student panel
              await ref.read(authProvider.notifier).switchRole(UserRole.farmer);
              if (context.mounted) {
                context.go(RouteNames.farmerHome);
              }
            },
            child: const Text(
              'OK, Switch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  final _searchController = TextEditingController();
  String _searchQuery = '';
  final String _ordering = '';
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

  void _showTransactionDetailsModal(
    BuildContext context,
    Map<String, dynamic> txn,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id =
        txn['id']?.toString() ?? txn['transaction_id']?.toString() ?? 'TXN-000';
    final item =
        txn['item']?.toString() ??
        txn['course_title']?.toString() ??
        txn['description']?.toString() ??
        'Course Purchase';
    final buyer =
        txn['buyer']?.toString() ??
        txn['student_name']?.toString() ??
        'Student';
    final date =
        txn['date']?.toString() ?? txn['created_at']?.toString() ?? 'Recently';
    final amount = txn['amount'] != null ? '₹${txn['amount']}' : '₹0.00';
    final status = txn['status']?.toString() ?? 'SUCCESS';
    final paymentMethod =
        txn['payment_method']?.toString() ??
        txn['payment_mode']?.toString() ??
        'Online Payment';

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
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.primaryGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(ref, 'Transaction Receipt'),
                              style: Theme.of(sheetCtx).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              id,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white60
                                    : AppColors.inkSoft,
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
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF9FAFB),
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
                          Text(
                            tr(ref, 'Amount Credited'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
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
                          Text(
                            tr(ref, 'Status'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
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
                                color: status.toUpperCase().contains('FAIL')
                                    ? Colors.red
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr(ref, 'Item / Course'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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
                          Text(
                            tr(ref, 'Enrolled Student'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          Text(
                            buyer,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr(ref, 'Date & Time'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          Text(
                            formatNum(ref, date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr(ref, 'Payment Method'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          Text(
                            tr(ref, paymentMethod),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: Text(
                      tr(ref, 'View Full Financial Ledger'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
        title: Text(
          tr(ref, 'Deactivate Course'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${tr(ref, 'Are you sure you want to deactivate')} "${course.title}"?\n\n'
          '${tr(ref, 'The course will be moved to Draft status and hidden from the public marketplace. You can review and manage it anytime.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr(ref, 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr(ref, 'Deactivate')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        debugPrint('📤 [DEACTIVATE] Deactivating course: ${course.id}');
        await ref.read(instructorRepositoryProvider).archiveCourse(course.id);
        await ref
            .read(deactivatedCoursesProvider.notifier)
            .markDeactivated(course.id);
        debugPrint(
          '✅ [DEACTIVATE] Successfully deactivated course: ${course.id}',
        );
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(tr(ref, 'Course deactivated and archived')),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorCoursesProvider);
        ref.invalidate(instructorCourseDetailProvider(course.id));
        unawaited(
          ref.refresh(
            instructorCoursesProvider((
              search: _searchQuery,
              ordering: _ordering,
            )).future,
          ),
        );
        ref.invalidate(studentCatalogProvider);
        ref.invalidate(featuredCoursesProvider);
        ref.invalidate(exploreCoursesProvider);
        ref.invalidate(studentEnrollmentsProvider);
        ref.invalidate(myCertificatesProvider);
        ref.invalidate(certificateEnrollmentsProvider);
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

  Future<void> _reactivateCourse(ApiCourseList course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          tr(ref, 'Reactivate Course'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${tr(ref, 'Are you sure you want to reactivate')} "${course.title}"?\n\n'
          '${tr(ref, 'The course will be restored back to live status on the marketplace.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr(ref, 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr(ref, 'Reactivate')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        debugPrint('📤 [REACTIVATE] Reactivating course: ${course.id}');
        await ref.read(instructorRepositoryProvider).unarchiveCourse(course.id);
        await ref
            .read(deactivatedCoursesProvider.notifier)
            .markReactivated(course.id);
        debugPrint(
          '✅ [REACTIVATE] Successfully reactivated course: ${course.id}',
        );
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(tr(ref, 'Course reactivated and is now live!')),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorCoursesProvider);
        ref.invalidate(instructorCourseDetailProvider(course.id));
        unawaited(
          ref.refresh(
            instructorCoursesProvider((
              search: _searchQuery,
              ordering: _ordering,
            )).future,
          ),
        );
        ref.invalidate(studentCatalogProvider);
        ref.invalidate(featuredCoursesProvider);
        ref.invalidate(exploreCoursesProvider);
        ref.invalidate(studentEnrollmentsProvider);
        ref.invalidate(myCertificatesProvider);
        ref.invalidate(certificateEnrollmentsProvider);
      } catch (e) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${tr(ref, 'Failed to reactivate course:')} $e'),
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
        content: Text(
          '${tr(ref, 'Are you sure you want to permanently delete')} "${course.title}"? ${tr(ref, 'This action cannot be undone.')}',
        ),
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
        unawaited(
          ref.refresh(
            instructorCoursesProvider((
              search: _searchQuery,
              ordering: _ordering,
            )).future,
          ),
        );
        ref.invalidate(studentCatalogProvider);
        ref.invalidate(featuredCoursesProvider);
        ref.invalidate(exploreCoursesProvider);
        ref.invalidate(studentEnrollmentsProvider);
        ref.invalidate(myCertificatesProvider);
        ref.invalidate(certificateEnrollmentsProvider);
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

  Future<void> _submitCourseForReview(ApiCourseList course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.rocket_launch, color: AppColors.primaryGreen),
            const SizedBox(width: 10),
            Text(
              tr(ref, 'Submit for Review'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '${tr(ref, 'Are you sure you want to submit')} "${course.title}" ${tr(ref, 'for automated AI safety review and administrator verification? Editing will be temporarily locked until the review completes.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr(ref, 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr(ref, 'Submit for Review')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final res = await ref
            .read(instructorRepositoryProvider)
            .publishCourse(course.id);
        if (!mounted) return;
        final message =
            res['message']?.toString() ??
            tr(ref, 'Course submitted for review successfully');
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorCoursesProvider);
        ref.invalidate(instructorCourseDetailProvider(course.id));
        unawaited(
          ref.refresh(
            instructorCoursesProvider((
              search: _searchQuery,
              ordering: _ordering,
            )).future,
          ),
        );
        ref.invalidate(instructorStatsProvider);
      } catch (e) {
        if (!mounted) return;
        String errorMsg = e.toString().replaceAll('Exception: ', '').trim();
        if (errorMsg.contains('{') && errorMsg.contains('}')) {
          try {
            final jsonPart = errorMsg.substring(
              errorMsg.indexOf('{'),
              errorMsg.lastIndexOf('}') + 1,
            );
            final decoded = jsonDecode(jsonPart);
            if (decoded is Map) {
              errorMsg =
                  decoded['error']?.toString() ??
                  decoded['detail']?.toString() ??
                  decoded.values
                      .map((v) => v is List ? v.join(' ') : v.toString())
                      .join(' ');
            }
          } catch (_) {}
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submitEBookForReview(dynamic ebook) async {
    final ebookId = ebook.id?.toString();
    final ebookTitle = ebook.title?.toString() ?? 'this draft e-book';
    if (ebookId == null || ebookId.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr(ref, 'Send for Review')),
        content: Text(
          '${tr(ref, 'Are you sure you want to submit')} "$ebookTitle" ${tr(ref, 'for admin review? Once approved, it will be published and visible to all students.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr(ref, 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text(tr(ref, 'Send for Review')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(instructorRepositoryProvider).submitEBook(ebookId);
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(tr(ref, 'E-book submitted for review successfully')),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorEbooksProvider);
        ref.invalidate(studentEbooksProvider);
        ref.invalidate(instructorStatsProvider);
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

  Future<void> _editEBookPrice(dynamic ebook) async {
    final ebookId = ebook.id?.toString();
    if (ebookId == null || ebookId.isEmpty) return;

    final currentPrice = (ebook.price ?? '0')
        .toString()
        .replaceAll('₹', '')
        .trim();
    final priceController = TextEditingController(
      text: currentPrice == '0.00' ? '0' : currentPrice,
    );

    final config = ref.read(appConfigProvider);
    final allowsCustomPrice = config.allowsCustomCoursePrice;
    String selectedTier =
        const ['0', '249', '499', '999', '1499'].contains(currentPrice)
        ? currentPrice
        : '0';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newPrice = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.currency_rupee,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Edit E-Book Price',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set pricing for "${ebook.title ?? 'E-Book'}". Enter 0 to offer this e-book for free to learners.',
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              if (allowsCustomPrice)
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                    labelText: 'Price (₹)',
                    hintText: 'e.g. 299',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['0', '249', '499', '999', '1499'].map((tier) {
                    final isSel = selectedTier == tier;
                    return ChoiceChip(
                      label: Text(tier == '0' ? 'FREE' : '₹$tier'),
                      selected: isSel,
                      selectedColor: isDark
                          ? const Color(0xFFD4FF80)
                          : AppColors.primaryGreen,
                      backgroundColor: isDark
                          ? const Color(0xFF2A2D32)
                          : Colors.grey.shade100,
                      side: BorderSide(
                        color: isSel
                            ? (isDark
                                  ? const Color(0xFFD4FF80)
                                  : AppColors.primaryGreen)
                            : (isDark ? Colors.white24 : AppColors.lineLight),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      labelStyle: TextStyle(
                        color: isSel
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white : AppColors.inkDark),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      onSelected: (_) =>
                          setDialogState(() => selectedTier = tier),
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(tr(ref, 'Cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final val = allowsCustomPrice
                    ? priceController.text.trim()
                    : selectedTier;
                Navigator.pop(dialogCtx, val);
              },
              child: Text(tr(ref, 'Save Price')),
            ),
          ],
        ),
      ),
    );

    if (newPrice != null) {
      final parsed = double.tryParse(newPrice);
      if (parsed == null || parsed < 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid price (>= 0)'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      try {
        final formatted = parsed.toStringAsFixed(2);
        await ref.read(instructorRepositoryProvider).updateEBook(ebookId, {
          'price': formatted,
        });
        ref.invalidate(instructorEbooksProvider);
        ref.invalidate(studentEbooksProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Price updated to ₹$formatted'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteEBook(dynamic ebook) async {
    final ebookId = ebook.id?.toString();
    final ebookTitle = ebook.title?.toString() ?? 'this draft e-book';
    if (ebookId == null || ebookId.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr(ref, 'Delete Draft E-Book')),
        content: Text(
          '${tr(ref, 'Are you sure you want to permanently delete')} "$ebookTitle"? ${tr(ref, 'This action cannot be undone.')}',
        ),
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
        await ref.read(instructorRepositoryProvider).deleteEBook(ebookId);
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(tr(ref, 'Draft e-book deleted successfully')),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorEbooksProvider);
        ref.invalidate(studentEbooksProvider);
        ref.invalidate(instructorStatsProvider);
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
    final userName = (user != null && user.fullName.isNotEmpty)
        ? user.fullName
        : 'Ravi Kumar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        toolbarHeight: 76,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${tr(ref, 'Welcome')} 👨‍🏫',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontSize: 20, height: 1.15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user?.isKycVerified == true) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (context) {
                final unreadCount = ref.watch(unreadNotificationsCountProvider);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(RouteNames.notifications),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.lineDark
                                : AppColors.lineLight,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.inkDark,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Switch to Student Mode Pill Button
                    InkWell(
                      onTap: () => _showSwitchToStudentDialog(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B4D2E),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.swap_horiz_rounded,
                              size: 15,
                              color: Color(0xFF86EFAC),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Student',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
              Future.microtask(
                () => ref.invalidate(instructorTransactionsProvider),
              ),
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
                  tr(
                    ref,
                    'Manage your courses, revenue, and AI moderation status.',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 16),

                // ── 1. Quick Action Buttons (Create Course & New E-Book) ──
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context.push(RouteNames.uploadCourse),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          tr(ref, 'Create a New Course'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.push(RouteNames.uploadEbook),
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        tr(ref, 'New E-Book'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── 3. Total Revenue & Analytics Banner ───
                const _TotalRevenueBanner(),
                const SizedBox(height: 14),

                // ── 4. Compact Upload Guide Chatbot Banner ───
                AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    context.push(RouteNames.uploadGuide);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF1E2E23),
                                        const Color(0xFF142017),
                                      ]
                                    : [
                                        const Color(0xFF2C3E31),
                                        const Color(0xFF1B2A1E),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      'assets/images/igrow_teacher_bot.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          tr(ref, 'Instructor Guide'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen
                                                .withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            'AI Assistant',
                                            style: TextStyle(
                                              color: Color(0xFF86EFAC),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tr(
                                        ref,
                                        'Learn how to upload courses & ebooks with our AI assistant.',
                                      ),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 11.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white70,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

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
                                  : (isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600),
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
                                  : (isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600),
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
                        final tabParam = _selectedDashboardTab == 1
                            ? '?tab=1'
                            : '';
                        context.push(
                          '${RouteNames.instructorUploads}$tabParam',
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? const Color(0xFF4ADE80)
                            : AppColors.primaryGreen,
                      ),
                      child: Text(
                        tr(ref, 'See All'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_selectedDashboardTab == 0)
                  ref
                      .watch(
                        instructorCoursesProvider((
                          search: _searchQuery,
                          ordering: _ordering,
                        )),
                      )
                      .when(
                        data: (courses) {
                          final isSearching = _searchQuery.trim().isNotEmpty;
                          if (courses.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 16,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSearching
                                          ? Icons.search_off_rounded
                                          : Icons.video_library_outlined,
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
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 16,
                                        ),
                                        label: Text(tr(ref, 'Clear Search')),
                                      )
                                    else
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              AppColors.accentOrange,
                                        ),
                                        onPressed: () => context.push(
                                          RouteNames.uploadCourse,
                                        ),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: Text(
                                          tr(ref, 'Create First Course'),
                                        ),
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
                                  onManage: () => context.push(
                                    '/instructor/manage-course/${course.id}',
                                  ),
                                  onSubmitForReview: () =>
                                      _submitCourseForReview(course),
                                  onViewLive: () {
                                    final target =
                                        (course.slug != null &&
                                            course.slug!.isNotEmpty)
                                        ? course.slug!
                                        : course.id;
                                    if (target.isNotEmpty) {
                                      context.push('/course/$target');
                                    }
                                  },
                                  onDeactivate: () => _deactivateCourse(course),
                                  onReactivate: () => _reactivateCourse(course),
                                  onDelete: () => _deleteCourse(course),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => Column(
                          children: List.generate(
                            3,
                            (_) => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: ShimmerCard(height: 80),
                            ),
                          ),
                        ),
                        error: (err, _) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 36,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tr(
                                      ref,
                                      'Unable to load courses. Please check your connection.',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => ref.invalidate(
                                      instructorCoursesProvider,
                                    ),
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: AppColors.primaryGreen,
                                    ),
                                    label: Text(
                                      tr(ref, 'Retry'),
                                      style: const TextStyle(
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                else
                  ref
                      .watch(instructorEbooksProvider)
                      .when(
                        data: (ebooks) {
                          final isSearching = _searchQuery.trim().isNotEmpty;
                          final filteredEbooks = isSearching
                              ? ebooks.where((e) {
                                  final title = (e.title ?? e['title'] ?? '')
                                      .toString()
                                      .toLowerCase();
                                  final desc =
                                      (e.description ?? e['description'] ?? '')
                                          .toString()
                                          .toLowerCase();
                                  final q = _searchQuery.trim().toLowerCase();
                                  return title.contains(q) || desc.contains(q);
                                }).toList()
                              : ebooks;

                          if (filteredEbooks.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 16,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSearching
                                          ? Icons.search_off_rounded
                                          : Icons.menu_book_rounded,
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
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 16,
                                        ),
                                        label: Text(tr(ref, 'Clear Search')),
                                      )
                                    else
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF9333EA,
                                          ),
                                        ),
                                        onPressed: () => context.push(
                                          RouteNames.uploadEbook,
                                        ),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: Text(
                                          tr(ref, 'Create First E-Book'),
                                        ),
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
                                    if (ebook.id != null &&
                                        ebook.id!.isNotEmpty) {
                                      context.push('/farmer/ebook/${ebook.id}');
                                    } else {
                                      context.push(
                                        '${RouteNames.instructorUploads}?tab=1',
                                      );
                                    }
                                  },
                                  onViewLive: () {
                                    if (ebook.id != null &&
                                        ebook.id!.isNotEmpty) {
                                      context.push('/farmer/ebook/${ebook.id}');
                                    }
                                  },
                                  onEdit: () => _editEBookPrice(ebook),
                                  onSubmitForReview: () =>
                                      _submitEBookForReview(ebook),
                                  onDelete: () => _deleteEBook(ebook),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => Column(
                          children: List.generate(
                            3,
                            (_) => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: ShimmerCard(height: 80),
                            ),
                          ),
                        ),
                        error: (err, _) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 36,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tr(
                                      ref,
                                      'Unable to load e-books. Please check your connection.',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => ref.invalidate(
                                      instructorEbooksProvider,
                                    ),
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: AppColors.primaryGreen,
                                    ),
                                    label: Text(
                                      tr(ref, 'Retry'),
                                      style: const TextStyle(
                                        color: AppColors.primaryGreen,
                                      ),
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
                    Text(
                      tr(ref, 'Recent Transactions'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          context.push(RouteNames.instructorTransactions),
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: isDark
                            ? const Color(0xFF4ADE80)
                            : AppColors.primaryGreen,
                      ),
                      label: Text(
                        tr(ref, 'View All'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF4ADE80)
                              : AppColors.primaryGreen,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? const Color(0xFF4ADE80)
                            : AppColors.primaryGreen,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ref
                    .watch(instructorTransactionsProvider)
                    .when(
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
                              final desc =
                                  txn['description'] ??
                                  txn['item'] ??
                                  txn['course_title'] ??
                                  'Transaction';
                              final date = txn['date'] ?? 'Recently';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ActivityItem(
                                  icon: Icons.payment_rounded,
                                  color: AppColors.primaryGreen,
                                  title: '₹$amount',
                                  subtitle: desc,
                                  time: date,
                                  onTap: () => _showTransactionDetailsModal(
                                    context,
                                    txn,
                                  ),
                                ),
                              );
                            }),
                            if (transactions.length > 5) ...[
                              const SizedBox(height: 4),
                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push(
                                    RouteNames.instructorTransactions,
                                  ),
                                  icon: Icon(
                                    Icons.receipt_long_rounded,
                                    size: 16,
                                    color: isDark
                                        ? const Color(0xFF4ADE80)
                                        : AppColors.primaryGreen,
                                  ),
                                  label: Text(
                                    'View All ${transactions.length} Transactions',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF4ADE80)
                                          : AppColors.primaryGreen,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark
                                        ? const Color(0xFF4ADE80)
                                        : AppColors.primaryGreen,
                                    side: BorderSide(
                                      color: isDark
                                          ? const Color(0xFF4ADE80)
                                          : AppColors.primaryGreen,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => Column(
                        children: List.generate(
                          5,
                          (_) => const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: ShimmerCard(height: 70),
                          ),
                        ),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                size: 36,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tr(
                                  ref,
                                  'Unable to load transactions. Please check your connection.',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => ref.invalidate(
                                  instructorTransactionsProvider,
                                ),
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: AppColors.primaryGreen,
                                ),
                                label: Text(
                                  tr(ref, 'Retry'),
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                  ),
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

typedef _AgriLearnCourseCard = AgriLearnCourseCard;

class AgriLearnCourseCard extends ConsumerWidget {
  const AgriLearnCourseCard({
    super.key,
    required this.course,
    required this.onManage,
    this.onSubmitForReview,
    this.onViewLive,
    this.onDeactivate,
    this.onReactivate,
    this.onDelete,
  });

  final ApiCourseList course;
  final VoidCallback onManage;
  final VoidCallback? onSubmitForReview;
  final VoidCallback? onViewLive;
  final VoidCallback? onDeactivate;
  final VoidCallback? onReactivate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = (course.status ?? 'DRAFT').toUpperCase();
    final isDeactivated =
        ref.watch(deactivatedCoursesProvider).contains(course.id) ||
        status == 'ARCHIVED' ||
        status == 'INACTIVE';

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    final isLive =
        (status == 'APPROVED' ||
            status == 'LIVE' ||
            status == 'PUBLISHED' ||
            status == 'ACTIVE') &&
        !isDeactivated;

    // Only new made courses still in draft / review period can be deleted.
    // Approved and subsequently deactivated courses must NOT show a delete button.
    final canDelete =
        !isLive &&
        !isDeactivated &&
        (status == 'DRAFT' ||
            status == 'PROCESSING' ||
            status == 'REVIEW' ||
            status == 'REJECTED');

    if (isDeactivated) {
      badgeBg = isDark
          ? Colors.amber.withValues(alpha: 0.2)
          : Colors.amber.shade50;
      badgeText = isDark ? Colors.amberAccent : Colors.amber.shade900;
      badgeLabel = tr(ref, '• Deactivated');
    } else if (isLive) {
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
                  child:
                      course.thumbnail != null && course.thumbnail!.isNotEmpty
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
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
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          '${course.enrollmentCount ?? 0} ${tr(ref, 'Students')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade400
                                : AppColors.inkSoft,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        side: const BorderSide(color: AppColors.primaryGreen),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onManage,
                      icon: const Icon(
                        Icons.settings_outlined,
                        size: 14,
                        color: AppColors.primaryGreen,
                      ),
                      label: Text(
                        tr(ref, 'Manage Course'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    if ((status == 'DRAFT' || status == 'REJECTED') &&
                        onSubmitForReview != null)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF009688),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                        ),
                        onPressed: onSubmitForReview,
                        icon: const Icon(
                          Icons.send_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        label: Text(
                          tr(ref, 'Submit for Review'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (isLive && onViewLive != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          side: BorderSide(color: Colors.teal.shade400),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onViewLive,
                        icon: Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: Colors.teal.shade700,
                        ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onDeactivate,
                        icon: const Icon(
                          Icons.pause_circle_outline,
                          size: 14,
                          color: Color(0xFFD97706),
                        ),
                        label: Text(
                          tr(ref, 'Deactivate'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    if (isDeactivated && onReactivate != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          side: const BorderSide(color: AppColors.primaryGreen),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onReactivate,
                        icon: const Icon(
                          Icons.play_circle_outline,
                          size: 14,
                          color: AppColors.primaryGreen,
                        ),
                        label: Text(
                          tr(ref, 'Reactivate'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    if (canDelete && onDelete != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
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
    this.onEdit,
    this.onSubmitForReview,
    this.onDelete,
  });

  final dynamic ebook;
  final VoidCallback? onTap;
  final VoidCallback? onViewLive;
  final VoidCallback? onEdit;
  final VoidCallback? onSubmitForReview;
  final VoidCallback? onDelete;

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
    final hasCover =
        ebook.coverImage != null &&
        ebook.coverImage.toString().trim().isNotEmpty;
    final status = _resolveStatus(ebook.status);
    final isLive = status == 'APPROVED';
    final isDraft = status == 'DRAFT';
    final isReview = status == 'REVIEW';

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    switch (status) {
      case 'APPROVED':
        badgeBg = isDark
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.green.shade50;
        badgeText = isDark ? Colors.greenAccent : Colors.green.shade700;
        badgeLabel = tr(ref, '• Live');
        break;
      case 'REVIEW':
        badgeBg = isDark
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.amber.shade50;
        badgeText = isDark ? Colors.amberAccent : Colors.amber.shade900;
        badgeLabel = tr(ref, '• Under Review');
        break;
      case 'REJECTED':
        badgeBg = isDark
            ? Colors.red.withValues(alpha: 0.2)
            : Colors.red.shade50;
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
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
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
                    if (ebook.authorName != null &&
                        ebook.authorName.toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By ${ebook.authorName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.inkSoft,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (ebook.price == null ||
                                    ebook.price == '0' ||
                                    ebook.price == '0.00' ||
                                    ebook.price == '0.0')
                                ? AppColors.primaryGreen.withValues(alpha: 0.12)
                                : const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                size: 10,
                                color:
                                    (ebook.price == null ||
                                        ebook.price == '0' ||
                                        ebook.price == '0.00' ||
                                        ebook.price == '0.0')
                                    ? AppColors.primaryGreen
                                    : const Color(0xFFD97706),
                              ),
                              Text(
                                (ebook.price == null ||
                                        ebook.price == '0' ||
                                        ebook.price == '0.00' ||
                                        ebook.price == '0.0')
                                    ? 'FREE'
                                    : '${ebook.price}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (ebook.price == null ||
                                          ebook.price == '0' ||
                                          ebook.price == '0.00' ||
                                          ebook.price == '0.0')
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

          // Action Buttons:
          // Draft: [Edit] [Send for Review] [Delete]
          // Under Review: [Delete] (Send for Review hidden)
          // Live: [View in Library]
          if (isLive || isDraft || isReview || onDelete != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (isLive && onViewLive != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      side: BorderSide(color: Colors.teal.shade400),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onViewLive,
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: Colors.teal.shade700,
                    ),
                    label: Text(
                      tr(ref, 'View in Library'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),
                if (!isLive && onEdit != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      side: const BorderSide(color: AppColors.primaryGreen),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    label: Text(
                      tr(ref, 'Edit'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                if (isDraft && onSubmitForReview != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onSubmitForReview,
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    label: Text(
                      tr(ref, 'Send for Review'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (!isLive && onDelete != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _TotalRevenueBanner extends ConsumerWidget {
  const _TotalRevenueBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(instructorStatsProvider);

    return statsAsync.maybeWhen(
      data: (stats) {
        final totalEarnings = (stats['total_earnings'] as num?)?.toDouble() ?? 0.0;
        final totalRevenue = (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
        final displayAmount = totalEarnings > 0 ? totalEarnings : totalRevenue;

        return AppCard(
          onTap: () => context.push(RouteNames.instructorAnalytics),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'Total Revenue'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : AppColors.inkSoft,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${displayAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF142418) : const Color(0xFFEBF6EC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr(ref, 'Analytics'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => AppCard(
        onTap: () => context.push(RouteNames.instructorAnalytics),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(ref, 'Total Revenue'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : AppColors.inkSoft,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹0.00',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
