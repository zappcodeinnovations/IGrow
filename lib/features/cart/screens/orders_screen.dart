import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/pdf_theme_helper.dart';
import '../../../data/models/api_models/order_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final studentName = user?.fullName ?? 'Valued Student';
    final studentEmail = user?.email ?? 'student@iagrow.com';

    return Scaffold(
      backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go('/farmer/profile');
                      }
                    },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                tr(ref, 'My Orders'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                  letterSpacing: -0.4,
                ),
              ),
              centerTitle: true,
            ),
            // Sticky Search & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.lineDark : AppColors.lineLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                    decoration: InputDecoration(
                      hintText: tr(ref, 'Search by course name, ref ID, date...'),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : AppColors.inkSoft,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark ? Colors.white54 : AppColors.inkSoft,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
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
                        color: isDark
                            ? AppColors.editorialSecondary.withValues(alpha: 0.2)
                            : AppColors.editorialSecondaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 44,
                        color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tr(ref, 'No Orders Found'),
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr(ref, 'You haven\'t purchased any courses yet. Once you enroll, your purchase history and invoices will appear here.'),
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
                      child: Text(
                        tr(ref, 'Browse Courses'),
                        style: TextStyle(
                          color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredOrders = _searchQuery.isEmpty
              ? orders
              : orders.where((order) {
                  final refId = (order.gatewayReference ?? order.id).toLowerCase();
                  final status = (order.status ?? '').toLowerCase();
                  final dateFormatted = order.createdAt != null
                      ? DateFormat('MMMM dd, yyyy • hh:mm a').format(order.createdAt!.toLocal()).toLowerCase()
                      : '';
                  final itemsMatch = order.items.any((it) {
                    final title = (it.courseTitle ?? '').toLowerCase();
                    final slug = (it.courseSlug ?? '').toLowerCase();
                    return title.contains(_searchQuery) || slug.contains(_searchQuery);
                  });
                  return refId.contains(_searchQuery) ||
                      status.contains(_searchQuery) ||
                      dateFormatted.contains(_searchQuery) ||
                      itemsMatch;
                }).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 56,
                      color: isDark ? Colors.white38 : AppColors.inkSoft,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(ref, 'No matching orders found'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tr(ref, 'No results for')} "$_searchQuery"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final dateStr = order.createdAt != null
                  ? DateFormat('MMMM dd, yyyy • hh:mm a').format(order.createdAt!.toLocal())
                  : 'Recent Purchase';
              final isSuccess = (order.status ?? 'SUCCESS').toUpperCase() == 'SUCCESS';
              final itemSubtotal = order.items.fold<double>(
                0.0,
                (sum, it) => sum + (double.tryParse(it.priceAtPurchase) ?? 0.0),
              );
              final parsedAmount = double.tryParse(order.totalAmount) ?? 0.0;
              final displayAmount = parsedAmount > 0 ? parsedAmount : (itemSubtotal > 0 ? itemSubtotal : 0.0);

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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
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
                                  ? (isDark ? AppColors.editorialSecondary.withValues(alpha: 0.25) : AppColors.editorialSecondaryFixed)
                                  : Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status ?? 'SUCCESS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSuccess
                                    ? (isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary)
                                    : Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.inkDark,
                        ),
                      ),
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
                                    Icon(
                                      Icons.school, 
                                      size: 16, 
                                      color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.courseTitle ?? 'Agriculture Course',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600, 
                                          fontSize: 13,
                                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${item.priceAtPurchase}', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 13,
                                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                ),
                              ),
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
                                    '₹${displayAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
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
                                  side: BorderSide(
                                    color: isDark ? AppColors.lineDark : AppColors.lineLight,
                                  ),
                                  foregroundColor: isDark ? Colors.white : AppColors.editorialOnSurface,
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
                                    backgroundColor: AppColors.editorialSecondary,
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
        loading: () => Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
          ),
        ),
        error: (err, _) {
          final errStr = err.toString().toLowerCase();
          final isOffline = errStr.contains('socketexception') ||
              errStr.contains('clientexception') ||
              errStr.contains('abort') ||
              errStr.contains('connection') ||
              errStr.contains('host lookup') ||
              errStr.contains('network');
          final displayMsg = isOffline
              ? 'No internet connection.\nPlease check your network and try again.'
              : 'Unable to load orders right now.\nPlease try again in a few moments.';

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffline ? Icons.wifi_off_rounded : Icons.receipt_long_outlined,
                    size: 54,
                    color: isDark ? Colors.white38 : AppColors.inkSoft,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : AppColors.inkDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.editorialSecondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: () => ref.refresh(ordersProvider),
                    label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          );
        },
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
    final subtotal = order.items.fold<double>(
      0.0,
      (sum, it) => sum + (double.tryParse(it.priceAtPurchase) ?? 0.0),
    );
    final rawPaid = double.tryParse(order.totalAmount) ?? 0.0;
    final totalPaid = rawPaid > 0 ? rawPaid : (subtotal > 0 ? subtotal : 0.0);
    final discount = (subtotal - totalPaid) > 0.01 ? (subtotal - totalPaid) : 0.0;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'iAGROW EDUCATION',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Kisan Ki Digital Pathshala',
                          style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
                  const Text('Subtotal:', style: TextStyle(fontSize: 12)),
                  Text('₹${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              if (discount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount / Coupon Applied:',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryGreen)),
                    Text('-₹${discount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
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
                  const Text('Grand Total Paid:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${totalPaid.toStringAsFixed(2)}',
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
                    'PAID & VERIFIED • iAGROW',
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
                          final pdfBytes = await _buildOrderReceiptPdfBytes(
                            order: order,
                            studentName: studentName,
                            studentEmail: studentEmail,
                            dateStr: dateStr,
                            subtotal: subtotal,
                            discount: discount,
                            totalPaid: totalPaid,
                          );

                          final safeShortId = order.id.length >= 8 ? order.id.substring(0, 8) : order.id;
                          await Printing.layoutPdf(
                            name: 'iAgrow_Receipt_$safeShortId',
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
                          final pdfBytes = await _buildOrderReceiptPdfBytes(
                            order: order,
                            studentName: studentName,
                            studentEmail: studentEmail,
                            dateStr: dateStr,
                            subtotal: subtotal,
                            discount: discount,
                            totalPaid: totalPaid,
                          );

                          final safeShortId = order.id.length >= 8 ? order.id.substring(0, 8) : order.id;
                          await Printing.sharePdf(
                            bytes: pdfBytes,
                            filename: 'iAgrow_Receipt_$safeShortId.pdf',
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

  Future<Uint8List> _buildOrderReceiptPdfBytes({
    required ApiOrder order,
    required String studentName,
    required String studentEmail,
    required String dateStr,
    required double subtotal,
    required double discount,
    required double totalPaid,
  }) async {
    final theme = await PdfThemeHelper.getInvoiceTheme();
    final pdf = pw.Document(theme: theme);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context pCtx) {
          final safeShortId = order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();
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
                        'iAgrow',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                      pw.Text(
                        'Agricultural E-Learning Platform',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'support@iagrow.zappcode.in',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      border: pw.Border.all(color: PdfColors.green700, width: 0.8),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'TAX INVOICE',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.green900, thickness: 1.2),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILLED TO:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.Text(PdfThemeHelper.sanitizePdfText(studentName), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(PdfThemeHelper.sanitizePdfText(studentEmail), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('PAYMENT DETAILS:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.Text('INV-$safeShortId',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text(
                        dateStr.replaceAll('•', '-').replaceAll('  ', ' ').trim(),
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Status: PAID & VERIFIED',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.green900),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headers: ['#', 'Item / Course Description', 'Type', 'Amount'],
                data: List<List<String>>.generate(
                  order.items.length,
                  (index) {
                    final item = order.items[index];
                    final itemType = (item.ebook != null || (item.courseTitle?.toLowerCase().contains('ebook') ?? false))
                        ? 'E-BOOK'
                        : 'COURSE';
                    return [
                      '${index + 1}',
                      PdfThemeHelper.sanitizePdfText(item.courseTitle ?? 'Agriculture Course'),
                      itemType,
                      '₹${item.priceAtPurchase}',
                    ];
                  },
                ),
              ),
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 11)),
                  pw.Text('₹${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              if (discount > 0) ...[
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount / Coupon Applied:',
                        style: pw.TextStyle(fontSize: 11, color: PdfColors.green800)),
                    pw.Text('-₹${discount.toStringAsFixed(2)}',
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
                  pw.Text('CGST (0%):', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  pw.Text('₹0.00', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SGST (0%):', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  pw.Text('₹0.00', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total Paid:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  pw.Text('₹${totalPaid.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 15,
                        color: PdfColors.green900,
                      )),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'This is an electronically generated invoice issued by iAgrow. No signature required.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
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
