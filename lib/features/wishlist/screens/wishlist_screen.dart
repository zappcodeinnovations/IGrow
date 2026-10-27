import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/api_models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistAsync = ref.watch(wishlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCount = wishlistAsync.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go('/farmer/home');
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
                        Icons.arrow_back,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      ),
                    ),
                  ),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Wishlist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (totalCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.editorialSecondary.withValues(alpha: 0.3)
                            : AppColors.editorialSecondaryFixed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$totalCount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.editorialSecondaryFixedDim
                              : AppColors.editorialSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: isDark ? Colors.white : AppColors.editorialSecondary,
                    unselectedLabelColor: isDark ? Colors.white54 : AppColors.inkSoft,
                    indicatorColor: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Courses'),
                      Tab(text: 'E-Books'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: wishlistAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load wishlist',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    err.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : AppColors.inkSoft,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppColors.editorialPrimary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                    ),
                    onPressed: () => ref.read(wishlistProvider.notifier).loadWishlist(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildWishlistList(context, items, isDark),
                _buildWishlistList(
                  context,
                  items.where((i) => i.isCourse).toList(),
                  isDark,
                ),
                _buildWishlistList(
                  context,
                  items.where((i) => i.isEbook).toList(),
                  isDark,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWishlistList(
    BuildContext context,
    List<ApiWishlistItem> items,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
        onRefresh: () => ref.read(wishlistProvider.notifier).loadWishlist(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 60),
            EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Your wishlist is empty',
              subtitle: "Save courses and e-books you're interested in for later.",
              actionLabel: 'Explore Courses',
              onAction: () => context.go('/farmer/explore'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
      onRefresh: () => ref.read(wishlistProvider.notifier).loadWishlist(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          return _WishlistCard(item: item);
        },
      ),
    );
  }
}

class _WishlistCard extends ConsumerWidget {
  const _WishlistCard({required this.item});

  final ApiWishlistItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.lineDark : AppColors.lineLight,
        ),
      ),
      color: isDark ? AppColors.cardDark : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (item.isCourse) {
            context.push('/farmer/course/${item.slug.isNotEmpty ? item.slug : item.targetId}');
          } else {
            context.push('/farmer/ebook/${item.slug.isNotEmpty ? item.slug : item.targetId}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail / Cover image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 90,
                  height: 90,
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
                  child: item.displayImage != null && item.displayImage!.isNotEmpty
                      ? Image.network(
                          item.displayImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            item.isCourse ? Icons.school : Icons.menu_book,
                            size: 36,
                            color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                          ),
                        )
                      : Icon(
                          item.isCourse ? Icons.school : Icons.menu_book,
                          size: 36,
                          color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.editorialSecondary.withValues(alpha: 0.2)
                                : AppColors.editorialSecondaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.editorialSecondaryFixedDim
                                  : AppColors.editorialSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                        const SizedBox(width: 3),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.25,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price and Actions
                    Row(
                      children: [
                        Text(
                          item.price == '0.00' || item.price == '0' ? 'Free' : '₹${item.price}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                          ),
                        ),
                        const Spacer(),
                        // Remove from Wishlist button
                        IconButton(
                          iconSize: 22,
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Remove from Wishlist',
                          onPressed: () async {
                            final success = await ref
                                .read(wishlistProvider.notifier)
                                .removeItem(item.id.isNotEmpty ? item.id : item.targetId);
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Removed from wishlist'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: Colors.amber,
                                    onPressed: () {
                                      if (item.isCourse) {
                                        ref
                                            .read(wishlistProvider.notifier)
                                            .toggleCourse(item.targetId, previewItem: item);
                                      } else {
                                        ref
                                            .read(wishlistProvider.notifier)
                                            .toggleEbook(item.targetId, previewItem: item);
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                          },
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
