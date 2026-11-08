import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../explore/providers/explore_provider.dart';
import '../../home_farmer/providers/farmer_home_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';
import '../../../core/services/app_config_service.dart';

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
      initialIndex: (widget.initialTabIndex >= 0 && widget.initialTabIndex < 2)
          ? widget.initialTabIndex
          : 0,
    );
  }

  @override
  void didUpdateWidget(covariant InstructorUploadsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex &&
        widget.initialTabIndex >= 0 &&
        widget.initialTabIndex < _tabController.length &&
        _tabController.index != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex);
    }
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
        title: Text(tr(ref, 'My Uploads')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.inkSoft,
          indicatorColor: AppColors.primaryGreen,
          tabs: [
            Tab(text: tr(ref, 'Courses')),
            Tab(text: tr(ref, 'E-Books')),
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

  Future<void> _deactivateCourse(
    BuildContext context,
    WidgetRef ref,
    ApiCourseList course,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Deactivate Course', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to deactivate "${course.title}"?\n\n'
          'The course will be moved to Draft status and hidden from the public marketplace. You can review and manage it anytime.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(instructorRepositoryProvider).updateCourse(course.id, {
          'status': 'DRAFT',
        });
        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Course deactivated and moved to Drafts'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          ref.invalidate(instructorCoursesProvider);
          ref.invalidate(studentCatalogProvider);
          ref.invalidate(featuredCoursesProvider);
          ref.invalidate(exploreCoursesProvider);
        }
      } catch (e) {
        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to deactivate course: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteCourse(
    BuildContext context,
    WidgetRef ref,
    ApiCourseList course,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to permanently delete "${course.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(instructorRepositoryProvider).deleteCourse(course.id);
        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Course deleted successfully'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          ref.invalidate(instructorCoursesProvider);
          ref.invalidate(studentCatalogProvider);
          ref.invalidate(featuredCoursesProvider);
          ref.invalidate(exploreCoursesProvider);
        }
      } catch (e) {
        if (context.mounted) {
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
  }

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

            final hasThumbnail = course.thumbnail != null &&
                course.thumbnail!.trim().isNotEmpty;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        child: hasThumbnail
                            ? Image.network(
                                course.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.play_circle_fill,
                                    color: AppColors.primaryGreen,
                                    size: 32,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.play_circle_fill,
                                  color: AppColors.primaryGreen,
                                  size: 32,
                                ),
                              ),
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
                        if (isLive)
                          IconButton(
                            icon: const Icon(Icons.pause_circle_outline, color: Color(0xFFD97706)),
                            tooltip: 'Deactivate Course',
                            onPressed: () => _deactivateCourse(context, ref, course),
                          ),
                        if (!isLive)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                            tooltip: 'Delete Course',
                            onPressed: () => _deleteCourse(context, ref, course),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text(
                tr(ref, 'Unable to load courses at this time. Please check your connection.'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(tr(ref, 'Try Again')),
                onPressed: () => ref.invalidate(instructorCoursesProvider),
              ),
            ],
          ),
        ),
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

  Future<void> _editEBookPrice(
    BuildContext context,
    WidgetRef ref,
    dynamic ebook,
  ) async {
    final ebookId = ebook.id?.toString();
    if (ebookId == null || ebookId.isEmpty) return;

    final currentPrice = (ebook.price ?? '0').toString().replaceAll('₹', '').trim();
    final priceController = TextEditingController(text: currentPrice == '0.00' ? '0' : currentPrice);

    final config = ref.read(appConfigProvider);
    final allowsCustomPrice = config.allowsCustomCoursePrice;
    String selectedTier = const ['0', '249', '499', '999', '1499'].contains(currentPrice)
        ? currentPrice
        : '0';

    final newPrice = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_rupee, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Set E-Book Price',
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Price (₹ INR)',
                    hintText: 'e.g. 199 or 0',
                    prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: selectedTier,
                  decoration: InputDecoration(
                    labelText: 'E-Book Price Tier *',
                    helperText: 'Select one of the standard price tiers.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('Free (₹0)')),
                    DropdownMenuItem(value: '249', child: Text('₹249 — Tier 1')),
                    DropdownMenuItem(value: '499', child: Text('₹499 — Tier 1.5')),
                    DropdownMenuItem(value: '999', child: Text('₹999 — Tier 2')),
                    DropdownMenuItem(value: '1499', child: Text('₹1,499 — Tier 3')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedTier = val;
                        priceController.text = val;
                      });
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final val = allowsCustomPrice ? priceController.text.trim() : selectedTier;
                Navigator.pop(dialogCtx, val);
              },
              child: const Text('Save Price'),
            ),
          ],
        ),
      ),
    );

    if (newPrice != null) {
      final parsed = double.tryParse(newPrice);
      if (parsed == null || parsed < 0) {
        if (context.mounted) {
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
        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Price updated to ${parsed == 0 ? 'FREE' : '₹$formatted'}!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to update price: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
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
                badgeLabel = tr(ref, 'Live');
                badgeIcon = Icons.check_circle_outline;
                break;
              case 'REVIEW':
                badgeBg = isDark
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.amber.shade50;
                badgeText = isDark ? Colors.amberAccent : Colors.amber.shade900;
                badgeLabel = tr(ref, 'Under Review');
                badgeIcon = Icons.hourglass_top_rounded;
                break;
              case 'REJECTED':
                badgeBg = isDark
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.red.shade50;
                badgeText = isDark ? Colors.redAccent : Colors.red.shade800;
                badgeLabel = tr(ref, 'Rejected');
                badgeIcon = Icons.cancel_outlined;
                break;
              case 'DRAFT':
              default:
                badgeBg = isDark ? Colors.white12 : Colors.grey.shade100;
                badgeText = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
                badgeLabel = tr(ref, 'Draft');
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
                              // Status Badge & Price Tag Row
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
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
                                  // Price Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
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
                                          size: 11,
                                          color: (ebook.price == null || ebook.price == '0' || ebook.price == '0.00' || ebook.price == '0.0')
                                              ? AppColors.primaryGreen
                                              : const Color(0xFFD97706),
                                        ),
                                        Text(
                                          (ebook.price == null || ebook.price == '0' || ebook.price == '0.00' || ebook.price == '0.0')
                                              ? 'FREE'
                                              : '${ebook.price}',
                                          style: TextStyle(
                                            fontSize: 11,
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
                        // Edit Price Button
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primaryGreen,
                          ),
                          tooltip: 'Edit Price',
                          onPressed: () => _editEBookPrice(context, ref, ebook),
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          tooltip: 'Delete E-Book',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Delete E-Book'),
                                content: Text(
                                  'Are you sure you want to delete "${ebook.title ?? 'this e-book'}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await ref
                                    .read(instructorRepositoryProvider)
                                    .deleteEBook(ebook.id!);
                                ref.invalidate(instructorEbooksProvider);
                                if (context.mounted) {
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('E-Book deleted successfully.'),
                                      backgroundColor: AppColors.primaryGreen,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  String cleanError = e.toString();
                                  if (cleanError.startsWith('Exception: ')) {
                                    cleanError = cleanError.substring('Exception: '.length);
                                  }
                                  if (cleanError.toLowerCase().contains('not permitted') ||
                                      cleanError.toLowerCase().contains('only platform administrators')) {
                                    cleanError = 'You do not have permission to delete e-books. Please contact an administrator.';
                                  }
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(cleanError),
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),

                    // Additional action / notification depending on status
                    if (status == 'APPROVED') ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal.shade700,
                              side: BorderSide(color: Colors.teal.shade400, width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.visibility_outlined, size: 14),
                            label: Text(
                              tr(ref, 'View in Library'),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (ebook.id != null && ebook.id!.isNotEmpty) {
                                context.push('/farmer/ebook/${ebook.id}');
                              }
                            },
                          ),
                        ],
                      ),
                    ] else if (status == 'DRAFT') ...[
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
                            label: Text(
                              tr(ref, 'Submit for Review'),
                              style: const TextStyle(
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
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.accentOrange,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                tr(ref, 'Submitted to Admin. Awaiting approval before going live to students.'),
                                style: const TextStyle(
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text(
                tr(ref, 'Unable to load e-books at this time. Please check your connection.'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(tr(ref, 'Try Again')),
                onPressed: () => ref.invalidate(instructorEbooksProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
