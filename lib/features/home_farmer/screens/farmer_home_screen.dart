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

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
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
    ref.invalidate(studentEbooksProvider(''));
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
    final ebooksAsync = ref.watch(studentEbooksProvider(''));
    final weatherAsync = ref.watch(weatherProvider);
    final weatherData = weatherAsync.valueOrNull;

    final enrollmentsCount = enrollmentsAsync.maybeWhen(data: (list) => list.length, orElse: () => 0);
    final ebooksCount = ebooksAsync.maybeWhen(data: (list) => list.length, orElse: () => 0);
    final completedCount = enrollmentsAsync.maybeWhen(
      data: (list) => list.where((e) => (e.completionPercentage ?? 0) >= 100).length,
      orElse: () => 0,
    );
    final quizzesTakenCount = _quizHistory.length;

    return SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: AppColors.primaryGreen,
          backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
          displacement: 60,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ResponsiveContentConstraint(
              maxWidth: 1040,
              padding: EdgeInsets.zero,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Navigation Bar (Stitch Exact Match) ──────────────────────
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
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                              ),
                              child: Icon(
                                Icons.menu_rounded,
                                size: 22,
                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                              ),
                            ),
                          ),
                      const SizedBox(width: 8),
                      Text(
                        'iAgrow',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Notification Bell Badge Button
                      InkWell(
                        onTap: () => context.push(RouteNames.notifications),
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 21,
                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                              ),
                              if (ref.watch(unreadNotificationsCountProvider) > 0)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.editorialSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Wishlist Heart Badge Button
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
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border_rounded,
                                    size: 21,
                                    color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                  ),
                                  if (wishlistCount > 0)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(2.5),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                        child: Text(
                                          '$wishlistCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8.5,
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white : AppColors.editorialPrimary,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── 2. Editorial Header & Micro Weather Indicator (Stitch Exact Match) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => ref.read(weatherProvider.notifier).refresh(),
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            weatherData?.weatherIcon ?? Icons.wb_sunny,
                            size: 16,
                            color: AppColors.editorialSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${weatherData?.temperatureFormatted ?? "32°C"} ${(weatherData != null && weatherData.locationName.trim().isNotEmpty) ? weatherData.locationName : "Nagpur"}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isDark ? Colors.white : AppColors.editorialOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.editorialSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr(ref, 'SEMESTER 04'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Time greeting and Title
              Text(
                '${tr(ref, _getTimeBasedGreeting())},',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.12,
                  letterSpacing: -0.8,
                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                ),
              ),
              const SizedBox(height: 16),



              // ── 4. Academic Ledger (Stitch Exact Match) ──────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(ref, 'ACADEMIC LEDGER'),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    tr(ref, 'Active Session'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),




              // ── 4 Summary Stat Cards Grid (Compact & Distinctively Color-Coded) ──
              LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final double aspectRatio = width < 360 ? 2.05 : (width < 420 ? 2.22 : 2.45);

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: aspectRatio,
                    children: [
                      // 1. Enrolled Courses
                      _SummaryStatCard(
                        icon: Icons.auto_stories_rounded,
                        iconBgColor: AppColors.editorialSecondary,
                        lightBgColor: AppColors.editorialSurfaceContainerLow,
                        darkBgColor: AppColors.cardDark,
                        lightBorderColor: AppColors.editorialOutlineVariant.withValues(alpha: 0.2),
                        darkBorderColor: AppColors.lineDark,
                        textColor: AppColors.editorialOnSurface,
                        count: '$enrollmentsCount',
                        label: tr(ref, 'Enrolled'),
                        unit: tr(ref, 'Courses'),
                        onTap: () => context.go(RouteNames.farmerLearning),
                      ),

                      // 2. Library E-Books
                      _SummaryStatCard(
                        icon: Icons.menu_book_rounded,
                        iconBgColor: AppColors.editorialSecondary,
                        lightBgColor: AppColors.editorialSurfaceContainerLow,
                        darkBgColor: AppColors.cardDark,
                        lightBorderColor: AppColors.editorialOutlineVariant.withValues(alpha: 0.2),
                        darkBorderColor: AppColors.lineDark,
                        textColor: AppColors.editorialOnSurface,
                        count: '$ebooksCount',
                        label: tr(ref, 'E-Books'),
                        unit: tr(ref, 'Text'),
                        onTap: () => context.go(RouteNames.farmerLearning),
                      ),

                      // 3. Completed Courses
                      _SummaryStatCard(
                        icon: Icons.verified_rounded,
                        iconBgColor: AppColors.editorialSecondary,
                        lightBgColor: AppColors.editorialSurfaceContainerLow,
                        darkBgColor: AppColors.cardDark,
                        lightBorderColor: AppColors.editorialOutlineVariant.withValues(alpha: 0.2),
                        darkBorderColor: AppColors.lineDark,
                        textColor: AppColors.editorialOnSurface,
                        count: '$completedCount',
                        label: tr(ref, 'Completed'),
                        unit: tr(ref, 'Units'),
                        onTap: () => context.go(RouteNames.farmerLearning),
                      ),

                      // 4. Quizzes Taken
                      _SummaryStatCard(
                        icon: Icons.task_alt_rounded,
                        iconBgColor: AppColors.editorialSecondary,
                        lightBgColor: AppColors.editorialSurfaceContainerLow,
                        darkBgColor: AppColors.cardDark,
                        lightBorderColor: AppColors.editorialOutlineVariant.withValues(alpha: 0.2),
                        darkBorderColor: AppColors.lineDark,
                        textColor: AppColors.editorialOnSurface,
                        count: '$quizzesTakenCount',
                        label: tr(ref, 'Pending'),
                        unit: tr(ref, 'Quizzes'),
                        onTap: () => context.go(RouteNames.farmerLearning),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

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

              // ── 6. Featured Courses Showcase (Stitch Exact Match Vertical Cards) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Curated specialist curriculums',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  ref.watch(studentCatalogProvider(const CatalogQuery())).maybeWhen(
                    data: (courses) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceContainerHighDark : AppColors.editorialSurfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '${courses.length} Available',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ref.watch(studentCatalogProvider(const CatalogQuery())).when(
                data: (courses) {
                  if (courses.isEmpty) return const SizedBox.shrink();
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
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: 24),

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
    ),
    );
  }
}

