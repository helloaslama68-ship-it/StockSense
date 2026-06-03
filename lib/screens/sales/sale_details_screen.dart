import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/sale.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/app_snack_bar.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;
  const SaleDetailsScreen({super.key, required this.sale});

  String _formatDateTime(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${months[d.month-1]} ${d.day}, ${d.year} · $h:$min $ampm';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Sale?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkRed),
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await context.read<SaleProvider>().deleteSale(sale.id);
              if (!context.mounted) return;
              Navigator.pop(context); // back to list
              AppSnackBar.success(context, 'Sale deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerLabel = (sale.customerName?.isNotEmpty == true)
        ? sale.customerName!
        : 'Walk-in Customer';

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
                  Text('Sale Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
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

                    // ── CUSTOMER + TOTAL CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('CUSTOMER', style: TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.grey, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(customerLabel, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
                              ]),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text('TOTAL PAID', style: TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.grey, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('₹${sale.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.grey),
                            const SizedBox(width: 6),
                            Text(_formatDateTime(sale.saleDate), style: TextStyle(fontSize: 11, color: AppColors.grey)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            _StatusBadge(label: sale.status.toUpperCase(), color: AppColors.darkGreen),
                            const SizedBox(width: 8),
                            _StatusBadge(label: sale.channel.toUpperCase(), color: AppColors.grey),
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── ORDER ITEMS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Items (${sale.items.length})',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                        Text('Receipt #${sale.receiptNumber}',
                            style: TextStyle(fontSize: 12, color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ...sale.items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          // Product icon placeholder
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('${item.quantity} unit${item.quantity > 1 ? 's' : ''} × ₹${item.unitPrice.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 11, color: AppColors.grey)),
                                if (item.sku != null) ...[
                                  const SizedBox(height: 2),
                                  Text('SKU: ${item.sku}', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                                ],
                              ],
                            ),
                          ),
                          Text('₹${item.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.black)),
                        ],
                      ),
                    )),

                    const SizedBox(height: 8),

                    // ── TOTALS SUMMARY
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(label: 'Subtotal', value: '₹${sale.subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Tax (${sale.taxPercent.toStringAsFixed(1)}%)',
                            value: '₹${sale.taxAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Grand Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
                              Text('₹${sale.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── DELETE BUTTON
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.darkRed, size: 18),
                        label: const Text('Delete Sale', style: TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey)),
      Text(value, style: TextStyle(fontSize: 13, color: AppColors.grey)),
    ],
  );
}