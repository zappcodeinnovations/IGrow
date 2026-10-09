import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../data/models/agri_news_model.dart';
import '../providers/news_provider.dart';

class AgriNewsScreen extends ConsumerStatefulWidget {
  const AgriNewsScreen({super.key});

  @override
  ConsumerState<AgriNewsScreen> createState() => _AgriNewsScreenState();
}

class _AgriNewsScreenState extends ConsumerState<AgriNewsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Agri Business',
    'Market & MSP',
    'Smart Farming',
    'Weather & Crops',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openArticle(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not open full news article. Please check your internet connection.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not open news link. Please try again later.'),
          ),
        );
      }
    }
  }

  void _shareArticle(AgriNews news) {
    final text = '${news.title}\n\nRead more on The Hindu Business Line: ${news.link}\n\nShared via iGrow Agriculture App';
    // ignore: deprecated_member_use
    Share.share(text);
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    try {
      return timeago.format(dt, allowFromNow: true);
    } catch (_) {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newsState = ref.watch(newsNotifierProvider);
    final filteredNews = newsState.filteredNews;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAF7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agriculture News',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Live updates from The Hindu Business Line',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white60 : AppColors.inkSoft,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Feed',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(newsNotifierProvider.notifier).refresh(),
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Filter Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        ref.read(newsNotifierProvider.notifier).setSearchQuery(val),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search agri news, commodities, MSP...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(newsNotifierProvider.notifier).setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.bgDark : const Color(0xFFF1F5F0),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Category Filter Pills
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = _categories[idx];
                        final isSelected = newsState.selectedCategory == cat;
                        return InkWell(
                          onTap: () =>
                              ref.read(newsNotifierProvider.notifier).setSelectedCategory(cat),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : (isDark ? AppColors.bgDark : const Color(0xFFF1F5F0)),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : (isDark ? AppColors.lineDark : const Color(0xFFCBD5E1)),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Live Feed Status Banner (if offline/fallback) ──
            if (filteredNews.isNotEmpty && filteredNews.first.isFallback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFFEF3C7),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Showing offline agricultural updates. Pull down to refresh live feed.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── News Feed Body ──
            Expanded(
              child: newsState.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2.5),
                          SizedBox(height: 16),
                          Text(
                            'Fetching live agriculture updates...',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(newsNotifierProvider.notifier).refresh(),
                      color: AppColors.primaryGreen,
                      child: filteredNews.isEmpty
                          ? _buildEmptyState(context, isDark, newsState.searchQuery)
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                              itemCount: filteredNews.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final news = filteredNews[index];
                                return _buildNewsCard(context, news, isDark);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HIGHLIGHTED NEWS CARD (CRISP LIGHT-MODE CONTRAST)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildNewsCard(BuildContext context, AgriNews news, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
          width: 1.3,
        ),
        boxShadow: [
          // Multi-layer shadow ensuring high contrast and clean highlight in Light Mode
          BoxShadow(
            color: isDark
                ? Colors.black38
                : const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
          // ── Header Image with Overlays ──
          if (news.imageUrl != null && news.imageUrl!.isNotEmpty)
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CachedNetworkImage(
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
                        child: Icon(Icons.eco_rounded, size: 40, color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
                ),
                // Gradient Scrim for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Source Pill Top Left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.newspaper_rounded, size: 12, color: AppColors.primaryGreen),
                        const SizedBox(width: 5),
                        Text(
                          news.source,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category Pill Top Right
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      news.category,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Time Ago Bottom Left
                if (news.pubDate != null)
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(news.pubDate),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

          // ── Card Content Body ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Headline Title
                Text(
                  news.title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  news.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Footer Row: Read Full Story + Share Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _openArticle(news.link),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Row(
                          children: [
                            Text(
                              'Read Full Story',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 19, color: AppColors.inkSoft),
                      tooltip: 'Share News',
                      onPressed: () => _shareArticle(news),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EMPTY SEARCH / FEED STATE
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, bool isDark, String query) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              size: 36,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          query.isNotEmpty ? 'No Results Found' : 'No News Updates',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.inkDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          query.isNotEmpty
              ? 'No articles match "$query". Try searching with different keywords like wheat, monsoon, or policy.'
              : 'Pull down to refresh and fetch the latest agricultural news.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : AppColors.inkSoft,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        if (query.isNotEmpty)
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(newsNotifierProvider.notifier).setSearchQuery('');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: const Text('Clear Search Filter'),
            ),
          ),
      ],
    );
  }
}
