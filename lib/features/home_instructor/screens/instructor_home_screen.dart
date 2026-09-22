import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/growth_ring_progress.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/api_models/course_models.dart';
import '../providers/instructor_home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/widgets/shimmer_placeholders.dart';

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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sort By', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Newest'),
                  trailing: _ordering == '-created_at' ? const Icon(Icons.check, color: AppColors.primaryGreen) : null,
                  onTap: () {
                    setState(() => _ordering = '-created_at');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Oldest'),
                  trailing: _ordering == 'created_at' ? const Icon(Icons.check, color: AppColors.primaryGreen) : null,
                  onTap: () {
                    setState(() => _ordering = 'created_at');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Title (A-Z)'),
                  trailing: _ordering == 'title' ? const Icon(Icons.check, color: AppColors.primaryGreen) : null,
                  onTap: () {
                    setState(() => _ordering = 'title');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Title (Z-A)'),
                  trailing: _ordering == '-title' ? const Icon(Icons.check, color: AppColors.primaryGreen) : null,
                  onTap: () {
                    setState(() => _ordering = '-title');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _ordering = '');
                      Navigator.pop(context);
                    },
                    child: const Text('Clear Filter'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStudentsBottomSheet(BuildContext context, Map<String, dynamic> stats) {
    final transactionsAsync = ref.read(instructorTransactionsProvider);
    final totalStudents = stats['total_students'] ?? 0;
    final totalEnrollments = stats['total_enrollments'] ?? totalStudents;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.skyBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.people_alt_rounded, color: AppColors.skyBlue, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Students',
                                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$totalStudents total students • $totalEnrollments enrollments',
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
                  Text(
                    'Recent Student Enrollments',
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  transactionsAsync.when(
                    data: (txs) {
                      if (txs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                const Text('No students enrolled yet', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text(
                                  'When students enroll in your courses, their names and course details will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: txs.take(10).map((tx) {
                          final buyer = tx['buyer']?.toString() ?? 'Student';
                          final course = tx['course_title']?.toString() ?? 'Enrolled Course';
                          final date = tx['date']?.toString() ?? 'Recent';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.bgLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.skyBlue.withValues(alpha: 0.15),
                                  foregroundColor: AppColors.skyBlue,
                                  radius: 20,
                                  child: Text(
                                    buyer.isNotEmpty ? buyer[0].toUpperCase() : 'S',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(buyer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(course, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Text(date, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                    error: (_, __) => const Center(child: Text('Unable to load student enrollments')),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: const Text('View Full Financial & Payout Ledger'),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.push(RouteNames.instructorAnalytics);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReviewsBottomSheet(BuildContext context, Map<String, dynamic> stats) {
    final totalReviews = stats['total_reviews'] ?? 0;
    final avgRating = (stats['average_rating'] as num?)?.toDouble() ?? 4.8;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
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
                                i < avgRating.floor() ? Icons.star_rounded : Icons.star_half_rounded,
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
              const SizedBox(height: 20),
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
  }

  Future<void> _confirmDeleteCourse(ApiCourseList course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Course Draft', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
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
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        ref.invalidate(instructorCoursesProvider);
        ref.invalidate(instructorStatsProvider);
      } catch (e) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete course: $e'),
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.lineDark : AppColors.lineLight,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search_rounded, color: AppColors.inkSoft, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            color: AppColors.primaryGreen,
            onPressed: _showFilterBottomSheet,
          ),
          const SizedBox(width: 12),
        ],
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
              const SizedBox(height: 16),
              // Greeting
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back 👨‍🏫',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft,),
                        ),
                        const SizedBox(height: 4),
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
                          width: 48,
                          height: 48,
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
                                  top: 10,
                                  right: 10,
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
              const SizedBox(height: 8),
              Text(
                'Manage your courses, revenue, and AI moderation status.',
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
                      label: const Text(
                        'Create a New Course',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                    label: const Text(
                      'New E-Book',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_alt_rounded,
                          label: 'Students',
                          value: '${stats['total_students'] ?? 0}',
                          color: AppColors.skyBlue,
                          onTap: () => _showStudentsBottomSheet(context, stats),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.play_lesson_rounded,
                          label: 'Courses',
                          value: '${stats['total_courses'] ?? 0}',
                          color: AppColors.primaryGreen,
                          onTap: () => context.push(RouteNames.instructorUploads),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star_rounded,
                          label: 'Reviews',
                          value: '${stats['total_reviews'] ?? 0}',
                          color: AppColors.signalYellow,
                          onTap: () => _showReviewsBottomSheet(context, stats),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Row(
                  children: [
                    Expanded(child: ShimmerCard(height: 100)),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerCard(height: 100)),
                    SizedBox(width: 12),
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
                                    'Instructor Guide',
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
                                    'Learn how to upload courses and ebooks with our AI assistant.',
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
                          'Recent Courses',
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
                          'My E-Books',
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
                    onPressed: () => context.push(RouteNames.instructorUploads),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_selectedDashboardTab == 0)
                ref.watch(instructorCoursesProvider((search: _searchQuery, ordering: _ordering))).when(
                  data: (courses) {
                    if (courses.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.video_library_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              const Text('No courses created yet.'),
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: AppColors.accentOrange),
                                onPressed: () => context.push(RouteNames.uploadCourse),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Create First Course'),
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
                            onDelete: () => _confirmDeleteCourse(course),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Failed to load courses'),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(instructorCoursesProvider),
                              icon: const Icon(Icons.refresh, size: 16, color: AppColors.primaryGreen),
                              label: const Text(
                                'Retry',
                                style: TextStyle(color: AppColors.primaryGreen),
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
                    if (ebooks.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('No e-books uploaded yet.'),
                      );
                    }
                    return Column(
                      children: ebooks.take(3).map((ebook) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CoursePerformanceCard(
                            title: ebook.title ?? 'Untitled E-Book',
                            students: '0',
                            revenue: '₹0',
                            rating: 'New',
                            percent: 0.0,
                            isFree: true,
                            onTap: () => context.push(RouteNames.instructorUploads),
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
                    return const Center(child: Text('Failed to load e-books'));
                  },
                ),
              const SizedBox(height: 28),

              // Recent Activity (Transactions)
              Text('Recent Transactions', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 14),
              ref.watch(instructorTransactionsProvider).when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('No recent transactions.'),
                    );
                  }
                  return Column(
                    children: transactions.take(5).map((txn) {
                      final amount = txn['amount'] ?? '0';
                      final desc = txn['description'] ?? 'Transaction';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ActivityItem(
                          icon: Icons.payment_rounded,
                          color: AppColors.primaryGreen,
                          title: '₹$amount',
                          subtitle: desc,
                          time: 'Recently',
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => Column(
                  children: List.generate(5, (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShimmerCard(height: 70),
                  )),
                ),
                error: (err, _) => const Center(child: Text('Failed to load transactions')),
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
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _CoursePerformanceCard extends StatelessWidget {
  const _CoursePerformanceCard({
    required this.title,
    required this.students,
    required this.revenue,
    required this.rating,
    required this.percent,
    this.isFree = false,
    this.onTap,
  });

  final String title;
  final String students;
  final String revenue;
  final String rating;
  final double percent;
  final bool isFree;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          GrowthRingProgress(
            percent: percent,
            size: 56,
            strokeWidth: 5,
            color: percent > 0.8 ? AppColors.primaryGreen : AppColors.accentOrange,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 14, color: AppColors.inkSoft),
                        const SizedBox(width: 4),
                        Text(students, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: AppColors.signalYellow),
                        const SizedBox(width: 3),
                        Text(rating, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    Text(
                      isFree ? 'Free' : revenue,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isFree ? AppColors.skyBlue : AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.inkSoft),
            ),
        ],
      ),
    );
  }
}

class _AgriLearnCourseCard extends StatelessWidget {
  const _AgriLearnCourseCard({
    required this.course,
    required this.onManage,
    this.onViewLive,
    required this.onDelete,
  });

  final ApiCourseList course;
  final VoidCallback onManage;
  final VoidCallback? onViewLive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = (course.status ?? 'DRAFT').toUpperCase();

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (status == 'APPROVED' || status == 'LIVE' || status == 'PUBLISHED') {
      badgeBg = Colors.green.shade50;
      badgeText = Colors.green.shade700;
      badgeLabel = '• Live';
    } else if (status == 'PROCESSING') {
      badgeBg = Colors.amber.shade50;
      badgeText = Colors.amber.shade800;
      badgeLabel = '• Processing';
    } else if (status == 'REJECTED') {
      badgeBg = Colors.red.shade50;
      badgeText = Colors.red.shade800;
      badgeLabel = '• Rejected';
    } else {
      badgeBg = isDark ? Colors.white10 : Colors.grey.shade100;
      badgeText = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
      badgeLabel = '• Draft';
    }

    final isLive = status == 'APPROVED' || status == 'LIVE' || status == 'PUBLISHED';

    return AppCard(
      padding: const EdgeInsets.all(14),
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
                          '₹${course.price ?? "0"}',
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
                          '${course.enrollmentCount ?? 0} Students',
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

          // Action Buttons: [Manage Course] [View Live] [Delete]
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
                      label: const Text(
                        'Manage Course',
                        style: TextStyle(
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
                          'View Live',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                tooltip: 'Delete Course',
              ),
            ],
          ),
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
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
          Container(
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
        ],
      ),
    );
  }
}
