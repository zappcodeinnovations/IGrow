import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shell_scaffold.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../cart/providers/cart_provider.dart';
import '../../home_farmer/providers/student_provider.dart';

/// My Learning Screen modeled strictly after the Udemy mobile UI reference:
/// - Top App Bar: "My courses" headline + Cast, Search, and Cart action icons
/// - Filter chips: "All", "Downloaded", "Archived", "E-Books"
/// - Course Card item:
///   - Square rounded thumbnail with progress ring/bar overlay
///   - Bold title (e.g. JavaScript From Scratch)
///   - Instructor name / subtitle
///   - Linear progress accent bar (100% complete)
///   - Tap to resume in course player
class MyLearningScreen extends ConsumerStatefulWidget {
  const MyLearningScreen({super.key});

  @override
  ConsumerState<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends ConsumerState<MyLearningScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Downloaded, 2: Archived, 3: E-Books
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  final List<String> _filters = ['All', 'Downloaded', 'Archived', 'E-Books'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
    final ebooksAsync = ref.watch(studentEbooksProvider(''));
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.maybeWhen(
      data: (cart) => cart.items.length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFBF9F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar (Udemy Header: "My courses" + Cast + Search + Cart) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  if (_isSearching)
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: tr(ref, 'Search my courses...'),
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : AppColors.editorialOnSurfaceVariant,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _isSearching = false;
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9999),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      ),
                    )
                  else ...[
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
                          color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                        ),
                        child: Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr(ref, 'My courses'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        ),
                      ),
                    ),
                    // Cast icon (Udemy exact feature)
                    IconButton(
                      icon: Icon(
                        Icons.cast_rounded,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        size: 22,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr(ref, 'Searching for wireless display devices...')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    // Search icon
                    IconButton(
                      icon: Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        size: 24,
                      ),
                      onPressed: () => setState(() => _isSearching = true),
                    ),
                    // Cart icon with badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                            size: 22,
                          ),
                          onPressed: () => context.push(RouteNames.cart),
                        ),
                        if (cartItemCount > 0)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              alignment: Alignment.center,
                              child: Text(
                                '$cartItemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Filter Chips (All, Downloaded, Archived, E-Books) ─────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  final label = _filters[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      borderRadius: BorderRadius.circular(9999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.transparent : Colors.transparent),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark ? Colors.white24 : const Color(0xFFC4C7C7)),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          tr(ref, label),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : (isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // ── Section Title ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _selectedFilterIndex == 3 ? tr(ref, 'My E-Books') : tr(ref, 'My courses'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ── Courses / E-Books Content List ───────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () async {
                  ref.invalidate(studentEnrollmentsProvider);
                  ref.invalidate(studentEbooksProvider);
                  ref.invalidate(ordersProvider);
                  await ref.read(studentEnrollmentsProvider.future).catchError((_) => <Enrollment>[]);
                },
                child: _selectedFilterIndex == 3
                    ? _buildEbooksList(context, ebooksAsync, isDark)
                    : _buildEnrollmentsList(context, enrollmentsAsync, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentsList(
    BuildContext context,
    AsyncValue<List<Enrollment>> enrollmentsAsync,
    bool isDark,
  ) {
    return enrollmentsAsync.when(
      data: (enrollments) {
        // Filter by downloaded/archived if needed
        var items = enrollments;
        if (_selectedFilterIndex == 1) {
          // Downloaded mock filter
          items = items.where((e) => (e.completionPercentage ?? 0) > 0).toList();
        } else if (_selectedFilterIndex == 2) {
          // Archived mock filter
          items = items.where((e) => (e.completionPercentage ?? 0) >= 100).toList();
        }

        // Search query filter
        if (_searchQuery.isNotEmpty) {
          items = items.where((e) {
            final title = (e.courseTitle ?? '').toLowerCase();
            return title.contains(_searchQuery);
          }).toList();
        }

        if (items.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedFilterIndex == 1
                        ? Icons.download_done_rounded
                        : (_selectedFilterIndex == 2 ? Icons.archive_outlined : Icons.school_outlined),
                    size: 56,
                    color: isDark ? Colors.white24 : AppColors.editorialOutlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilterIndex == 1
                        ? tr(ref, 'No Downloaded Courses')
                        : (_selectedFilterIndex == 2 ? tr(ref, 'No Archived Courses') : tr(ref, 'No Courses Found')),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr(ref, 'Explore expert agricultural courses and boost your harvest knowledge.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.explore),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: Text(tr(ref, 'Explore Courses'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final item = items[index];
            final percent = (item.completionPercentage ?? 0).round();
            final courseTarget = (item.courseSlug != null && item.courseSlug!.isNotEmpty)
                ? item.courseSlug!
                : item.course;

            return InkWell(
              onTap: () async {
                if (courseTarget.isNotEmpty) {
                  await context.push('/player/$courseTarget');
                  ref.invalidate(studentEnrollmentsProvider);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Square Thumbnail (Udemy style with JS/Python colored square)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 68,
                      height: 68,
                      color: _getThumbnailColor(item.courseTitle ?? ''),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (item.courseThumbnail != null && item.courseThumbnail!.isNotEmpty)
                            Image.network(
                              item.courseThumbnail!,
                              fit: BoxFit.cover,
                              width: 68,
                              height: 68,
                              errorBuilder: (_, __, ___) => _buildFallbackThumbnailIcon(item.courseTitle ?? ''),
                            )
                          else
                            _buildFallbackThumbnailIcon(item.courseTitle ?? ''),
                          // Mini play badge overlay
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title, Instructor, Progress Bar (Udemy layout)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.courseTitle ?? 'Agricultural Course',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Agri Specialist & Field Agronomist',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Udemy style progress bar line: Purple accent bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            height: 3.5,
                            width: double.infinity,
                            color: isDark ? Colors.white12 : const Color(0xFFE2E0F5),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (percent / 100).clamp(0.0, 1.0),
                              child: Container(
                                color: AppColors.editorialSecondaryFixedDim,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Percentage Complete readout
                        Text(
                          '$percent% complete',
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
            );
          },
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const ShimmerCard(height: 76),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: isDark ? Colors.white38 : AppColors.editorialOutlineVariant,
              ),
              const SizedBox(height: 12),
              Text(
                tr(ref, 'Unable to load your courses right now.'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.editorialOnSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(studentEnrollmentsProvider);
                  ref.invalidate(ordersProvider);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(tr(ref, 'Retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEbooksList(
    BuildContext context,
    AsyncValue<List<EBook>> ebooksAsync,
    bool isDark,
  ) {
    return ebooksAsync.when(
      data: (ebooks) {
        var items = ebooks;
        if (_searchQuery.isNotEmpty) {
          items = items.where((e) {
            final title = e.title.toLowerCase();
            final author = e.authorName.toLowerCase();
            return title.contains(_searchQuery) || author.contains(_searchQuery);
          }).toList();
        }

        if (items.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 56,
                    color: isDark ? Colors.white24 : AppColors.editorialOutlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(ref, 'No E-Books in Library'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr(ref, 'Browse practical agricultural guides and add them to your library.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.explore),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: Text(tr(ref, 'Browse E-Books'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final ebook = items[index];
            final target = (ebook.slug != null && ebook.slug!.isNotEmpty) ? ebook.slug! : ebook.id;

            return InkWell(
              onTap: () => context.push('/farmer/ebook/$target'),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Book Cover Icon Container
                  Container(
                    width: 60,
                    height: 72,
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

                  // Title, Author, Read Button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ebook.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ebook.authorName.isNotEmpty ? ebook.authorName : (ebook.instructorName ?? 'Agri Specialist'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Available Offline • PDF Text',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : AppColors.editorialSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            );
          },
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const ShimmerCard(height: 76),
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Color _getThumbnailColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('java') || t.contains('js')) {
      return const Color(0xFFD97706);
    } else if (t.contains('python') || t.contains('tech') || t.contains('hydro')) {
      return const Color(0xFF0284C7);
    } else if (t.contains('soil') || t.contains('cultiv') || t.contains('crop')) {
      return const Color(0xFF16A34A);
    } else {
      return AppColors.editorialSecondary;
    }
  }

  Widget _buildFallbackThumbnailIcon(String title) {
    return Center(
      child: Icon(
        Icons.auto_stories_rounded,
        size: 30,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
