import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/purchase_provider.dart';
import '../../models/purchase_record.dart';
import '../../widgets/app_snack_bar.dart';
import 'purchase_screen.dart';
import 'purchase_detail_screen.dart';

class PurchaseListScreen extends StatelessWidget {
  const PurchaseListScreen({super.key});

  String _formatDate(DateTime d) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $h:$min $ampm';
  }

  void _confirmDelete(BuildContext context, PurchaseRecord p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Purchase?'),
        content: Text('Remove "${p.productName}" from records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkRed),
            onPressed: () {
              context.read<PurchaseProvider>().deletePurchase(p.id);
              Navigator.pop(context);
              AppSnackBar.error(context, '${p.productName} deleted');
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseProvider>();
    final purchases = provider.allPurchases;

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
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8)
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Purchases',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldDark,
                      )),
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
                    //  MONTHLY TOTAL CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MONTHLY PROCUREMENT',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 8),
                          Text(
                            '₹${provider.monthlyTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _statChip(
                                Icons.receipt_long_rounded,
                                '${purchases.length} Orders',
                                AppColors.goldDark.withOpacity(0.1),
                                AppColors.goldDark,
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                Icons.local_shipping_rounded,
                                '${provider.supplierCount} Suppliers',
                                AppColors.blue.withOpacity(0.08),
                                AppColors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SECTION HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Purchases',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            )),
                        Text('This Month',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),

                    const SizedBox(height: 12),

                    //  PURCHASE TILES
                    if (purchases.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 48, color: AppColors.lightGrey),
                            const SizedBox(height: 12),
                            const Text('No purchases yet',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black)),
                            const SizedBox(height: 4),
                            Text('Tap + to record your first purchase.',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.grey)),
                          ],
                        ),
                      )
                    else
                      ...purchases.map((p) => _purchaseTile(context, p)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      //  FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PurchaseScreen()),
        ),
        backgroundColor: AppColors.goldDark,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _purchaseTile(BuildContext context, PurchaseRecord p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PurchaseDetailScreen(record: p),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // IMAGE or icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.goldDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: p.imagePath != null
                ? Image.file(
                    File(p.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                        Icons.shopping_bag_rounded,
                        color: AppColors.goldDark,
                        size: 22),
                  )
                : Icon(Icons.shopping_bag_rounded,
                    color: AppColors.goldDark, size: 22),
          ),
          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.black)),
                const SizedBox(height: 2),
                Text(p.supplierName,
                    style: TextStyle(fontSize: 11, color: AppColors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.grey),
                    const SizedBox(width: 3),
                    Text(_formatDate(p.purchaseDate),
                        style: TextStyle(fontSize: 10, color: AppColors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // AMOUNT + ACTIONS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${p.quantityPurchased} units',
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${p.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.black),
              ),
              const SizedBox(height: 6),
              // EDIT / DELETE
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PurchaseScreen(existingRecord: p),
                      ),
                    ),
                    child: Icon(Icons.edit_rounded,
                        size: 16, color: AppColors.grey),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, p),
                    child: const Icon(Icons.delete_rounded,
                        size: 16, color: AppColors.darkRed),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}