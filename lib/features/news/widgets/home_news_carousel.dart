import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/agri_news_model.dart';
import '../providers/news_provider.dart';

/// Horizontal showcase carousel of latest agriculture news displayed on FarmerHomeScreen.
class HomeNewsCarousel extends ConsumerWidget {
  const HomeNewsCarousel({super.key});

  Future<void> _openArticle(BuildContext context, String url) async {
    if (url.trim().isEmpty) return;
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        context.push(RouteNames.news);
      }
    } catch (_) {
      if (context.mounted) {
        context.push(RouteNames.news);
      }
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    try {
      return timeago.format(dt, allowFromNow: true);
    } catch (_) {
      return '${dt.day}/${dt.month}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topNews = ref.watch(topAgriNewsProvider);

    if (topNews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Agri Market News',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'The Hindu Business Line updates',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white60 : AppColors.inkSoft,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push(RouteNames.news),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Horizontal Cards Carousel ──
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: topNews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final news = topNews[index];
              return _buildCarouselCard(context, news, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselCard(BuildContext context, AgriNews news, bool isDark) {
    return InkWell(
      onTap: () => _openArticle(context, news.link),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            // Light-mode highlighting: Crisp shadow so card pops cleanly
            BoxShadow(
              color: isDark
                  ? Colors.black38
                  : const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.05 : 0.03),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image (Height: 125)
            Stack(
              children: [
                SizedBox(
                  height: 125,
                  width: double.infinity,
                  child: news.imageUrl != null && news.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: news.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark ? Colors.white10 : Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(Icons.eco_rounded, size: 32, color: AppColors.primaryGreen),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(Icons.newspaper_rounded, size: 32, color: AppColors.primaryGreen),
                          ),
                        ),
                ),
                // Gradient scrim
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category Pill Top Right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      news.category,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Time Ago Bottom Left
                if (news.pubDate != null)
                  Positioned(
                    bottom: 6,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 11, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          _formatDate(news.pubDate),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Text Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        'Read Story',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primaryGreen),
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
