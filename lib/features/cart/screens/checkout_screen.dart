import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/network/swagger_generated/app_api.swagger.dart' show EBook;
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/apple_iap_service.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../../data/models/api_models/order_models.dart';
import '../../../core/services/app_config_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../explore/providers/explore_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    this.directCourseId,
    this.directEbookId,
  });

  final String? directCourseId;
  final String? directEbookId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late Razorpay _razorpay;

  final _couponController = TextEditingController();
  bool _isProcessing = false;
  bool _isApplyingCoupon = false;
  String? _couponError;

  // Cached order snapshot while payment sheet is open
  double _lastOriginalTotal = 0.0;
  double _lastFinalTotal = 0.0;
  double _lastDiscountAmount = 0.0;
  List<dynamic> _lastItemsSnapshot = [];
  String? _lastCouponCode;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(appliedCouponProvider.notifier).state = null;
      }
    });
  }

  @override
  void didUpdateWidget(CheckoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.directCourseId != widget.directCourseId ||
        oldWidget.directEbookId != widget.directEbookId) {
      ref.read(appliedCouponProvider.notifier).state = null;
      _couponController.clear();
      _couponError = null;
      _lastOriginalTotal = 0.0;
      _lastFinalTotal = 0.0;
      _lastDiscountAmount = 0.0;
      _lastItemsSnapshot = [];
      _lastCouponCode = null;
    }
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  // ─── Razorpay Callbacks ───────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('🎉 [Razorpay] Payment SUCCESS: paymentId=${response.paymentId}, orderId=${response.orderId}');
    final paymentId = response.paymentId;
    final orderId = response.orderId;
    final signature = response.signature;

    if (paymentId == null || orderId == null || signature == null) {
      if (mounted) {
        setState(() => _isProcessing = false);
        AppToast.show(
          context,
          'Payment successful, but missing verification details. Please contact support.',
          isError: true,
        );
      }
      return;
    }

    try {
      if (mounted) setState(() => _isProcessing = true);

      // Step 3: Verify payment with backend
      final verifyResult = await ref.read(cartProvider.notifier).verifyRazorpayPayment(
            paymentId: paymentId,
            orderId: orderId,
            signature: signature,
          );

      // Invalidate enrollments, orders, and clear cart if checking out cart
      ref.invalidate(studentEnrollmentsProvider);
      ref.invalidate(ordersProvider);
      if (widget.directCourseId != null) {
        ref.invalidate(courseDetailProvider(widget.directCourseId!));
      } else {
        await ref.read(cartProvider.notifier).clearCart();
      }

      _completeOrderSuccess(
        result: verifyResult,
        paymentMethodName: 'Razorpay',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        final friendlyErr = _formatPaymentError(e);
        AppToast.show(
          context,
          'Payment verification failed: $friendlyErr. If money was debited, your enrollment will reflect shortly.',
          isError: true,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ [Razorpay] Payment ERROR: code=${response.code}, message=${response.message}');
    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Code 2 is user cancelled
    final isCancelled = response.code == Razorpay.PAYMENT_CANCELLED ||
        (response.message != null && response.message!.toLowerCase().contains('cancelled'));

    if (isCancelled) {
      AppToast.show(
        context,
        'Payment was cancelled. You can retry whenever ready.',
        isError: false,
      );
    } else {
      String message = 'Payment could not be completed. Please try again.';
      if (response.code == Razorpay.NETWORK_ERROR) {
        message = 'Network connection problem during payment. Please check your internet.';
      } else if (response.message != null && response.message!.trim().isNotEmpty) {
        message = response.message!.trim();
      }
      AppToast.show(
        context,
        message,
        isError: true,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('👛 [Razorpay] External Wallet Selected: ${response.walletName}');
    if (mounted) {
      AppToast.show(
        context,
        'Redirecting to ${response.walletName ?? "Wallet"}...',
        isError: false,
      );
    }
  }

  // ─── Payment Initiation Flow ──────────────────────────────────────

  Future<void> _startPaymentFlow({
    required double originalTotal,
    required double finalTotal,
    required double discountAmount,
    required List<dynamic> items,
  }) async {
    setState(() => _isProcessing = true);

    // Snapshot order details
    _lastOriginalTotal = originalTotal;
    _lastFinalTotal = finalTotal;
    _lastDiscountAmount = discountAmount;
    _lastItemsSnapshot = List<dynamic>.from(items);
    _lastCouponCode = ref.read(appliedCouponProvider)?.code;

    try {
      // Step 1: Create Order via Backend
      final orderData = await ref.read(cartProvider.notifier).createRazorpayOrder(
            couponCode: _lastCouponCode,
            courseId: widget.directCourseId,
            ebookId: widget.directEbookId,
          );

      debugPrint('📦 [Razorpay] createRazorpayOrder response: $orderData');

      final status = orderData['status']?.toString().toUpperCase();

      // Scenario B: 100% Discount / Free Order
      if (status == 'FREE_ENROLLED') {
        ref.invalidate(studentEnrollmentsProvider);
        ref.invalidate(ordersProvider);
        if (widget.directCourseId == null) {
          await ref.read(cartProvider.notifier).clearCart();
        }

        _completeOrderSuccess(
          result: orderData,
          paymentMethodName: '100% Discount Coupon',
        );
        return;
      }

      // Scenario A: Payment Required
      final razorpayOrderId = orderData['razorpay_order_id']?.toString();
      final keyId = orderData['key_id']?.toString();
      final amount = orderData['amount'];

      if (razorpayOrderId == null || keyId == null || amount == null) {
        throw Exception('Invalid payment order details received from server.');
      }

      // Prefill user details
      final user = ref.read(authProvider).user;
      final phone = user?.phone ?? '';
      final email = user?.email ?? '';
      final userName = user?.fullName ?? 'Krishi Learner';

      final descriptionText = items.length == 1
          ? _getItemTitle(items.first)
          : '${items.length} Courses/Materials Purchase';

      final options = {
        'key': keyId,
        'amount': amount,
        'name': 'KrishiShiksha (iAgrow)',
        'description': descriptionText,
        'order_id': razorpayOrderId,
        'prefill': {
          'contact': phone,
          'email': email,
          'name': userName,
        },
        'theme': {
          'color': '#4B9C0A', // iAgrow brand green
        },
        'send_sms_hash': true,
        'retry': {'enabled': true, 'max_count': 2},
      };

      // Check if Razorpay is enabled for this platform/config
      final canShowRazorpay = ref.read(appConfigProvider).canShowPaymentGateway;
      if (!canShowRazorpay && !kIsWeb && Platform.isIOS) {
        // Razorpay is disabled on iOS for App Store review. Execute Apple In-App Purchase flow!
        await _startAppleIapFlow(items: items);
        return;
      }

      debugPrint('🚀 [Razorpay] Launching native checkout UI...');
      _razorpay.open(options);

      // Reset local spinner so screen remains responsive
      if (mounted) setState(() => _isProcessing = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        final friendlyErr = _formatPaymentError(e);
        AppToast.show(
          context,
          'Unable to initiate payment: $friendlyErr',
          isError: true,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  /// Apple In-App Purchase Flow (StoreKit) for iOS App Store compliance
  Future<void> _startAppleIapFlow({required List<dynamic> items}) async {
    try {
      debugPrint('🍏 [CheckoutScreen] Starting Apple IAP flow...');
      String targetCourseId = '';
      if (widget.directCourseId != null && widget.directCourseId!.isNotEmpty) {
        targetCourseId = widget.directCourseId!;
      } else if (items.isNotEmpty) {
        targetCourseId = _getItemCourseId(items.first);
      }

      if (targetCourseId.isEmpty) {
        throw Exception('No course selected for purchase.');
      }

      const String productId = AppleIapService.defaultProductId; // com.zappkode.igrow.tier1

      // 1. Launch StoreKit In-App Purchase sheet
      final purchaseDetails = await AppleIapService.instance.buyProduct(productId: productId);
      final transactionId = purchaseDetails.purchaseID ?? DateTime.now().millisecondsSinceEpoch.toString();
      final receiptData = AppleIapService.instance.extractReceiptData(purchaseDetails);

      debugPrint('🍏 [CheckoutScreen] IAP bought successfully: txId=$transactionId, receipt length=${receiptData.length}');

      // 2. Post receipt & transaction to backend
      final result = await ref.read(cartProvider.notifier).processIosAppleTransaction(
            courseId: targetCourseId,
            productId: productId,
            transactionId: transactionId,
            receiptData: receiptData,
          );

      debugPrint('🎉 [CheckoutScreen] Backend Apple IAP confirmation result: $result');

      // 3. Clear cart if cart checkout
      if (widget.directCourseId == null) {
        await ref.read(cartProvider.notifier).clearCart();
      }

      if (mounted) {
        setState(() => _isProcessing = false);
      }

      // 4. Complete order
      _completeOrderSuccess(
        result: result,
        paymentMethodName: 'Apple In-App Purchase',
      );
    } catch (e) {
      debugPrint('❌ [CheckoutScreen] Apple IAP flow error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        final errText = e.toString().replaceAll('Exception: ', '').replaceAll('UnsupportedError: ', '');
        AppToast.show(
          context,
          'Apple Purchase error: $errText',
          isError: true,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _completeOrderSuccess({
    required Map<String, dynamic> result,
    required String paymentMethodName,
  }) {
    ref.read(lastCheckoutDataProvider.notifier).state = LastCheckoutData(
      orderResult: result,
      originalTotal: _lastOriginalTotal,
      finalTotal: _lastFinalTotal,
      discountAmount: _lastDiscountAmount,
      couponCode: _lastCouponCode,
      paymentMethod: paymentMethodName,
      purchasedItems: _lastItemsSnapshot,
    );

    // Reset applied coupon for next session
    ref.read(appliedCouponProvider.notifier).state = null;

    if (mounted) {
      final queryParams = <String, String>{
        'originalTotal': _lastOriginalTotal.toStringAsFixed(2),
        'finalTotal': _lastFinalTotal.toStringAsFixed(2),
        'discountAmount': _lastDiscountAmount.toStringAsFixed(2),
        if (_lastCouponCode != null) 'couponCode': _lastCouponCode!,
        'paymentMethod': paymentMethodName,
      };

      final uri = Uri(
        path: RouteNames.paymentSuccess,
        queryParameters: queryParams,
      );

      context.pushReplacement(
        uri.toString(),
        extra: {
          'orderResult': result,
          'originalTotal': _lastOriginalTotal,
          'finalTotal': _lastFinalTotal,
          'discountAmount': _lastDiscountAmount,
          'couponCode': _lastCouponCode,
          'paymentMethod': paymentMethodName,
          'purchasedItems': _lastItemsSnapshot,
        },
      );
    }
  }

  // ─── Coupon Engine ────────────────────────────────────────────────

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

  void _removeCoupon() {
    ref.read(appliedCouponProvider.notifier).state = null;
    _couponController.clear();
    setState(() => _couponError = null);
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
        lower.contains('doesnotexist') ||
        lower.contains('invalid coupon')) {
      return 'Invalid coupon code. Try AGRI10 or KISAN50';
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

  String _formatPaymentError(dynamic error) {
    if (error == null) return 'Something went wrong. Please try again.';
    final raw = error.toString().replaceAll('Exception: ', '').trim();
    final lower = raw.toLowerCase();

    if (lower.contains('no internet') || lower.contains('socketexception') || lower.contains('failed host lookup')) {
      return 'No internet connection. Please check your network.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'Payment request timed out. Please try again.';
    }
    if (lower.contains('signature') || lower.contains('tampered')) {
      return 'Payment verification failed. Please contact support.';
    }
    if (lower.contains('api credentials') || lower.contains('verify api credentials')) {
      return 'Server error: Razorpay API credentials on backend are unverified or missing.';
    }
    if (lower.contains('server is temporarily') || lower.contains('500') || lower.contains('502')) {
      return 'Payment server is busy. Please try again in a moment.';
    }
    if (raw.isNotEmpty && raw.length < 150 && !raw.contains('{') && !raw.contains('StackTrace')) {
      return raw;
    }
    return 'Payment could not be processed. Please try again.';
  }

  String _getItemTitle(dynamic item) {
    if (item is ApiCourseDetail) return item.title;
    if (item is EBook) return item.title;
    if (item is ApiCartItem) {
      return item.courseDetail?['title']?.toString() ??
          item.courseDetail?['name']?.toString() ??
          'Course';
    }
    if (item is Map) return item['title']?.toString() ?? 'Item';
    return 'Course';
  }

  String _getItemPrice(dynamic item) {
    if (item is ApiCourseDetail) return item.price ?? '0.00';
    if (item is EBook) {
      final json = item.toJson();
      return json['price']?.toString() ?? json['discount_price']?.toString() ?? '0.00';
    }
    if (item is ApiCartItem) {
      return item.courseDetail?['price']?.toString() ??
          item.courseDetail?['discount_price']?.toString() ??
          '0.00';
    }
    if (item is Map) return item['price']?.toString() ?? '0.00';
    return '0.00';
  }

  String _getItemInstructor(dynamic item) {
    if (item is ApiCourseDetail) return item.instructorName ?? 'iAgrow Faculty';
    if (item is EBook) return item.instructorName ?? item.authorName;
    if (item is ApiCartItem) {
      return item.courseDetail?['instructor_name']?.toString() ?? 'iAgrow Faculty';
    }
    if (item is Map) return item['instructor_name']?.toString() ?? item['author_name']?.toString() ?? 'iAgrow Faculty';
    return 'iAgrow Faculty';
  }

  String _getItemCourseId(dynamic item) {
    if (widget.directCourseId != null && widget.directCourseId!.isNotEmpty) {
      return widget.directCourseId!;
    }
    if (item is ApiCourseDetail) return item.id;
    if (item is ApiCartItem) return item.course;
    if (item is Map) {
      return item['course_id']?.toString() ??
          item['course']?.toString() ??
          item['id']?.toString() ??
          '';
    }
    return '';
  }

  // ─── Build UI ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appliedCoupon = ref.watch(appliedCouponProvider);
    final isDirectBuy = widget.directCourseId != null && widget.directCourseId!.isNotEmpty;

    // Direct single course buy
    if (isDirectBuy) {
      final courseAsync = ref.watch(courseDetailProvider(widget.directCourseId!));
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF6F9F3),
        appBar: AppBar(
          title: const Text(
            'Secure Checkout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? AppColors.bgDark : Colors.white,
          foregroundColor: isDark ? Colors.white : AppColors.inkDark,
          elevation: 0,
          centerTitle: false,
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
                'Error loading course: $err',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkDark),
              ),
            ),
          ),
        ),
      );
    }

    // Direct single ebook buy
    final isDirectEbookBuy = widget.directEbookId != null && widget.directEbookId!.isNotEmpty;
    if (isDirectEbookBuy) {
      final ebookAsync = ref.watch(ebookDetailProvider(widget.directEbookId!));
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF6F9F3),
        appBar: AppBar(
          title: const Text(
            'E-Book Checkout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? AppColors.bgDark : Colors.white,
          foregroundColor: isDark ? Colors.white : AppColors.inkDark,
          elevation: 0,
          centerTitle: false,
        ),
        body: ebookAsync.when(
          data: (ebook) {
            final rawPrice = ebook.toJson()['price']?.toString() ??
                ebook.toJson()['discount_price']?.toString() ??
                '0.00';
            final parsedPrice = double.tryParse(rawPrice) ?? 0.0;
            return _buildCheckoutContent(
              context,
              isDark: isDark,
              appliedCoupon: appliedCoupon,
              items: [ebook],
              originalTotal: parsedPrice,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error loading e-book: $err',
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
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF6F9F3),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.inkDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: cartState.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 54,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore our wide range of agriculture courses and study materials.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Explore Courses'),
                    ),
                  ],
                ),
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
              'Error loading cart: $err',
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

    final is100PercentFree = finalTotal <= 0.001;
    final appConfig = ref.watch(appConfigProvider);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── 1. Highlighted Trust & Security Banner ────────────
              _buildSecurityHeaderBanner(isDark),

              const SizedBox(height: 16),

              // ── 2. Order Items Review Card ────────────────────────
              _buildOrderItemsSection(items, isDark),

              // ── 3. Coupon & Promo Code Engine (hidden if disabled) ─
              if (appConfig.canShowCoupons) ...[
                const SizedBox(height: 16),
                _buildCouponSection(appliedCoupon, discountAmount, isDark),
              ],

              const SizedBox(height: 16),

              // ── 4. Payment Gateway Methods Showcase ─
              _buildPaymentGatewayShowcase(isDark, is100PercentFree),

              const SizedBox(height: 16),

              // ── 5. Detailed Bill Summary ──────────────────────────
              _buildBillSummaryCard(
                originalTotal: originalTotal,
                discountAmount: discountAmount,
                finalTotal: finalTotal,
                appliedCoupon: appliedCoupon,
                isDark: isDark,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── 6. Bottom Sticky Pay Bar ────────────────────────────────
        _buildBottomStickyBar(
          originalTotal: originalTotal,
          finalTotal: finalTotal,
          discountAmount: discountAmount,
          items: items,
          is100PercentFree: is100PercentFree,
          isDark: isDark,
        ),
      ],
    );
  }

  // ─── Sub-widgets ──────────────────────────────────────────────────

  Widget _buildSecurityHeaderBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2E23), const Color(0xFF16231A)]
              : [const Color(0xFFEBF6E4), const Color(0xFFF7FCF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '100% Secure Checkout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.greenDark,
                      ),
                    ),
                    if (ref.watch(appConfigProvider).canShowPaymentGateway) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'RAZORPAY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ] else if (!kIsWeb && Platform.isIOS) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF333333) : const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'APPLE PAY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'End-to-end encrypted • Instant course activation upon successful payment.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(List<dynamic> items, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E23) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE2EADF),
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Items (${items.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  items.length == 1 ? 'Single Course' : 'Multiple Courses',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFECEFE8)),
          const SizedBox(height: 12),
          ...items.map((item) {
            final title = _getItemTitle(item);
            final price = _getItemPrice(item);
            final instructor = _getItemInstructor(item);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withValues(alpha: 0.25),
                          AppColors.greenLight.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.inkDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              size: 13,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                instructor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : AppColors.inkSoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹$price',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCouponSection(AppliedCoupon? appliedCoupon, double discountAmount, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E23) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE2EADF),
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  size: 16,
                  color: AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Have a Coupon Code?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
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
                        color: isDark ? Colors.white38 : AppColors.inkSoft.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF14201A) : const Color(0xFFF9FBF7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334A3A) : const Color(0xFFD4DFCF),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334A3A) : const Color(0xFFD4DFCF),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    minimumSize: const Size(82, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.18 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupon "${appliedCoupon.code}" Applied!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.greenLight : AppColors.greenDark,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appliedCoupon.discountPercent > 0
                              ? 'Saved ₹${discountAmount.toStringAsFixed(2)} (${appliedCoupon.discountPercent.toInt()}%)'
                              : 'Saved ₹${discountAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.redAccent),
                    tooltip: 'Remove Coupon',
                    onPressed: _removeCoupon,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentGatewayShowcase(bool isDark, bool is100PercentFree) {
    if (is100PercentFree) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.celebration_rounded, color: AppColors.primaryGreen, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '100% Free Enrollment Activated',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.greenDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No payment needed! Click below to enroll instantly.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isRazorpayEnabled = ref.watch(appConfigProvider).canShowPaymentGateway;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E23) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE2EADF),
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    isRazorpayEnabled ? 'Razorpay Gateway' : 'Apple Pay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14201A) : const Color(0xFFF9FCF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE0EAD9),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isRazorpayEnabled
                            ? Icons.account_balance_wallet_rounded
                            : Icons.apple_rounded,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRazorpayEnabled
                                ? 'All Major Payment Modes Supported'
                                : 'Apple Pay Express Checkout',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.inkDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRazorpayEnabled
                                ? 'Select your preferred mode inside the official Razorpay sheet:'
                                : 'Fast, easy and secure payment with Face ID or Touch ID.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white60 : AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isRazorpayEnabled) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPaymentPill(Icons.qr_code_2_rounded, 'UPI (GPay, PhonePe, Paytm)', isDark),
                      _buildPaymentPill(Icons.credit_card_rounded, 'Cards (Visa, Master, RuPay)', isDark),
                      _buildPaymentPill(Icons.account_balance_rounded, 'Net Banking (50+ Banks)', isDark),
                      _buildPaymentPill(Icons.wallet_rounded, 'Wallets', isDark),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPaymentPill(Icons.apple_rounded, 'Apple Pay', isDark),
                      _buildPaymentPill(Icons.security_rounded, 'Touch ID / Face ID', isDark),
                      _buildPaymentPill(Icons.credit_card_rounded, 'Saved Cards', isDark),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPill(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E23) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334A3A) : const Color(0xFFD6E2D0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.inkDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard({
    required double originalTotal,
    required double discountAmount,
    required double finalTotal,
    required AppliedCoupon? appliedCoupon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E23) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE2EADF),
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow('Subtotal', '₹${originalTotal.toStringAsFixed(2)}', isDark: isDark),
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              'Coupon Discount (${appliedCoupon?.code ?? "Applied"})',
              '-₹${discountAmount.toStringAsFixed(2)}',
              isDark: isDark,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 8),
          _buildBillRow(
            'Platform & Processing Fee',
            'FREE',
            isDark: isDark,
            isFree: true,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFECEFE8)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              Text(
                '₹${finalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    required bool isDark,
    bool isDiscount = false,
    bool isFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : AppColors.inkSoft,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isDiscount || isFree ? FontWeight.bold : FontWeight.w600,
            color: isDiscount || isFree
                ? (isDark ? AppColors.greenLight : AppColors.primaryGreen)
                : (isDark ? Colors.white : AppColors.inkDark),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStickyBar({
    required double originalTotal,
    required double finalTotal,
    required double discountAmount,
    required List<dynamic> items,
    required bool is100PercentFree,
    required bool isDark,
  }) {
    final buttonLabel = _isProcessing
        ? 'Processing...'
        : (is100PercentFree ? 'Enroll for Free' : 'Pay ₹${finalTotal.toStringAsFixed(2)} Securely');

    return Container(
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
            color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE2EADF),
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    : Icon(
                        is100PercentFree ? Icons.check_circle_outline_rounded : Icons.lock_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                label: Text(
                  buttonLabel,
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
                    : () => _startPaymentFlow(
                          originalTotal: originalTotal,
                          finalTotal: finalTotal,
                          discountAmount: discountAmount,
                          items: items,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
