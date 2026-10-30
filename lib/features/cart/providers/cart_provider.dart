import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/order_models.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_farmer/providers/student_provider.dart';

/// Provider for CartRepository.
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final appApi = ref.watch(appApiProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return CartRepository(appApi: appApi, tokenStorage: tokenStorage);
});

/// Model representing an applied discount coupon returned dynamically by backend.
class AppliedCoupon {
  const AppliedCoupon({
    required this.code,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    this.newTotal,
    required this.description,
    this.rawBackendResponse,
  });

  final String code;
  final double discountPercent;
  final double discountAmount;
  final double? newTotal;
  final String description;
  final Map<String, dynamic>? rawBackendResponse;
}

/// State provider for tracking the currently applied coupon.
final appliedCouponProvider = StateProvider<AppliedCoupon?>((ref) => null);

/// Model representing the last completed checkout data.
class LastCheckoutData {
  const LastCheckoutData({
    this.orderResult = const {},
    this.originalTotal = 0.0,
    this.finalTotal = 0.0,
    this.discountAmount = 0.0,
    this.couponCode,
    this.paymentMethod = 'DUMMY_CARD',
    this.purchasedItems = const [],
  });

  final Map<String, dynamic> orderResult;
  final double originalTotal;
  final double finalTotal;
  final double discountAmount;
  final String? couponCode;
  final String paymentMethod;
  final List<dynamic> purchasedItems;
}

/// Provider for persisting the last checkout session data across navigation & router rebuilds.
final lastCheckoutDataProvider = StateProvider<LastCheckoutData?>((ref) => null);

/// Provider for fetching user's order history.
final ordersProvider = FutureProvider<List<ApiOrder>>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return await repo.getOrders();
});

/// AsyncNotifier provider for managing the user's cart state.
final cartProvider = AsyncNotifierProvider<CartNotifier, ApiCart>(() {
  return CartNotifier();
});

/// Helper family provider to check if a specific course is currently in the cart.
final isCourseInCartProvider = Provider.family<bool, String>((ref, courseIdOrSlug) {
  final target = courseIdOrSlug.trim();
  if (target.isEmpty) return false;
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.maybeWhen(
    data: (cart) => cart.items.any((item) {
      final matchesCourseId = item.course == target || item.id == target;
      final matchesDetailId = item.courseDetail?['id']?.toString() == target;
      final matchesDetailSlug = item.courseDetail?['slug']?.toString() == target;
      return matchesCourseId || matchesDetailId || matchesDetailSlug;
    }),
    orElse: () => false,
  );
});

class CartNotifier extends AsyncNotifier<ApiCart> {
  late CartRepository _repository;

  @override
  Future<ApiCart> build() async {
    _repository = ref.watch(cartRepositoryProvider);
    return _fetchCart();
  }

  Future<ApiCart> _fetchCart() async {
    try {
      final cart = await _repository.getCart();
      return cart;
    } catch (e) {
      return const ApiCart(id: '');
    }
  }

  /// Add a course to the cart.
  Future<void> addToCart(String courseId) async {
    final previousState = state;
    state = const AsyncLoading();

    try {
      await _repository.addToCart(courseId);
    } catch (e) {
      // POST failed! Revert state to previous cart so UI state is NOT desynced or wiped.
      state = previousState;
      rethrow;
    }

    // POST to add item succeeded on server! Now fetch the updated cart.
    try {
      final newCart = await _repository.getCart();
      state = AsyncData(newCart);
    } catch (e) {
      debugPrint('⚠️ [CartNotifier] addToCart: item added on backend, but getCart failed: $e');
      // If fetching the updated cart failed due to transient connection drop, retry once.
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final retryCart = await _repository.getCart();
        state = AsyncData(retryCart);
      } catch (_) {
        // Since the course WAS successfully added to the server cart,
        // synthesize/preserve the cart state so UI reflects it accurately without throwing a false error!
        if (previousState.hasValue) {
          final existing = previousState.value!;
          final alreadyPresent = existing.items.any((it) => it.course == courseId || it.id == courseId);
          if (!alreadyPresent) {
            final optimisticItem = ApiCartItem(id: courseId, course: courseId);
            final updatedItems = [...existing.items, optimisticItem];
            state = AsyncData(ApiCart(
              id: existing.id,
              items: updatedItems,
              itemCount: updatedItems.length.toString(),
              total: existing.total,
            ));
          } else {
            state = previousState;
          }
        } else {
          state = AsyncData(ApiCart(
            id: '',
            items: [ApiCartItem(id: courseId, course: courseId)],
            itemCount: '1',
          ));
        }
      }
    }
  }

  /// Remove a course from the cart.
  Future<void> removeFromCart(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.removeFromCart(courseId);
      return _fetchCart();
    });
  }

  /// Clear all items from the cart.
  Future<void> clearCart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.clearCart();
      return _fetchCart();
    });
  }

  /// Step 1: Create Razorpay Order
  Future<Map<String, dynamic>> createRazorpayOrder({
    String? couponCode,
    String? courseId,
    String? ebookId,
  }) async {
    return _repository.createRazorpayOrder(
      couponCode: couponCode,
      courseId: courseId,
      ebookId: ebookId,
    );
  }

  /// Step 3: Verify Razorpay Payment & fulfill order
  Future<Map<String, dynamic>> verifyRazorpayPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.verifyRazorpayPayment(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

      final newCart = await _fetchCart();
      state = AsyncData(newCart);

      // Invalidate enrollments & orders so newly purchased courses show immediately!
      ref.invalidate(studentEnrollmentsProvider);
      ref.invalidate(ordersProvider);

      return result;
    } catch (e) {
      state = await AsyncValue.guard(() => _fetchCart());
      rethrow;
    }
  }

  /// Step 4: Process Apple In-App Purchase & fulfill enrollment
  Future<Map<String, dynamic>> processIosAppleTransaction({
    required String courseId,
    required String productId,
    required String transactionId,
    required String receiptData,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.processIosAppleTransaction(
        courseId: courseId,
        productId: productId,
        transactionId: transactionId,
        receiptData: receiptData,
      );

      final newCart = await _fetchCart();
      state = AsyncData(newCart);

      // Invalidate student enrollments & orders so course activates instantly!
      ref.invalidate(studentEnrollmentsProvider);
      ref.invalidate(ordersProvider);

      return result;
    } catch (e) {
      state = await AsyncValue.guard(() => _fetchCart());
      rethrow;
    }
  }

  /// Checkout the cart or direct single course (legacy/sandbox fallback).
  Future<Map<String, dynamic>> checkout({
    String? paymentMethod,
    String? courseId,
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
    String? cardHolder,
    String? couponCode,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.checkout(
        paymentMethod: paymentMethod,
        courseId: courseId,
        cardNumber: cardNumber,
        cardExpiry: cardExpiry,
        cardCvv: cardCvv,
        cardHolder: cardHolder,
        couponCode: couponCode,
      );

      final newCart = await _fetchCart();
      state = AsyncData(newCart);

      // Invalidate enrollments & orders so newly purchased courses show immediately!
      ref.invalidate(studentEnrollmentsProvider);
      ref.invalidate(ordersProvider);

      return result;
    } catch (e) {
      state = await AsyncValue.guard(() => _fetchCart());
      rethrow;
    }
  }
}
