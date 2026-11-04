import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/instructor_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/services/quiz_service.dart';
import '../providers/student_provider.dart';
import '../providers/weather_provider.dart';
import '../../news/widgets/home_news_carousel.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../../core/widgets/shell_scaffold.dart';
import '../../../core/localization/app_strings.dart';

/// Upgraded Student / Farmer Dashboard Screen matching the Agrilearn Web UI & UX.
class FarmerHomeScreen extends ConsumerStatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen> {
  // Quiz history initialized clean for the farmer account, dynamically loaded from QuizService
  final List<Map<String, dynamic>> _quizHistory = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizHistory() async {
    final user = ref.read(authProvider).user;
    final userId = user?.id ?? user?.email;
    final history = await QuizService.getQuizHistory(userId: userId);
    if (mounted) {
      setState(() {
        _quizHistory.clear();
        _quizHistory.addAll(history);
      });
    }
  }

  Future<void> _refreshDashboard() async {
    // Invalidate all data providers so they re-fetch from the network
    ref.invalidate(studentEnrollmentsProvider);
    ref.invalidate(studentEbooksProvider(const EbooksQuery()));
    ref.invalidate(studentCatalogProvider(const CatalogQuery()));
    ref.invalidate(studentCategoriesProvider);
    ref.invalidate(topInstructorsProvider);
    ref.invalidate(studentCartProvider);
    // Reload quiz history from local storage
    await _loadQuizHistory();
    // Refresh real-time weather data
    ref.read(weatherProvider.notifier).refresh();
    // Wait for enrollments to finish re-fetching before completing
    await ref.read(studentEnrollmentsProvider.future).catchError((_) => <Enrollment>[]);
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final fullName = (user != null && user.fullName.isNotEmpty) ? user.fullName : 'Farmer';
    final firstName = fullName.split(' ').first;

    // Fetch async data providers
    final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
    final weatherAsync = ref.watch(weatherProvider);
    final weatherData = weatherAsync.valueOrNull;

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      color: AppColors.primaryGreen,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      displacement: 60,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Curved Deep Forest Green Header (Strictly matching prototype) ─────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF143E24) : const Color(0xFF1B4D2E),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Header Row: Sprout Icon + "IAGROW ACADEMY" + Right Icons (Notification bell, etc.)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (shellScaffoldKey.currentState != null) {
                                shellScaffoldKey.currentState!.openDrawer();
                              } else {
                                Scaffold.of(context).openDrawer();
                              }
                            },
                            borderRadius: BorderRadius.circular(9999),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              child: const Icon(
                                Icons.menu_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.eco_rounded,
                            size: 19,
                            color: Color(0xFF86EFAC),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'IAGROW ACADEMY',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: Color(0xFF86EFAC),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notification Bell
                          InkWell(
                            onTap: () => context.push(RouteNames.notifications),
                            borderRadius: BorderRadius.circular(9999),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  if (ref.watch(unreadNotificationsCountProvider) > 0)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFBBF24),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Wishlist / Heart
                          Consumer(
                            builder: (context, ref, child) {
                              final wishlistCount = ref.watch(wishlistProvider).maybeWhen(
                                    data: (items) => items.length,
                                    orElse: () => 0,
                                  );
                              return InkWell(
                                onTap: () => context.push(RouteNames.wishlist),
                                borderRadius: BorderRadius.circular(9999),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(
                                        Icons.favorite_border_rounded,
                                        size: 19,
                                        color: Colors.white,
                                      ),
                                      if (wishlistCount > 0)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(2.5),
                                            decoration: const BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(minWidth: 13, minHeight: 13),
                                            child: Text(
                                              '$wishlistCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          // Profile Avatar Pill
                          InkWell(
                            onTap: () => context.go(RouteNames.farmerProfile),
                            borderRadius: BorderRadius.circular(9999),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Color(0xFF1B4D2E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Greeting Title with Namaste & Waving Hand
                  const Text(
                    'Namaste, grow with knowledge',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Learn farming from the best',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // White Rounded Search Bar inside Green Header
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: tr(ref, 'Search farming courses...'),
                        hintStyle: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF888888),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF666666),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                color: const Color(0xFF666666),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Content Body on Light/Dark Canvas ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: ResponsiveContentConstraint(
                maxWidth: 1040,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── "Browse by category" Section (App's actual dynamic categories) ──────
                    if (_searchQuery.isEmpty) ...[
                      Text(
                        tr(ref, 'Browse by category'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ref.watch(studentCategoriesProvider).when(
                        data: (categories) {
                          if (categories.isEmpty) return const SizedBox.shrink();
                          return SizedBox(
                            height: 98,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final iconData = _getCategoryIcon(cat.name);
                                final pastelBg = _getCategoryBg(index, isDark);

                                return InkWell(
                                  onTap: () {
                                    context.push('/farmer/explore?category=${cat.id}');
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 62,
                                        height: 62,
                                        decoration: BoxDecoration(
                                          color: pastelBg,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDark ? AppColors.lineDark : Colors.transparent,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            iconData,
                                            size: 28,
                                            color: _getCategoryColor(index, isDark),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 66,
                                        child: Text(
                                          cat.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : const Color(0xFF333333),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => SizedBox(
                          height: 98,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 4,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) => Column(
                              children: const [
                                ShimmerContainer(width: 62, height: 62, borderRadius: 16),
                                SizedBox(height: 6),
                                ShimmerContainer(width: 48, height: 10, borderRadius: 4),
                              ],
                            ),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── "Featured courses" Section Header ────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _searchQuery.isNotEmpty
                              ? '${tr(ref, "Search Results")} (${tr(ref, "Courses")})'
                              : tr(ref, 'Featured courses'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                          ),
                        ),
                        InkWell(
                          onTap: () => context.go(RouteNames.explore),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tr(ref, 'See all'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B4D2E),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Color(0xFF1B4D2E),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
              ref.watch(studentCatalogProvider(CatalogQuery(search: _searchQuery))).when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 44, color: AppColors.inkSoft.withValues(alpha: 0.5)),
                            const SizedBox(height: 10),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No courses found for "$_searchQuery"'
                                  : 'No courses available right now',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : AppColors.editorialOnSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: Text(tr(ref, 'Clear Search')),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < courses.length; i++) ...[
                        _CourseCard(course: courses[i], index: i),
                        if (i < courses.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  );
                },
                loading: () => Column(
                  children: const [
                    ShimmerCourseCard(),
                    SizedBox(height: 14),
                    ShimmerCourseCard(),
                  ],
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.orange),
                        const SizedBox(height: 10),
                        Text(
                          tr(ref, 'Unable to load courses. Please check your connection.'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.editorialOutline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(tr(ref, 'Try Again')),
                          onPressed: () => ref.invalidate(studentCatalogProvider(CatalogQuery(search: _searchQuery))),
                        ),
                      ],
                    ),
                  ),
                ),
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

              // ── Latest Agriculture News Carousel ───────────────────────
              const HomeNewsCarousel(),
              const SizedBox(height: 28),

              // ── 5. Recent Module Peek (Stitch Exact Match) ────────────────
              enrollmentsAsync.when(
                data: (enrollments) {
                  final activeEnrollment = enrollments.isNotEmpty ? enrollments.first : null;
                  final courseTitle = activeEnrollment?.courseTitle ?? 'zhc';
                  final progressPct = (activeEnrollment?.completionPercentage ?? 100).round();
                  final isComplete = progressPct >= 100;
                  final courseTarget = (activeEnrollment?.courseSlug != null && activeEnrollment!.courseSlug!.isNotEmpty)
                      ? activeEnrollment.courseSlug!
                      : (activeEnrollment?.course ?? '');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Module',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : AppColors.editorialOnSurface,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.go(RouteNames.farmerLearning),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'My Learning',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.editorialSecondary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: AppColors.editorialSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isComplete
                                              ? (isDark ? const Color(0xFF262060) : AppColors.editorialSecondaryFixed)
                                              : (isDark ? const Color(0xFF1E3524) : const Color(0xFFDCFCE7)),
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isComplete ? Icons.check_circle_rounded : Icons.pending_rounded,
                                              size: 13,
                                              color: isComplete
                                                  ? (isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialOnSecondaryFixed)
                                                  : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534)),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isComplete ? 'MODULE COMPLETE' : 'IN PROGRESS',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.4,
                                                color: isComplete
                                                    ? (isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialOnSecondaryFixed)
                                                    : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        courseTitle,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.3,
                                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Advanced Zero-Tillage Horticulture • Core Course',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (courseTarget.isNotEmpty) {
                                        context.push('/player/$courseTarget');
                                      } else {
                                        context.push(RouteNames.explore);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? Colors.white : Colors.black,
                                      foregroundColor: isDark ? Colors.black : Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    ),
                                    child: const Text(
                                      'Resume',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Linear Architectural Progress Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '$progressPct%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(9999),
                              child: Container(
                                height: 6,
                                width: double.infinity,
                                color: isDark ? Colors.white12 : AppColors.editorialSurfaceContainer,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (progressPct / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    color: AppColors.editorialSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),


              // ── 7. Daily Agricultural Tip (Stitch Exact Match) ───────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceContainerLowDark : AppColors.editorialSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 18,
                              color: AppColors.editorialSecondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'DAILY AGRICULTURAL TIP',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AppColors.editorialSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Vol. 18',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.editorialSecondary.withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        '“Optimizing drip line pressure to 1.0–1.5 bar minimizes emitter clogging and ensures uniform micro-nutrient dissemination across lateral orchard rows.”',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prof. R. Deshmukh • Soil & Water Div.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tip saved to your agriculture notes'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bookmark_border_rounded,
                                size: 16,
                                color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Icon & Color Helpers ─────────────────────────────
IconData _getCategoryIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('crop') || lower.contains('field')) {
    return Icons.grass_rounded;
  } else if (lower.contains('water') || lower.contains('irrigat')) {
    return Icons.water_drop_rounded;
  } else if (lower.contains('pest') || lower.contains('protect')) {
    return Icons.pest_control_rounded;
  } else if (lower.contains('organic') || lower.contains('soil')) {
    return Icons.eco_rounded;
  } else if (lower.contains('animal') || lower.contains('dairy') || lower.contains('husbandry')) {
    return Icons.pets_rounded;
  } else if (lower.contains('tech') || lower.contains('machin')) {
    return Icons.agriculture_rounded;
  } else if (lower.contains('horticult') || lower.contains('fruit') || lower.contains('veget')) {
    return Icons.yard_rounded;
  } else if (lower.contains('climate') || lower.contains('weather')) {
    return Icons.cloud_outlined;
  }
  return Icons.menu_book_rounded;
}

Color _getCategoryBg(int index, bool isDark) {
  if (isDark) return const Color(0xFF1F2D24);
  const tints = [
    Color(0xFFE8F5E9), // Crops / light green
    Color(0xFFE1F5FE), // Water / light cyan
    Color(0xFFE8F8F5), // Pests / light teal
    Color(0xFFF1F8E9), // Organic / light lime
    Color(0xFFFFF3E0), // Animal / light orange
    Color(0xFFF3E5F5), // Tech / light purple
    Color(0xFFFFEBEE), // Horticulture / light pink
    Color(0xFFECEFF1), // Climate / light blue-grey
  ];
  return tints[index % tints.length];
}

Color _getCategoryColor(int index, bool isDark) {
  if (isDark) return const Color(0xFF86EFAC);
  const colors = [
    Color(0xFF2E7D32), // Crops
    Color(0xFF0288D1), // Water
    Color(0xFF00897B), // Pests
    Color(0xFF558B2F), // Organic
    Color(0xFFE65100), // Animal
    Color(0xFF7B1FA2), // Tech
    Color(0xFFC2185B), // Horticulture
    Color(0xFF455A64), // Climate
  ];
  return colors[index % colors.length];
}

// ── Course Card Component (Matching Prototype Screen 11 Large Card) ───────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.index});

  final CourseList course;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFree = course.price == null ||
        course.price == '0' ||
        course.price == '0.00' ||
        course.price == '0.0';
    final priceText = isFree ? 'FREE' : '₹${course.price}';
    final badgeLabel = isFree ? 'Free course' : (index % 2 == 0 ? 'Bestseller' : 'Popular');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/farmer/course/${course.id}');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.lineDark : const Color(0xFFE5ECE5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Thumbnail Container with Bestseller/Free Badge
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: isDark ? const Color(0xFF24242A) : const Color(0xFFE9EFE9),
                        child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                            ? Image.network(
                                course.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.spa_rounded,
                                    size: 48,
                                    color: Color(0xFF86EFAC),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.spa_rounded,
                                  size: 48,
                                  color: Color(0xFF86EFAC),
                                ),
                              ),
                      ),
                      // Top Left Badge Pill
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isFree ? const Color(0xFFFEF3C7) : const Color(0xFFFDE68A),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            badgeLabel,
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Details Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : const Color(0xFF192A1D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Instructor Row
                    Text(
                      'By ${course.instructorName ?? "IAGROW Agriculture Experts"}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Rating & Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.8 (248)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isFree
                                ? const Color(0xFF1B4D2E)
                                : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF1B4D2E)),
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
      ),
    );
  }
}

// ── Verified Faculty Showcase Component ──────────────────────────────────────
class _TopInstructorsShowcase extends ConsumerWidget {
  const _TopInstructorsShowcase({required this.instructors});

  final List<ApiTopInstructor> instructors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 13, color: Color(0xFFB45309)),
              const SizedBox(width: 4),
              Text(
                tr(ref, 'VERIFIED FACULTY'),
                style: const TextStyle(
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
                    tr(ref, 'Explore Courses by Top Agricultural Instructors'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          height: 1.2,
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
                      tr(ref, 'Explore All'),
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
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: instructors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
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
      width: 172,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.lineDark
              : AppColors.editorialOutlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/farmer/explore?search=${Uri.encodeComponent(inst.fullName)}');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Avatar with verified check & Experience Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.editorialSecondary.withValues(alpha: 0.2)
                                : AppColors.editorialSecondaryFixed,
                            border: Border.all(
                              color: AppColors.editorialSecondary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: inst.avatar != null && inst.avatar!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      inst.avatar!,
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                        inst.fullName.isNotEmpty ? inst.fullName[0].toUpperCase() : 'I',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.editorialSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    inst.fullName.isNotEmpty ? inst.fullName[0].toUpperCase() : 'I',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.editorialSecondary,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: AppColors.editorialSecondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (inst.experience.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.editorialSecondary.withValues(alpha: 0.15)
                              : AppColors.editorialSecondaryFixed.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          inst.experience,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.editorialSecondaryFixedDim
                                : AppColors.editorialOnSecondaryFixed,
                          ),
                        ),
                      ),
                  ],
                ),

                // Name & Expertise
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inst.fullName,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inst.specialtyCrops ?? inst.expertiseTags ?? 'Agricultural Specialist',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Footer Row: Rating & Course count tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 2),
                        Text(
                          inst.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.editorialSurfaceContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${inst.totalCourses} courses',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


