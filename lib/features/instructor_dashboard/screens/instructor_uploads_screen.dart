import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

class InstructorUploadsScreen extends ConsumerStatefulWidget {
  const InstructorUploadsScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  ConsumerState<InstructorUploadsScreen> createState() =>
      _InstructorUploadsScreenState();
}

class _InstructorUploadsScreenState extends ConsumerState<InstructorUploadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Uploads'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.inkSoft,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'E-Books'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CoursesTab(),
          _EBooksTab(),
        ],
      ),
    );
  }
}

class _CoursesTab extends ConsumerWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coursesAsync = ref.watch(
      instructorCoursesProvider((search: '', ordering: '')),
    );

    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return const Center(child: Text('No courses uploaded yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            final cStatus = (course.status ?? 'DRAFT').toUpperCase();
            final isLive = cStatus == 'APPROVED' ||
                cStatus == 'LIVE' ||
                cStatus == 'PUBLISHED' ||
                cStatus == 'ACTIVE';

            Color cBadgeBg;
            Color cBadgeText;
            String cBadgeLabel;

            if (isLive) {
              cBadgeBg = isDark
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.green.shade50;
              cBadgeText = isDark ? Colors.greenAccent : Colors.green.shade700;
              cBadgeLabel = 'Live';
            } else if (cStatus == 'PROCESSING' || cStatus == 'REVIEW') {
              cBadgeBg = isDark
                  ? Colors.amber.withValues(alpha: 0.2)
                  : Colors.amber.shade50;
              cBadgeText = isDark ? Colors.amberAccent : Colors.amber.shade900;
              cBadgeLabel = 'Under Review';
            } else if (cStatus == 'REJECTED') {
              cBadgeBg = isDark
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.red.shade50;
              cBadgeText = isDark ? Colors.redAccent : Colors.red.shade800;
              cBadgeLabel = 'Rejected';
            } else {
              cBadgeBg = isDark ? Colors.white12 : Colors.grey.shade100;
              cBadgeText = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
              cBadgeLabel = 'Draft';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill,
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    size: 15,
                                    color: AppColors.inkSoft,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${course.enrollmentCount ?? 0} Students',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.inkSoft),
                                  ),
                                ],
                              ),
                              Text(
                                course.price == '0.00' ? 'Free' : 'Paid',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppColors.primaryGreen),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cBadgeBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cBadgeLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: cBadgeText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_document, color: AppColors.primaryGreen),
                          tooltip: 'Manage Content',
                          onPressed: () => context.push('/instructor/manage-course/${course.id}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const ShimmerListTile(),
      ),
      error: (err, stack) => Center(
        child: Text('Error loading courses: $err'),
      ),
    );
  }
}

class _EBooksTab extends ConsumerWidget {
  const _EBooksTab();

  String _resolveStatus(dynamic statusObj) {
    if (statusObj == null) return 'DRAFT';
    final s = statusObj.toString().toUpperCase();
    if (s.contains('APPROV') || s.contains('LIVE')) return 'APPROVED';
    if (s.contains('REVIEW')) return 'REVIEW';
    if (s.contains('REJECT')) return 'REJECTED';
    return 'DRAFT';
  }

  Future<void> _submitEBookForReview(
    BuildContext context,
    WidgetRef ref,
    String? ebookId,
    String? title,
  ) async {
    if (ebookId == null || ebookId.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Submit E-Book for Review'),
        content: Text(
          'Are you sure you want to submit "${title ?? 'this e-book'}" to the admin team for review?\n\nOnce approved by the admin, it will be published and visible to all students.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Submit for Review'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(instructorRepositoryProvider).submitEBook(ebookId);
      ref.invalidate(instructorEbooksProvider);
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('E-Book "${title ?? ''}" submitted for review!'),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to submit e-book: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ebooksAsync = ref.watch(instructorEbooksProvider);

    return ebooksAsync.when(
      data: (ebooks) {
        if (ebooks.isEmpty) {
          return const Center(child: Text('No e-books uploaded yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ebooks.length,
          itemBuilder: (context, index) {
            final ebook = ebooks[index];
            final status = _resolveStatus(ebook.status);

            Color badgeBg;
            Color badgeText;
            String badgeLabel;
            IconData badgeIcon;

            switch (status) {
              case 'APPROVED':
                badgeBg = isDark
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.green.shade50;
                badgeText = isDark ? Colors.greenAccent : Colors.green.shade700;
                badgeLabel = 'Live';
                badgeIcon = Icons.check_circle_outline;
                break;
              case 'REVIEW':
                badgeBg = isDark
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.amber.shade50;
                badgeText = isDark ? Colors.amberAccent : Colors.amber.shade900;
                badgeLabel = 'Under Review';
                badgeIcon = Icons.hourglass_top_rounded;
                break;
              case 'REJECTED':
                badgeBg = isDark
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.red.shade50;
                badgeText = isDark ? Colors.redAccent : Colors.red.shade800;
                badgeLabel = 'Rejected';
                badgeIcon = Icons.cancel_outlined;
                break;
              case 'DRAFT':
              default:
                badgeBg = isDark ? Colors.white12 : Colors.grey.shade100;
                badgeText = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
                badgeLabel = 'Draft';
                badgeIcon = Icons.edit_note_rounded;
                break;
            }

            final hasCover = ebook.coverImage != null &&
                ebook.coverImage.toString().trim().isNotEmpty;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover thumbnail or fallback icon
                        Container(
                          width: 60,
                          height: 75,
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            image: hasCover
                                ? DecorationImage(
                                    image: NetworkImage(ebook.coverImage.toString()),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: !hasCover
                              ? const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.accentOrange,
                                  size: 32,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        // Title & Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ebook.title ?? 'Untitled E-Book',
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (ebook.authorName != null &&
                                  ebook.authorName.toString().trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'By ${ebook.authorName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.inkSoft),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(badgeIcon, size: 12, color: badgeText),
                                    const SizedBox(width: 4),
                                    Text(
                                      badgeLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: badgeText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Additional action / notification depending on status
                    if (status == 'DRAFT') ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 14),
                            label: const Text(
                              'Submit for Review',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _submitEBookForReview(
                              context,
                              ref,
                              ebook.id,
                              ebook.title,
                            ),
                          ),
                        ],
                      ),
                    ] else if (status == 'REVIEW') ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.accentOrange,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Submitted to Admin. Awaiting approval before going live to students.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (status == 'REJECTED' &&
                        ebook.rejectionReason != null &&
                        ebook.rejectionReason.toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Rejection Reason: ${ebook.rejectionReason}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const ShimmerListTile(),
      ),
      error: (err, stack) => Center(
        child: Text('Error loading e-books: $err'),
      ),
    );
  }
}
