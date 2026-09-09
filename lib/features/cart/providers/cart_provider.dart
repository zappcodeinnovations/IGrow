import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/order_models.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for CartRepository.
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final appApi = ref.watch(appApiProvider);
  return CartRepository(appApi: appApi);
});

/// AsyncNotifier provider for managing the user's cart state.
final cartProvider = AsyncNotifierProvider<CartNotifier, ApiCart>(() {
  return CartNotifier();
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
      // Return empty cart if not found or on error
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

  /// Checkout the cart.
  Future<void> checkout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.checkout(
        gatewayName: 'sandbox',
        paymentMethod: 'card',
      );
      // After checkout, the cart is cleared by the backend.
      return _fetchCart();
    });
  }
}
