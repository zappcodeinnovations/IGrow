import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/providers/cart_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../../data/models/api_models/wishlist_model.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import 'ebooks_tab.dart';
import '../../../core/widgets/shimmer_placeholders.dart';

/// Explore screen for courses.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.initialSearch});

  final String? initialSearch;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedLevel = '';
  String _selectedOrdering = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchQuery = widget.initialSearch!;
      _searchController.text = widget.initialSearch!;
    }
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filter & Sort', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    
                    Text('Level', style: Theme.of(context).textTheme.titleMedium),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedLevel == '',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedLevel = '');
                              setState(() => _selectedLevel = '');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Beginner'),
                          selected: _selectedLevel == 'beginner',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedLevel = 'beginner');
                              setState(() => _selectedLevel = 'beginner');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Intermediate'),
                          selected: _selectedLevel == 'intermediate',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedLevel = 'intermediate');
                              setState(() => _selectedLevel = 'intermediate');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Advanced'),
                          selected: _selectedLevel == 'advanced',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedLevel = 'advanced');
                              setState(() => _selectedLevel = 'advanced');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Text('Sort by', style: Theme.of(context).textTheme.titleMedium),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Newest'),
                          selected: _selectedOrdering == '-created_at',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedOrdering = '-created_at');
                              setState(() => _selectedOrdering = '-created_at');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Price: Low to High'),
                          selected: _selectedOrdering == 'price',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedOrdering = 'price');
                              setState(() => _selectedOrdering = 'price');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Price: High to Low'),
                          selected: _selectedOrdering == '-price',
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedOrdering = '-price');
                              setState(() => _selectedOrdering = '-price');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedLevel = '';
                            _selectedOrdering = '';
                          });
                          setState(() {
                            _selectedLevel = '';
                            _selectedOrdering = '';
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            Consumer(
              builder: (context, ref, child) {
                final cartState = ref.watch(cartProvider);
                final itemCount = cartState.maybeWhen(
                  data: (cart) => cart.items.length,
                  orElse: () => 0,
                );
                
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        context.push('/cart');
                      },
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Agricultural Course Catalog',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover expert-led courses to advance your farming skills.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 14),
                const TabBar(
                  tabs: [
                    Tab(text: 'Courses'),
                    Tab(text: 'E-Books'),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Courses Tab
                      Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ref.watch(studentCategoriesProvider).when(
                              data: (cats) {
                                if (cats.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('categories not found'),
                                  );
                                }
                                final list = [{'label': 'All', 'value': 'all'}];
                                for (var c in cats) {
                                  if (c.id != null) {
                                    list.add({'label': c.name, 'value': c.id!});
                                  }
                                }
                                return Row(
                                  children: list.map((cat) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = cat['value']!;
                                        });
                                      },
                                      child: _Tab(
                                        label: cat['label']!,
                                        isActive: _selectedCategory == cat['value'],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    4, 
                                    (_) => const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: ShimmerCategoryChip(),
                                    ),
                                  ),
                                ),
                              ),
                              error: (err, st) => const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('categories not found'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ref.watch(studentCatalogProvider((
                              search: _searchQuery, 
                              category: _selectedCategory == 'all' ? '' : _selectedCategory,
                            ))).when(
                              data: (courses) {
                                if (courses.isEmpty) {
                                  return const Center(child: Text('categories not found'));
                                }
                                return ListView.separated(
                                  itemCount: courses.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    return _CatalogCourseCard(course: courses[index]);
                                  },
                                );
                              },
                              loading: () => ListView.separated(
                                itemCount: 4,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) => const ShimmerListTile(),
                              ),
                              error: (err, st) => const Center(child: Text('categories not found')),
                            ),
                          ),
                        ],
                      ),
                      // E-Books Tab
                      const EbooksTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, this.isActive = false});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? null
              : Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.lineDark
                      : AppColors.lineLight,
                ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isActive ? AppColors.white : AppColors.inkSoft,),
        ),
      ),
    );
  }
}

class _CatalogCourseCard extends ConsumerWidget {
  const _CatalogCourseCard({required this.course});

  final CourseList course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWishlisted = ref.watch(isWishlistedProvider(course.id ?? ''));
    final isEnrolled = ref.watch(isCourseEnrolledProvider(course.id ?? '')) ||
        (course.slug != null && ref.watch(isCourseEnrolledProvider(course.slug!)));

    final priceText = course.price == null || course.price == '0' || course.price == '0.00'
        ? '₹0'
        : '₹${course.price}';

    final categoryName = course.category?.name ?? 'Agriculture';
    final instructorName = course.instructorName ?? 'Instructor';
    final totalLectures = course.totalLectures ?? 1;

    return GestureDetector(
      onTap: () {
        context.push('/farmer/course/${course.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
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
          children: [
            // Top Media with Category badge & Wishlist Heart
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Container(
                    height: 125,
                    width: double.infinity,
                    color: const Color(0xFF1B2E21),
                    child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                        ? Image.network(
                            course.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.school, size: 40, color: AppColors.primaryGreen),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.school, size: 40, color: AppColors.primaryGreen),
                          ),
                  ),
                  // Category Tag & Enrolled badge top-left
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isEnrolled) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 11),
                                SizedBox(width: 4),
                                Text(
                                  'Enrolled',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Wishlist Heart top-right
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final preview = ApiWishlistItem(
                            id: '',
                            targetId: course.id ?? '',
                            type: 'course',
                            title: course.title,
                            slug: course.slug ?? '',
                            thumbnail: course.thumbnail,
                            price: course.price ?? '0.00',
                            category: categoryName,
                            rating: 4.8,
                          );
                          final inWishlist = await ref
                              .read(wishlistProvider.notifier)
                              .toggleCourse(course.id ?? '', previewItem: preview);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(inWishlist
                                    ? 'Added to wishlist! ❤️'
                                    : 'Removed from wishlist'),
                                duration: const Duration(milliseconds: 1400),
                                backgroundColor: inWishlist
                                    ? AppColors.primaryGreen
                                    : AppColors.inkDark,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.redAccent : Colors.grey.shade700,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.shortDescription != null && course.shortDescription!.isNotEmpty
                        ? course.shortDescription!
                        : course.title,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Meta Row matching Screenshot 3: "1 Lectures  0 hrs  ⭐ 0"
                  Row(
                    children: [
                      Icon(Icons.video_library_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text(
                        '$totalLectures Lectures',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text(
                        course.totalDuration != null ? '${course.totalDuration} hrs' : '0 hrs',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text(
                        '0',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Divider(height: 1, color: isDark ? AppColors.lineDark : Colors.grey.shade200),
                  const SizedBox(height: 8),

                  // Instructor & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFF166534),
                            child: Text(
                              instructorName.isNotEmpty ? instructorName[0].toUpperCase() : 'I',
                              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: Text(
                              instructorName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (isEnrolled)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Enrolled',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      else
                        Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
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
