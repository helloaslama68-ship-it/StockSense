import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/alert_provider.dart';
import '../../providers/product_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedTab = 'All';
  final _tabs = ['All', 'Low Stock', 'Expiry', 'High Due'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── APP BAR 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Alerts',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark)),
                ],
              ),
            ),

            // ── TABS 
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final tab = _tabs[i];
                  final active = _selectedTab == tab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.goldDark
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppColors.goldDark
                              : AppColors.lightGrey,
                        ),
                      ),
                      child: Text(tab,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? AppColors.white
                                  : AppColors.grey)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── ALERT LIST ---------------------
            Expanded(
              child: Consumer<AlertProvider>(
                builder: (_, alertProvider, __) {
                  final lowStock   = alertProvider.lowStockAlerts;
                  final expiry     = alertProvider.expiryAlerts;

                  final List<Widget> cards = [];

                  // LOW STOCK cards
                  if (_selectedTab == 'All' || _selectedTab == 'Low Stock') {
                    for (final p in lowStock) {
                      cards.add(_LowStockCard(product: p));
                    }
                  }

                  // EXPIRY cards
                  if (_selectedTab == 'All' || _selectedTab == 'Expiry') {
                    for (final alert in expiry) {
                      final p       = alert['product'] as Product;
                      final days    = alert['daysLeft'] as int;
                      final expired = alert['isExpired'] as bool;
                      cards.add(_ExpiryCard(
                          product: p, daysLeft: days, isExpired: expired));
                    }
                  }

                  // HIGH DUE — placeholder
                  if (_selectedTab == 'High Due') {
                    cards.add(_CreditCard(
                      name: 'Rahul',
                      amount: '₹2,000 pending',
                    ));
                  }

                  if (cards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 64, color: AppColors.lightGrey),
                          const SizedBox(height: 12),
                          Text('No alerts right now!',
                              style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Everything looks good.',
                              style: TextStyle(
                                  color: AppColors.lightGrey,
                                  fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => cards[i],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------
// LOW STOCK CARD
// -------------------------------------
class _LowStockCard extends StatelessWidget {
  final Product product;
  const _LowStockCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isOut = product.quantity == 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
            left: BorderSide(color: AppColors.darkRed, width: 3)),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STOCK STATUS',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              _urgentBadge('URGENT', AppColors.darkRed),
            ],
          ),
          const SizedBox(height: 6),
          Text(product.name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.inventory_2_rounded,
                  color: AppColors.grey, size: 14),
              const SizedBox(width: 6),
              Text(
                isOut
                    ? 'Out of stock'
                    : 'Only ${product.quantity} units left',
                style: TextStyle(
                    fontSize: 13,
                    color: isOut ? AppColors.darkRed : AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Restock button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {},
              child: const Text('Restock',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

//--------------------------------------------------------------
// EXPIRY CARD
// ----------------------------------------------------------
class _ExpiryCard extends StatelessWidget {
  final Product product;
  final int daysLeft;
  final bool isExpired;

  const _ExpiryCard({
    required this.product,
    required this.daysLeft,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final isNear   = !isExpired && daysLeft <= 3;
    final badgeColor = isExpired ? AppColors.darkRed : AppColors.orange;
    final badgeText  = isExpired ? 'URGENT' : 'WARNING';
    final borderColor = isExpired ? AppColors.darkRed : AppColors.orange;

    String expiryText;
    if (isExpired) {
      expiryText = daysLeft == -1
          ? 'Expired yesterday'
          : 'Expired ${daysLeft.abs()} days ago';
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
            left: BorderSide(color: borderColor, width: 3)),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QUALITY ALERT',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              _urgentBadge(badgeText, badgeColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(product.name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isExpired
                    ? Icons.cancel_rounded
                    : Icons.access_time_rounded,
                color: badgeColor,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(expiryText,
                  style:
                      TextStyle(fontSize: 13, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.lightGrey, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    child: Text('Details',
                        style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpired
                          ? AppColors.black
                          : AppColors.goldDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: Text(
                      isExpired ? 'Mark as Waste' : 'Discount',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// CREDIT CARD
class _CreditCard extends StatelessWidget {
  final String name;
  final String amount;

  const _CreditCard({required this.name, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
            left: BorderSide(color: AppColors.purple, width: 3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CREDIT LIMIT',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              _urgentBadge('URGENT', AppColors.darkRed),
            ],
          ),
          const SizedBox(height: 6),
          Text(name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.grey, size: 14),
                  const SizedBox(width: 6),
                  Text(amount,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.grey)),
                ],
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {},
              child: const Text('Collect Payment',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SHARED BADGE 
Widget _urgentBadge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5)),
    );