import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../../data/models/api_models/order_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class CheckoutSuccessScreen extends ConsumerStatefulWidget {
  const CheckoutSuccessScreen({
    super.key,
    required this.orderResult,
    required this.originalTotal,
    required this.finalTotal,
    this.discountAmount = 0.0,
    this.couponCode,
    required this.paymentMethod,
    required this.purchasedItems,
  });

  final Map<String, dynamic> orderResult;
  final double originalTotal;
  final double finalTotal;
  final double discountAmount;
  final String? couponCode;
  final String paymentMethod;
  final List<dynamic> purchasedItems;

  @override
  ConsumerState<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends ConsumerState<CheckoutSuccessScreen> {
  late Map<String, dynamic> _orderResult;
  late double _originalTotal;
  late double _finalTotal;
  late double _discountAmount;
  late String? _couponCode;
  late String _paymentMethod;
  late List<dynamic> _purchasedItems;

  @override
  void initState() {
    super.initState();
    _orderResult = Map<String, dynamic>.from(widget.orderResult);
    _originalTotal = widget.originalTotal;
    _finalTotal = widget.finalTotal;
    _discountAmount = widget.discountAmount;
    _couponCode = widget.couponCode;
    _paymentMethod = widget.paymentMethod;
    _purchasedItems = List<dynamic>.from(widget.purchasedItems);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithSavedState();
  }

  @override
  void didUpdateWidget(CheckoutSuccessScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Never overwrite valid non-zero values with 0.0 when GoRouter rebuilds after modal pop
    if (widget.finalTotal > 0) {
      _finalTotal = widget.finalTotal;
    }
    if (widget.originalTotal > 0) {
      _originalTotal = widget.originalTotal;
    }
    if (widget.purchasedItems.isNotEmpty) {
      _purchasedItems = List<dynamic>.from(widget.purchasedItems);
    }
    if (widget.orderResult.isNotEmpty) {
      _orderResult = Map<String, dynamic>.from(widget.orderResult);
    }
    if (widget.couponCode != null) {
      _couponCode = widget.couponCode;
    }
    if (widget.paymentMethod.isNotEmpty && widget.paymentMethod != 'DUMMY_CARD') {
      _paymentMethod = widget.paymentMethod;
    }
    _syncWithSavedState();
  }

  static (String title, String id, String price) extractItemInfo(dynamic item) {
    if (item is ApiCourseDetail) {
      return (item.title, item.id, item.price ?? '0.00');
    } else if (item is ApiCartItem) {
      final title = item.courseDetail?['title']?.toString() ??
          item.courseDetail?['name']?.toString() ??
          'Course';
      final price = item.courseDetail?['price']?.toString() ??
          item.courseDetail?['discount_price']?.toString() ??
          '0.00';
      return (title, item.course, price);
    } else if (item is ApiOrderItem) {
      final title = item.courseTitle ?? 'Course';
      final courseId = item.course ?? item.id;
      final price = item.priceAtPurchase;
      return (title, courseId, price);
    } else if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final title = map['course_title']?.toString() ??
          map['title']?.toString() ??
          map['name']?.toString() ??
          (map['course_detail'] is Map
              ? (map['course_detail']['title']?.toString() ?? map['course_detail']['name']?.toString())
              : null) ??
          'Course';
      final courseId = map['course']?.toString() ??
          map['course_id']?.toString() ??
          map['id']?.toString() ??
          '';
      final price = map['price_at_purchase']?.toString() ??
          map['price']?.toString() ??
          (map['course_detail'] is Map ? map['course_detail']['price']?.toString() : null) ??
          '0.00';
      return (title, courseId, price);
    }
    if (item is String) {
      return (item, '', '0.00');
    }
    return ('Course', '', '0.00');
  }

  void _syncWithSavedState() {
    final saved = ref.read(lastCheckoutDataProvider);
    if (saved != null) {
      if (_finalTotal <= 0 && saved.finalTotal > 0) {
        _finalTotal = saved.finalTotal;
      }
      if (_originalTotal <= 0 && saved.originalTotal > 0) {
        _originalTotal = saved.originalTotal;
      }
      if (_purchasedItems.isEmpty && saved.purchasedItems.isNotEmpty) {
        _purchasedItems = List<dynamic>.from(saved.purchasedItems);
      }
      if (_orderResult.isEmpty && saved.orderResult.isNotEmpty) {
        _orderResult = Map<String, dynamic>.from(saved.orderResult);
      }
      if (_couponCode == null && saved.couponCode != null) {
        _couponCode = saved.couponCode;
      }
      if (_discountAmount <= 0 && saved.discountAmount > 0) {
        _discountAmount = saved.discountAmount;
      }
    }

    // Also fallback to backend order object inside _orderResult
    final orderMap = _orderResult['order'] is Map
        ? _orderResult['order'] as Map<String, dynamic>
        : _orderResult;

    if (_purchasedItems.isEmpty && orderMap['items'] is List && (orderMap['items'] as List).isNotEmpty) {
      _purchasedItems = List<dynamic>.from(orderMap['items'] as List);
    } else if (_purchasedItems.isEmpty && _orderResult['enrolled_courses'] is List && (_orderResult['enrolled_courses'] as List).isNotEmpty) {
      _purchasedItems = List<dynamic>.from(_orderResult['enrolled_courses'] as List);
    }

    if (orderMap['discount_amount'] != null) {
      final backendDiscount = double.tryParse(orderMap['discount_amount'].toString()) ?? 0.0;
      if (backendDiscount > 0) _discountAmount = backendDiscount;
    }
    if (orderMap['coupon_code'] != null && _couponCode == null) {
      _couponCode = orderMap['coupon_code'].toString();
    }

    if (_finalTotal <= 0 && orderMap['total_amount'] != null) {
      final backendTotal = double.tryParse(orderMap['total_amount'].toString()) ?? 0.0;
      if (backendTotal > 0) {
        _finalTotal = backendTotal;
        if (_originalTotal <= 0) {
          _originalTotal = backendTotal + _discountAmount;
        }
      }
    }

    if (_finalTotal <= 0 && _originalTotal > 0) {
      _finalTotal = (_originalTotal - _discountAmount).clamp(0.0, double.infinity);
    }

    if (_finalTotal <= 0 && _purchasedItems.isNotEmpty) {
      double sum = 0.0;
      for (final it in _purchasedItems) {
        final (_, _, priceStr) = extractItemInfo(it);
        sum += double.tryParse(priceStr) ?? 0.0;
      }
      if (sum > 0) {
        if (_originalTotal <= 0) _originalTotal = sum;
        _finalTotal = (_originalTotal - _discountAmount).clamp(0.0, double.infinity);
      }
    }

    if (_originalTotal <= 0 && _finalTotal > 0) {
      _originalTotal = _finalTotal + _discountAmount;
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncWithSavedState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final studentName = user?.fullName ?? 'Valued Student';
    final studentEmail = user?.email ?? 'student@igrow.com';

    final ordersAsync = ref.watch(ordersProvider);
    final orderData = _orderResult['order'] is Map
        ? _orderResult['order'] as Map<String, dynamic>
        : _orderResult;

    // Fallback items and amounts from the newly created order in ordersProvider if still empty
    if (_purchasedItems.isEmpty && ordersAsync.valueOrNull?.isNotEmpty == true) {
      final latest = ordersAsync.valueOrNull!.first;
      if (latest.items.isNotEmpty) {
        _purchasedItems = List<dynamic>.from(latest.items);
      }
      if (_finalTotal <= 0) {
        final latestTotal = double.tryParse(latest.totalAmount) ?? 0.0;
        if (latestTotal > 0) {
          if (_originalTotal <= 0) _originalTotal = latestTotal;
          _finalTotal = (_originalTotal - _discountAmount).clamp(0.0, double.infinity);
        }
      }
    }

    final gatewayRef = orderData['gateway_reference']?.toString() ??
        _orderResult['gateway_reference']?.toString() ??
        (ordersAsync.valueOrNull?.isNotEmpty == true
            ? ordersAsync.valueOrNull!.first.gatewayReference
            : null) ??
        'AGRIPAY_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final orderId = orderData['id']?.toString() ??
        (ordersAsync.valueOrNull?.isNotEmpty == true
            ? ordersAsync.valueOrNull!.first.id
            : null) ??
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final nowFormatted = DateFormat('MMMM dd, yyyy • hh:mm a').format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(RouteNames.farmerHome);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Confirmed'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close to Dashboard',
            onPressed: () => context.go(RouteNames.farmerHome),
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Celebration Icon & Header ──────────────────────────────
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryGreen,
                size: 54,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.inkDark,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _orderResult['message']?.toString() ??
                  'You have been successfully enrolled in your course(s).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : AppColors.inkSoft,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Order Details Card ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2E23) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Reference ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: gatewayRef));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reference ID copied!')),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    gatewayRef,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.copy,
                                    size: 14,
                                    color: isDark ? AppColors.greenLight : AppColors.primaryGreen),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 20,
                  color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                ),
                _buildDetailRow('Date & Time', nowFormatted, isDark),
                _buildDetailRow('Payment Mode', _paymentMethod, isDark),
                _buildDetailRow('Status', 'COMPLETED (PAID)', isDark,
                    valueColor: isDark ? AppColors.greenLight : AppColors.primaryGreen),
                Divider(
                  height: 20,
                  color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Amount Paid',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        '₹${_finalTotal.toStringAsFixed(2)}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Enrolled Courses List ──────────────────────────────────
          Text(
            'Enrolled Courses (${_purchasedItems.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 10),

          ..._purchasedItems.map((item) {
            final (title, courseId, _) = extractItemInfo(item);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2E23) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          color: AppColors.primaryGreen,
                          size: 24,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lifetime Access • Verified Certificate',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text(
                        'Start Learning',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (courseId.isNotEmpty) {
                          context.push('/player/$courseId?fromCheckout=true');
                        } else {
                          context.go(RouteNames.farmerHome);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── Action Buttons ─────────────────────────────────────────
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primaryGreen),
              foregroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.receipt_long),
            label: const Text('View Tax Invoice / Receipt',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _showInvoiceDialog(
              context,
              orderId: orderId,
              gatewayRef: gatewayRef,
              dateStr: nowFormatted,
              studentName: studentName,
              studentEmail: studentEmail,
              originalTotal: _originalTotal,
              finalTotal: _finalTotal,
              discountAmount: _discountAmount,
              couponCode: _couponCode,
              items: _purchasedItems,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.home),
            label: const Text('Back to My Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              context.go(RouteNames.farmerHome);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : AppColors.inkSoft,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? Colors.white : AppColors.inkDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDialog(
    BuildContext context, {
    required String orderId,
    required String gatewayRef,
    required String dateStr,
    required String studentName,
    required String studentEmail,
    required double originalTotal,
    required double finalTotal,
    required double discountAmount,
    String? couponCode,
    required List<dynamic> items,
    required bool isDark,
  }) {
    final effectiveDiscount = discountAmount > 0
        ? discountAmount
        : ((originalTotal - finalTotal) > 0.01 ? (originalTotal - finalTotal) : 0.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IGROW EDUCATION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'Kisan Ki Digital Pathshala',
                        style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'TAX INVOICE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Invoice Details Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Billed To:',
                            style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                        Text(studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(studentEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Invoice No:',
                          style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      Text('INV-${orderId.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(dateStr, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Items Table Header
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.lineDark : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('Course / Description',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('SAC',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Text('Amount',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Items
              ...items.map((item) {
                final (title, _, price) = extractItemInfo(item);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(title,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Text('998311',
                            style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      ),
                      Text('₹$price',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),

              const Divider(height: 24),

              // Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:', style: TextStyle(fontSize: 12)),
                  Text('₹${originalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              if (effectiveDiscount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Coupon Discount (${couponCode ?? "PROMO"}):',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                        )),
                    Text(
                      '-₹${effectiveDiscount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CGST (0%):', style: TextStyle(fontSize: 12)),
                  const Text('₹0.00', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SGST (0%):', style: TextStyle(fontSize: 12)),
                  const Text('₹0.00', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total Paid:',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${finalTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stamp
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryGreen, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PAID & VERIFIED • IGROW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('Save / Print PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () async {
                        try {
                          final pdfBytes = await _buildReceiptPdfBytes(
                            orderId: orderId,
                            dateStr: dateStr,
                            studentName: studentName,
                            studentEmail: studentEmail,
                            originalTotal: originalTotal,
                            finalTotal: finalTotal,
                            effectiveDiscount: effectiveDiscount,
                            couponCode: couponCode,
                            items: items,
                          );

                          final safeShortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
                          await Printing.layoutPdf(
                            name: 'IGrow_Receipt_$safeShortId',
                            onLayout: (PdfPageFormat format) async => pdfBytes,
                          );
                        } catch (e) {
                          debugPrint('Error saving/printing receipt PDF: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to open PDF: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGreen),
                        foregroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () async {
                        try {
                          final pdfBytes = await _buildReceiptPdfBytes(
                            orderId: orderId,
                            dateStr: dateStr,
                            studentName: studentName,
                            studentEmail: studentEmail,
                            originalTotal: originalTotal,
                            finalTotal: finalTotal,
                            effectiveDiscount: effectiveDiscount,
                            couponCode: couponCode,
                            items: items,
                          );

                          final safeShortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
                          await Printing.sharePdf(
                            bytes: pdfBytes,
                            filename: 'IGrow_Receipt_$safeShortId.pdf',
                          );
                        } catch (e) {
                          debugPrint('Error sharing receipt PDF: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to share receipt: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _buildReceiptPdfBytes({
    required String orderId,
    required String dateStr,
    required String studentName,
    required String studentEmail,
    required double originalTotal,
    required double finalTotal,
    required double effectiveDiscount,
    String? couponCode,
    required List<dynamic> items,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context pCtx) {
          final safeShortId = orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase();
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'IGROW EDUCATION',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.Text(
                        'Kisan Ki Digital Pathshala',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'TAX INVOICE',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed To:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                      pw.Text(studentName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(studentEmail, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                      pw.Text('INV-$safeShortId',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.green50),
                cellStyle: const pw.TextStyle(fontSize: 11),
                headers: ['Course / Description', 'SAC', 'Amount'],
                data: items.map((item) {
                  final (title, _, price) = extractItemInfo(item);
                  return [title, '998311', 'Rs. $price'];
                }).toList(),
              ),
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 11)),
                  pw.Text('Rs. ${originalTotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              if (effectiveDiscount > 0) ...[
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Coupon Discount (${couponCode ?? "PROMO"}):',
                        style: pw.TextStyle(fontSize: 11, color: PdfColors.green800)),
                    pw.Text('-Rs. ${effectiveDiscount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        )),
                  ],
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CGST (0%):', style: const pw.TextStyle(fontSize: 11)),
                  pw.Text('Rs. 0.00', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SGST (0%):', style: const pw.TextStyle(fontSize: 11)),
                  pw.Text('Rs. 0.00', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total Paid:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  pw.Text('Rs. ${finalTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 15,
                        color: PdfColors.green800,
                      )),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.green800, width: 2),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'PAID & VERIFIED  •  IGROW',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }
}
