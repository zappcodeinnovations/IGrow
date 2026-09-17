import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/growth_ring_progress.dart';
import '../../../core/widgets/app_card.dart';
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
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push(RouteNames.instructorAnalytics),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people_alt_rounded,
                            label: 'Students',
                            value: '${stats['total_students'] ?? 0}',
                            color: AppColors.skyBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.play_lesson_rounded,
                            label: 'Courses',
                            value: '${stats['total_courses'] ?? 0}',
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_rounded,
                            label: 'Reviews',
                            value: '${stats['total_reviews'] ?? 0}',
                            color: AppColors.signalYellow,
                          ),
                        ),
                      ],
                    ),
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

              // Course Performance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Course Performance', style: Theme.of(context).textTheme.headlineSmall),
                  TextButton(
                    onPressed: () => context.push(RouteNames.instructorUploads),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ref.watch(instructorCoursesProvider((search: _searchQuery, ordering: _ordering))).when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('No courses uploaded yet.'),
                    );
                  }
                  return Column(
                    children: courses.take(3).map((course) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CoursePerformanceCard(
                          title: course.title,
                          students: course.enrollmentCount?.toString() ?? '0',
                          revenue: '₹10', // Calculate actual revenue if API supports
                          rating: '4.5',
                          percent: 0.0,
                          isFree: course.price == '0.00',
                          onTap: () => context.push('/instructor/manage-course/${course.id}'),
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
              ),
              const SizedBox(height: 28),

              // E-Book Performance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('E-Book Performance', style: Theme.of(context).textTheme.headlineSmall),
                  TextButton(
                    onPressed: () => context.push(RouteNames.instructorUploads), // Could pass query param to start on tab index 1
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                          students: '0', // Adjust if API returns buyers count
                          revenue: '₹0', // Adjust if API returns revenue
                          rating: 'New',
                          percent: 0.0,
                          isFree: true,
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 14, color: AppColors.inkSoft),
                    const SizedBox(width: 4),
                    Text(students, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Icon(Icons.star_rounded, size: 14, color: AppColors.signalYellow),
                    const SizedBox(width: 3),
                    Text(rating, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Text(
                      isFree ? 'Free' : revenue,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isFree ? AppColors.skyBlue : AppColors.primaryGreen,),
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
