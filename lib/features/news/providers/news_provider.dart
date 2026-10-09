import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/agri_news_model.dart';

class NewsRepository {
  static const String _rssUrl =
      'https://www.thehindubusinessline.com/economy/agri-business/feeder/default.rss';

  /// Fetches real-time agriculture news from live RSS2JSON API.
  /// Falls back smoothly to curated mock items if offline or on network error.
  Future<List<AgriNews>> getLatestNews() async {
    final encodedRss = Uri.encodeComponent(_rssUrl);
    final endpoint = Uri.parse('https://api.rss2json.com/v1/api.json?rss_url=$encodedRss');

    try {
      final response = await http.get(
        endpoint,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'ok' && data['items'] is List) {
          final items = data['items'] as List;
          final newsList = <AgriNews>[];

          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            if (item is Map<String, dynamic>) {
              newsList.add(AgriNews.fromRssJson(item, index: i));
            }
          }

          if (newsList.isNotEmpty) {
            debugPrint('📰 [NewsRepository] Successfully fetched ${newsList.length} live agri news items');
            return newsList;
          }
        }
      }
      debugPrint('⚠️ [NewsRepository] Live RSS returned non-ok status, using fallback mock data');
    } catch (e) {
      debugPrint('⚠️ [NewsRepository] Failed to fetch live RSS ($e), using fallback mock data');
    }

    // Resilience fallback: Return 3 static agricultural news items matching website's mockData.js
    return AgriNews.mockFallbackNews;
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

/// Riverpod StateNotifier for managing news state, search query, and pull-to-refresh
class NewsState {
  final bool isLoading;
  final bool isRefreshing;
  final List<AgriNews> allNews;
  final String searchQuery;
  final String selectedCategory;
  final String? error;

  const NewsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.allNews = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.error,
  });

  NewsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<AgriNews>? allNews,
    String? searchQuery,
    String? selectedCategory,
    String? error,
  }) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      allNews: allNews ?? this.allNews,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error,
    );
  }

  /// Filtered news based on search query and category
  List<AgriNews> get filteredNews {
    return allNews.where((news) {
      final matchesCategory = selectedCategory == 'All' ||
          news.category.toLowerCase().contains(selectedCategory.toLowerCase());
      final matchesQuery = searchQuery.trim().isEmpty ||
          news.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          news.description.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final NewsRepository _repo;

  NewsNotifier(this._repo) : super(const NewsState(isLoading: true)) {
    loadNews();
  }

  Future<void> loadNews() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final news = await _repo.getLatestNews();
      state = state.copyWith(isLoading: false, allNews: news);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        allNews: AgriNews.mockFallbackNews,
        error: 'Showing offline updates',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    try {
      final news = await _repo.getLatestNews();
      state = state.copyWith(isRefreshing: false, allNews: news, error: null);
    } catch (e) {
      state = state.copyWith(isRefreshing: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedCategory(String cat) {
    state = state.copyWith(selectedCategory: cat);
  }
}

final newsNotifierProvider =
    StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  final repo = ref.watch(newsRepositoryProvider);
  return NewsNotifier(repo);
});

/// Top 5 news items for Home Screen showcase carousel
final topAgriNewsProvider = Provider<List<AgriNews>>((ref) {
  final newsState = ref.watch(newsNotifierProvider);
  if (newsState.allNews.isEmpty) {
    return AgriNews.mockFallbackNews;
  }
  return newsState.allNews.take(5).toList();
});
