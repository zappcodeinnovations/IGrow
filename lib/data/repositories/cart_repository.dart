import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/token_storage.dart';
import '../models/api_models/order_models.dart';

/// Repository for cart operations, checkout, and order history.
class CartRepository {
  CartRepository({required this.appApi, required this.tokenStorage});

  final AppApi appApi;
  final TokenStorage tokenStorage;

  bool _isNetworkOrAbortError(dynamic e) {
    if (e is SocketException || e is TimeoutException || e is http.ClientException) {
      return true;
    }
    final s = e.toString().toLowerCase();
    return s.contains('abort') ||
        s.contains('connection') ||
        s.contains('socket') ||
        s.contains('handshake') ||
        s.contains('timeout') ||
        s.contains('clientexception') ||
        s.contains('failed host lookup') ||
        s.contains('network is unreachable');
  }

  /// Get the current cart with automatic single retry for transient connection drops.
  Future<ApiCart> getCart() async {
    debugPrint('🛒 [CartRepository] getCart: fetching user cart');
    try {
      return await _fetchCartFromApi();
    } catch (e) {
      if (_isNetworkOrAbortError(e)) {
        debugPrint('🔄 [CartRepository] getCart network/abort failure ($e). Retrying once after 350ms...');
        await Future.delayed(const Duration(milliseconds: 350));
        try {
          return await _fetchCartFromApi();
        } catch (retryErr) {
          debugPrint('❌ [CartRepository] getCart retry also failed: $retryErr');
          throw ApiException.network('Unable to load cart. Please check your internet connection.');
        }
      }
      rethrow;
    }
  }

  Future<ApiCart> _fetchCartFromApi() async {
    final response = await appApi.apiV1CartGet();
    if (!response.isSuccessful) {
      if (response.statusCode == 404) {
        return const ApiCart(id: '');
      }
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load cart (${response.statusCode})',
      );
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
    
    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'course_id': courseId,
          'course': courseId,
        }),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('❌ [CartRepository] addToCart network error: $e');
      if (_isNetworkOrAbortError(e)) {
        throw ApiException.network('Unable to add course to cart. Please check your internet connection.');
      }
      rethrow;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] addToCart SUCCESS');
    } else {
      debugPrint('❌ [CartRepository] addToCart ERROR (${response.statusCode}): ${response.body}');
      String errorMessage = 'Failed to add to cart (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          if (decoded.containsKey('error') && decoded['error'] != null) {
            errorMessage = decoded['error'].toString();
          } else if (decoded.containsKey('detail') && decoded['detail'] != null) {
            errorMessage = decoded['detail'].toString();
          } else if (decoded.containsKey('message') && decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        }
      } catch (e) {
        if (e is! FormatException) rethrow;
      }

      if (response.statusCode >= 500) {
        throw ApiException.server('Server error. Please try again later.');
      }
      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
      );
    }
  }

  /// Remove a course from cart.
  Future<void> removeFromCart(String courseId) async {
    debugPrint('🗑️ [CartRepository] removeFromCart: courseId=$courseId');
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/cart/remove/$courseId/');
      final response = await http.delete(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [CartRepository] removeFromCart SUCCESS');
      } else {
        debugPrint('⚠️ [CartRepository] removeFromCart status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [CartRepository] removeFromCart network/timeout error: $e');
    }
  }

  /// Clear the entire cart.
  Future<void> clearCart() async {
    debugPrint('🧹 [CartRepository] clearCart');
    try {
      final token = await tokenStorage.getAccessToken();
      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/cart/clear/');
      final response = await http.delete(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [CartRepository] clearCart SUCCESS');
      }
    } catch (e) {
      debugPrint('⚠️ [CartRepository] clearCart network/timeout error: $e');
    }
  }

  /// Validate and apply coupon code via backend API.
  Future<Map<String, dynamic>> applyCoupon(String code, {String? courseId}) async {
    debugPrint('🎟️ [CartRepository] applyCoupon: code=$code, courseId=$courseId');
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/apply-coupon/');
    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'code': code,
          if (courseId != null) 'course_id': courseId,
        }),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      if (_isNetworkOrAbortError(e)) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      throw Exception('Unable to reach server. Please try again.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] applyCoupon SUCCESS: ${response.body}');
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return Map<String, dynamic>.from(decoded as Map);
    } else {
      debugPrint('⚠️ [CartRepository] applyCoupon FAILED (${response.statusCode}): ${response.body}');
      if (response.statusCode >= 500) {
        throw Exception('Server is temporarily unavailable. Please try again in a few moments.');
      }
      String errMsg = 'Invalid or expired coupon code.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          if (decoded.containsKey('error') && decoded['error'] != null) {
            errMsg = decoded['error'].toString();
          } else if (decoded.containsKey('message') && decoded['message'] != null) {
            errMsg = decoded['message'].toString();
          } else if (decoded.containsKey('detail') && decoded['detail'] != null) {
            errMsg = decoded['detail'].toString();
          }
        }
      } catch (_) {}

      // Clean up technical backend exceptions if any
      final lower = errMsg.toLowerCase();
      if (lower.contains('matching query does not exist') || lower.contains('not found') || lower.contains('doesnotexist')) {
        errMsg = 'Invalid coupon code. Please verify the code and try again.';
      } else if (lower.contains('already used') || lower.contains('limit reached')) {
        errMsg = 'This coupon has already been used or reached its usage limit.';
      } else if (lower.contains('expired')) {
        errMsg = 'This coupon code has expired.';
      }

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

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 25));
    } catch (e) {
      if (_isNetworkOrAbortError(e)) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      throw Exception('Payment request timed out. Please check your connection and try again.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [CartRepository] checkout SUCCESS (${response.statusCode}): ${response.body}');
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'status': 'SUCCESS', 'message': 'Payment successful!'};
      }
    } else {
      debugPrint('❌ [CartRepository] checkout ERROR (${response.statusCode}): ${response.body}');
      if (response.statusCode >= 500) {
        throw Exception('Payment server is temporarily unavailable. Please try again in a few moments.');
      }
      String message = 'Payment failed. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error') && decoded['error'] != null) {
          message = decoded['error'].toString();
        } else if (decoded is Map && decoded.containsKey('message') && decoded['message'] != null) {
          message = decoded['message'].toString();
        } else if (decoded is Map && decoded.containsKey('detail') && decoded['detail'] != null) {
          message = decoded['detail'].toString();
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
