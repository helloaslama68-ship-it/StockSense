import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../models/purchase_record.dart';
import '../../models/purchase_line_item.dart';
import '../../providers/purchase_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/manage_widgets.dart';
import '../../widgets/app_snack_bar.dart';
import 'purchase_screen.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final PurchaseRecord record;
  const PurchaseDetailScreen({super.key, required this.record});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Purchase?',
        message: 'Remove "${record.productName}" from records?',
        onConfirm: () {
          context.read<PurchaseProvider>().deletePurchase(record.id);
          Navigator.pop(context);
          AppSnackBar.error(context, '${record.productName} deleted');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = record.lineItems.isNotEmpty;

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
                  const Text('Purchase Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SUMMARY CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: appCardDecoration(),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppSectionLabel(label: 'SUPPLIER'),
                                    const SizedBox(height: 4),
                                    Text(record.supplierName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const AppSectionLabel(label: 'TOTAL AMOUNT'),
                                  const SizedBox(height: 4),
                                  Text('₹${record.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.goldDark)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppSectionLabel(label: 'PURCHASE DATE'),
                                    const SizedBox(height: 4),
                                    Text(formatDate(record.purchaseDate),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black)),
                                    const SizedBox(height: 2),
                                    Text(formatTime(record.purchaseDate),
                                        style: TextStyle(
                                            fontSize: 11, color: AppColors.grey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const AppSectionLabel(label: 'INVOICE ID'),
                                  const SizedBox(height: 4),
                                  Text(record.invoiceId,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('● PROCESSED',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGreen,
                                            letterSpacing: 0.5)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PURCHASED ITEMS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppSectionLabel(label: 'PURCHASED ITEMS'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.goldDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            hasItems
                                ? '${record.lineItems.length} Assets'
                                : '${record.quantityPurchased} units',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (hasItems)
                      ...record.lineItems.map((item) => _itemTile(item))
                    else
                      _fallbackItemTile(record),

                    const SizedBox(height: 16),

                    // TOTALS CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: appCardDecoration(),
                      child: Column(
                        children: [
                          appTotalRow('Subtotal',
                              '₹${record.subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          appTotalRow(
                            'Tax & Logistics (${record.taxPercent.toStringAsFixed(0)}%)',
                            '₹${record.taxAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('FINAL TOTAL',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                      letterSpacing: 0.5)),
                              Text('₹${record.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM ACTIONS
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldDark),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => PurchaseScreen(existingRecord: record))),
                icon: const Icon(Icons.edit_rounded,
                    size: 16, color: AppColors.goldDark),
                label: const Text('Edit Purchase',
                    style: TextStyle(
                        color: AppColors.goldDark, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Delete Record',
                    style: TextStyle(
                        color: AppColors.darkRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemTile(PurchaseLineItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imagePath != null
                ? Image.file(File(item.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.grey, size: 24))
                : const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.grey, size: 24),
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
                Text('₹${item.costPrice.toStringAsFixed(2)} / ${item.unit}',
                    style: TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('+${item.quantity}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text('₹${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackItemTile(PurchaseRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: r.imagePath != null
                ? Image.file(File(r.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.grey, size: 24))
                : const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.grey, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(r.productName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Text('+${r.quantityPurchased} units',
              style: TextStyle(fontSize: 12, color: AppColors.grey)),
        ],
      ),
    );
  }
}