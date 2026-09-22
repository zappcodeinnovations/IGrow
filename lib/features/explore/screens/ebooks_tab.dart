import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../../core/widgets/shimmer_placeholders.dart';

class EbooksTab extends ConsumerWidget {
  const EbooksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ref.watch(studentEbooksProvider('')).when(
      data: (ebooks) {
        if (ebooks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 56,
                    color: AppColors.inkSoft.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No E-Books Available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Agricultural e-books and farming guides will appear here soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          itemCount: ebooks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final ebook = ebooks[index];
            return GestureDetector(
              onTap: () {
                final identifier = (ebook.slug != null && ebook.slug!.isNotEmpty)
                    ? ebook.slug!
                    : (ebook.id ?? '');
                if (identifier.isNotEmpty) {
                  context.push('/farmer/ebook/$identifier');
                }
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
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        image: ebook.coverImage != null
                            ? DecorationImage(
                                image: NetworkImage(ebook.coverImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: ebook.coverImage == null
                          ? const Icon(Icons.picture_as_pdf, color: AppColors.primaryGreen, size: 40)
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
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
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
            );
          },
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const ShimmerListTile(),
      ),
      error: (err, _) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Unable to load e-books at this time. Please check your connection.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkSoft),
          ),
        ),
      ),
    );
  }
}
