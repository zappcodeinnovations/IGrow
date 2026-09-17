// Wishlist model matching the IAgrow / AgriLearn backend API schema.

class ApiWishlistItem {
  const ApiWishlistItem({
    required this.id,
    required this.targetId,
    required this.type,
    required this.title,
    required this.slug,
    this.thumbnail,
    this.cover,
    required this.price,
    required this.category,
    this.rating = 4.8,
    this.addedAt,
  });

  final String id;
  final String targetId;
  final String type; // 'course' or 'ebook'
  final String title;
  final String slug;
  final String? thumbnail;
  final String? cover;
  final String price;
  final String category;
  final double rating;
  final DateTime? addedAt;

  bool get isCourse => type.toLowerCase() == 'course';
  bool get isEbook => type.toLowerCase() == 'ebook';

  String? get displayImage => thumbnail ?? cover;

  factory ApiWishlistItem.fromJson(Map<String, dynamic> json) {
    DateTime? added;
    if (json['added_at'] != null) {
      try {
        added = DateTime.parse(json['added_at'] as String);
      } catch (_) {}
    }

    double parsedRating = 4.8;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toDouble();
      } else if (json['rating'] is String) {
        parsedRating = double.tryParse(json['rating'] as String) ?? 4.8;
      }
    }

    return ApiWishlistItem(
      id: json['id']?.toString() ?? '',
      targetId: json['target_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'course',
      title: json['title']?.toString() ?? 'Untitled',
      slug: json['slug']?.toString() ?? '',
      thumbnail: json['thumbnail'] as String?,
      cover: json['cover'] as String?,
      price: json['price']?.toString() ?? '0.00',
      category: json['category']?.toString() ?? 'General',
      rating: parsedRating,
      addedAt: added,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_id': targetId,
      'type': type,
      'title': title,
      'slug': slug,
      'thumbnail': thumbnail,
      'cover': cover,
      'price': price,
      'category': category,
      'rating': rating,
      'added_at': addedAt?.toIso8601String(),
    };
  }
}

class WishlistToggleResult {
  const WishlistToggleResult({
    required this.inWishlist,
    required this.message,
    this.id,
  });

  final bool inWishlist;
  final String message;
  final String? id;

  factory WishlistToggleResult.fromJson(Map<String, dynamic> json) {
    return WishlistToggleResult(
      inWishlist: json['in_wishlist'] == true,
      message: json['message']?.toString() ?? '',
      id: json['id']?.toString(),
    );
  }
}
