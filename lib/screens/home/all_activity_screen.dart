import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/sale.dart';
import '../../models/inventory_loss.dart';
import '../../models/purchase_record.dart';
import '../../providers/sale_provider.dart';
import '../../providers/loss_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';

class AllActivityScreen extends StatelessWidget {
  const AllActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: const AppBackButton(),
        title: Text(
          'All Activity',
          style: TextStyle(
            fontSize: r.sp(17),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Consumer3<SaleProvider, LossProvider, PurchaseProvider>(
        builder: (_, sales, losses, purchases, __) {
          final items = _buildActivityItems(
            sales.allSales,
            losses.allLosses,
            purchases.allPurchases,
          );

          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'No activity yet',
              subtitle: 'Your store activity will appear here.',
            );
          }

          return ListView(
            padding: r.pagePadding.copyWith(top: 16, bottom: 32),
            children: [
              r.constrain(
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      return ActivityRow(
                        icon: item.icon,
                        iconBg: item.iconBg,
                        iconColor: item.iconColor,
                        title: item.title,
                        subtitle: item.subtitle,
                        time: item.time,
                        timeColor: item.timeColor,
                        badge: item.badge,
                        isLast: i == items.length - 1,
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_ActivityItem> _buildActivityItems(
    List<Sale> sales,
    List<InventoryLoss> losses,
    List<PurchaseRecord> purchases,
  ) {
    final List<_ActivityItem> items = [];

    // Sales
    for (final s in sales) {
      final itemCount = s.items.length;
      items.add(_ActivityItem(
        icon: Icons.receipt_rounded,
        iconBg: AppColors.creamBg,
        iconColor: AppColors.blue,
        title: 'Sales Transaction',
        subtitle: 'Order #SL${s.receiptNumber} · $itemCount ${itemCount == 1 ? 'item' : 'items'}',
        time: _formatTime(s.saleDate),
        timeColor: AppColors.warmGrey,
        badge: '₹${s.totalAmount.toStringAsFixed(0)}',
        sortDate: s.saleDate,
      ));
    }

    // Losses
    for (final l in losses) {
      items.add(_ActivityItem(
        icon: Icons.delete_rounded,
        iconBg: AppColors.lightRed,
        iconColor: AppColors.darkRed,
        title: 'Waste Logged',
        subtitle: '${l.quantity}x ${l.productName} (${_capitalise(l.reason)})',
        time: _formatTime(l.loggedAt),
        timeColor: AppColors.darkRed,
        badge: '-₹${l.valuationLoss.toStringAsFixed(0)}',
        sortDate: l.loggedAt,
      ));
    }

    // Purchases
    for (final p in purchases) {
      items.add(_ActivityItem(
        icon: Icons.shopping_cart_rounded,
        iconBg: AppColors.paleBlue,
        iconColor: AppColors.royalBlue,
        title: 'Purchase Recorded',
        subtitle: '${p.productName} · ${p.supplierName}',
        time: _formatTime(p.purchaseDate),
        timeColor: AppColors.warmGrey,
        badge: '₹${p.totalAmount.toStringAsFixed(0)}',
        sortDate: p.purchaseDate,
      ));
    }

    // Sort newest first
    items.sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return items;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(dt.year, dt.month, dt.day);

    if (d == today) {
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      return '$h12:$m $period';
    }
    if (d == yesterday) return 'Yesterday';
    final diff = today.difference(d).inDays;
    if (diff < 7) return '$diff days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _ActivityItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final Color timeColor;
  final String? badge;
  final DateTime sortDate;

  const _ActivityItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.timeColor,
    required this.sortDate,
    this.badge,
  });
}