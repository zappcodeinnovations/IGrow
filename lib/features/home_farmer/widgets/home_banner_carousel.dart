import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../data/models/home_banner_model.dart';
import 'course_banner_dialog.dart';

/// Clean, full-bleed Swiping Banner Carousel.
///
/// Priority 1: Backend dynamic banners from GET /api/v1/banners/ ([apiBanners]).
/// Priority 2: Fallback to ambient welcome slide + top catalog courses if [apiBanners] is empty.
class HomeBannerCarousel extends StatefulWidget {
  final List<HomeBannerItem> apiBanners;
  final List<CourseList> fallbackCourses;
  final String userName;

  const HomeBannerCarousel({
    super.key,
    this.apiBanners = const [],
    this.fallbackCourses = const [],
    required this.userName,
  });

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  bool get _hasApiBanners => widget.apiBanners.isNotEmpty;

  int get _totalItems => _hasApiBanners
      ? widget.apiBanners.length
      : (1 + widget.fallbackCourses.length);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients || _totalItems <= 1) return;
      final nextPage = (_currentPage + 1) % _totalItems;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onApiBannerTapped(HomeBannerItem banner) {
    if (banner.bannerCourse == true &&
        banner.courseSlug != null &&
        banner.courseSlug!.trim().isNotEmpty) {
      // 🎓 Case 1: Course Linked Banner
      final target = banner.courseSlug!.trim();
      context.push('/farmer/course/$target');
    } else if (banner.targetLink != null && banner.targetLink!.trim().isNotEmpty) {
      // 📢 Case 2: Deep Link or Web Link
      final link = banner.targetLink!.trim();
      if (link.startsWith('http://') || link.startsWith('https://')) {
        final uri = Uri.tryParse(link);
        if (uri != null) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else if (link == '/community') {
        context.go('/community');
      } else if (link == '/ebooks' || link.contains('ebook')) {
        context.push('/farmer/explore');
      } else if (link.startsWith('/')) {
        context.push(link);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_totalItems == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 206,
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            itemCount: _totalItems,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx);
            },
            itemBuilder: (context, index) {
              if (_hasApiBanners) {
                final banner = widget.apiBanners[index];
                return _buildApiBannerSlide(banner, isDark);
              } else {
                if (index == 0) {
                  return _buildWelcomeSlide(isDark);
                } else {
                  final course = widget.fallbackCourses[index - 1];
                  return _buildCourseSlide(course, isDark);
                }
              }
            },
          ),
        ),

        const SizedBox(height: 12),

        // Indicator Dots
        if (_totalItems > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalItems, (i) {
              final isSelected = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                height: 6,
                width: isSelected ? 22 : 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B4D2E)
                      : (isDark ? Colors.white24 : Colors.black12),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
      ],
    );
  }

  // ── DYNAMIC BACKEND API BANNER SLIDE ──────────────────────────────────────
  Widget _buildApiBannerSlide(HomeBannerItem banner, bool isDark) {
    return GestureDetector(
      onTap: () => _onApiBannerTapped(banner),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner Image
              banner.imageUrl.isNotEmpty
                  ? Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackGradient(),
                    )
                  : _buildFallbackGradient(),

              // Gradient protection for text overlay if banner has title
              if (banner.title.isNotEmpty || (banner.courseTitle != null && banner.courseTitle!.isNotEmpty)) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 0.70, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        banner.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (banner.courseTitle != null && banner.courseTitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          banner.courseTitle!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── FALLBACK SLIDE 0: Welcome greeting with lush landscape image ──────────
  Widget _buildWelcomeSlide(bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/farmer/explore'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/banners/welcome_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackGradient(),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 0.65, 1.0],
                  ),
                ),
              ),

              Positioned(
                left: 18,
                right: 18,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.userName.isNotEmpty
                          ? 'Welcome back, ${widget.userName} 👋'
                          : 'Welcome to iAgrow 🌾',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Learn modern techniques & grow your harvest with iAgrow.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  // ── FALLBACK SLIDE 1..N: Full-bleed Course Image ───────────────────────────
  Widget _buildCourseSlide(CourseList course, bool isDark) {
    final thumbnailUrl = course.thumbnail ?? '';
    final isFree = course.price == null ||
        course.price == '0' ||
        course.price == '0.00' ||
        course.price == '0.0';

    return GestureDetector(
      onTap: () => CourseBannerDialog.show(context, course),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              thumbnailUrl.isNotEmpty
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackGradient(),
                    )
                  : _buildFallbackGradient(),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 0.65, 1.0],
                  ),
                ),
              ),

              Positioned(
                top: 14,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isFree ? const Color(0xFF16A34A) : const Color(0xFF1B4D2E),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    isFree ? 'FREE COURSE' : (course.category?.name ?? 'FEATURED').toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      course.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.7),
                            offset: const Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          isFree ? 'FREE' : '₹${course.price}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isFree
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (course.instructorName != null && course.instructorName!.isNotEmpty)
                          Expanded(
                            child: Text(
                              'By ${course.instructorName}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  Widget _buildFallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4D2E), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.eco_rounded, size: 48, color: Colors.white24),
      ),
    );
  }
}
