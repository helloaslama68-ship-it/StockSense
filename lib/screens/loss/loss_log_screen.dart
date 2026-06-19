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
import 'loss_detail_screen.dart';

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
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Loss Log',
          style: TextStyle(
            color: onSurface,
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
                Text(
                  'Inventory Loss',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Monthly Audit Period: ${formatMonthYear(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                  ),
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
                          Text(
                            'TOTAL LOSS ITEMS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${lossP.totalLossItems}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Units',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                            ),
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
                        color: isDark ? AppColors.surfaceDark : AppColors.nearBlack,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(
                          color: AppColors.black.withOpacity(isDark ? 0.0 : 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL LOSS AMOUNT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warmGrey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${lossP.totalLossAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                Text(
                  'RECENT ENTRIES',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // LIST
                filtered.isEmpty
                    ? _emptyState(filterP.filter, isDark)
                    : AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: List.generate(filtered.length, (i) {
                            return _LossTile(
                              loss: filtered[i],
                              isLast: i == filtered.length - 1,
                              isDark: isDark,
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
                        Text(
                          'Audit Complete',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Next scheduled audit in 14 days.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                          ),
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

  Widget _emptyState(String filter, bool isDark) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 48,
                  color: isDark ? AppColors.warmGrey : AppColors.mutedGrey),
              const SizedBox(height: 12),
              Text(
                'No ${filter == 'All' ? '' : filter.toLowerCase() + ' '}losses logged',
                style: TextStyle(
                  color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                  fontWeight: FontWeight.w600,
                ),
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
  final bool isDark;
  final VoidCallback onDelete;

  const _LossTile({
    required this.loss,
    required this.isLast,
    required this.isDark,
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
    final m         = _meta[loss.reason] ?? _meta['other']!;
    final dateStr   = formatDate(loss.loggedAt);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final subColor  = isDark ? AppColors.warmGrey : AppColors.charcoalGrey;

    // dark-mode badge: lighten bg, slightly lighten color
    final badgeBg    = isDark ? m.color.withOpacity(0.18) : m.bg;
    final badgeColor = isDark ? Color.lerp(m.color, Colors.white, 0.3)! : m.color;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LossDetailScreen(loss: loss)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_reasonIcon(loss.reason), color: badgeColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loss.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        m.label,
                        style: TextStyle(
                            fontSize: 9,
                            color: badgeColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 11, color: subColor),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.inventory_2_outlined, size: 12, color: subColor),
                    const SizedBox(width: 4),
                    Text(
                      loss.qtyDisplay,
                      style: TextStyle(fontSize: 12, color: subColor),
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
              child: Icon(Icons.delete_outline_rounded,
                  size: 18,
                  color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey),
            ),
          ],
        ),
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