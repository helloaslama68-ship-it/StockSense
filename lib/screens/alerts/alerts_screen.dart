import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gold_button.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AlertProvider>(
          builder: (_, provider, __) {
            final lowStock = provider.lowStockAlerts;
            final expiry   = provider.expiryAlerts;
            final current  = provider.selectedTab;
            final isDark   = Theme.of(context).brightness == Brightness.dark;

            final List<Widget> cards = [];

            if (current == 'All' || current == 'Low Stock') {
              for (final p in lowStock) {
                cards.add(_LowStockCard(product: p));
              }
            }

            if (current == 'All' || current == 'Expiry') {
              for (final alert in expiry) {
                final p       = alert['product']   as Product;
                final days    = alert['daysLeft']  as int;
                final expired = alert['isExpired'] as bool;
                cards.add(_ExpiryCard(product: p, daysLeft: days, isExpired: expired));
              }
            }

            if (current == 'High Due') {
              cards.add(const _CreditCard(name: 'Rahul', amount: '₹2,000 pending'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Alerts',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark)),
                ),

                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: AlertProvider.tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final tab    = AlertProvider.tabs[i];
                      final active = current == tab;
                      return GestureDetector(
                        onTap: () => context.read<AlertProvider>().selectTab(tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.goldDark
                                : (isDark ? const Color(0xFF1E1E1E) : AppColors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? AppColors.goldDark
                                  : (isDark ? const Color(0xFF3C3C3C) : AppColors.lightGrey),
                            ),
                          ),
                          child: Text(tab,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? AppColors.white
                                      : (isDark ? Colors.white54 : AppColors.grey))),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: cards.isEmpty
                      ? EmptyState(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'No alerts right now!',
                          subtitle: 'Everything looks good.',
                          iconColor: AppColors.lightGrey,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: cards.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => cards[i],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final Product product;
  const _LowStockCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isOut = product.quantity == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.darkRed, width: 3)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withOpacity(isDark ? 0.0 : 0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('STOCK STATUS',
              style: TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          _urgentBadge('URGENT', AppColors.darkRed),
        ]),
        const SizedBox(height: 6),
        Text(product.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.inventory_2_rounded, color: AppColors.grey, size: 14),
          const SizedBox(width: 6),
          Text(
            isOut ? 'Out of stock' : 'Only ${product.quantity} units left',
            style: TextStyle(fontSize: 13, color: isOut ? AppColors.darkRed : AppColors.grey),
          ),
        ]),
        const SizedBox(height: 12),
        GoldButton(label: 'Restock', onPressed: () {}, height: 42),
      ]),
    );
  }
}

class _ExpiryCard extends StatelessWidget {
  final Product product;
  final int     daysLeft;
  final bool    isExpired;

  const _ExpiryCard({required this.product, required this.daysLeft, required this.isExpired});

  @override
  Widget build(BuildContext context) {
    final badgeColor  = isExpired ? AppColors.darkRed : AppColors.orange;
    final badgeText   = isExpired ? 'URGENT' : 'WARNING';
    final borderColor = isExpired ? AppColors.darkRed : AppColors.orange;
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    String expiryText;
    if (isExpired) {
      expiryText = daysLeft == -1 ? 'Expired yesterday' : 'Expired ${daysLeft.abs()} days ago';
    } else if (daysLeft == 0) {
      expiryText = 'Expires today';
    } else if (daysLeft == 1) {
      expiryText = 'Expires tomorrow';
    } else {
      expiryText = 'Expires in $daysLeft days';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withOpacity(isDark ? 0.0 : 0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('QUALITY ALERT',
              style: TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          _urgentBadge(badgeText, badgeColor),
        ]),
        const SizedBox(height: 6),
        Text(product.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Row(children: [
          Icon(isExpired ? Icons.cancel_rounded : Icons.access_time_rounded, color: badgeColor, size: 14),
          const SizedBox(width: 6),
          Text(expiryText, style: TextStyle(fontSize: 13, color: AppColors.grey)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? const Color(0xFF3C3C3C) : AppColors.lightGrey, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {},
                child: Text('Details',
                    style: TextStyle(color: isDark ? Colors.white70 : AppColors.black, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpired ? AppColors.black : AppColors.goldDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Text(
                  isExpired ? 'Mark as Waste' : 'Discount',
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final String name;
  final String amount;
  const _CreditCard({required this.name, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.purple, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.0 : 0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('CREDIT LIMIT',
              style: TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          _urgentBadge('URGENT', AppColors.darkRed),
        ]),
        const SizedBox(height: 6),
        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(Icons.account_balance_wallet_rounded, color: AppColors.grey, size: 14),
            const SizedBox(width: 6),
            Text(amount, style: TextStyle(fontSize: 13, color: AppColors.grey)),
          ]),
          Icon(Icons.chevron_right_rounded, color: AppColors.grey, size: 20),
        ]),
        const SizedBox(height: 12),
        GoldButton(label: 'Collect Payment', onPressed: () {}, height: 42),
      ]),
    );
  }
}

Widget _urgentBadge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );