import 'package:chopper/chopper.dart' as chopper;
import '../../core/network/api_client.dart';
import '../models/api_models/order_models.dart';

/// Repository for cart operations and checkout.
class CartRepository {
  CartRepository({required this.appApi});

  final AppApi appApi;

  /// Get the current cart.
  Future<ApiCart> getCart() async {
    final response = await appApi.apiV1CartGet();
    if (!response.isSuccessful) {
      if (response.statusCode == 404) {
        return const ApiCart(id: '');
      }
      throw Exception('Failed to load cart: ${response.statusCode}');
    }

    final dynamic data = response.body;
    if (data == null) {
      return const ApiCart(id: '');
    }

    if (data is Map<String, dynamic>) {
      return ApiCart.fromJson(data);
    } else if (data is Map) {
      return ApiCart.fromJson(Map<String, dynamic>.from(data));
    } else {
      try {
        final jsonMap = (data as dynamic).toJson();
        if (jsonMap is Map<String, dynamic>) {
          return ApiCart.fromJson(jsonMap);
        } else if (jsonMap is Map) {
          return ApiCart.fromJson(Map<String, dynamic>.from(jsonMap));
        }
      } catch (_) {}
    }
    return const ApiCart(id: '');
  }

  /// Add a course to cart.
  Future<void> addToCart(String courseId) async {
    final request = chopper.Request(
      'POST',
      Uri.parse('https://iagrow.zappcode.in/api/v1/cart/add/'),
      Uri.parse('https://iagrow.zappcode.in'),
      body: {
        'course_id': courseId,
        'course': courseId,
      },
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final response = await appApi.client.send<dynamic, dynamic>(request);
    if (!response.isSuccessful) {
      throw Exception(
        'Failed to add to cart (${response.statusCode}): ${response.bodyString.isNotEmpty ? response.bodyString : response.error}',
      );
    }
  }

  /// Remove a course from cart.
  Future<void> removeFromCart(String courseId) async {
    await appApi.apiV1CartRemoveCourseIdDelete(courseId: courseId);
  }

  /// Clear the entire cart.
  Future<void> clearCart() async {
    await appApi.apiV1CartClearDelete();
  }

  /// Checkout — processes sandbox payment and enrolls.
  Future<Map<String, dynamic>> checkout({
    String? gatewayName,
    String? paymentMethod,
  }) async {
    final body = <String, dynamic>{};
    if (gatewayName != null) body['gateway_name'] = gatewayName;
    if (paymentMethod != null) body['payment_method'] = paymentMethod;
    
    final request = chopper.Request(
      'POST',
      Uri.parse('https://iagrow.zappcode.in/api/v1/checkout/'),
      Uri.parse('https://iagrow.zappcode.in'),
      body: body,
    );
    final response = await appApi.client.send<dynamic, dynamic>(request);
    final dynamic data = response.body;
    if (data is Map<String, dynamic>) return data;
    return data?.toJson() as Map<String, dynamic>? ?? {};
  }

  /// Get order history.
  Future<Map<String, dynamic>> getOrders({
    int? page,
    String? ordering,
  }) async {
    final response = await appApi.apiV1OrdersGet(
      page: page,
      ordering: ordering,
    );
    final dynamic data = response.body;
    if (data is Map<String, dynamic>) return data;
    return data?.toJson() as Map<String, dynamic>? ?? {};
  }
}
