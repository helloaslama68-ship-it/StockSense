import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale.dart';
import 'sale_details_screen.dart';

class SaleHistoryScreen extends StatefulWidget {
  const SaleHistoryScreen({super.key});

  @override
  State<SaleHistoryScreen> createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends State<SaleHistoryScreen> {
  final _searchCtrl = TextEditingController();
  DateTime? _filterDate;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Sale> _filtered(List<Sale> sales) {
    var list = sales;

    if (_filterDate != null) {
      list = list.where((s) =>
        s.saleDate.year == _filterDate!.year &&
        s.saleDate.month == _filterDate!.month &&
        s.saleDate.day == _filterDate!.day,
      ).toList();
    }

    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) {
        final name = (s.customerName ?? '').toLowerCase();
        final receipt = s.receiptNumber.toString();
        return name.contains(q) || receipt.contains(q);
      }).toList();
    }

    return list;
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${months[d.month-1]} ${d.day}, ${d.year} · $h:$min $ampm';
  }

  String _formatShortDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month-1]} ${d.day}';
  }

  // Returns last 7 days revenue for bar chart
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

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.goldDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SaleProvider>();
    final allSales = provider.allSales;
    final filtered = _filtered(allSales);
    final bars = _last7Days(allSales);
    final maxBar = bars.map((b) => b.total).fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(
                          color: AppColors.black.withOpacity(0.05),
                          blurRadius: 8,
                        )],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Sales History',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark)),
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

                    // ── SEARCH + DATE FILTER
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              )],
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search customer or receipt...',
                                hintStyle: TextStyle(
                                    color: AppColors.grey, fontSize: 13),
                                prefixIcon: Icon(Icons.search_rounded,
                                    color: AppColors.grey, size: 20),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _pickDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _filterDate != null
                                  ? AppColors.goldDark
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              )],
                            ),
                            child: Icon(Icons.calendar_month_rounded,
                                color: _filterDate != null
                                    ? AppColors.white
                                    : AppColors.grey,
                                size: 20),
                          ),
                        ),
                        if (_filterDate != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _filterDate = null),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: AppColors.grey, size: 20),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── PERFORMANCE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        )],
                      ),
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
                                  '₹${provider.todaySalesTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    provider.salesChangeLabel,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGreen),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text('Transactions',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.grey)),
                                Text(
                                  '${allSales.where((s) {
                                    final t = DateTime.now();
                                    return s.saleDate.year == t.year &&
                                        s.saleDate.month == t.month &&
                                        s.saleDate.day == t.day;
                                  }).length}',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black),
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
                                final isToday = b.day.day == DateTime.now().day &&
                                    b.day.month == DateTime.now().month;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        width: 14,
                                        height: 80 * frac,
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? AppColors.goldDark
                                              : AppColors.goldLight
                                                  .withOpacity(0.35),
                                          borderRadius:
                                              BorderRadius.circular(4),
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

                    // ── SECTION LABEL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('RECENT RECORDS',
                            style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600)),
                        if (_filterDate != null)
                          Text(
                            _formatShortDate(_filterDate!),
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── EMPTY STATE
                    if (filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_outlined,
                                size: 48, color: AppColors.lightGrey),
                            const SizedBox(height: 12),
                            Text('No records found',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black)),
                            const SizedBox(height: 4),
                            Text(
                              _filterDate != null
                                  ? 'No sales on this date.'
                                  : 'No sales match your search.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey),
                            ),
                          ],
                        ),
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
    final customerLabel = (s.customerName?.isNotEmpty == true)
        ? s.customerName!
        : '+91 ${s.receiptNumber}-${s.receiptNumber.toString().padLeft(5, '0')}';
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
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black)),
                  const SizedBox(height: 2),
                  Text(_formatDate(s.saleDate),
                      style: TextStyle(fontSize: 11, color: AppColors.grey)),
                ],
              ),
            ),
            Text(
              '₹${s.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: s.totalAmount >= 100
                      ? AppColors.goldDark
                      : AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBar {
  final DateTime day;
  final double total;
  _DayBar({required this.day, required this.total});
}