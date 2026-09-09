import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Cart',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cart'),
                  content: const Text('Are you sure you want to remove all items from your cart?'),
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
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: cartState.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final courseTitle = item.courseDetail?['title']?.toString() ??
                        item.courseDetail?['name']?.toString() ??
                        'Course';
                    final coursePrice =
                        item.courseDetail?['price']?.toString() ?? '0.00';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: isDark ? AppColors.cardDark : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.menu_book, size: 32, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courseTitle,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹$coursePrice',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                ref.read(cartProvider.notifier).removeFromCart(item.course);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total (${cart.itemCount ?? cart.items.length} items)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '₹${cart.total ?? '0.00'}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Checkout',
                        onPressed: () async {
                          try {
                            await ref.read(cartProvider.notifier).checkout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Checkout successful!')),
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Checkout failed: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading cart', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              AppButton(
                label: 'Retry',
                onPressed: () => ref.refresh(cartProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
