import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale.dart';
import 'sale_screen.dart';
import 'sale_details_screen.dart';
import 'sale_history_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Sale> _filtered(List<Sale> sales) {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return sales;
    return sales.where((s) {
      final name = (s.customerName ?? '').toLowerCase();
      final receipt = s.receiptNumber.toString();
      return name.contains(q) || receipt.contains(q);
    }).toList();
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${months[d.month-1]} ${d.day}, ${d.year} · $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SaleProvider>();
    final sales = provider.allSales;
    final filtered = _filtered(sales);

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
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: AppColors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Sales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SaleHistoryScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: Icon(Icons.history_rounded, color: AppColors.goldDark, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── SEARCH
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by customer or receipt #...',
                          hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── STATS
                    Row(
                      children: [
                        Expanded(child: _statCard(
                          "TODAY'S REVENUE",
                          '₹${provider.todaySalesTotal.toStringAsFixed(2)}',
                          AppColors.goldDark.withOpacity(0.08),
                          AppColors.goldDark,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _statCard(
                          'TOTAL SALES',
                          '${sales.length}',
                          Colors.blue.withOpacity(0.08),
                          Colors.blue,
                        )),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text('RECENT TRANSACTIONS',
                        style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppColors.grey, fontWeight: FontWeight.w600)),

                    const SizedBox(height: 12),

                    // ── EMPTY STATE
                    if (filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_outlined, size: 48, color: AppColors.lightGrey),
                            const SizedBox(height: 12),
                            Text('No sales yet', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
                            const SizedBox(height: 4),
                            Text('Tap Add Sale to record your first sale.',
                                style: TextStyle(fontSize: 12, color: AppColors.grey)),
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

      // ── FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaleScreen()),
        ),
        backgroundColor: AppColors.goldDark,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const Text('Add Sale', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statCard(String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, letterSpacing: 1, color: fg, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fg)),
        ],
      ),
    );
  }

  Widget _saleTile(BuildContext context, Sale s) {
    final customerLabel = (s.customerName?.isNotEmpty == true) ? s.customerName! : 'Walk-in Customer';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SaleDetailsScreen(sale: s)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.darkGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.receipt_rounded, color: AppColors.darkGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customerLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.black)),
                  const SizedBox(height: 3),
                  Text(_formatDate(s.saleDate), style: TextStyle(fontSize: 10, color: AppColors.grey)),
                  const SizedBox(height: 2),
                  Text('${s.items.length} item${s.items.length > 1 ? 's' : ''} · #${s.receiptNumber}',
                      style: TextStyle(fontSize: 10, color: AppColors.grey)),
                ],
              ),
            ),
            Text('₹${s.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.black)),
          ],
        ),
      ),
    );
  }
}