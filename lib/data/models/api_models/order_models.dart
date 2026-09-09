/// Order & Cart models matching the IAgrow Swagger schema.

// ── Cart Item ───────────────────────────────────────────────────

class ApiCartItem {
  const ApiCartItem({
    required this.id,
    required this.course,
    this.courseDetail,
    this.addedAt,
  });

  final String id;
  final String course;
  final Map<String, dynamic>? courseDetail;
  final DateTime? addedAt;

  factory ApiCartItem.fromJson(Map<String, dynamic> json) => ApiCartItem(
        id: json['id']?.toString() ?? '',
        course: json['course']?.toString() ?? '',
        courseDetail: json['course_detail'] is Map
            ? Map<String, dynamic>.from(json['course_detail'] as Map)
            : null,
        addedAt: json['added_at'] != null
            ? DateTime.tryParse(json['added_at'].toString())
            : null,
      );
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
    required this.priceAtPurchase,
  });

  final String id;
  final String? course;
  final String? courseTitle;
  final String? courseSlug;
  final String priceAtPurchase;

  factory ApiOrderItem.fromJson(Map<String, dynamic> json) => ApiOrderItem(
        id: json['id'] as String,
        course: json['course'] as String?,
        courseTitle: json['course_title'] as String?,
        courseSlug: json['course_slug'] as String?,
        priceAtPurchase: json['price_at_purchase']?.toString() ?? '0',
      );
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
