import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/instructor_model.dart';
import '../../../data/models/api_models/course_models.dart' show CourseCategory;
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/services/quiz_service.dart';
import '../providers/student_provider.dart';
import '../providers/weather_provider.dart';
import '../../news/widgets/home_news_carousel.dart';
import '../../../core/widgets/shell_scaffold.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/models/user_role.dart';
import '../../auth/widgets/become_instructor_bottom_sheet.dart';
import '../widgets/floating_offer_badge.dart';
import '../widgets/home_banner_carousel.dart';

/// Upgraded Student / Farmer Dashboard Screen matching the Agrilearn Web UI & UX.
class FarmerHomeScreen extends ConsumerStatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen> {
  void _showSwitchRoleDialog(BuildContext context) {
    final user = ref.read(authProvider).user;
    final hasInstructorRole = user?.grantedRoles.contains(UserRole.instructor) == true;

    // If user has not yet unlocked Instructor role, show the Become Instructor flow (Name + Phone)
    if (!hasInstructorRole) {
      BecomeInstructorBottomSheet.show(
        context,
        onSuccess: () {
          if (context.mounted) {
            context.go(RouteNames.instructorHome);
          }
        },
      );
      return;
    }

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
            Text('Switch Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'You are switching to Instructor Mode. You will be able to create courses, manage students, and view teaching analytics.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              // Switch role in AuthProvider and navigate to Instructor panel
              await ref.read(authProvider.notifier).switchRole(UserRole.instructor);
              if (context.mounted) {
                context.go(RouteNames.instructorHome);
              }
            },
            child: const Text('OK, Switch', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
    await ref
        .read(studentEnrollmentsProvider.future)
        .catchError((_) => <Enrollment>[]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final fullName = (user != null && user.fullName.isNotEmpty)
        ? user.fullName
        : 'Farmer';
    final firstName = fullName.split(' ').first;

    // Fetch async data providers
    ref.watch(weatherProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: AppColors.primaryGreen,
          backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
          displacement: 60,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Clean Transparent / Natural Top App Bar ─────
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 18,
                right: 18,
                bottom: 12,
              ),
              child: Row(
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
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE8F0EA),
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            size: 20,
                            color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.eco_rounded,
                        size: 20,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'IAGROW',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF1B4D2E),
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
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE8F0EA),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 20,
                                color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                              ),
                              if (ref.watch(unreadNotificationsCountProvider) > 0)
                                Positioned(
                                  top: 9,
                                  right: 9,
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
                      const SizedBox(width: 10),
                      // Switch to Instructor Mode Pill Button
                      InkWell(
                        onTap: () => _showSwitchRoleDialog(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                                size: 16,
                                color: Color(0xFF86EFAC),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Instructor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 2. Top Interactive Swiping Banner Carousel ───────────────────
            // Slide 0: High-aesthetic ambient welcome landscape
            // Slide 1..N: Featured Courses (Tap opens modal with View Course)
            ref.watch(studentCatalogProvider(const CatalogQuery())).maybeWhen(
              data: (courses) => HomeBannerCarousel(
                courses: courses.take(6).toList(),
                userName: firstName,
              ),
              orElse: () => HomeBannerCarousel(
                courses: const [],
                userName: firstName,
              ),
            ),

            // ── 3. Content Body on Light/Dark Canvas ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: ResponsiveContentConstraint(
                maxWidth: 1040,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── "Browse by category" Section with matching graphic badges ─────
                    if (_searchQuery.isEmpty) ...[
                      Text(
                        tr(ref, 'Browse by category'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1B4D2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ref
                          .watch(studentCategoriesProvider)
                          .when(
                            data: (categories) {
                              if (categories.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(
                                height: 98,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final cat = categories[index];
                                    final iconData = _getCategoryIcon(cat.name, cat.slug);
                                    final visual = _getCategoryVisual(cat.name, cat.slug, isDark, index);

                                    return InkWell(
                                      onTap: () {
                                        context.push(
                                          '/farmer/explore?category=${cat.id}',
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(18),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 62,
                                            height: 62,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: visual.gradient,
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: visual.borderColor,
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: visual.shadowColor,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                iconData,
                                                size: 26,
                                                color: visual.iconColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: 68,
                                            child: Text(
                                              cat.name,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.2,
                                                color: isDark
                                                    ? Colors.white.withValues(alpha: 0.9)
                                                    : const Color(0xFF1E293B),
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
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) => Column(
                                  children: const [
                                    ShimmerContainer(
                                      width: 62,
                                      height: 62,
                                      borderRadius: 16,
                                    ),
                                    SizedBox(height: 6),
                                    ShimmerContainer(
                                      width: 48,
                                      height: 10,
                                      borderRadius: 4,
                                    ),
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1B4D2E),
                          ),
                        ),
                        InkWell(
                          onTap: () => context.go(RouteNames.explore),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tr(ref, 'See all'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B4D2E),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B4D2E),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ref
                        .watch(
                          studentCatalogProvider(
                            CatalogQuery(search: _searchQuery),
                          ),
                        )
                        .when(
                          data: (courses) {
                            if (courses.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 44,
                                        color: AppColors.inkSoft.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'No courses found for "$_searchQuery"'
                                            : 'No courses available right now',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white70
                                              : AppColors.editorialOnSurface,
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
                                  if (i < courses.length - 1)
                                    const SizedBox(height: 14),
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
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 40,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    tr(
                                      ref,
                                      'Unable to load courses. Please check your connection.',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.editorialOutline,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                    ),
                                    label: Text(tr(ref, 'Try Again')),
                                    onPressed: () => ref.invalidate(
                                      studentCatalogProvider(
                                        CatalogQuery(search: _searchQuery),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 28),

                    // ── Verified Faculty Showcase (Top Agricultural Instructors) ──
                    ref
                        .watch(topInstructorsProvider)
                        .when(
                          data: (instructors) {
                            if (instructors.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                _TopInstructorsShowcase(
                                  instructors: instructors,
                                ),
                                const SizedBox(height: 28),
                              ],
                            );
                          },
                          loading: () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ShimmerContainer(
                                width: 130,
                                height: 22,
                                borderRadius: 12,
                              ),
                              const SizedBox(height: 8),
                              const ShimmerContainer(width: 250, height: 24),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 240,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 2,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) =>
                                      const ShimmerContainer(
                                        width: 220,
                                        height: 240,
                                        borderRadius: 18,
                                      ),
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

                    // ── 7. Daily Agricultural Tip (Stitch Exact Match) ───────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceContainerLowDark
                            : AppColors.editorialSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.03,
                            ),
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
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 18,
                                    color: AppColors.editorialSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tr(ref, 'DAILY AGRICULTURAL TIP'),
                                    style: const TextStyle(
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
                                  color: isDark
                                      ? Colors.white60
                                      : AppColors.editorialOnSurfaceVariant,
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
                                  color: AppColors.editorialSecondary
                                      .withValues(alpha: 0.5),
                                  width: 2.5,
                                ),
                              ),
                            ),
                            child: Text(
                              tr(ref, 'Optimizing drip line pressure to 1.0–1.5 bar minimizes emitter clogging and ensures uniform micro-nutrient dissemination across lateral orchard rows.'),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontStyle: FontStyle.italic,
                                height: 1.45,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.editorialOnSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tr(ref, 'Prof. R. Deshmukh • Soil & Water Div.'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white60
                                      : AppColors.editorialOnSurfaceVariant,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr(ref, 'Tip saved to your agriculture notes'),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bookmark_border_rounded,
                                      size: 16,
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.editorialOnSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      tr(ref, 'Save'),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors
                                                  .editorialOnSurfaceVariant,
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
          ],
        ),
      ),
    ),
    const FloatingOfferBadge(),
  ],
);
  }
}

// ── Professional Category Visual Configurations ─────────────────────────────
class _CategoryVisualConfig {
  final List<Color> gradient;
  final Color borderColor;
  final Color shadowColor;
  final Color iconColor;

  const _CategoryVisualConfig({
    required this.gradient,
    required this.borderColor,
    required this.shadowColor,
    required this.iconColor,
  });
}

IconData _getCategoryIcon(String name, [String? slug]) {
  final key = '${name.toLowerCase()} ${slug?.toLowerCase() ?? ''}';
  if (key.contains('crop') || key.contains('agronomy') || key.contains('फसल') || key.contains('पिके')) {
    return Icons.agriculture_rounded;
  } else if (key.contains('organic') || key.contains('sustainable') || key.contains('जैविक') || key.contains('सेंद्रिय')) {
    return Icons.eco_rounded;
  } else if (key.contains('water') || key.contains('irrigat') || key.contains('सिंचाई') || key.contains('सिंचन')) {
    return Icons.water_drop_rounded;
  } else if (key.contains('pest') || key.contains('disease') || key.contains('protect') || key.contains('कीट') || key.contains('कीड')) {
    return Icons.shield_outlined;
  } else if (key.contains('dairy') || key.contains('cow') || key.contains('milk') || key.contains('दुग्ध')) {
    return Icons.local_drink_rounded;
  } else if (key.contains('livestock') || key.contains('animal') || key.contains('husbandry') || key.contains('पशुधन')) {
    return Icons.pets_rounded;
  } else if (key.contains('poultry') || key.contains('मुर्गी') || key.contains('कुक्कुट')) {
    return Icons.egg_outlined;
  } else if (key.contains('aquaculture') || key.contains('fish') || key.contains('मछली') || key.contains('मत्स्य')) {
    return Icons.set_meal_rounded;
  } else if (key.contains('horticult') || key.contains('fruit') || key.contains('veget') || key.contains('बागवानी') || key.contains('फलोत्पादन')) {
    return Icons.local_florist_rounded;
  } else if (key.contains('agroforestry') || key.contains('forestry') || key.contains('वानिकी') || key.contains('वनशेती')) {
    return Icons.park_rounded;
  } else if (key.contains('food') || key.contains('process') || key.contains('storage') || key.contains('खाद्य') || key.contains('अन्न')) {
    return Icons.inventory_2_outlined;
  } else if (key.contains('business') || key.contains('market') || key.contains('व्यवसाय') || key.contains('विपणन')) {
    return Icons.storefront_rounded;
  } else if (key.contains('precision') || key.contains('tech') || key.contains('machin') || key.contains('यंत्र') || key.contains('अवजारे')) {
    return Icons.precision_manufacturing_rounded;
  } else if (key.contains('soil') || key.contains('मृदा') || key.contains('माती')) {
    return Icons.landscape_rounded;
  } else if (key.contains('climate') || key.contains('weather') || key.contains('मौसम')) {
    return Icons.wb_sunny_rounded;
  }
  return Icons.spa_rounded;
}

_CategoryVisualConfig _getCategoryVisual(String name, String? slug, bool isDark, int index) {
  final key = '${name.toLowerCase()} ${slug?.toLowerCase() ?? ''}';

  if (isDark) {
    if (key.contains('crop') || key.contains('agronomy') || key.contains('organic') || key.contains('sustainable')) {
      return _CategoryVisualConfig(
        gradient: [const Color(0xFF143E24), const Color(0xFF1B4D2E)],
        borderColor: const Color(0xFF22C55E).withValues(alpha: 0.35),
        shadowColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
        iconColor: const Color(0xFF86EFAC),
      );
    } else if (key.contains('water') || key.contains('irrigat') || key.contains('aquaculture')) {
      return _CategoryVisualConfig(
        gradient: [const Color(0xFF0F314D), const Color(0xFF134E74)],
        borderColor: const Color(0xFF38BDF8).withValues(alpha: 0.35),
        shadowColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
        iconColor: const Color(0xFF7DD3FC),
      );
    } else if (key.contains('pest') || key.contains('disease') || key.contains('protect')) {
      return _CategoryVisualConfig(
        gradient: [const Color(0xFF422020), const Color(0xFF6B2D2D)],
        borderColor: const Color(0xFFF87171).withValues(alpha: 0.35),
        shadowColor: const Color(0xFFF87171).withValues(alpha: 0.15),
        iconColor: const Color(0xFFFCA5A5),
      );
    } else if (key.contains('dairy') || key.contains('livestock') || key.contains('poultry')) {
      return _CategoryVisualConfig(
        gradient: [const Color(0xFF3E2D12), const Color(0xFF5E431B)],
        borderColor: const Color(0xFFFBBF24).withValues(alpha: 0.35),
        shadowColor: const Color(0xFFFBBF24).withValues(alpha: 0.15),
        iconColor: const Color(0xFFFDE68A),
      );
    } else if (key.contains('horticult') || key.contains('agroforestry')) {
      return _CategoryVisualConfig(
        gradient: [const Color(0xFF183B32), const Color(0xFF235447)],
        borderColor: const Color(0xFF34D399).withValues(alpha: 0.35),
        shadowColor: const Color(0xFF34D399).withValues(alpha: 0.15),
        iconColor: const Color(0xFFA7F3D0),
      );
    } else if (key.contains('food') || key.contains('business')) {
      return _CategoryVisualConfig(
        gradient: [const Color(0xFF452B14), const Color(0xFF663E1C)],
        borderColor: const Color(0xFFFB923C).withValues(alpha: 0.35),
        shadowColor: const Color(0xFFFB923C).withValues(alpha: 0.15),
        iconColor: const Color(0xFFFED7AA),
      );
    } else {
      return _CategoryVisualConfig(
        gradient: [const Color(0xFF272A3D), const Color(0xFF3A3F5C)],
        borderColor: const Color(0xFF818CF8).withValues(alpha: 0.35),
        shadowColor: const Color(0xFF818CF8).withValues(alpha: 0.15),
        iconColor: const Color(0xFFC7D2FE),
      );
    }
  }

  // Light Mode (Clean, subtle pastel tints with crisp professional icon colors)
  if (key.contains('crop') || key.contains('agronomy') || key.contains('organic') || key.contains('sustainable')) {
    return _CategoryVisualConfig(
      gradient: [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
      borderColor: const Color(0xFFBBF7D0),
      shadowColor: const Color(0xFF16A34A).withValues(alpha: 0.10),
      iconColor: const Color(0xFF15803D),
    );
  } else if (key.contains('water') || key.contains('irrigat') || key.contains('aquaculture')) {
    return _CategoryVisualConfig(
      gradient: [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
      borderColor: const Color(0xFFBAE6FD),
      shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.10),
      iconColor: const Color(0xFF0369A1),
    );
  } else if (key.contains('pest') || key.contains('disease') || key.contains('protect')) {
    return _CategoryVisualConfig(
      gradient: [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)],
      borderColor: const Color(0xFFFECACA),
      shadowColor: const Color(0xFFDC2626).withValues(alpha: 0.10),
      iconColor: const Color(0xFFB91C1C),
    );
  } else if (key.contains('dairy') || key.contains('livestock') || key.contains('poultry')) {
    return _CategoryVisualConfig(
      gradient: [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
      borderColor: const Color(0xFFFDE68A),
      shadowColor: const Color(0xFFD97706).withValues(alpha: 0.10),
      iconColor: const Color(0xFFB45309),
    );
  } else if (key.contains('horticult') || key.contains('agroforestry')) {
    return _CategoryVisualConfig(
      gradient: [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
      borderColor: const Color(0xFFA7F3D0),
      shadowColor: const Color(0xFF059669).withValues(alpha: 0.10),
      iconColor: const Color(0xFF047857),
    );
  } else if (key.contains('food') || key.contains('business')) {
    return _CategoryVisualConfig(
      gradient: [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
      borderColor: const Color(0xFFFED7AA),
      shadowColor: const Color(0xFFEA580C).withValues(alpha: 0.10),
      iconColor: const Color(0xFFC2410C),
    );
  } else {
    return _CategoryVisualConfig(
      gradient: [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
      borderColor: const Color(0xFFDDD6FE),
      shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.10),
      iconColor: const Color(0xFF6D28D9),
    );
  }
}

// ── Course Card Component (Matching Prototype Screen 11 Large Card) ───────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.index});

  final CourseList course;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFree =
        course.price == null ||
        course.price == '0' ||
        course.price == '0.00' ||
        course.price == '0.0';
    final priceText = isFree ? 'FREE' : '₹${course.price}';
    final categoryName =
        course.category?.name ??
        CourseCategory.fromValue(course.category?.slug)?.display;
    final badgeLabel = (categoryName != null && categoryName.trim().isNotEmpty)
        ? categoryName.trim()
        : (isFree
              ? 'Free course'
              : (index % 2 == 0 ? 'Bestseller' : 'Popular'));

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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: isDark
                            ? const Color(0xFF24242A)
                            : const Color(0xFFE9EFE9),
                        child:
                            course.thumbnail != null &&
                                course.thumbnail!.isNotEmpty
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A2F)
                                : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFF132A13),
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
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6B7280),
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
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF374151),
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
                                : (isDark
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFF1B4D2E)),
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
              const Icon(
                Icons.auto_awesome,
                size: 13,
                color: Color(0xFFB45309),
              ),
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
                        color: isDark
                            ? AppColors.accentOrange
                            : const Color(0xFF1B4D2E),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: isDark
                          ? AppColors.accentOrange
                          : const Color(0xFF1B4D2E),
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
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: instructors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final inst = instructors[index];
              return _InstructorCard(inst: inst, index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard({required this.inst, required this.index});

  final ApiTopInstructor inst;
  final int index;

  static const List<Color> _portraitBackdropColors = [
    Color(0xFFE5A638), // Warm mustard yellow (matches screenshot)
    Color(0xFF3B82F6), // Ocean blue
    Color(0xFF10B981), // Emerald green
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF97316), // Tangerine
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backdropColor =
        _portraitBackdropColors[index % _portraitBackdropColors.length];
    final specialty =
        (inst.specialtyCrops != null && inst.specialtyCrops!.trim().isNotEmpty)
        ? inst.specialtyCrops!.trim()
        : ((inst.expertiseTags != null && inst.expertiseTags!.trim().isNotEmpty)
              ? inst.expertiseTags!.trim()
              : 'Agri Specialist');

    final studentCountFormatted = inst.totalStudents >= 1000
        ? '${(inst.totalStudents / 1000).toStringAsFixed(inst.totalStudents % 1000 == 0 ? 0 : 1)}k'
        : '${inst.totalStudents}';

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.lineDark : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/farmer/instructor/${inst.id}', extra: inst);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top Image Container with Colored Backdrop & Overlay Action Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: backdropColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                        child: inst.avatar != null && inst.avatar!.isNotEmpty
                            ? Image.network(
                                inst.avatar!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackAvatar(backdropColor),
                              )
                            : _buildFallbackAvatar(backdropColor),
                      ),
                    ),
                    // Blue Circle Plus Button pinned at bottom-right corner of photo
                    Positioned(
                      bottom: -10,
                      right: 10,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E5BB8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1E5BB8,
                              ).withValues(alpha: 0.35),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // ── Instructor Info & Metrics ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Instructor Name
                    Text(
                      inst.fullName,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Row 1: Specialty / Role & Course Count
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            specialty,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${inst.totalCourses} ${inst.totalCourses == 1 ? "Course" : "Courses"}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Row 2: Students Count & Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$studentCountFormatted Students',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          inst.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        if (inst.reviewCount > 0)
                          Text(
                            ' (${inst.reviewCount})',
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Divider & "View Profile ->" link
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      color: isDark
                          ? AppColors.lineDark
                          : const Color(0xFFF3F4F6),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'View Profile',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.greenLight
                                : const Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.greenLight
                              : const Color(0xFF1B5E20),
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

  Widget _buildFallbackAvatar(Color backdropColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          child: Center(
            child: Text(
              inst.fullName.isNotEmpty ? inst.fullName[0].toUpperCase() : 'I',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
