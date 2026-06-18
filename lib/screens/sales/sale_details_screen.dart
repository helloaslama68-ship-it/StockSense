import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../models/sale.dart';
import '../../providers/sale_provider.dart';
import '../../services/invoice_pdf_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/manage_widgets.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;
  const SaleDetailsScreen({super.key, required this.sale});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Sale?',
        message: 'This cannot be undone.',
        onConfirm: () async {
          Navigator.pop(context);
          await context.read<SaleProvider>().deleteSale(sale.id);
          if (!context.mounted) return;
          Navigator.pop(context);
          AppSnackBar.success(context, 'Sale deleted');
        },
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    try {
      await InvoicePdfService.downloadInvoice(sale);
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Failed to generate invoice');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerLabel = (sale.customerName?.isNotEmpty == true)
        ? sale.customerName!
        : 'Walk-in Customer';

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
                    child: Text('Sale Details',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldDark)),
                  ),
                  GestureDetector(
                    onTap: () => _downloadInvoice(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldDark.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded, size: 16, color: AppColors.white),
                          SizedBox(width: 6),
                          Text('Invoice',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600)),
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

                    // CUSTOMER & TOTAL CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: appCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CUSTOMER',
                                      style: TextStyle(
                                          fontSize: 9,
                                          letterSpacing: 1,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(customerLabel,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.black)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('TOTAL PAID',
                                      style: TextStyle(
                                          fontSize: 9,
                                          letterSpacing: 1,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('₹${sale.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.goldDark)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.grey),
                            const SizedBox(width: 6),
                            Text(formatDateTime(sale.saleDate),
                                style: TextStyle(fontSize: 11, color: AppColors.grey)),
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

                    //  ORDER ITEMS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Items (${sale.items.length})',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black)),
                        Text('Receipt #${sale.receiptNumber}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ...sale.items.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: appCardDecoration(radius: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.inventory_2_outlined,
                                    size: 20, color: AppColors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(
                                        '${item.quantity} unit${item.quantity > 1 ? 's' : ''} × ₹${item.unitPrice.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 11, color: AppColors.grey)),
                                    if (item.sku != null) ...[
                                      const SizedBox(height: 2),
                                      Text('SKU: ${item.sku}',
                                          style: TextStyle(fontSize: 10, color: AppColors.grey)),
                                    ],
                                  ],
                                ),
                              ),
                              Text('₹${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.black)),
                            ],
                          ),
                        )),

                    const SizedBox(height: 8),

                    // TOTALS SUMMARY
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: appCardDecoration(),
                      child: Column(
                        children: [
                          appTotalRow('Subtotal', '₹${sale.subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          appTotalRow(
                            'Tax (${sale.taxPercent.toStringAsFixed(1)}%)',
                            '₹${sale.taxAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Grand Total',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black)),
                              Text('₹${sale.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.goldDark)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  DOWNLOAD INVOICE
                    GestureDetector(
                      onTap: () => _downloadInvoice(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.goldDark.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.goldDark.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.picture_as_pdf_rounded, size: 18, color: AppColors.goldDark),
                            SizedBox(width: 8),
                            Text('Download Invoice PDF',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DELETE
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.darkRed, size: 18),
                        label: const Text('Delete Sale',
                            style: TextStyle(
                                color: AppColors.darkRed,
                                fontWeight: FontWeight.w600)),
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
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      );
}