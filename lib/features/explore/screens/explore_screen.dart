import 'package:flutter/material.dart';
import 'package:krushi_siksha/features/home_farmer/providers/student_provider.dart';

import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/providers/cart_provider.dart';

import 'ebooks_tab.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
/// Explore screen for courses.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedLevel = '';
  String _selectedOrdering = '';
  final _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'label': 'All', 'value': 'all'},
  ];

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
                Text('Explore', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 16),
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
                                    list.add({'label': c.name ?? 'Unknown', 'value': c.id!});
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
                                    final course = courses[index];
                                    return GestureDetector(
                                      onTap: () {
                                        context.push('/farmer/course/${course.id}');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.cardDark : AppColors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: AppColors.greenShadow(
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                            opacity: isDark ? 0.06 : 0.1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(12),
                                                image: course.thumbnail != null
                                                    ? DecorationImage(
                                                        image: NetworkImage(course.thumbnail!),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: course.thumbnail == null
                                                  ? const Icon(Icons.menu_book, color: AppColors.primaryGreen)
                                                  : null,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    course.title,
                                                    style: Theme.of(context).textTheme.titleSmall,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.star_rounded, size: 14, color: AppColors.signalYellow),
                                                      const SizedBox(width: 4),
                                                      Text('4.5', style: Theme.of(context).textTheme.labelSmall),
                                                      const Spacer(),
                                                      Text(
                                                        course.price == '0.00' ? 'Free' : '₹${course.price}',
                                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_shopping_cart, size: 20),
                                              color: AppColors.primaryGreen,
                                              onPressed: () async {
                                                try {
                                                  await ref.read(cartProvider.notifier).addToCart(course.id ?? '');
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('${course.title} added to cart')),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Could not add to cart: $e')),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
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
