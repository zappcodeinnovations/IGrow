import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../../data/models/api_models/order_models.dart';
import '../../explore/providers/explore_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.directCourseId});

  final String? directCourseId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'UPI'; // 'UPI' | 'CARD' | 'NET_BANKING' | 'SANDBOX'
  String _selectedUpiApp = 'Google Pay';
  String _selectedBank = 'HDFC Bank';

  final _upiController = TextEditingController();
  final _couponController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  bool _isProcessing = false;
  bool _isApplyingCoupon = false;
  String? _couponError;

  @override
  void dispose() {
    _upiController.dispose();
    _couponController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _couponError = 'Please enter a coupon code';
      });
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });

    try {
      final res = await ref.read(cartRepositoryProvider).applyCoupon(
            code,
            courseId: widget.directCourseId,
          );

      // Dynamically extract values returned by backend API
      final discountAmountVal = (res['discount_amount'] as num?)?.toDouble() ??
          (res['discount'] as num?)?.toDouble() ??
          0.0;
      final discountPercentVal = (res['discount_percent'] as num?)?.toDouble() ??
          (res['percent'] as num?)?.toDouble() ??
          0.0;
      final newTotalVal = (res['new_total'] as num?)?.toDouble() ??
          (res['payable_amount'] as num?)?.toDouble() ??
          (res['total'] as num?)?.toDouble();
      final desc = res['message']?.toString() ??
          res['description']?.toString() ??
          res['detail']?.toString() ??
          'Coupon applied successfully!';

      ref.read(appliedCouponProvider.notifier).state = AppliedCoupon(
        code: res['code']?.toString() ?? code,
        discountPercent: discountPercentVal,
        discountAmount: discountAmountVal,
        newTotal: newTotalVal,
        description: desc,
        rawBackendResponse: res,
      );

      if (mounted) {
        setState(() => _couponError = null);
        AppToast.show(context, desc, isError: false);
      }
    } catch (e) {
      if (mounted) {
        final friendlyErr = _formatUserFriendlyError(e);
        setState(() {
          _couponError = friendlyErr;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isApplyingCoupon = false);
      }
    }
  }

  String _formatUserFriendlyError(dynamic error) {
    if (error == null) return 'Something went wrong. Please try again.';
    final raw = error.toString().replaceAll('Exception: ', '').trim();
    final lower = raw.toLowerCase();

    if (lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection abort') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('handshakeexception') ||
        lower.contains('no internet')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'Request timed out. Please check your network and try again.';
    }

    if (lower.contains('matching query does not exist') ||
        lower.contains('not found') ||
        lower.contains('invalid code') ||
        lower.contains('doesnotexist')) {
      return 'Invalid coupon code. Please verify the code and try again.';
    }

    if (lower.contains('expired')) {
      return 'This coupon code has expired.';
    }

    if (lower.contains('already used') || lower.contains('limit reached')) {
      return 'This coupon has already been used or reached its usage limit.';
    }

    if (lower.contains('500') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('server is temporarily') ||
        lower.contains('server error') ||
        lower.contains('internal server')) {
      return 'Server is temporarily unavailable. Please try again in a few moments.';
    }

    if (raw.isNotEmpty && raw.length < 100 && !raw.contains('{') && !raw.contains('StackTrace')) {
      return raw;
    }

    return 'Unable to process request. Please try again.';
  }

  void _removeCoupon() {
    ref.read(appliedCouponProvider.notifier).state = null;
    _couponController.clear();
    setState(() => _couponError = null);
  }

  Future<void> _handlePayment({
    required double originalTotal,
    required double finalTotal,
    required List<dynamic> items,
  }) async {
    setState(() => _isProcessing = true);

    // Snapshot purchased items immediately before async checkout clears cart
    final purchasedItemsSnapshot = List<dynamic>.from(items);

    try {
      final coupon = ref.read(appliedCouponProvider);
      final rawCard = _cardNumberController.text.replaceAll(' ', '');
      final result = await ref.read(cartProvider.notifier).checkout(
            paymentMethod: _selectedPaymentMethod,
            courseId: widget.directCourseId,
            cardNumber: rawCard.isNotEmpty ? rawCard : '4242424242424242',
            cardExpiry: _cardExpiryController.text.isNotEmpty ? _cardExpiryController.text : '12/28',
            cardCvv: _cardCvvController.text.isNotEmpty ? _cardCvvController.text : '123',
            cardHolder: _cardHolderController.text.isNotEmpty ? _cardHolderController.text : 'Kisan Learner',
            couponCode: coupon?.code,
          );

      ref.invalidate(studentEnrollmentsProvider);

      // Dynamically extract values directly from backend order summary payload
      final orderData = (result['order'] is Map)
          ? result['order'] as Map<String, dynamic>
          : result;

      final backendTotal = (orderData['total_amount'] as num?)?.toDouble() ??
          double.tryParse(orderData['total_amount']?.toString() ?? '');
      final backendDiscount = (orderData['discount_amount'] as num?)?.toDouble() ??
          double.tryParse(orderData['discount_amount']?.toString() ?? '');
      final backendItems = orderData['items'] is List ? (orderData['items'] as List) : null;

      final dynamicDiscount = backendDiscount ??
          (coupon != null
              ? (coupon.discountAmount > 0
                  ? coupon.discountAmount
                  : (originalTotal * coupon.discountPercent / 100))
              : (originalTotal - finalTotal).clamp(0.0, double.infinity));

      final dynamicPayable = backendTotal ??
          (originalTotal - dynamicDiscount).clamp(0.0, double.infinity);

      final dynamicItems = (backendItems != null && backendItems.isNotEmpty)
          ? List<dynamic>.from(backendItems)
          : purchasedItemsSnapshot;

      // Persist dynamic checkout state in provider so modal dismissals or rebuilds never reset amounts
      ref.read(lastCheckoutDataProvider.notifier).state = LastCheckoutData(
        orderResult: result,
        originalTotal: originalTotal,
        finalTotal: dynamicPayable,
        discountAmount: dynamicDiscount,
        couponCode: coupon?.code,
        paymentMethod: _selectedPaymentMethod,
        purchasedItems: dynamicItems,
      );

      // Reset active coupon for next order sessions
      ref.read(appliedCouponProvider.notifier).state = null;

      if (mounted) {
        final queryParams = <String, String>{
          'originalTotal': originalTotal.toStringAsFixed(2),
          'finalTotal': dynamicPayable.toStringAsFixed(2),
          'discountAmount': dynamicDiscount.toStringAsFixed(2),
          if (coupon?.code != null) 'couponCode': coupon!.code,
          'paymentMethod': _selectedPaymentMethod,
        };
        final uri = Uri(
          path: RouteNames.paymentSuccess,
          queryParameters: queryParams,
        );

        context.pushReplacement(
          uri.toString(),
          extra: {
            'orderResult': result,
            'originalTotal': originalTotal,
            'finalTotal': dynamicPayable,
            'discountAmount': dynamicDiscount,
            'couponCode': coupon?.code,
            'paymentMethod': _selectedPaymentMethod,
            'purchasedItems': dynamicItems,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        final friendlyErr = _formatUserFriendlyError(e);
        AppToast.show(
          context,
          'Payment failed: $friendlyErr',
          isError: true,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appliedCoupon = ref.watch(appliedCouponProvider);

    // Direct single course buy or cart items
    final isDirectBuy = widget.directCourseId != null && widget.directCourseId!.isNotEmpty;

    if (isDirectBuy) {
      final courseAsync = ref.watch(courseDetailProvider(widget.directCourseId!));
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          title: const Text('Express Checkout'),
          backgroundColor: isDark ? AppColors.bgDark : Colors.white,
          foregroundColor: isDark ? Colors.white : AppColors.inkDark,
        ),
        body: courseAsync.when(
          data: (course) => _buildCheckoutContent(
            context,
            isDark: isDark,
            appliedCoupon: appliedCoupon,
            items: [course],
            originalTotal: double.tryParse(course.price ?? '0') ?? 0.0,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error: $err',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkDark),
              ),
            ),
          ),
        ),
      );
    }

    // Cart items checkout
    final cartState = ref.watch(cartProvider);
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.inkDark,
      ),
      body: cartState.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your cart is empty.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Back to Cart'),
                  ),
                ],
              ),
            );
          }

          final parsedCartTotal = double.tryParse(cart.total ?? '0') ?? 0.0;
          final calculatedCartTotal = cart.items.fold<double>(0.0, (sum, it) {
            final p = double.tryParse(it.courseDetail?['price']?.toString() ?? '') ??
                double.tryParse(it.courseDetail?['discount_price']?.toString() ?? '') ??
                0.0;
            return sum + p;
          });
          final originalTotal = parsedCartTotal > 0 ? parsedCartTotal : calculatedCartTotal;

          return _buildCheckoutContent(
            context,
            isDark: isDark,
            appliedCoupon: appliedCoupon,
            items: cart.items,
            originalTotal: originalTotal,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error: $err',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutContent(
    BuildContext context, {
    required bool isDark,
    required AppliedCoupon? appliedCoupon,
    required List<dynamic> items,
    required double originalTotal,
  }) {
    final double discountAmount;
    final double finalTotal;

    if (appliedCoupon != null) {
      if (appliedCoupon.newTotal != null) {
        finalTotal = appliedCoupon.newTotal!.clamp(0.0, double.infinity);
        discountAmount = (originalTotal - finalTotal).clamp(0.0, double.infinity);
      } else if (appliedCoupon.discountAmount > 0) {
        discountAmount = appliedCoupon.discountAmount.clamp(0.0, originalTotal);
        finalTotal = (originalTotal - discountAmount).clamp(0.0, double.infinity);
      } else if (appliedCoupon.discountPercent > 0) {
        discountAmount = (originalTotal * appliedCoupon.discountPercent / 100).clamp(0.0, originalTotal);
        finalTotal = (originalTotal - discountAmount).clamp(0.0, double.infinity);
      } else {
        discountAmount = 0.0;
        finalTotal = originalTotal;
      }
    } else {
      discountAmount = 0.0;
      finalTotal = originalTotal;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── 1. Sandbox Info Notice ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: AppColors.greenLight, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Razorpay Sandbox Active: This is a secure simulation. Instant course enrollment will be granted upon payment.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── 2. Order Items Review ──────────────────────────────
              Text(
                'Order Summary (${items.length} ${items.length == 1 ? "Item" : "Items"})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              const SizedBox(height: 10),

              ...items.map((item) {
                String title = 'Course';
                String price = '0.00';
                String instructor = 'IGrow Faculty';

                if (item is ApiCourseDetail) {
                  title = item.title;
                  price = item.price ?? '0.00';
                  instructor = item.instructorName ?? 'IGrow Faculty';
                } else if (item is ApiCartItem) {
                  title = item.courseDetail?['title']?.toString() ??
                      item.courseDetail?['name']?.toString() ??
                      'Course';
                  price = item.courseDetail?['price']?.toString() ?? '0.00';
                  instructor = item.courseDetail?['instructor_name']?.toString() ??
                      'IGrow Faculty';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: isDark ? const Color(0xFF1E2E23) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: AppColors.greenLight, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'By $instructor',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹$price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 18),

              // ── 3. Coupon & Promo Code Engine ──────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2E23) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined,
                            size: 18, color: AppColors.accentOrange),
                        const SizedBox(width: 8),
                        Text(
                          'Have a Coupon Code?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.inkDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (appliedCoupon == null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (value) {
                                if (_couponError != null) {
                                  setState(() => _couponError = null);
                                }
                              },
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.inkDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter code (e.g. AG10, AGRI10)',
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white38 : AppColors.inkSoft,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                errorText: _couponError,
                                errorMaxLines: 3,
                                errorStyle: const TextStyle(
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(80, 48),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _isApplyingCoupon ? null : _applyCoupon,
                            child: _isApplyingCoupon
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter a promotional coupon code to apply an instant discount.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppColors.inkSoft,
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.greenLight, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coupon "${appliedCoupon.code}" Applied!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    appliedCoupon.discountPercent > 0
                                        ? 'Saved ₹${discountAmount.toStringAsFixed(2)} (${appliedCoupon.discountPercent.toInt()}%)'
                                        : 'Saved ₹${discountAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: Colors.redAccent),
                              onPressed: _removeCoupon,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── 4. Payment Method Selector ─────────────────────────
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              const SizedBox(height: 12),

              _buildPaymentOption(
                value: 'UPI',
                title: 'UPI (Instant)',
                subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
                icon: Icons.qr_code_2_rounded,
                isDark: isDark,
              ),
              if (_selectedPaymentMethod == 'UPI') ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 14),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Google Pay', 'PhonePe', 'Paytm', 'BHIM']
                            .map((app) => ChoiceChip(
                                  label: Text(
                                    app,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _selectedUpiApp == app
                                          ? Colors.white
                                          : (isDark ? Colors.white70 : AppColors.inkDark),
                                    ),
                                  ),
                                  selected: _selectedUpiApp == app,
                                  selectedColor: AppColors.primaryGreen,
                                  backgroundColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade100,
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedUpiApp = app);
                                  },
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _upiController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
                        decoration: InputDecoration(
                          labelText: 'Virtual Payment Address (VPA / UPI ID)',
                          hintText: 'e.g. yourname@okaxis',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              _buildPaymentOption(
                value: 'CARD',
                title: 'Credit / Debit Card',
                subtitle: 'Visa, MasterCard, RuPay',
                icon: Icons.credit_card_rounded,
                isDark: isDark,
              ),
              if (_selectedPaymentMethod == 'CARD') ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 14),
                  child: Column(
                    children: [
                      TextField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: '4242 4242 4242 4242',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                          ),
                          prefixIcon: const Icon(Icons.credit_card, color: AppColors.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cardExpiryController,
                              style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
                              decoration: InputDecoration(
                                labelText: 'Expiry (MM/YY)',
                                hintText: '12/28',
                                labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _cardCvvController,
                              obscureText: true,
                              style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              _buildPaymentOption(
                value: 'NET_BANKING',
                title: 'Net Banking',
                subtitle: 'SBI, HDFC, ICICI, Axis Bank',
                icon: Icons.account_balance_rounded,
                isDark: isDark,
              ),
              if (_selectedPaymentMethod == 'NET_BANKING') ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['HDFC Bank', 'SBI', 'ICICI Bank', 'Axis Bank', 'PNB']
                        .map((bank) => ChoiceChip(
                              label: Text(
                                bank,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedBank == bank
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : AppColors.inkDark),
                                ),
                              ),
                              selected: _selectedBank == bank,
                              selectedColor: AppColors.primaryGreen,
                              backgroundColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade100,
                              onSelected: (val) {
                                if (val) setState(() => _selectedBank = bank);
                              },
                            ))
                        .toList(),
                  ),
                ),
              ],

              _buildPaymentOption(
                value: 'SANDBOX',
                title: '1-Tap Simulator',
                subtitle: 'Instant test purchase (100% success)',
                icon: Icons.bolt_rounded,
                isDark: isDark,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        // ── Bottom Price & Pay Button Bar ────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A271E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF2E4334) : AppColors.lineLight,
                width: 1,
              ),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                      ),
                    ),
                    Text(
                      '₹${originalTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                  ],
                ),
                if (discountAmount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Coupon Discount (${appliedCoupon?.code}):',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        '-₹${discountAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Platform & GST (0%):',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.inkSoft,
                      ),
                    ),
                    Text(
                      '₹0.00',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 20,
                  color: isDark ? const Color(0xFF2E4334) : AppColors.lineLight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Grand Total',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.inkSoft,
                            ),
                          ),
                          FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹${finalTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 6,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.lock, color: Colors.white, size: 18),
                        label: Text(
                          _isProcessing
                              ? 'Processing...'
                              : 'Pay Now ₹${finalTotal.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () => _handlePayment(
                                  originalTotal: originalTotal,
                                  finalTotal: finalTotal,
                                  items: items,
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? (isDark ? AppColors.greenLight : AppColors.primaryGreen)
              : (isDark ? const Color(0xFF334A3A) : AppColors.lineLight),
          width: isSelected ? 2 : 1.2,
        ),
      ),
      color: isSelected
          ? (isDark
              ? AppColors.primaryGreen.withValues(alpha: 0.15)
              : AppColors.primaryGreen.withValues(alpha: 0.08))
          : (isDark ? const Color(0xFF1E2E23) : Colors.white),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _selectedPaymentMethod = value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? (isDark ? AppColors.greenLight : AppColors.primaryGreen)
                    : (isDark ? Colors.white70 : AppColors.inkSoft),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? (isDark ? AppColors.greenLight : AppColors.primaryGreen)
                    : (isDark ? Colors.white38 : AppColors.inkSoft),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
