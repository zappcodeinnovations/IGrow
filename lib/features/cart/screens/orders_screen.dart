import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/order_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final studentName = user?.fullName ?? 'Valued Student';
    final studentEmail = user?.email ?? 'student@igrow.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders & Receipts'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 44,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Orders Found',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You haven\'t purchased any courses yet. Once you enroll, your purchase history and invoices will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go(RouteNames.explore),
                      child: const Text('Browse Courses'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final dateStr = order.createdAt != null
                  ? DateFormat('MMMM dd, yyyy • hh:mm a').format(order.createdAt!)
                  : 'Recent Purchase';
              final isSuccess = (order.status ?? 'SUCCESS').toUpperCase() == 'SUCCESS';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppColors.lineDark : AppColors.lineLight,
                  ),
                ),
                color: isDark ? AppColors.cardDark : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Ref ID + Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    order.gatewayReference ?? 'REF-${order.id.substring(0, 8)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: () {
                                    final refId = order.gatewayReference ?? 'REF-${order.id.substring(0, 8)}';
                                    Clipboard.setData(ClipboardData(text: refId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Reference ID copied!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.copy, size: 14, color: AppColors.inkSoft),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? AppColors.primaryGreen.withValues(alpha: 0.12)
                                  : Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status ?? 'SUCCESS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSuccess
                                    ? AppColors.primaryGreen
                                    : Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      const Divider(height: 20),

                      // Order Items
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.school, size: 16, color: AppColors.primaryGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.courseTitle ?? 'Agriculture Course',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('₹${item.priceAtPurchase}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        );
                      }),

                      const Divider(height: 20),

                      // Bottom Row: Total & Invoice Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total Paid', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '₹${order.totalAmount}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  side: const BorderSide(color: AppColors.primaryGreen),
                                  foregroundColor: AppColors.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.receipt_long, size: 14),
                                label: const Text('Invoice', style: TextStyle(fontSize: 12)),
                                onPressed: () => _showOrderInvoice(
                                  context,
                                  order: order,
                                  studentName: studentName,
                                  studentEmail: studentEmail,
                                  dateStr: dateStr,
                                  isDark: isDark,
                                ),
                              ),
                              if (order.items.isNotEmpty && order.items.first.course != null)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.play_arrow, size: 14),
                                  label: const Text('Learn', style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    context.push('/player/${order.items.first.course}');
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading orders: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(ordersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderInvoice(
    BuildContext context, {
    required ApiOrder order,
    required String studentName,
    required String studentEmail,
    required String dateStr,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

              // Billed To & Invoice No
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Billed To:', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                        Text(
                          studentName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          studentEmail,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Invoice No:', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                        Text(
                          'INV-${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
                      child: Text('Course / Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('SAC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Text('Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(item.courseTitle ?? 'Agriculture Course', style: const TextStyle(fontSize: 12)),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Text('998311', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      ),
                      Text('₹${item.priceAtPurchase}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),

              const Divider(height: 24),

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
                  const Text('Grand Total Paid:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${order.totalAmount}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                onPressed: () async {
                  // --- Build the PDF document ---
                  final pdf = pw.Document();
                  pdf.addPage(
                    pw.Page(
                      pageFormat: PdfPageFormat.a4,
                      margin: const pw.EdgeInsets.all(32),
                      build: (pw.Context pCtx) {
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Header
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

                            // Billed To & Invoice Info
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
                                    pw.Text('INV-${order.id.substring(0, 8).toUpperCase()}',
                                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                    pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 16),

                            // Items Table
                            pw.TableHelper.fromTextArray(
                              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                              headerDecoration: const pw.BoxDecoration(color: PdfColors.green50),
                              cellStyle: const pw.TextStyle(fontSize: 11),
                              headers: ['Course / Description', 'SAC', 'Amount'],
                              data: order.items
                                  .map((item) => [
                                        item.courseTitle ?? 'Agriculture Course',
                                        '998311',
                                        'Rs. ${item.priceAtPurchase}',
                                      ])
                                  .toList(),
                            ),
                            pw.Divider(color: PdfColors.grey300),

                            // Taxes
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
                                pw.Text('Rs. ${order.totalAmount}',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 15,
                                      color: PdfColors.green800,
                                    )),
                              ],
                            ),
                            pw.SizedBox(height: 24),

                            // Verified Stamp
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

                  // --- Save PDF to documents directory ---
                  final pdfBytes = await pdf.save();
                  final dir = await getApplicationDocumentsDirectory();
                  final filePath = '${dir.path}/receipt_${order.id.substring(0, 8)}.pdf';
                  final file = File(filePath);
                  await file.writeAsBytes(pdfBytes);

                  // --- Open OS share sheet ---
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'IGrow_Receipt_${order.id.substring(0, 8)}.pdf',
                  );

                  // Close the invoice bottom sheet first
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
