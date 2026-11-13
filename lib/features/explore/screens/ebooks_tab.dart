import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../cart/providers/cart_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../../core/widgets/shimmer_placeholders.dart';

class EbooksTab extends ConsumerWidget {
  const EbooksTab({
    super.key,
    this.searchQuery = '',
    this.category,
    this.instructorId,
    this.shrinkWrap = false,
    this.physics,
  });

  final String searchQuery;
  final String? category;
  final String? instructorId;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = EbooksQuery(
      search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
      category: category,
      instructorId: instructorId,
    );
    
    return RefreshIndicator(
      color: AppColors.editorialSecondary,
      onRefresh: () async {
        ref.invalidate(studentEbooksProvider(query));
      },
      child: ref.watch(studentEbooksProvider(query)).when(
        data: (ebooks) {
          if (ebooks.isEmpty) {
            final isFiltering = searchQuery.trim().isNotEmpty ||
                (category != null && category!.isNotEmpty && category != 'all') ||
                (instructorId != null && instructorId!.isNotEmpty);

            return ListView(
              shrinkWrap: shrinkWrap,
              physics: physics ?? const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFiltering ? Icons.search_off_rounded : Icons.menu_book_rounded,
                          size: 56,
                          color: AppColors.inkSoft,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isFiltering ? tr(ref, 'No Matching E-Books') : tr(ref, 'No E-Books Available'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isFiltering
                              ? tr(ref, 'No e-books found matching the selected instructor or search keywords.')
                              : tr(ref, 'Agricultural e-books and farming guides will appear here soon.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            shrinkWrap: shrinkWrap,
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            itemCount: ebooks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final ebook = ebooks[index];
            final rawPrice = ebook.price ?? '0.00';
            final parsedPrice = double.tryParse(rawPrice) ?? 0.0;
            final isFree = parsedPrice <= 0.0;
            final ebookId = ebook.id ?? '';
            final ebookSlug = ebook.slug ?? '';
            final isPurchased = ebook.isPurchased == true ||
                (ebookId.isNotEmpty && ref.watch(isEbookPurchasedProvider(ebookId))) ||
                (ebookSlug.isNotEmpty && ref.watch(isEbookPurchasedProvider(ebookSlug))) ||
                ref.watch(isEbookPurchasedProvider(ebook.title));
            final identifier = (ebook.slug != null && ebook.slug!.isNotEmpty)
                ? ebook.slug!
                : (ebook.id ?? '');

            return Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (isPurchased || isFree)
                        ? () {
                            if (identifier.isNotEmpty) {
                              context.push('/farmer/ebook/$identifier');
                            }
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.editorialSecondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            image: ebook.coverImage != null
                                ? DecorationImage(
                                    image: NetworkImage(ebook.coverImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: ebook.coverImage == null
                              ? const Icon(Icons.picture_as_pdf, color: AppColors.editorialSecondary, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ebook.title.isNotEmpty ? ebook.title : 'Untitled E-Book',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ebook.authorName.isNotEmpty ? ebook.authorName : 'Unknown Author',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.editorialSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ebook.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.inkSoft,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  // Price and Buy / Read Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price Badge
                      Row(
                        children: [
                          Text(
                            isFree ? tr(ref, 'FREE') : '₹${parsedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isFree
                                  ? AppColors.primaryGreen
                                  : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF1B4D2E)),
                            ),
                          ),
                          if (isPurchased) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tr(ref, 'Purchased'),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Action Button (Read Now or Buy Now)
                      if (isPurchased || isFree)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4D2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 14),
                          label: Text(
                            tr(ref, 'Read Now'),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (identifier.isNotEmpty) {
                              context.push('/farmer/ebook/$identifier');
                            }
                          },
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Add to cart button
                            Consumer(
                              builder: (context, ref, _) {
                                final cart = ref.watch(cartProvider).valueOrNull;
                                final isInCart = cart?.items.any((it) =>
                                        it.id == ebook.id ||
                                        it.course == ebook.id ||
                                        it.id == ebook.slug ||
                                        it.course == ebook.slug ||
                                        it.ebook == ebook.id ||
                                        it.ebook == ebook.slug ||
                                        it.effectiveId == ebook.id ||
                                        it.effectiveId == ebook.slug ||
                                        it.ebookDetail?['id']?.toString() == ebook.id ||
                                        it.ebookDetail?['slug']?.toString() == ebook.slug) ??
                                    false;

                                return OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryGreen,
                                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () async {
                                    if (isInCart) {
                                      context.push('/cart');
                                      return;
                                    }
                                    try {
                                      final targetId = ebook.id ?? identifier;
                                      await ref.read(cartProvider.notifier).addToCart('', ebookId: targetId);
                                      if (context.mounted) {
                                        final messenger = ScaffoldMessenger.of(context);
                                        messenger.clearSnackBars();
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('E-Book added to cart! 🛒'),
                                            backgroundColor: AppColors.primaryGreen,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        final messenger = ScaffoldMessenger.of(context);
                                        messenger.clearSnackBars();
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to add to cart: $e'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Icon(
                                    isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                    size: 16,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            // Buy Now button
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1B4D2E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                final targetId = ebook.id ?? identifier;
                                context.push('/checkout?ebookId=$targetId');
                              },
                              child: Text(
                                tr(ref, 'Buy Now'),
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const ShimmerListTile(),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text(
                tr(ref, getUserFriendlyErrorMessage(err)),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(tr(ref, 'Try Again')),
                onPressed: () {
                  ref.invalidate(studentEbooksProvider);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
