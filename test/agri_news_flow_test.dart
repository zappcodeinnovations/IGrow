import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/router/route_names.dart';
import 'package:krushi_siksha/data/models/agri_news_model.dart';

void main() {
  group('AgriNews Model & Flow Tests', () {
    test('parses live RSS JSON item with enclosure image accurately', () {
      final json = {
        'title': 'Grim situation in South reservoirs as water storage dips',
        'pubDate': '2026-10-09 12:21:07',
        'link':
            'https://www.thehindubusinessline.com/economy/agri-business/grim-situation-in-south/article71563982.ece',
        'guid': 'article-71563982',
        'description':
            '<p>Storage in India&#39;s 178 major reservoirs dipped &amp; reached 71% of capacity.</p>',
        'enclosure': {
          'link': 'https://bl-i.thgim.com/public/incoming/pic1.jpg',
        },
        'categories': ['Agri Business'],
      };

      final news = AgriNews.fromRssJson(json);

      expect(news.title, 'Grim situation in South reservoirs as water storage dips');
      expect(news.link,
          'https://www.thehindubusinessline.com/economy/agri-business/grim-situation-in-south/article71563982.ece');
      expect(news.imageUrl, 'https://bl-i.thgim.com/public/incoming/pic1.jpg');
      expect(news.category, 'Agri Business');
      expect(news.source, 'The Hindu Business Line');
      expect(news.isFallback, isFalse);
      expect(news.pubDate, isNotNull);
      // Verify HTML tags and entities were cleaned
      expect(news.description, "Storage in India's 178 major reservoirs dipped & reached 71% of capacity.");
    });

    test('stripHtml cleans diverse HTML tags and entities', () {
      const html = '<div><b>Record harvest:</b> &lt;Wheat&gt; &quot;MSP&quot; approved&nbsp;by Cabinet.</div>';
      final cleaned = AgriNews.stripHtml(html);
      expect(cleaned, 'Record harvest: <Wheat> "MSP" approved by Cabinet.');
    });

    test('mockFallbackNews contains 3 curated fallback articles for offline resilience', () {
      final fallback = AgriNews.mockFallbackNews;
      expect(fallback.length, 3);
      for (final item in fallback) {
        expect(item.isFallback, isTrue);
        expect(item.title.isNotEmpty, isTrue);
        expect(item.imageUrl, isNotNull);
        expect(item.link.isNotEmpty, isTrue);
      }
    });

    test('RouteNames defines news path correctly', () {
      expect(RouteNames.news, '/news');
    });
  });
}
