import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/order_models.dart';
import 'package:krushi_siksha/features/cart/providers/cart_provider.dart';

void main() {
  group('E-Book Cart Status Tests', () {
    test('isEbookInCartProvider returns false for second ebook when cart only contains a course and first ebook', () async {
      final courseItem = ApiCartItem(
        id: 'cart-item-1',
        course: 'course-uuid-499',
        courseDetail: {'id': 'course-uuid-499', 'title': 'चंदन लागवडीसाठी योग्य होस्ट वनस्पतींची निवड'},
        ebook: null,
        ebookDetail: null,
        itemType: 'course',
      );

      final firstEbookItem = ApiCartItem(
        id: 'cart-item-2',
        course: '',
        ebook: 'ebook-uuid-599',
        ebookDetail: {'id': 'ebook-uuid-599', 'title': 'हळद शेती'},
        itemType: 'ebook',
      );

      final cart = ApiCart(
        id: 'cart-123',
        items: [courseItem, firstEbookItem],
        total: '1098.00',
        itemCount: '2',
      );

      final container = ProviderContainer(
        overrides: [
          cartProvider.overrideWith(() => _StaticCartNotifier(cart)),
        ],
      );

      // Wait for cart notifier future to complete
      await container.read(cartProvider.future);

      // First ebook is in cart
      expect(container.read(isEbookInCartProvider('ebook-uuid-599')), isTrue);

      // Second ebook (different id) is NOT in cart
      expect(container.read(isEbookInCartProvider('ebook-uuid-499')), isFalse);

      // Course id is NOT an ebook in cart
      expect(container.read(isEbookInCartProvider('course-uuid-499')), isFalse);

      // Empty target returns false without matching null/empty
      expect(container.read(isEbookInCartProvider('')), isFalse);
    });
  });
}

class _StaticCartNotifier extends CartNotifier {
  final ApiCart _cart;
  _StaticCartNotifier(this._cart);

  @override
  Future<ApiCart> build() async => _cart;
}
