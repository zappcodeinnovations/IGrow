import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../models/api_models/order_models.dart';

/// Repository for cart operations, checkout, and order history.
class CartRepository {
  CartRepository({required this.appApi, required this.tokenStorage});

  final AppApi appApi;
  final TokenStorage tokenStorage;

  /// Get the current cart.
  Future<ApiCart> getCart() async {
    debugPrint('🛒 [CartRepository] getCart: fetching user cart');
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
    debugPrint('➕ [CartRepository] addToCart: courseId=$courseId');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/cart/add/');
    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_id': courseId,
        'course': courseId,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] addToCart SUCCESS');
    } else {
      debugPrint('❌ [CartRepository] addToCart ERROR (${response.statusCode}): ${response.body}');
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error')) {
          throw Exception(decoded['error']);
        }
      } catch (e) {
        if (e is! FormatException) rethrow;
      }
      throw Exception('Failed to add to cart (${response.statusCode})');
    }
  }

  /// Remove a course from cart.
  Future<void> removeFromCart(String courseId) async {
    debugPrint('🗑️ [CartRepository] removeFromCart: courseId=$courseId');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/cart/remove/$courseId/');
    final response = await http.delete(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] removeFromCart SUCCESS');
    } else {
      debugPrint('⚠️ [CartRepository] removeFromCart status: ${response.statusCode}');
    }
  }

  /// Clear the entire cart.
  Future<void> clearCart() async {
    debugPrint('🧹 [CartRepository] clearCart');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/cart/clear/');
    final response = await http.delete(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] clearCart SUCCESS');
    }
  }

  /// Validate and apply coupon code via backend API.
  Future<Map<String, dynamic>> applyCoupon(String code) async {
    debugPrint('🎟️ [CartRepository] applyCoupon: code=$code');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/apply-coupon/');
    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] applyCoupon SUCCESS: ${response.body}');
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return Map<String, dynamic>.from(decoded as Map);
    } else {
      debugPrint('⚠️ [CartRepository] applyCoupon FAILED (${response.statusCode}): ${response.body}');
      String errMsg = 'Invalid or expired coupon code.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error')) {
          errMsg = decoded['error'].toString();
        }
      } catch (_) {}
      throw Exception(errMsg);
    }
  }

  /// Checkout — processes sandbox payment and enrolls.
  Future<Map<String, dynamic>> checkout({
    String? gatewayName,
    String? paymentMethod,
    String? courseId,
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
    String? cardHolder,
    String? couponCode,
  }) async {
    debugPrint('💳 [CartRepository] checkout START: method=$paymentMethod, courseId=$courseId, coupon=$couponCode');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/checkout/');

    final payload = <String, dynamic>{
      'payment_method': paymentMethod ?? 'DUMMY_CARD',
      'gateway_name': gatewayName ?? 'AgriPay Sandbox',
      if (courseId != null) 'course_id': courseId,
      'card_number': cardNumber ?? '4242424242424242',
      'card_expiry': cardExpiry ?? '12/28',
      'card_cvv': cardCvv ?? '123',
      'card_holder': cardHolder ?? 'IGrow Student',
      if (couponCode != null) 'coupon_code': couponCode,
    };

    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] checkout SUCCESS (${response.statusCode}): ${response.body}');
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'status': 'SUCCESS', 'message': 'Payment successful!'};
      }
    } else {
      debugPrint('❌ [CartRepository] checkout ERROR (${response.statusCode}): ${response.body}');
      String message = 'Payment failed. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error')) {
          message = decoded['error'].toString();
        } else if (decoded is Map && decoded.containsKey('message')) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Get order history.
  Future<List<ApiOrder>> getOrders() async {
    debugPrint('📦 [CartRepository] getOrders: loading user orders');
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/orders/');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = <dynamic>[];
        if (decoded is List) {
          list.addAll(decoded);
        } else if (decoded is Map && decoded['results'] is List) {
          list.addAll(decoded['results'] as List);
        }

        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => ApiOrder.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ [CartRepository] getOrders error: $e');
      return [];
    }
  }
}
