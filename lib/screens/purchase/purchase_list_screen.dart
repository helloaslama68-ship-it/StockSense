import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/purchase_filter_provider.dart';
import '../../models/purchase_record.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/manage_widgets.dart';
import '../../widgets/app_snack_bar.dart';
import 'purchase_screen.dart';
import 'purchase_detail_screen.dart';
import 'purchase_filter_sheet.dart';

class PurchaseListScreen extends StatelessWidget {
  const PurchaseListScreen({super.key});

  void _confirmDelete(BuildContext context, PurchaseRecord p) {
    showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Purchase?',
        message: 'Remove "${p.productName}" from records?',
        onConfirm: () {
          context.read<PurchaseProvider>().deletePurchase(p.id);
          AppSnackBar.error(context, '${p.productName} deleted');
        },
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PurchaseFilterProvider>(),
        child: const PurchaseFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = context.watch<PurchaseProvider>();
    final filterProvider = context.watch<PurchaseFilterProvider>();

    final allPurchases = purchaseProvider.allPurchases;
    final purchases = filterProvider.apply(List.from(allPurchases));
    final filterCount = filterProvider.activeFilterCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            //HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Purchases',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark,
                        )),
                  ),
                  // Filter button
                  GestureDetector(
                    onTap: () => _openFilterSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: filterCount > 0
                            ? AppColors.goldDark
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: filterCount > 0
                                ? AppColors.white
                                : AppColors.goldDark,
                          ),
                          if (filterCount > 0)
                            Positioned(
                              top: -5,
                              right: -5,
                              child: Container(
                                width: 14,
                                height: 14,
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MONTHLY TOTAL CARD
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MONTHLY PROCUREMENT',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 8),
                          Text(
                            '₹${purchaseProvider.monthlyTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _statChip(
                                Icons.receipt_long_rounded,
                                '${allPurchases.length} Orders',
                                AppColors.goldDark.withOpacity(0.1),
                                AppColors.goldDark,
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                Icons.local_shipping_rounded,
                                '${purchaseProvider.supplierCount} Suppliers',
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
                        Text(
                          filterCount > 0
                              ? 'Filtered Results (${purchases.length})'
                              : 'Recent Purchases',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (filterCount > 0)
                          GestureDetector(
                            onTap: () =>
                                context.read<PurchaseFilterProvider>().reset(),
                            child: const Text('Clear',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w600)),
                          )
                        else
                          const Text('This Month',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w500,
                              )),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ACTIVE FILTER CHIPS
                    if (filterCount > 0) ...[
                      _ActiveFilterChips(provider: filterProvider),
                      const SizedBox(height: 12),
                    ],

                    // PURCHASE TILES
                    if (purchases.isEmpty)
                      EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: filterCount > 0
                            ? 'No matches'
                            : 'No purchases yet',
                        subtitle: filterCount > 0
                            ? 'Try adjusting your filters.'
                            : 'Tap + to record your first purchase.',
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PurchaseScreen()),
        ),
        backgroundColor: AppColors.goldDark,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _purchaseTile(BuildContext context, PurchaseRecord p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PurchaseDetailScreen(record: p)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.goldDark.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: p.imagePath != null
                  ? Image.file(File(p.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.shopping_bag_rounded,
                          color: AppColors.goldDark, size: 22))
                  : Icon(Icons.shopping_bag_rounded,
                      color: AppColors.goldDark, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.productName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text(p.supplierName,
                      style:
                          TextStyle(fontSize: 11, color: AppColors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 11, color: AppColors.grey),
                      const SizedBox(width: 3),
                      Text(formatDateTime(p.purchaseDate),
                          style: TextStyle(
                              fontSize: 10, color: AppColors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('+${p.quantityPurchased} units',
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Text('₹${p.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PurchaseScreen(existingRecord: p))),
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

  Widget _statChip(
      IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: fg,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// Active filter pills shown below section header
class _ActiveFilterChips extends StatelessWidget {
  final PurchaseFilterProvider provider;
  const _ActiveFilterChips({required this.provider});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (provider.sortBy != PurchaseSortOption.newest) {
      chips.add(_chip(provider.sortBy.label, () => provider.setSortBy(PurchaseSortOption.newest)));
    }
    if (provider.supplierQuery.isNotEmpty) {
      chips.add(_chip('Supplier: ${provider.supplierQuery}', () => provider.setSupplierQuery('')));
    }
    if (provider.dateRange != null) {
      final r = provider.dateRange!;
      final label =
          '${r.start.day}/${r.start.month} – ${r.end.day}/${r.end.month}';
      chips.add(_chip(label, () => provider.setDateRange(null)));
    }
    if (provider.minAmount != 0 || provider.maxAmount != 99999) {
      final label = provider.maxAmount >= 99999
          ? '₹${provider.minAmount.toStringAsFixed(0)}+'
          : '₹${provider.minAmount.toStringAsFixed(0)}–₹${provider.maxAmount.toStringAsFixed(0)}';
      chips.add(_chip(label, () => provider.setAmountRange(0, 99999)));
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
            child: const Icon(Icons.close_rounded,
                size: 13, color: AppColors.goldDark),
          ),
        ],
      ),
    );
  }
}