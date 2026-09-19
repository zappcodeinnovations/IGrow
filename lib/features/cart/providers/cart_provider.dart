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

/// Model representing an applied discount coupon.
class AppliedCoupon {
  const AppliedCoupon({
    required this.code,
    required this.discountPercent,
    required this.description,
  });

  final String code;
  final double discountPercent;
  final String description;
}

/// State provider for tracking the currently applied coupon.
final appliedCouponProvider = StateProvider<AppliedCoupon?>((ref) => null);

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
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.maybeWhen(
    data: (cart) => cart.items.any((item) {
      final matchesCourseId = item.course == courseIdOrSlug || item.id == courseIdOrSlug;
      final matchesDetailId = item.courseDetail?['id']?.toString() == courseIdOrSlug;
      final matchesDetailSlug = item.courseDetail?['slug']?.toString() == courseIdOrSlug;
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
    state = const AsyncLoading();
    try {
      await _repository.addToCart(courseId);
      final newCart = await _repository.getCart();
      state = AsyncData(newCart);
    } catch (e) {
      state = await AsyncValue.guard(() => _fetchCart());
      rethrow;
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

  /// Checkout the cart or direct single course.
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
