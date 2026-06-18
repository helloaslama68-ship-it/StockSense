import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../models/inventory_loss.dart';
import '../../providers/loss_filter_provider.dart';
import '../../providers/loss_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_filter_chip.dart';
import 'log_loss_screen.dart';

class LossLogScreen extends StatelessWidget {
  const LossLogScreen({super.key});

  static const _reasonMeta = {
    'damaged': (label: 'Damaged', color: AppColors.darkBlue2, bg: AppColors.lightBlue),
    'spoiled': (label: 'Spoiled', color: AppColors.forestGreen, bg: AppColors.lightGreen),
    'expired': (label: 'Expired', color: AppColors.darkRed, bg: AppColors.lightRed),
    'other':   (label: 'Other',   color: AppColors.charcoalGrey, bg: AppColors.creamBg),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text(
          'Loss Log',
          style: TextStyle(
            color: AppColors.nearBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer2<LossFilterProvider, LossProvider>(
        builder: (_, filterP, lossP, __) {
          final all = lossP.allLosses;
          final filtered = filterP.filter == 'All'
              ? all
              : lossP.byReason(filterP.filter.toLowerCase());

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // HEADER
                const Text('Inventory Loss', style: appPageTitleStyle),
                const SizedBox(height: 2),
                Text(
                  'Monthly Audit Period: ${formatMonthYear(DateTime.now())}',
                  style: const TextStyle(fontSize: 13, color: AppColors.charcoalGrey),
                ),
                const SizedBox(height: 16),

                // STATS ROW
                Row(children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL LOSS ITEMS',
                            style: appPageCategoryStyle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${lossP.totalLossItems}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.nearBlack,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Text(
                            'Units',
                            style: TextStyle(fontSize: 12, color: AppColors.charcoalGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.nearBlack,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL LOSS AMOUNT',
                            style: appPageCategoryStyle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${lossP.totalLossAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.redAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '↑ this month',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // FILTER TABS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LossFilterProvider.filters.map((f) => AppFilterChip(
                      label: f,
                      active: filterP.filter == f,
                      onTap: () => filterP.setFilter(f),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // ENTRIES LABEL
                const Text('RECENT ENTRIES', style: appPageCategoryStyle),
                const SizedBox(height: 12),

                // LIST
                filtered.isEmpty
                    ? _emptyState(filterP.filter)
                    : AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: List.generate(filtered.length, (i) {
                            return _LossTile(
                              loss: filtered[i],
                              isLast: i == filtered.length - 1,
                              onDelete: () =>
                                  context.read<LossProvider>().deleteLoss(filtered[i].id),
                            );
                          }),
                        ),
                      ),

                const SizedBox(height: 24),

                // AUDIT COMPLETE FOOTER
                if (all.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 48, color: AppColors.goldDark.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'Audit Complete',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.nearBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Next scheduled audit in 14 days.',
                          style: TextStyle(fontSize: 12, color: AppColors.charcoalGrey),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.goldDark,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogLossScreen())),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _emptyState(String filter) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.lightGrey),
              const SizedBox(height: 12),
              Text(
                'No ${filter == 'All' ? '' : filter.toLowerCase() + ' '}losses logged',
                style: const TextStyle(
                    color: AppColors.charcoalGrey, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
}

// LOSS TILE 

class _LossTile extends StatelessWidget {
  final InventoryLoss loss;
  final bool isLast;
  final VoidCallback onDelete;

  const _LossTile({
    required this.loss,
    required this.isLast,
    required this.onDelete,
  });

  static const _meta = {
    'damaged': (label: 'DAMAGED', color: AppColors.darkBlue2, bg: AppColors.lightBlue),
    'spoiled': (label: 'SPOILED', color: AppColors.forestGreen, bg: AppColors.lightGreen),
    'expired': (label: 'EXPIRED', color: AppColors.darkRed, bg: AppColors.lightRed),
    'other':   (label: 'OTHER',   color: AppColors.charcoalGrey, bg: AppColors.creamBg),
  };

  @override
  Widget build(BuildContext context) {
    final m = _meta[loss.reason] ?? _meta['other']!;
    final dateStr = formatDate(loss.loggedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.creamBg, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: m.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_reasonIcon(loss.reason), color: m.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loss.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.nearBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: m.bg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      m.label,
                      style: TextStyle(
                          fontSize: 9,
                          color: m.color,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.charcoalGrey),
                  ),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 12, color: AppColors.charcoalGrey),
                  const SizedBox(width: 4),
                  Text(
                    '${loss.quantity}${loss.unit != null ? ' ${loss.unit}' : ''} units',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.charcoalGrey),
                  ),
                ]),
                const SizedBox(height: 2),
                Text(
                  'Valuation Loss: ₹${loss.valuationLoss.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: const Icon(Icons.delete_outline_rounded,
                size: 18, color: AppColors.charcoalGrey),
          ),
        ],
      ),
    );
  }

  IconData _reasonIcon(String reason) {
    switch (reason) {
      case 'damaged': return Icons.broken_image_rounded;
      case 'spoiled': return Icons.warning_amber_rounded;
      case 'expired': return Icons.hourglass_disabled_rounded;
      default:        return Icons.delete_rounded;
    }
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Loss Entry?',
      message: 'Remove "${loss.productName}" from loss log?',
    );
    if (confirmed) onDelete();
  }
}

// LOG LOSS SHEET 

class _LogLossSheet extends StatefulWidget {
  const _LogLossSheet();

  @override
  State<_LogLossSheet> createState() => _LogLossSheetState();
}

class _LogLossSheetState extends State<_LogLossSheet> {
  final _qtyCtrl = TextEditingController();
  double _costPrice = 0;
  String? _unit;

  static const _reasons = ['expired', 'damaged', 'spoiled', 'other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LossFilterProvider>().resetSheet();
    });
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final p = context.read<LossFilterProvider>();
    if (p.selectedProductId == null) return;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0) return;

    context.read<LossProvider>().addLoss(
      productId:     p.selectedProductId!,
      productName:   p.selectedProductName!,
      quantity:      qty,
      valuationLoss: _costPrice * qty,
      reason:        p.reason,
      unit:          _unit,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final products = context.read<ProductProvider>().allProducts;

    return Consumer<LossFilterProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color:  AppColors.warmSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Log Inventory Loss',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 20),

              const Text('PRODUCT', style: appPageCategoryStyle),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: p.selectedProductId,
                hint: const Text('Select product'),
                decoration: appInputDeco(''),
                items: products.map((prod) => DropdownMenuItem(
                  value: prod.id,
                  child: Text(prod.name),
                )).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final prod = products.firstWhere((prod) => prod.id == id);
                  _costPrice = prod.costPrice;
                  _unit      = prod.unit;
                  p.setSelectedProduct(id, prod.name);
                },
              ),

              const SizedBox(height: 14),

              const Text('QUANTITY LOST', style: appPageCategoryStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: appInputDeco('e.g. 5'),
              ),

              const SizedBox(height: 14),

              const Text('REASON', style: appPageCategoryStyle),
              const SizedBox(height: 6),
              Row(
                children: _reasons.map((r) => AppFilterChip(
                  label: r[0].toUpperCase() + r.substring(1),
                  active: p.reason == r,
                  onTap: () => p.setReason(r),
                  margin: const EdgeInsets.only(right: 8),
                )).toList(),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _save(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Log Loss',
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}