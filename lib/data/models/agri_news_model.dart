/// Represents an agriculture news item fetched from live RSS feed or fallback mock data.
class AgriNews {
  final String id;
  final String title;
  final String description;
  final String link;
  final String? imageUrl;
  final DateTime? pubDate;
  final String source;
  final String category;
  final bool isFallback;

  const AgriNews({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    this.imageUrl,
    this.pubDate,
    this.source = 'The Hindu Business Line',
    this.category = 'Agri Business',
    this.isFallback = false,
  });

  /// Factory to parse from RSS2JSON item object safely.
  factory AgriNews.fromRssJson(Map<String, dynamic> json, {int index = 0}) {
    final rawTitle = (json['title'] ?? '').toString().trim();
    final rawDesc = (json['description'] ?? json['content'] ?? '').toString();
    final cleanDesc = stripHtml(rawDesc);
    final link = (json['link'] ?? json['guid'] ?? '').toString().trim();

    // High-resolution image extraction from enclosure, thumbnail, or content
    String? imgUrl;
    if (json['enclosure'] is Map && json['enclosure']['link'] != null) {
      final enc = json['enclosure']['link'].toString().trim();
      if (enc.isNotEmpty && enc.startsWith('http')) {
        imgUrl = enc;
      }
    }

    if (imgUrl == null && json['thumbnail'] != null) {
      final thumb = json['thumbnail'].toString().trim();
      if (thumb.isNotEmpty && thumb.startsWith('http')) {
        imgUrl = thumb;
      }
    }

    if (imgUrl == null && rawDesc.contains('<img')) {
      final imgMatch = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(rawDesc);
      if (imgMatch != null && imgMatch.group(1) != null) {
        imgUrl = imgMatch.group(1);
      }
    }

    // Default agriculture fallback images if no image present
    if (imgUrl == null || imgUrl.isEmpty) {
      imgUrl = _defaultAgriImages[index % _defaultAgriImages.length];
    }

    DateTime? date;
    if (json['pubDate'] != null) {
      date = DateTime.tryParse(json['pubDate'].toString());
    }

    String cat = 'Agri Business';
    if (json['categories'] is List && (json['categories'] as List).isNotEmpty) {
      cat = (json['categories'] as List).first.toString();
    }

    return AgriNews(
      id: (json['guid'] ?? 'news-$index').toString(),
      title: rawTitle,
      description: cleanDesc,
      link: link,
      imageUrl: imgUrl,
      pubDate: date,
      source: 'The Hindu Business Line',
      category: cat,
      isFallback: false,
    );
  }

  /// Utility to strip HTML tags and decode common HTML entities
  static String stripHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Default high quality agriculture placeholder photos
  static const List<String> _defaultAgriImages = [
    'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=800&q=80',
  ];

  /// Static 3 mock news items matching website's mockData.js (offline / API failure fallback)
  static List<AgriNews> get mockFallbackNews => [
        AgriNews(
          id: 'mock-1',
          title: 'Cabinet Approves MSP Hike for Rabi Crops to Boost Farmer Income',
          description:
              'The Union Cabinet has approved higher Minimum Support Prices (MSP) for key Rabi crops including wheat, gram, and mustard for the upcoming marketing season to ensure remunerative returns for farmers.',
          link: 'https://www.thehindubusinessline.com/economy/agri-business/',
          imageUrl:
              'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80',
          pubDate: DateTime.now().subtract(const Duration(hours: 3)),
          source: 'Agri Policy Desk',
          category: 'Market & MSP',
          isFallback: true,
        ),
        AgriNews(
          id: 'mock-2',
          title: 'Drone Technology in Agriculture: Government Expands 50% Subsidies for Farmers',
          description:
              'Agricultural cooperatives and individual farmers can now avail up to 50% subsidy on precision spraying drones, aimed at optimizing fertilizer use and cutting crop management costs.',
          link: 'https://www.thehindubusinessline.com/economy/agri-business/',
          imageUrl:
              'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=800&q=80',
          pubDate: DateTime.now().subtract(const Duration(hours: 7)),
          source: 'AgriTech Insights',
          category: 'Smart Farming',
          isFallback: true,
        ),
        AgriNews(
          id: 'mock-3',
          title: 'Monsoon Revival Sparks Hope for Bumper Kharif Crop Harvest Across India',
          description:
              'Widespread late monsoon rainfall in key agricultural belts has replenished major reservoirs and lifted soil moisture, setting the stage for strong harvest yields.',
          link: 'https://www.thehindubusinessline.com/economy/agri-business/',
          imageUrl:
              'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=800&q=80',
          pubDate: DateTime.now().subtract(const Duration(hours: 14)),
          source: 'Weather & Crops',
          category: 'Monsoon Update',
          isFallback: true,
        ),
      ];
}
