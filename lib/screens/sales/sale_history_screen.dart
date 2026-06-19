import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../providers/sale_provider.dart';
import '../../providers/sale_filter_provider.dart';
import '../../models/sale.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/empty_state.dart';
import 'sale_details_screen.dart';
import '../reports/sales_report_filter_sheet.dart';

class SaleHistoryScreen extends StatelessWidget {
  const SaleHistoryScreen({super.key});

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SaleFilterProvider>(),
        child: const SalesReportFilterSheet(),
      ),
    );
  }

  List<_DayBar> _last7Days(List<Sale> sales) {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final total = sales
          .where((s) =>
              s.saleDate.year == day.year &&
              s.saleDate.month == day.month &&
              s.saleDate.day == day.day)
          .fold(0.0, (sum, s) => sum + s.totalAmount);
      return _DayBar(day: day, total: total);
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();
    final filterProvider = context.watch<SaleFilterProvider>();

    final allSales = saleProvider.allSales;
    final filtered = filterProvider.apply(List.from(allSales));
    final filterCount = filterProvider.activeFilterCount;
    final bars = _last7Days(allSales);
    final maxBar = bars.map((b) => b.total).fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Sales History',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldDark)),
                  ),
                  GestureDetector(
                    onTap: () => _openFilterSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: filterCount > 0 ? AppColors.goldDark : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(
                          color: AppColors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.tune_rounded,
                              size: 20,
                              color: filterCount > 0 ? AppColors.white : AppColors.goldDark),
                          if (filterCount > 0)
                            Positioned(
                              top: -5, right: -5,
                              child: Container(
                                width: 14, height: 14,
                                decoration: const BoxDecoration(
                                  color: AppColors.goldLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('$filterCount',
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PERFORMANCE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: appCardDecoration(context: context),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PERFORMANCE TODAY',
                                    style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey)),
                                const SizedBox(height: 6),
                                Text(
                                  '₹${saleProvider.todaySalesTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    saleProvider.salesChangeLabel,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGreen),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text('Transactions',
                                    style: TextStyle(fontSize: 11, color: AppColors.grey)),
                                Text(
                                  '${allSales.where((s) {
                                    final t = DateTime.now();
                                    return s.saleDate.year == t.year &&
                                        s.saleDate.month == t.month &&
                                        s.saleDate.day == t.day;
                                  }).length}',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                          // Mini bar chart
                          SizedBox(
                            height: 80,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: bars.map((b) {
                                final frac = maxBar == 0
                                    ? 0.0
                                    : (b.total / maxBar).clamp(0.05, 1.0);
                                final isToday =
                                    b.day.day == DateTime.now().day &&
                                    b.day.month == DateTime.now().month;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        width: 14,
                                        height: 80 * frac,
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? AppColors.goldDark
                                              : AppColors.goldLight.withOpacity(0.35),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SECTION LABEL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filterCount > 0
                              ? 'FILTERED RESULTS (${filtered.length})'
                              : 'RECENT RECORDS',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                        if (filterCount > 0)
                          GestureDetector(
                            onTap: () => filterProvider.reset(),
                            child: const Text('Clear',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (filterCount > 0) ...[
                      _ActiveFilterChips(provider: filterProvider),
                      const SizedBox(height: 12),
                    ],

                    if (filtered.isEmpty)
                      EmptyState(
                        icon: Icons.receipt_outlined,
                        title: 'No records found',
                        subtitle: filterCount > 0
                            ? 'Try adjusting your filters.'
                            : 'No sales match your search.',
                      )
                    else
                      ...filtered.map((s) => _saleTile(context, s)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saleTile(BuildContext context, Sale s) {
    final displayName = (s.customerName?.isNotEmpty == true)
        ? s.customerName!
        : 'Walk-in · #${s.receiptNumber}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SaleDetailsScreen(sale: s)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.lightGrey, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(formatDateTime(s.saleDate),
                          style: TextStyle(fontSize: 11, color: AppColors.grey)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: s.channel == 'online'
                              ? AppColors.blue.withOpacity(0.1)
                              : AppColors.goldDark.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s.channel == 'online' ? 'Online' : 'In-Store',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: s.channel == 'online'
                                ? AppColors.blue
                                : AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '₹${s.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: s.totalAmount >= 100 ? AppColors.goldDark : Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilterChips extends StatelessWidget {
  final SaleFilterProvider provider;
  const _ActiveFilterChips({required this.provider});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (provider.sortBy != SaleSortOption.newest) {
      chips.add(_chip(provider.sortBy.label,
          () => provider.setSortBy(SaleSortOption.newest)));
    }
    if (provider.customerQuery.isNotEmpty) {
      chips.add(_chip('Customer: ${provider.customerQuery}',
          () => provider.setCustomerQuery('')));
    }
    if (provider.channel.isNotEmpty) {
      chips.add(_chip(
          provider.channel == 'online' ? 'Online' : 'In-Store',
          () => provider.setChannel('')));
    }
    if (provider.dateRange != null) {
      final r = provider.dateRange!;
      chips.add(_chip(
          '${r.start.day}/${r.start.month} – ${r.end.day}/${r.end.month}',
          () => provider.setDateRange(null)));
    }
    if (provider.minAmount != 0 || provider.maxAmount != SaleFilterProvider.kMaxAmount) {
      final label = provider.maxAmount >= SaleFilterProvider.kMaxAmount
          ? '₹${provider.minAmount.toStringAsFixed(0)}+'
          : '₹${provider.minAmount.toStringAsFixed(0)}–₹${provider.maxAmount.toStringAsFixed(0)}';
      chips.add(_chip(label,
          () => provider.setAmountRange(0, SaleFilterProvider.kMaxAmount)));
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _chip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goldDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldDark.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 13, color: AppColors.goldDark),
          ),
        ],
      ),
    );
  }
}

class _DayBar {
  final DateTime day;
  final double total;
  _DayBar({required this.day, required this.total});
}