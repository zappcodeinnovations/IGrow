import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

class InstructorTransactionsScreen extends ConsumerStatefulWidget {
  const InstructorTransactionsScreen({super.key});

  @override
  ConsumerState<InstructorTransactionsScreen> createState() =>
      _InstructorTransactionsScreenState();
}

class _InstructorTransactionsScreenState
    extends ConsumerState<InstructorTransactionsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'ALL'; // 'ALL' | 'SUCCESS' | 'PENDING' | 'FAILED'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTransactionDetailsModal(BuildContext context, Map<String, dynamic> txn) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = txn['id']?.toString() ??
        txn['transaction_id']?.toString() ??
        txn['order_id']?.toString() ??
        'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final item = txn['item']?.toString() ??
        txn['course_title']?.toString() ??
        txn['description']?.toString() ??
        'Course Enrollment';
    final buyer = txn['buyer']?.toString() ??
        txn['student_name']?.toString() ??
        txn['user_name']?.toString() ??
        'Student';
    final date = txn['date']?.toString() ??
        txn['created_at']?.toString() ??
        'Recently';
    final amount = txn['amount'] != null ? '₹${txn['amount']}' : '₹0.00';
    final status = (txn['status']?.toString() ?? 'SUCCESS').toUpperCase();
    final paymentMethod = txn['payment_method']?.toString() ??
        txn['payment_mode']?.toString() ??
        'Online Payment';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.primaryGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Receipt',
                              style: Theme.of(sheetCtx)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              id,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : AppColors.inkSoft,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.lineLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Amount Credited',
                            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                          ),
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: status.contains('FAIL')
                                  ? Colors.red.withValues(alpha: 0.12)
                                  : status.contains('PEND')
                                      ? Colors.amber.withValues(alpha: 0.12)
                                      : Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: status.contains('FAIL')
                                    ? Colors.red
                                    : status.contains('PEND')
                                        ? Colors.amber.shade800
                                        : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Item / Course',
                            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                          ),
                          Flexible(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.end,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Enrolled Student',
                            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                          ),
                          Text(
                            buyer,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Date & Time',
                            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                          ),
                          Text(
                            date,
                            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                          ),
                          Text(
                            paymentMethod,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(instructorTransactionsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAF7),
      appBar: AppBar(
        title: Text(
          tr(ref, 'All Transactions'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: tr(ref, 'Retry'),
            onPressed: () {
              ref.invalidate(instructorTransactionsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async {
          ref.invalidate(instructorTransactionsProvider);
          await ref.read(instructorTransactionsProvider.future);
        },
        child: transactionsAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: List.generate(
              7,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerCard(height: 80),
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orange),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white60 : AppColors.inkSoft),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    onPressed: () => ref.invalidate(instructorTransactionsProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (allTransactions) {
            // Calculate totals
            double totalEarned = 0;
            int successfulCount = 0;
            int pendingCount = 0;
            int failedCount = 0;

            for (final txn in allTransactions) {
              final rawStatus = (txn['status']?.toString() ?? 'SUCCESS').toUpperCase();
              final numAmount = num.tryParse(txn['amount']?.toString() ?? '0') ?? 0;
              if (rawStatus.contains('FAIL')) {
                failedCount++;
              } else if (rawStatus.contains('PEND')) {
                pendingCount++;
              } else {
                successfulCount++;
                totalEarned += numAmount;
              }
            }

            // Filter transactions
            final filteredTransactions = allTransactions.where((txn) {
              final rawStatus = (txn['status']?.toString() ?? 'SUCCESS').toUpperCase();
              if (_selectedFilter == 'SUCCESS' && (rawStatus.contains('FAIL') || rawStatus.contains('PEND'))) {
                return false;
              }
              if (_selectedFilter == 'PENDING' && !rawStatus.contains('PEND')) {
                return false;
              }
              if (_selectedFilter == 'FAILED' && !rawStatus.contains('FAIL')) {
                return false;
              }

              if (_searchQuery.isNotEmpty) {
                final item = (txn['item'] ?? txn['course_title'] ?? txn['description'] ?? '').toString().toLowerCase();
                final buyer = (txn['buyer'] ?? txn['student_name'] ?? '').toString().toLowerCase();
                final id = (txn['id'] ?? txn['transaction_id'] ?? '').toString().toLowerCase();
                if (!item.contains(_searchQuery) &&
                    !buyer.contains(_searchQuery) &&
                    !id.contains(_searchQuery)) {
                  return false;
                }
              }
              return true;
            }).toList();

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Summary Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr(ref, 'Total Settled Earnings'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${formatNum(ref, totalEarned.toStringAsFixed(2))}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _buildSummaryStat(
                                    label: tr(ref, 'Total Orders'),
                                    value: formatNum(ref, allTransactions.length),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: Colors.white24,
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  _buildSummaryStat(
                                    label: tr(ref, 'Successful'),
                                    value: formatNum(ref, successfulCount),
                                  ),
                                  if (pendingCount > 0) ...[
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.white24,
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    _buildSummaryStat(
                                      label: tr(ref, 'Pending'),
                                      value: formatNum(ref, pendingCount),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Search Field
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by course, student, or ID...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey.shade400,
                              fontSize: 13.5,
                            ),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark ? AppColors.cardDark : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('ALL', '${tr(ref, 'All')} (${formatNum(ref, allTransactions.length)})'),
                              const SizedBox(width: 8),
                              _buildFilterChip('SUCCESS', '${tr(ref, 'Successful')} (${formatNum(ref, successfulCount)})'),
                              if (pendingCount > 0) ...[
                                const SizedBox(width: 8),
                                _buildFilterChip('PENDING', '${tr(ref, 'Pending')} (${formatNum(ref, pendingCount)})'),
                              ],
                              if (failedCount > 0) ...[
                                const SizedBox(width: 8),
                                _buildFilterChip('FAILED', '${tr(ref, 'FAILED')} (${formatNum(ref, failedCount)})'),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // Transactions List or Empty View
                if (filteredTransactions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _searchQuery.isNotEmpty || _selectedFilter != 'ALL'
                                  ? 'No matching transactions'
                                  : 'No Transactions Yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.inkDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _searchQuery.isNotEmpty || _selectedFilter != 'ALL'
                                  ? 'Try adjusting your search terms or filters.'
                                  : 'Transactions will appear here once students purchase your courses or e-books.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : AppColors.inkSoft,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty || _selectedFilter != 'ALL') ...[
                              const SizedBox(height: 14),
                              TextButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _selectedFilter = 'ALL');
                                },
                                icon: const Icon(Icons.clear_all_rounded, size: 16),
                                label: const Text('Clear Filters'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final txn = filteredTransactions[index];
                          final amount = txn['amount'] ?? '0';
                          final desc = txn['description'] ??
                              txn['item'] ??
                              txn['course_title'] ??
                              'Transaction';
                          final buyer = txn['buyer'] ??
                              txn['student_name'] ??
                              txn['user_name'] ??
                              'Student';
                          final date = txn['date'] ?? txn['created_at'] ?? 'Recently';
                          final rawStatus = (txn['status']?.toString() ?? 'SUCCESS').toUpperCase();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.lineDark
                                    : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black26
                                      : const Color(0xFF0F172A).withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _showTransactionDetailsModal(context, txn),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: rawStatus.contains('FAIL')
                                              ? Colors.red.withValues(alpha: 0.12)
                                              : AppColors.primaryGreen.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          rawStatus.contains('FAIL')
                                              ? Icons.error_outline_rounded
                                              : Icons.arrow_downward_rounded,
                                          color: rawStatus.contains('FAIL')
                                              ? Colors.red
                                              : AppColors.primaryGreen,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              desc,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : AppColors.inkDark,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Enrolled: $buyer • $date',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: isDark ? Colors.white60 : AppColors.inkSoft,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '+₹${formatNum(ref, amount)}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: rawStatus.contains('FAIL')
                                                  ? Colors.red.withValues(alpha: 0.1)
                                                  : Colors.green.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tr(ref, rawStatus),
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: rawStatus.contains('FAIL')
                                                    ? Colors.red
                                                    : Colors.green.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: filteredTransactions.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : isDark
                  ? AppColors.cardDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : isDark
                    ? AppColors.lineDark
                    : const Color(0xFFCBD5E1),
            width: 1.1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isDark
                    ? Colors.white70
                    : AppColors.inkDark,
          ),
        ),
      ),
    );
  }
}
