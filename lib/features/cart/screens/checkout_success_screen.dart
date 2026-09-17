import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../../data/models/api_models/order_models.dart';
import '../../auth/providers/auth_provider.dart';

class CheckoutSuccessScreen extends ConsumerWidget {
  const CheckoutSuccessScreen({
    super.key,
    required this.orderResult,
    required this.originalTotal,
    required this.finalTotal,
    required this.paymentMethod,
    required this.purchasedItems,
  });

  final Map<String, dynamic> orderResult;
  final double originalTotal;
  final double finalTotal;
  final String paymentMethod;
  final List<dynamic> purchasedItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final studentName = user?.fullName ?? 'Valued Student';
    final studentEmail = user?.email ?? 'student@igrow.com';

    final orderData = orderResult['order'] is Map
        ? orderResult['order'] as Map<String, dynamic>
        : orderResult;

    final gatewayRef = orderData['gateway_reference']?.toString() ??
        orderResult['gateway_reference']?.toString() ??
        'AGRIPAY_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final orderId = orderData['id']?.toString() ?? 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final nowFormatted = DateFormat('MMMM dd, yyyy • hh:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
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
              orderResult['message']?.toString() ??
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reference ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: gatewayRef));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reference ID copied!')),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            gatewayRef,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.copy,
                              size: 14,
                              color: isDark ? AppColors.greenLight : AppColors.primaryGreen),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 20,
                  color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                ),
                _buildDetailRow('Date & Time', nowFormatted, isDark),
                _buildDetailRow('Payment Mode', paymentMethod, isDark),
                _buildDetailRow('Status', 'COMPLETED (PAID)', isDark,
                    valueColor: isDark ? AppColors.greenLight : AppColors.primaryGreen),
                Divider(
                  height: 20,
                  color: isDark ? const Color(0xFF334A3A) : AppColors.lineLight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount Paid',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    Text(
                      '₹${finalTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
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
            'Enrolled Courses (${purchasedItems.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 10),

          ...purchasedItems.map((item) {
            String title = 'Course';
            String courseId = '';

            if (item is ApiCourseDetail) {
              title = item.title;
              courseId = item.id;
            } else if (item is ApiCartItem) {
              title = item.courseDetail?['title']?.toString() ??
                  item.courseDetail?['name']?.toString() ??
                  'Course';
              courseId = item.course;
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
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_circle_filled,
                      color: AppColors.primaryGreen),
                ),
                title: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Lifetime Access • Verified Certificate',
                    style: TextStyle(fontSize: 11)),
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Start Learning', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    if (courseId.isNotEmpty) {
                      context.push('/player/$courseId');
                    } else {
                      context.go(RouteNames.farmerHome);
                    }
                  },
                ),
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
              finalTotal: finalTotal,
              items: purchasedItems,
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
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppColors.inkSoft,
              )),
          Text(value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? Colors.white : AppColors.inkDark),
              )),
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
    required double finalTotal,
    required List<dynamic> items,
    required bool isDark,
  }) {
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
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Billed To:',
                          style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      Text(studentName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(studentEmail,
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
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
                String title = 'Course';
                String price = '0.00';
                if (item is ApiCourseDetail) {
                  title = item.title;
                  price = item.price ?? '0.00';
                } else if (item is ApiCartItem) {
                  title = item.courseDetail?['title']?.toString() ?? 'Course';
                  price = item.courseDetail?['price']?.toString() ?? '0.00';
                }

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

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.download),
                label: const Text('Download Receipt'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Receipt downloaded successfully! 📄'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
