/// Order & Cart models matching the IAgrow Swagger schema.
library;

// ── Cart Item ───────────────────────────────────────────────────

class ApiCartItem {
  const ApiCartItem({
    required this.id,
    this.course = '',
    this.courseDetail,
    this.ebook,
    this.ebookDetail,
    this.itemType,
    this.addedAt,
  });

  final String id;
  final String course;
  final Map<String, dynamic>? courseDetail;
  final String? ebook;
  final Map<String, dynamic>? ebookDetail;
  final String? itemType;
  final DateTime? addedAt;

  bool get isEbook =>
      itemType == 'ebook' || (ebook != null && ebook!.isNotEmpty) || ebookDetail != null;

  /// Effective identifier (e.g. for cart removal or detail navigation)
  String get effectiveId {
    if (isEbook && ebook != null && ebook!.isNotEmpty) return ebook!;
    if (course.isNotEmpty) return course;
    return id;
  }

  /// Title of the course or ebook
  String get title {
    if (isEbook) {
      return ebookDetail?['title']?.toString() ??
          ebookDetail?['name']?.toString() ??
          'Agriculture E-Book';
    }
    return courseDetail?['title']?.toString() ??
        courseDetail?['name']?.toString() ??
        'Agriculture Course';
  }

  /// Instructor or author name
  String get instructorOrAuthor {
    if (isEbook) {
      return ebookDetail?['author_name']?.toString() ??
          ebookDetail?['instructor_name']?.toString() ??
          'iAgrow Author';
    }
    return courseDetail?['instructor_name']?.toString() ??
        courseDetail?['author_name']?.toString() ??
        'iAgrow Specialist';
  }

  /// Formatted or raw price
  String get price {
    if (isEbook) {
      return ebookDetail?['price']?.toString() ??
          ebookDetail?['discount_price']?.toString() ??
          '0.00';
    }
    return courseDetail?['price']?.toString() ??
        courseDetail?['discount_price']?.toString() ??
        '0.00';
  }

  /// Thumbnail or cover image URL
  String? get thumbnail {
    if (isEbook) {
      return ebookDetail?['cover_image']?.toString() ??
          ebookDetail?['thumbnail']?.toString() ??
          ebookDetail?['image']?.toString();
    }
    return courseDetail?['thumbnail']?.toString() ??
        courseDetail?['cover_image']?.toString() ??
        courseDetail?['image']?.toString();
  }

  factory ApiCartItem.fromJson(Map<String, dynamic> json) {
    final ebookRaw = json['ebook'] ?? json['ebook_id'];
    final ebookId = ebookRaw is Map ? ebookRaw['id']?.toString() : ebookRaw?.toString();
    final ebookDetail = json['ebook_detail'] is Map
        ? Map<String, dynamic>.from(json['ebook_detail'] as Map)
        : (json['ebook'] is Map ? Map<String, dynamic>.from(json['ebook'] as Map) : null);

    final courseRaw = json['course'] ?? json['course_id'];
    final courseId = courseRaw is Map ? courseRaw['id']?.toString() : courseRaw?.toString();
    final courseDetail = json['course_detail'] is Map
        ? Map<String, dynamic>.from(json['course_detail'] as Map)
        : (json['course'] is Map ? Map<String, dynamic>.from(json['course'] as Map) : null);

    final itemType = json['item_type']?.toString().toLowerCase() ??
        (ebookId != null && ebookId.isNotEmpty || ebookDetail != null ? 'ebook' : 'course');

    return ApiCartItem(
      id: json['id']?.toString() ?? '',
      course: courseId ?? '',
      courseDetail: courseDetail,
      ebook: ebookId,
      ebookDetail: ebookDetail,
      itemType: itemType,
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at'].toString())
          : null,
    );
  }
}

// ── Cart ────────────────────────────────────────────────────────

class ApiCart {
  const ApiCart({
    required this.id,
    this.items = const [],
    this.total,
    this.itemCount,
    this.updatedAt,
  });

  final String id;
  final List<ApiCartItem> items;
  final String? total;
  final String? itemCount;
  final DateTime? updatedAt;

  factory ApiCart.fromJson(Map<String, dynamic> json) => ApiCart(
        id: json['id']?.toString() ?? '',
        items: (json['items'] as List?)
                ?.whereType<Map>()
                .map((e) => ApiCartItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
        total: json['total']?.toString(),
        itemCount: json['item_count']?.toString(),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
}

// ── Order Item ──────────────────────────────────────────────────

class ApiOrderItem {
  const ApiOrderItem({
    required this.id,
    this.course,
    this.courseTitle,
    this.courseSlug,
    this.ebook,
    this.ebookId,
    this.ebookTitle,
    this.ebookSlug,
    this.itemType,
    required this.priceAtPurchase,
  });

  final String id;
  final String? course;
  final String? courseTitle;
  final String? courseSlug;
  final String? ebook;
  final String? ebookId;
  final String? ebookTitle;
  final String? ebookSlug;
  final String? itemType;
  final String priceAtPurchase;

  factory ApiOrderItem.fromJson(Map<String, dynamic> json) => ApiOrderItem(
        id: json['id'] as String,
        course: json['course'] as String?,
        courseTitle: json['course_title'] as String?,
        courseSlug: json['course_slug'] as String?,
        ebook: json['ebook'] as String?,
        ebookId: json['ebook_id'] as String? ?? json['ebook'] as String?,
        ebookTitle: json['ebook_title'] as String?,
        ebookSlug: json['ebook_slug'] as String?,
        itemType: json['item_type'] as String?,
        priceAtPurchase: json['price_at_purchase']?.toString() ?? '0',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (course != null) 'course': course,
        if (courseTitle != null) 'course_title': courseTitle,
        if (courseSlug != null) 'course_slug': courseSlug,
        if (ebook != null) 'ebook': ebook,
        if (ebookId != null) 'ebook_id': ebookId,
        if (ebookTitle != null) 'ebook_title': ebookTitle,
        if (ebookSlug != null) 'ebook_slug': ebookSlug,
        if (itemType != null) 'item_type': itemType,
        'price_at_purchase': priceAtPurchase,
      };
}

// ── Order ────────────────────────────────────────────────────────

class ApiOrder {
  const ApiOrder({
    required this.id,
    required this.totalAmount,
    this.gatewayReference,
    this.gatewayName,
    this.status,
    this.paymentMethod,
    this.items = const [],
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String totalAmount;
  final String? gatewayReference;
  final String? gatewayName;
  final String? status; // 'PENDING' | 'SUCCESS' | 'FAILED' | 'REFUNDED'
  final String? paymentMethod;
  final List<ApiOrderItem> items;
  final DateTime? createdAt;
  final DateTime? completedAt;

  factory ApiOrder.fromJson(Map<String, dynamic> json) => ApiOrder(
        id: json['id'] as String,
        totalAmount: json['total_amount']?.toString() ?? '0',
        gatewayReference: json['gateway_reference'] as String?,
        gatewayName: json['gateway_name'] as String?,
        status: json['status'] as String?,
        paymentMethod: json['payment_method'] as String?,
        items: (json['items'] as List?)
                ?.map((e) => ApiOrderItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'] as String)
            : null,
      );
}
