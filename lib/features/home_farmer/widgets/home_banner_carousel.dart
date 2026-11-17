import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart';
import 'course_banner_dialog.dart';

/// Clean, full-bleed Swiping Banner Carousel.
///
/// Slide 0: High-aesthetic greeting & ambient agriculture landscape banner with subtle text overlay.
/// Slide 1..N: Full-bleed Course thumbnail with gradient protection and title on the bottom.
/// Tapping the card opens [CourseBannerDialog].
class HomeBannerCarousel extends StatefulWidget {
  final List<CourseList> courses;
  final String userName;

  const HomeBannerCarousel({
    super.key,
    required this.courses,
    required this.userName,
  });

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  int get _totalItems => 1 + widget.courses.length;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              if (index == 0) {
                return _buildWelcomeSlide(isDark);
              } else {
                final course = widget.courses[index - 1];
                return _buildCourseSlide(course, isDark);
              }
            },
          ),
        ),

        const SizedBox(height: 12),

        // Indicator Dots
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

  // SLIDE 0: Welcome greeting with lush landscape image (No translucent card, no button)
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
              // Background Image
              Image.asset(
                'assets/images/banners/welcome_banner.png',
                fit: BoxFit.cover,
              ),

              // Smooth bottom gradient overlay for clear text contrast
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

              // Bottom Title & Subtitle Overlay
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B4D2E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF86EFAC).withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'WELCOME BACK',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF86EFAC),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('🌾', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.userName.isNotEmpty ? 'Namaste, ${widget.userName}!' : 'Namaste, Farmer!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
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

  // SLIDE 1..N: Full-bleed Course Image with Title on Bottom (No translucent card, no button)
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
              // Full background Course Image
              thumbnailUrl.isNotEmpty
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackGradient(),
                    )
                  : _buildFallbackGradient(),

              // Smooth gradient from middle to bottom for clear typography
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

              // Top Badge (Category / Status)
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

              // Bottom Course Title & Price (Clean overlay, tapping card opens dialog)
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
