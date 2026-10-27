import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  // 0: Bag, 1: Wishlist
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlistAsync = ref.watch(wishlistProvider);
    final wishlistCount = ref.watch(wishlistCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cartItemsCount = cartState.maybeWhen(
      data: (cart) => cart.items.length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go(RouteNames.farmerHome);
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
        title: Text(
          _activeTab == 0 ? 'Curriculum Bag' : 'Saved Wishlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.editorialOnSurface,
          ),
        ),
        actions: [
          if (_activeTab == 0 && cartItemsCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Clear Bag?'),
                        content: const Text('Are you sure you want to remove all modules from your bag?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(cartProvider.notifier).clearCart();
                            },
                            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
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
                      Icons.delete_outline,
                      size: 20,
                      color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Tactile Segmented Pill Control (Bag vs Wishlist)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _activeTab == 0
                              ? (isDark ? Colors.white : AppColors.editorialPrimary)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: _activeTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bag',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 0
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _activeTab == 0
                                    ? (_activeTab == 0
                                        ? (isDark ? Colors.black12 : Colors.white24)
                                        : Colors.transparent)
                                    : (isDark ? Colors.white12 : AppColors.editorialSurfaceContainerHigh),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '$cartItemsCount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _activeTab == 0
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _activeTab == 1
                              ? (isDark ? Colors.white : AppColors.editorialPrimary)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: _activeTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Wishlist',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 1
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _activeTab == 1
                                    ? (isDark ? Colors.black12 : Colors.white24)
                                    : (isDark ? Colors.white12 : AppColors.editorialSurfaceContainerHigh),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '$wishlistCount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _activeTab == 1
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main View (Tab 0: Cart Bag, Tab 1: Wishlist)
          Expanded(
            child: _activeTab == 0
                ? _buildCartView(context, cartState, isDark)
                : _buildWishlistView(context, wishlistAsync, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCartView(BuildContext context, AsyncValue<dynamic> cartState, bool isDark) {
    return cartState.when(
      data: (cart) {
        if (cart.items.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sculpted Organic Icon Pod
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.editorialSurfaceContainerLowDark : AppColors.editorialSecondaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 38,
                          color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your bag is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 290),
                      child: Text(
                        'Looks like you haven\'t added any agricultural courses yet. Explore our curated syllabus to accelerate your agro-research.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : AppColors.editorialPrimary,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text(
                          'Explore Marketplace',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: () => context.go(RouteNames.explore),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, size: 15, color: AppColors.editorialSecondary),
                        const SizedBox(width: 5),
                        Text(
                          'ACCREDITED FIELD MODULES',
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
              ),
            ),
          );
        }

        final itemCount = cart.items.length;

        return Column(
          children: [
            // Cart items header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Modules ($itemCount)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                    ),
                  ),
                  Text(
                    '$itemCount ${itemCount == 1 ? "item" : "items"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.editorialSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  final courseTitle = item.courseDetail?['title']?.toString() ??
                      item.courseDetail?['name']?.toString() ??
                      'Agriculture Course';
                  final coursePrice = item.courseDetail?['price']?.toString() ?? '0.00';
                  final instructor =
                      item.courseDetail?['instructor_name']?.toString() ?? 'iAgrow Specialist';
                  final thumbnail = item.courseDetail?['thumbnail']?.toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.25),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 75,
                            color: isDark ? AppColors.lineDark : AppColors.editorialSurfaceContainerLow,
                            child: thumbnail != null && thumbnail.isNotEmpty && thumbnail.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: thumbnail,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.editorialPrimary,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.menu_book,
                                      color: AppColors.editorialSecondary,
                                    ),
                                  )
                                : const Icon(Icons.menu_book, color: AppColors.editorialSecondary, size: 28),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courseTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'By $instructor',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹$coursePrice',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Remove
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                          tooltip: 'Remove',
                          onPressed: () {
                            ref.read(cartProvider.notifier).removeFromCart(item.course);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Order Summary Card (Editorial EdTech)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Price Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${cart.total ?? "0.00"}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : AppColors.editorialPrimary,
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.lock_outline, size: 18),
                            label: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              context.push('/checkout');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.editorialPrimary),
      ),
      error: (error, _) {
        String displayError = 'Unable to load cart. Please check your internet connection.';
        if (error is ApiException) {
          displayError = error.message;
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayError,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Retry',
                  onPressed: () => ref.refresh(cartProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistView(BuildContext context, AsyncValue<dynamic> wishlistAsync, bool isDark) {
    return wishlistAsync.when(
      data: (items) {
        final list = items as List;
        if (list.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.editorialSurfaceContainerLowDark : AppColors.editorialSurfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.favorite_border,
                          size: 38,
                          color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No saved research',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 290),
                      child: Text(
                        'Save courses and peer-reviewed e-books you\'re interested in for continuous cultivation later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : AppColors.editorialOnSurface,
                          side: BorderSide(
                            color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        onPressed: () => context.go(RouteNames.explore),
                        child: const Text('View Recommendations'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final title = item.title ?? 'Agricultural Item';
            final price = item.price != null ? '₹${item.price}' : 'Free';
            final instructor = item.instructorName ?? 'iAgrow Specialist';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.lineDark : AppColors.editorialOutlineVariant.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: isDark ? AppColors.lineDark : AppColors.editorialSurfaceContainerLow,
                      child: item.thumbnail != null && item.thumbnail.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.thumbnail,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(Icons.bookmark_border),
                            )
                          : const Icon(Icons.bookmark_border),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'By $instructor',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () {
                      ref.read(wishlistProvider.notifier).removeItem(item.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.editorialPrimary),
      ),
      error: (_, __) => Center(
        child: Text(
          'Unable to load wishlist',
          style: TextStyle(color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant),
        ),
      ),
    );
  }
}
