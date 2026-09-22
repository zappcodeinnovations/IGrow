import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/growth_ring_progress.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/instructor_model.dart';
import '../../../data/models/api_models/wishlist_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/student_provider.dart';

/// Upgraded Student / Farmer Dashboard Screen matching the Agrilearn Web UI & UX.
class FarmerHomeScreen extends ConsumerStatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen> {
  int _selectedTabIndex = 0; // 0: My Courses, 1: My E-Books, 2: Quiz History, 3: Wishlist

  // Sample/Fallback quiz history data matching Agrilearn web dashboard screenshot
  final List<Map<String, dynamic>> _quizHistory = [
    {
      'topic': 'आधुनिक जैविक खेती (Modern Organic Farming)',
      'date': '2026-06-15',
      'score': '85%',
    },
    {
      'topic': 'मृदा स्वास्थ्य एवं उर्वरता (Soil Health & Fertility)',
      'date': '2026-05-20',
      'score': '90%',
    },
  ];

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning 🌾';
    } else if (hour < 17) {
      return 'Good afternoon 🍊';
    } else {
      return 'Good evening 🌙';
    }
  }

  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help & Support',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'We are here to assist your farming & learning journey.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.inkSoft,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryGreen),
                title: const Text('Chat with Agri Specialist'),
                subtitle: const Text('Get instant technical support & advisory'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.chat);
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email_outlined, color: AppColors.skyBlue),
                title: const Text('Email Support'),
                subtitle: const Text('support@iagrow.zappcode.in'),
                trailing: const Icon(Icons.copy_rounded, size: 18, color: AppColors.inkSoft),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(const ClipboardData(text: 'support@iagrow.zappcode.in'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support email copied to clipboard: support@iagrow.zappcode.in'),
                      duration: Duration(milliseconds: 2000),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final fullName = (user != null && user.fullName.isNotEmpty) ? user.fullName : 'Farmer';
    final firstName = fullName.split(' ').first;

    // Fetch async data providers
    final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
    final ebooksAsync = ref.watch(studentEbooksProvider(''));
    final cartAsync = ref.watch(studentCartProvider);
    final wishlistAsync = ref.watch(wishlistProvider);

    final enrollmentsCount = enrollmentsAsync.maybeWhen(data: (list) => list.length, orElse: () => 0);
    final ebooksCount = ebooksAsync.maybeWhen(data: (list) => list.length, orElse: () => 0);
    final completedCount = enrollmentsAsync.maybeWhen(
      data: (list) => list.where((e) => (e.completionPercentage ?? 0) >= 100).length,
      orElse: () => 0,
    );
    final quizzesTakenCount = _quizHistory.length;

    final cartItemCount = cartAsync.maybeWhen(
      data: (cart) => (cart.items?.length ?? 0),
      orElse: () => 0,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Brand App Bar (Agrilearn Web Header Actions) ──────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand Logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'iGrow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Header Action Icons (Theme, Wishlist, Cart, Notifications, Profile)
                  Row(
                    children: [
                      // Wishlist Heart Badge Button
                      InkWell(
                        onTap: () => context.push(RouteNames.wishlist),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 21,
                                color: isDark ? AppColors.white : AppColors.inkDark,
                              ),
                              if (ref.watch(wishlistCountProvider) > 0)
                                Positioned(
                                  top: -4,
                                  right: -5,
                                  child: Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text(
                                      '${ref.watch(wishlistCountProvider)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Shopping Cart Badge Button
                      InkWell(
                        onTap: () => context.push(RouteNames.cart),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 21,
                                color: isDark ? AppColors.white : AppColors.inkDark,
                              ),
                              if (cartItemCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -5,
                                  child: Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentOrange,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text(
                                      '$cartItemCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Notification Bell Badge Button
                      InkWell(
                        onTap: () => context.push(RouteNames.notifications),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 21,
                                color: isDark ? AppColors.white : AppColors.inkDark,
                              ),
                              if (ref.watch(unreadNotificationsCountProvider) > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
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
                      ),
                      const SizedBox(width: 6),

                      // Profile Avatar Circle Button
                      InkWell(
                        onTap: () => context.go(RouteNames.farmerProfile),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen,
                            border: Border.all(color: isDark ? AppColors.greenLight : AppColors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'T',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Header Greeting & Weather Row ───────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTimeBasedGreeting(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$firstName's Dashboard",
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back to your agricultural learning journey!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.inkSoft,
                                fontSize: 12.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Weather Chip
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          color: AppColors.accentOrange,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '32°C',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(height: 1, fontSize: 12),
                            ),
                            Text(
                              'Pune',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkSoft, fontSize: 9.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),


              // ── Quick Navigation Action Buttons (Cart, Support, Browse Courses, Browse E-books) ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Cart Badge Button
                    InkWell(
                      onTap: () => context.push(RouteNames.cart),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.lineDark : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 19,
                                  color: isDark ? AppColors.white : AppColors.inkDark,
                                ),
                                if (cartItemCount > 0)
                                  Positioned(
                                    top: -5,
                                    right: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text(
                                        '$cartItemCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Help & Support
                    OutlinedButton.icon(
                      onPressed: () => _showHelpSupportModal(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? AppColors.lineDark : Colors.grey.shade300),
                        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                      ),
                      icon: Icon(Icons.help_outline_rounded, size: 16, color: isDark ? AppColors.white : AppColors.inkDark),
                      label: Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.inkDark,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Browse Courses Button
                    ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.explore),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706), // Agrilearn Orange Accent
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 16),
                      label: const Text(
                        'Browse Courses',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Browse E-books Button
                    OutlinedButton.icon(
                      onPressed: () => context.push(RouteNames.explore),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? const Color(0xFF047857) : const Color(0xFF166534)),
                        backgroundColor: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text(
                        'Browse E-books',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── 4 Summary Stat Cards Grid (Fully Responsive Across All Devices) ──
              LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final double aspectRatio = width < 360 ? 1.32 : (width < 420 ? 1.42 : 1.55);

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: aspectRatio,
                    children: [
                      _SummaryStatCard(
                        icon: Icons.auto_stories_rounded,
                        iconBgColor: const Color(0xFF2E7D32),
                        count: '$enrollmentsCount',
                        label: 'ENROLLED COURSES',
                      ),
                      _SummaryStatCard(
                        icon: Icons.menu_book_rounded,
                        iconBgColor: const Color(0xFFD97706),
                        count: '$ebooksCount',
                        label: 'LIBRARY E-BOOKS',
                      ),
                      _SummaryStatCard(
                        icon: Icons.verified_rounded,
                        iconBgColor: const Color(0xFF0284C7),
                        count: '$completedCount',
                        label: 'COMPLETED COURSES',
                      ),
                      _SummaryStatCard(
                        icon: Icons.task_alt_rounded,
                        iconBgColor: const Color(0xFF9333EA),
                        count: '$quizzesTakenCount',
                        label: 'QUIZZES TAKEN',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),


              // ── Tabbed Section (My Courses · My E-Books · Quiz History · Wishlist) ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TabPill(
                      label: 'My Courses',
                      isSelected: _selectedTabIndex == 0,
                      onTap: () => setState(() => _selectedTabIndex = 0),
                    ),
                    const SizedBox(width: 8),
                    _TabPill(
                      label: 'My E-Books',
                      isSelected: _selectedTabIndex == 1,
                      onTap: () => setState(() => _selectedTabIndex = 1),
                    ),
                    const SizedBox(width: 8),
                    _TabPill(
                      label: 'Quiz History',
                      isSelected: _selectedTabIndex == 2,
                      onTap: () => setState(() => _selectedTabIndex = 2),
                    ),
                    const SizedBox(width: 8),
                    _TabPill(
                      label: 'Wishlist',
                      isSelected: _selectedTabIndex == 3,
                      onTap: () => setState(() => _selectedTabIndex = 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Dynamic Tab Content ────────────────────────────────────
              IndexedStack(
                index: _selectedTabIndex,
                children: [
                  // Tab 0: My Courses
                  _buildMyCoursesTab(context, enrollmentsAsync),

                  // Tab 1: My E-Books
                  _buildMyEbooksTab(context, ebooksAsync),

                  // Tab 2: Quiz History Table
                  _buildQuizHistoryTab(context),

                  // Tab 3: Wishlist
                  _buildWishlistTab(context, wishlistAsync),
                ],
              ),
              const SizedBox(height: 28),

              // ── Verified Faculty Showcase (Top Agricultural Instructors) ──
              ref.watch(topInstructorsProvider).when(
                data: (instructors) {
                  if (instructors.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _TopInstructorsShowcase(instructors: instructors),
                      const SizedBox(height: 28),
                    ],
                  );
                },
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerContainer(width: 130, height: 22, borderRadius: 12),
                    const SizedBox(height: 8),
                    const ShimmerContainer(width: 250, height: 24),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 2,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) => const ShimmerContainer(width: 220, height: 240, borderRadius: 18),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
                error: (err, _) => const SizedBox.shrink(),
              ),

              // ── Featured Courses Showcase ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Featured Courses', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      context.push(RouteNames.explore);
                    },
                    child: Text(
                      'See All',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ref.watch(studentCatalogProvider(const CatalogQuery())).when(
                data: (courses) {
                  if (courses.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        return _CourseCard(course: courses[index], index: index);
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) => const ShimmerCourseCard(),
                  ),
                ),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: 28),

              // ── Categories ─────────────────────────────────────────────
              Text('Categories', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
              const SizedBox(height: 14),
              ref.watch(studentCategoriesProvider).when(
                data: (categories) {
                  if (categories.isEmpty) return const SizedBox.shrink();
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((cat) => _CategoryChip(icon: Icons.label_outline_rounded, label: cat.name)).toList(),
                  );
                },
                loading: () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(5, (_) => const ShimmerCategoryChip()),
                ),
                error: (err, _) => const Center(child: Text('Categories not found')),
              ),
              const SizedBox(height: 28),

              // ── Daily Tip ──────────────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.signalYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.signalYellow,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Daily Agricultural Tip',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Water your crops early in the morning to reduce evaporation and promote root moisture absorption.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkSoft,
                                  height: 1.3,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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

  // ── Tab 0 Content: My Courses ──────────────────────────────────────────────
  Widget _buildMyCoursesTab(BuildContext context, AsyncValue<List<Enrollment>> enrollmentsAsync) {
    return enrollmentsAsync.when(
      data: (enrollments) {
        if (enrollments.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.school_outlined, size: 40, color: AppColors.inkSoft),
                const SizedBox(height: 8),
                const Text('No Enrolled Courses Yet', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Explore top agricultural courses to boost your farming skills.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => context.push(RouteNames.explore),
                  child: const Text('Explore Catalog', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: enrollments.map((enr) {
            final percent = ((enr.completionPercentage ?? 0) / 100).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GrowthRingProgress(
                      percent: percent,
                      size: 64,
                      strokeWidth: 6,
                      label: '${enr.completionPercentage?.toInt() ?? 0}%',
                      sublabel: 'Done',
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            enr.courseTitle ?? 'Agricultural Course',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Resume Learning',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft, fontSize: 11.5),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => context.push('/player/${enr.courseSlug}'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Continue',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const ShimmerCard(height: 100),
      error: (err, _) => const Text('Error loading courses'),
    );
  }

  // ── Tab 1 Content: My E-Books ──────────────────────────────────────────────
  Widget _buildMyEbooksTab(BuildContext context, AsyncValue<List<EBook>> ebooksAsync) {
    return ebooksAsync.when(
      data: (ebooks) {
        if (ebooks.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.picture_as_pdf_outlined, size: 40, color: AppColors.inkSoft),
                const SizedBox(height: 8),
                const Text('No E-Books in Library', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Browse and add practical farming guides & e-books to your digital library.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => context.push(RouteNames.explore),
                  child: const Text('Browse E-Books', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: ebooks.map((ebook) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: const Center(
                        child: Icon(Icons.menu_book_rounded, color: Color(0xFFD97706), size: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ebook.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ebook.authorName.isNotEmpty ? ebook.authorName : (ebook.instructorName ?? 'Agri Specialist'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                          ),

                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: const BorderSide(color: Color(0xFFD97706)),
                            ),
                            icon: const Icon(Icons.visibility_rounded, size: 14, color: Color(0xFFD97706)),
                            label: const Text('Read E-Book', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                            onPressed: () => context.push('/farmer/explore'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const ShimmerCard(height: 100),
      error: (err, _) => const Text('Error loading e-books'),
    );
  }

  // ── Tab 2 Content: Quiz History Table (Matching Agrilearn Web Screenshot) ──
  Widget _buildQuizHistoryTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Course / Topic',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: isDark ? AppColors.white : AppColors.inkDark,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Date Taken',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: isDark ? AppColors.white : AppColors.inkDark,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Score',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: isDark ? AppColors.white : AppColors.inkDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // Table Rows
          if (_quizHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No quiz history recorded yet.', style: TextStyle(color: AppColors.inkSoft, fontSize: 12)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quizHistory.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Divider(height: 1),
              ),
              itemBuilder: (context, index) {
                final quiz = _quizHistory[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          quiz['topic'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          quiz['date'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            quiz['score'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Tab 3 Content: Wishlist ────────────────────────────────────────────────
  Widget _buildWishlistTab(BuildContext context, AsyncValue<List<ApiWishlistItem>> wishlistAsync) {
    return wishlistAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.favorite_border_rounded, size: 40, color: AppColors.inkSoft),
                const SizedBox(height: 8),
                const Text('Your Wishlist is Empty', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Save courses & e-books to your wishlist to learn anytime.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => context.push(RouteNames.explore),
                  child: const Text('Explore Now', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.isEbook ? Icons.menu_book_rounded : Icons.play_circle_fill_rounded,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.category,
                            style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        ref.read(wishlistProvider.notifier).removeItem(item.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const ShimmerCard(height: 100),
      error: (err, _) => const Text('Error loading wishlist'),
    );
  }
}

// ── Custom Summary Stat Card Widget ──────────────────────────────────────────
class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.icon,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconBgColor;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.lineDark : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconBgColor, size: 17),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    count,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── Custom Dashboard Tab Selector Pill ────────────────────────────────────────
class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
              : (isDark ? AppColors.cardDark : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFF86EFAC))
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D))
                : (isDark ? AppColors.white.withValues(alpha: 0.7) : AppColors.inkSoft),
          ),
        ),
      ),
    );
  }
}

// ── Course Card Component ───────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.index});

  final CourseList course;
  final int index;

  static const _colors = [
    AppColors.primaryGreen,
    AppColors.skyBlue,
    AppColors.accentOrange,
    AppColors.earthBrown,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colors[index % _colors.length];

    return GestureDetector(
      onTap: () {
        context.push('/farmer/course/${course.id}');
      },
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
          boxShadow: AppColors.greenShadow(
            blurRadius: 14,
            offset: const Offset(0, 4),
            opacity: isDark ? 0.05 : 0.08,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 95,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: course.thumbnail != null
                    ? DecorationImage(
                        image: NetworkImage(course.thumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: course.thumbnail == null
                  ? Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 38,
                        color: color,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.signalYellow),
                      const SizedBox(width: 3),
                      Text(
                        '4.5',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        course.price == '0.00' ? 'Free' : '₹${course.price}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.lineDark : AppColors.lineLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

// ── Verified Faculty Showcase Component ──────────────────────────────────────
class _TopInstructorsShowcase extends StatelessWidget {
  const _TopInstructorsShowcase({required this.instructors});

  final List<ApiTopInstructor> instructors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verified Faculty Tag Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 13, color: Color(0xFFB45309)),
              SizedBox(width: 4),
              Text(
                'VERIFIED FACULTY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF92400E),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Section Title & Link Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Courses by Top Agricultural Instructors',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Learn directly from verified farming experts, agronomists, and agricultural specialists.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSoft,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => context.push(RouteNames.explore),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore All',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.accentOrange : const Color(0xFF1B4D2E),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: isDark ? AppColors.accentOrange : const Color(0xFF1B4D2E),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Instructors Horizontal List
        SizedBox(
          height: 235,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: instructors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final inst = instructors[index];
              return _InstructorCard(inst: inst);
            },
          ),
        ),
      ],
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard({required this.inst});

  final ApiTopInstructor inst;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.lineDark : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 4,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFFF59E0B), Color(0xFF1B5E20)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFDCFCE7),
                            border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                          ),
                          child: Center(
                            child: inst.avatar != null && inst.avatar!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      inst.avatar!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                        inst.fullName.isNotEmpty ? inst.fullName[0].toUpperCase() : 'I',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF166534),
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    inst.fullName.isNotEmpty ? inst.fullName[0].toUpperCase() : 'I',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
                        ),
                      ),
                      child: Text(
                        inst.experience,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  inst.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  inst.specialtyCrops ?? inst.expertiseTags ?? 'Agricultural Specialist',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text(
                      inst.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    if (inst.reviewCount > 0)
                      Text(
                        ' (${inst.reviewCount})',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    const Spacer(),
                    Icon(Icons.people_alt_outlined, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 3),
                    Text(
                      '${inst.totalStudents} learners',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E3A2B) : const Color(0xFFF0FDF4),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(
                      Icons.menu_book_rounded,
                      size: 12,
                      color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
                    ),
                    label: Text(
                      'View Courses (${inst.totalCourses})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
                      ),
                    ),
                    onPressed: () {
                      context.push('/farmer/explore?search=${Uri.encodeComponent(inst.fullName)}');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


