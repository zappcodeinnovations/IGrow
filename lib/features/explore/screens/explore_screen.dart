import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/shell_scaffold.dart';
import '../../cart/providers/cart_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../../data/models/api_models/wishlist_model.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import 'ebooks_tab.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../core/utils/app_toast.dart';

/// Explore screen for courses.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.initialSearch, this.initialTab = 0});

  final String? initialSearch;
  final int initialTab;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedLevel = '';
  String _selectedOrdering = '';
  String _selectedPricePreset = 'all'; // all, free, under_500, 500_1000, above_1000
  num? _minPrice;
  num? _maxPrice;
  double? _minRating;
  final _searchController = TextEditingController();

  int get _activeFilterCount {
    int count = 0;
    if (_selectedLevel.isNotEmpty) count++;
    if (_selectedOrdering.isNotEmpty && _selectedOrdering != '-created_at') count++;
    if (_selectedPricePreset != 'all') count++;
    if (_minRating != null && _minRating! > 0) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchQuery = widget.initialSearch!;
      _searchController.text = widget.initialSearch!;
    }
  }

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSearch != oldWidget.initialSearch) {
      setState(() {
        _searchQuery = widget.initialSearch ?? '';
        _searchController.text = widget.initialSearch ?? '';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    String tempLevel = _selectedLevel;
    String tempOrdering = _selectedOrdering;
    String tempPricePreset = _selectedPricePreset;
    num? tempMinPrice = _minPrice;
    num? tempMaxPrice = _maxPrice;
    double? tempMinRating = _minRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            int getTempCount() {
              int count = 0;
              if (tempLevel.isNotEmpty) count++;
              if (tempOrdering.isNotEmpty && tempOrdering != '-created_at') count++;
              if (tempPricePreset != 'all') count++;
              if (tempMinRating != null && tempMinRating! > 0) count++;
              return count;
            }

            final tempCount = getTempCount();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Handle & Title
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.lineDark : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.editorialSecondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune_rounded, color: AppColors.editorialSecondary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Filter & Sort Courses',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            ],
                          ),
                          if (tempCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$tempCount active',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 1. Rating Filter (4.5★+, 4.0★+, 3.5★+, 3.0★+)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text('Minimum Rating', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All Ratings'),
                            selected: tempMinRating == null,
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempMinRating == null ? AppColors.editorialSecondary : null,
                              fontWeight: tempMinRating == null ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tempMinRating = null);
                              }
                            },
                          ),
                          ...[4.5, 4.0, 3.5, 3.0].map((rating) {
                            final isSelected = tempMinRating == rating;
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('$rating & up'),
                                ],
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.editorialSecondary : null,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (val) {
                                setModalState(() => tempMinRating = val ? rating : null);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Price Range Presets
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 18, color: AppColors.editorialSecondary),
                          const SizedBox(width: 6),
                          Text('Price Range', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All Prices'),
                            selected: tempPricePreset == 'all',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'all' ? AppColors.editorialSecondary : null,
                              fontWeight: tempPricePreset == 'all' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  tempPricePreset = 'all';
                                  tempMinPrice = null;
                                  tempMaxPrice = null;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Free (₹0)'),
                            selected: tempPricePreset == 'free',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'free' ? AppColors.editorialSecondary : null,
                              fontWeight: tempPricePreset == 'free' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                tempPricePreset = val ? 'free' : 'all';
                                tempMinPrice = val ? 0 : null;
                                tempMaxPrice = val ? 0 : null;
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Under ₹500'),
                            selected: tempPricePreset == 'under_500',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'under_500' ? AppColors.editorialSecondary : null,
                              fontWeight: tempPricePreset == 'under_500' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                tempPricePreset = val ? 'under_500' : 'all';
                                tempMinPrice = val ? 0 : null;
                                tempMaxPrice = val ? 500 : null;
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('₹500 - ₹1,000'),
                            selected: tempPricePreset == '500_1000',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == '500_1000' ? AppColors.editorialSecondary : null,
                              fontWeight: tempPricePreset == '500_1000' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                tempPricePreset = val ? '500_1000' : 'all';
                                tempMinPrice = val ? 500 : null;
                                tempMaxPrice = val ? 1000 : null;
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Above ₹1,000'),
                            selected: tempPricePreset == 'above_1000',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'above_1000' ? AppColors.editorialSecondary : null,
                              fontWeight: tempPricePreset == 'above_1000' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                tempPricePreset = val ? 'above_1000' : 'all';
                                tempMinPrice = val ? 1000 : null;
                                tempMaxPrice = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. Difficulty Level
                      Row(
                        children: [
                          const Icon(Icons.signal_cellular_alt_rounded, size: 18, color: AppColors.editorialSecondary),
                          const SizedBox(width: 6),
                          Text('Difficulty Level', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All Levels'),
                            selected: tempLevel.isEmpty,
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel.isEmpty ? AppColors.editorialSecondary : null,
                              fontWeight: tempLevel.isEmpty ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tempLevel = '');
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Beginner'),
                            selected: tempLevel == 'beginner',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel == 'beginner' ? AppColors.editorialSecondary : null,
                              fontWeight: tempLevel == 'beginner' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLevel = val ? 'beginner' : '');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Intermediate'),
                            selected: tempLevel == 'intermediate',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel == 'intermediate' ? AppColors.editorialSecondary : null,
                              fontWeight: tempLevel == 'intermediate' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLevel = val ? 'intermediate' : '');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Advanced'),
                            selected: tempLevel == 'advanced',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel == 'advanced' ? AppColors.editorialSecondary : null,
                              fontWeight: tempLevel == 'advanced' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLevel = val ? 'advanced' : '');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4. Sort By Ordering
                      Row(
                        children: [
                          const Icon(Icons.sort_rounded, size: 18, color: AppColors.editorialSecondary),
                          const SizedBox(width: 6),
                          Text('Sort by', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Newest'),
                            selected: tempOrdering == '-created_at' || tempOrdering == '',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: (tempOrdering == '-created_at' || tempOrdering == '') ? AppColors.editorialSecondary : null,
                              fontWeight: (tempOrdering == '-created_at' || tempOrdering == '') ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tempOrdering = '-created_at');
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Most Popular'),
                            selected: tempOrdering == '-views_count',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempOrdering == '-views_count' ? AppColors.editorialSecondary : null,
                              fontWeight: tempOrdering == '-views_count' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempOrdering = val ? '-views_count' : '');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Price: Low to High'),
                            selected: tempOrdering == 'price',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempOrdering == 'price' ? AppColors.editorialSecondary : null,
                              fontWeight: tempOrdering == 'price' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempOrdering = val ? 'price' : '');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Price: High to Low'),
                            selected: tempOrdering == '-price',
                            selectedColor: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempOrdering == '-price' ? AppColors.editorialSecondary : null,
                              fontWeight: tempOrdering == '-price' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempOrdering = val ? '-price' : '');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: isDark ? AppColors.lineDark : Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  tempLevel = '';
                                  tempOrdering = '';
                                  tempPricePreset = 'all';
                                  tempMinPrice = null;
                                  tempMaxPrice = null;
                                  tempMinRating = null;
                                });
                              },
                              child: const Text('Reset All', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.editorialSecondary,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedLevel = tempLevel;
                                  _selectedOrdering = tempOrdering;
                                  _selectedPricePreset = tempPricePreset;
                                  _minPrice = tempMinPrice;
                                  _maxPrice = tempMaxPrice;
                                  _minRating = tempMinRating;
                                });
                              },
                              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
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
      initialIndex: widget.initialTab.clamp(0, 1),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leadingWidth: 54,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
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
          ),
          title: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.lineDark : const Color(0xFFE2EBE0),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.editorialSecondary.withValues(alpha: isDark ? 0.08 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, color: AppColors.inkSoft, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                      filled: false,
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.inkSoft),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  color: _activeFilterCount > 0 ? AppColors.accentOrange : AppColors.editorialSecondary,
                  tooltip: 'Filter Courses',
                  onPressed: _showFilterBottomSheet,
                ),
                if (_activeFilterCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accentOrange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$_activeFilterCount',
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
                    const Icon(Icons.menu_book_rounded, color: AppColors.editorialSecondary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Agricultural Course Catalog',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
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
                              error: (err, st) => Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = 'all';
                                      });
                                    },
                                    child: _Tab(
                                      label: 'All Courses',
                                      isActive: _selectedCategory == 'all',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_activeFilterCount > 0 || _searchQuery.isNotEmpty) ...[
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (_searchQuery.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: InputChip(
                                        label: Text('Search: "$_searchQuery"'),
                                        avatar: const Icon(Icons.search_rounded, size: 14, color: AppColors.editorialSecondary),
                                        onDeleted: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                        },
                                        deleteIconColor: AppColors.editorialSecondary,
                                        backgroundColor: AppColors.editorialSecondary.withValues(alpha: 0.1),
                                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialSecondary),
                                      ),
                                    ),
                                  if (_selectedLevel.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: InputChip(
                                        label: Text(_selectedLevel[0].toUpperCase() + _selectedLevel.substring(1)),
                                        avatar: const Icon(Icons.signal_cellular_alt_rounded, size: 14),
                                        onDeleted: () => setState(() => _selectedLevel = ''),
                                        deleteIconColor: AppColors.editorialSecondary,
                                        backgroundColor: AppColors.editorialSecondary.withValues(alpha: 0.1),
                                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialSecondary),
                                      ),
                                    ),
                                  if (_selectedPricePreset != 'all')
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: InputChip(
                                        label: Text(_selectedPricePreset == 'free'
                                            ? 'Free'
                                            : _selectedPricePreset == 'under_500'
                                                ? '< ₹500'
                                                : _selectedPricePreset == '500_1000'
                                                    ? '₹500 - ₹1,000'
                                                    : '> ₹1,000'),
                                        avatar: const Icon(Icons.payments_outlined, size: 14),
                                        onDeleted: () => setState(() {
                                          _selectedPricePreset = 'all';
                                          _minPrice = null;
                                          _maxPrice = null;
                                        }),
                                        deleteIconColor: AppColors.editorialSecondary,
                                        backgroundColor: AppColors.editorialSecondary.withValues(alpha: 0.1),
                                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialSecondary),
                                      ),
                                    ),
                                  if (_minRating != null && _minRating! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: InputChip(
                                        label: Text('$_minRating+ ★'),
                                        avatar: const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                        onDeleted: () => setState(() => _minRating = null),
                                        deleteIconColor: AppColors.editorialSecondary,
                                        backgroundColor: AppColors.editorialSecondary.withValues(alpha: 0.1),
                                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialSecondary),
                                      ),
                                    ),
                                  if (_selectedOrdering.isNotEmpty && _selectedOrdering != '-created_at')
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: InputChip(
                                        label: Text(_selectedOrdering == '-views_count'
                                            ? 'Most Popular'
                                            : _selectedOrdering == 'price'
                                                ? 'Price: Low to High'
                                                : 'Price: High to Low'),
                                        avatar: const Icon(Icons.sort_rounded, size: 14),
                                        onDeleted: () => setState(() => _selectedOrdering = ''),
                                        deleteIconColor: AppColors.editorialSecondary,
                                        backgroundColor: AppColors.editorialSecondary.withValues(alpha: 0.1),
                                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialSecondary),
                                      ),
                                    ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      minimumSize: const Size(50, 30),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedLevel = '';
                                        _selectedOrdering = '';
                                        _selectedPricePreset = 'all';
                                        _minPrice = null;
                                        _maxPrice = null;
                                        _minRating = null;
                                      });
                                    },
                                    child: const Text('Clear All', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Expanded(
                            child: ref.watch(studentCatalogProvider(CatalogQuery(
                              search: _searchQuery, 
                              category: _selectedCategory == 'all' ? '' : _selectedCategory,
                              level: _selectedLevel,
                              minPrice: _minPrice,
                              maxPrice: _maxPrice,
                              ordering: _selectedOrdering,
                              minRating: _minRating,
                            ))).when(
                              data: (courses) {
                                if (courses.isEmpty) {
                                  return RefreshIndicator(
                                    color: AppColors.editorialSecondary,
                                    onRefresh: () async {
                                      ref.invalidate(studentCatalogProvider);
                                      ref.invalidate(studentCategoriesProvider);
                                    },
                                    child: ListView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        const SizedBox(height: 60),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.search_off_rounded, size: 56, color: AppColors.inkSoft.withValues(alpha: 0.5)),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'No courses found',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Try adjusting your search keywords, price, or rating filters.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                                                ),
                                                const SizedBox(height: 16),
                                                TextButton.icon(
                                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                                  label: const Text('Show All Courses'),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                      _searchQuery = '';
                                                      _selectedLevel = '';
                                                      _selectedOrdering = '';
                                                      _selectedPricePreset = 'all';
                                                      _minPrice = null;
                                                      _maxPrice = null;
                                                      _minRating = null;
                                                      _selectedCategory = 'all';
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return RefreshIndicator(
                                  color: AppColors.editorialSecondary,
                                  onRefresh: () async {
                                    ref.invalidate(studentCatalogProvider);
                                    ref.invalidate(studentCategoriesProvider);
                                  },
                                  child: ListView.separated(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: courses.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      return _CatalogCourseCard(course: courses[index]);
                                    },
                                  ),
                                );
                              },
                              loading: () => ListView.separated(
                                itemCount: 4,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) => const ShimmerListTile(),
                              ),
                              error: (err, st) => Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.orange),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Unable to load courses',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        err.toString().replaceAll('Exception: ', ''),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.refresh_rounded, size: 18),
                                        label: const Text('Try Again'),
                                        onPressed: () {
                                          ref.invalidate(studentCatalogProvider);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
          color: isActive ? AppColors.editorialSecondary : Colors.transparent,
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
        ? 'Free'
        : '₹${course.price}';

    final categoryName = course.category?.name ?? 'Agriculture';
    final instructorName = course.instructorName ?? 'Instructor';
    final totalLectures = course.totalLectures ?? 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/farmer/course/${course.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.lineDark
                  : AppColors.editorialOutlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Compact Thumbnail with rounded corners & Category badge
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFF1B2E21),
                        child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                            ? Image.network(
                                course.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.school, size: 32, color: AppColors.editorialSecondary),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.school, size: 32, color: AppColors.editorialSecondary),
                              ),
                      ),
                      // Category Tag bottom of thumbnail
                      Positioned(
                        bottom: 4,
                        left: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Right: Udemy Compact Course Info
              Expanded(
                child: SizedBox(
                  height: 88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title & Wishlist Heart Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                letterSpacing: -0.2,
                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Material(
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
                                  AppToast.showWishlistToast(
                                    context,
                                    isAdded: inWishlist,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                                  color: isWishlisted ? Colors.redAccent : (isDark ? Colors.white54 : Colors.grey.shade500),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Instructor & Enrolled Badge
                      Row(
                        children: [
                          Text(
                            instructorName,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isEnrolled) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSecondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Enrolled',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.editorialSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Meta Specs & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                              const SizedBox(width: 2),
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$totalLectures lec',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatCourseDuration(course.totalDuration),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            priceText,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.editorialOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCourseDuration(String? totalDuration) {
    if (totalDuration == null || totalDuration.trim().isEmpty) return '0 mins';
    final parsed = double.tryParse(totalDuration.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final totalMinutes = parsed.round();
    if (totalMinutes <= 0) return '0 mins';
    if (totalMinutes < 60) {
      return '$totalMinutes mins';
    }
    final hours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? "hr" : "hrs"}';
    }
    return '$hours hr $remainingMinutes mins';
  }
}