// ── Custom Summary Stat Card Widget ──────────────────────────────────────────
class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.icon,
    required this.iconBgColor,
    required this.lightBgColor,
    required this.darkBgColor,
    required this.lightBorderColor,
    required this.darkBorderColor,
    required this.textColor,
    required this.count,
    required this.label,
    this.unit = '',
    this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color lightBgColor;
  final Color darkBgColor;
  final Color lightBorderColor;
  final Color darkBorderColor;
  final Color textColor;
  final String count;
  final String label;
  final String unit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                  ),
                ),
                Icon(
                  icon,
                  size: 16,
                  color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.editorialOnSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Course Card Component (Coursera & MasterClass Inspired) ──────────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.index});

  final CourseList course;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagLabel = index % 2 == 0 ? 'Core Specialization' : 'Applied Agrotech';

    return GestureDetector(
      onTap: () {
        context.push('/farmer/course/${course.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? AppColors.lineDark
                : AppColors.editorialOutlineVariant.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Container with Coursera-Style 16:9 Aspect Ratio and Floating Badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: isDark ? const Color(0xFF24242A) : AppColors.editorialSurfaceContainer,
                    child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                        ? Image.network(
                            course.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                size: 48,
                                color: AppColors.editorialSecondary,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              size: 48,
                              color: AppColors.editorialSecondary,
                            ),
                          ),
                  ),
                ),
                // Gradient Scrim for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                ),
                // Coursera-style Floating Rating Pill
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Specialization Pill
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.editorialSecondary,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.editorialSecondary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      tagLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body: Clean Coursera / MasterClass Typography & Attributes
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5,
                      height: 1.25,
                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Subtitle / Description
                  Text(
                    (course.shortDescription != null && course.shortDescription!.isNotEmpty)
                        ? course.shortDescription!
                        : 'Comprehensive practical field syllabus designed by certified faculty',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 14),

                  // Divider
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.25),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Specs & Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '14 hrs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 15,
                            color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Certificate',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        course.price == '0.00' ? 'Free' : '₹${course.price}',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
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
                  const SizedBox(height: 4),
                  Text(
                    tr(ref, 'Learn directly from verified farming experts, agronomists, and agricultural specialists.'),
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
          height: 252,
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
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppColors.lineDark
              : AppColors.editorialOutlineVariant.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar with verified badge & Experience Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.editorialSecondary.withValues(alpha: 0.2)
                            : AppColors.editorialSecondaryFixed,
                        border: Border.all(
                          color: AppColors.editorialSecondary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: inst.avatar != null && inst.avatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  inst.avatar!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Text(
                                    inst.fullName.isNotEmpty ? inst.fullName[0].toUpperCase() : 'I',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.editorialSecondary,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                inst.fullName.isNotEmpty ? inst.fullName[0].toUpperCase() : 'I',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.editorialSecondary,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: -1,
                      right: -1,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.editorialSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            width: 1.5,
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.editorialSecondary.withValues(alpha: 0.15)
                        : AppColors.editorialSecondaryFixed.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    inst.experience,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.editorialSecondaryFixedDim
                          : AppColors.editorialOnSecondaryFixed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Instructor Name
            Text(
              inst.fullName,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),

            // Specialty Crops / Agro Role
            Text(
              inst.specialtyCrops ?? inst.expertiseTags ?? 'Agricultural Specialist',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Rating & Students Row
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
                const SizedBox(width: 3),
                Text(
                  inst.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.editorialOnSurface,
                  ),
                ),
                if (inst.reviewCount > 0)
                  Text(
                    ' (${inst.reviewCount})',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
                    ),
                  ),
                const Spacer(),
                Icon(
                  Icons.people_alt_outlined,
                  size: 13,
                  color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${inst.totalStudents} learners',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Elevated Action Button
            SizedBox(
              width: double.infinity,
              height: 34,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF24242A)
                      : AppColors.editorialSurfaceContainerLow,
                  foregroundColor: isDark ? Colors.white : AppColors.editorialOnSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  context.push('/farmer/explore?search=${Uri.encodeComponent(inst.fullName)}');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: AppColors.editorialSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'View Courses (${inst.totalCourses})',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


