import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../models/credit_transaction.dart';
import '../../models/sale.dart';
import '../../providers/customer_detail_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../models/customer.dart';
import 'record_payment_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final allSales = context.read<SaleProvider>().allSales;
    final customerProvider = context.read<CustomerProvider>();
    return ChangeNotifierProvider(
      create: (_) => CustomerDetailProvider(
        customer: customer,
        allSales: allSales,
        customerProvider: customerProvider,
      ),
      child: const _CustomerDetailView(),
    );
  }
}

class _CustomerDetailView extends StatelessWidget {
  const _CustomerDetailView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CustomerDetailProvider>();
    final c = p.customer;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  Text('Customer Details',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                child: Column(
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.goldDark.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                c.name[0].toUpperCase(),
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldDark),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(c.name,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_rounded,
                                  size: 12, color: AppColors.grey),
                              const SizedBox(width: 4),
                              Text(c.phone,
                                  style: TextStyle(
                                      fontSize: 13, color: AppColors.grey)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: p.currentBalance == 0
                                  ? AppColors.darkGreen.withOpacity(0.06)
                                  : AppColors.darkRed.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text('TOTAL OUTSTANDING DEBT',
                                    style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 1,
                                        color: AppColors.darkRed,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(
                                  '₹${p.currentBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: p.currentBalance == 0
                                          ? AppColors.darkGreen
                                          : AppColors.darkRed),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Text('Activity History',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          const _ActivityList(),
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
      bottomNavigationBar: const _BottomBar(),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CustomerDetailProvider>();

    // Build combined list — keep reference to original CreditTransaction
    final txnItems = p.transactions
        .map((t) => (item: _ActivityItem.fromTransaction(t), txn: t))
        .toList();
    final saleItems = p.linkedSales
        .map((s) => (item: _ActivityItem.fromSale(s), txn: null as CreditTransaction?))
        .toList();

    final all = [...saleItems, ...txnItems]
      ..sort((a, b) => b.item.date.compareTo(a.item.date));

    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text('No activity yet.',
            style: TextStyle(fontSize: 13, color: AppColors.warmGrey)),
      );
    }

    return Column(
      children: all.asMap().entries.map((e) {
        final item = e.value.item;
        final txn = e.value.txn;
        final isLast = e.key == all.length - 1;

        final row = ActivityRow(
          icon: item.icon,
          iconBg: item.iconBg,
          iconColor: item.iconColor,
          title: item.title,
          subtitle: formatDate(item.date),
          time: item.amount,
          timeColor: item.amountColor,
          badge: item.badge,
          isLast: isLast,
        );

        // Only CreditTransaction rows are editable
        if (txn == null) return row;

        return GestureDetector(
          onLongPress: () => _openEdit(context, txn, p),
          child: Stack(
            children: [
              row,
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _openEdit(context, txn, p),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit_rounded,
                          size: 14, color: AppColors.goldDark),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _openEdit(
    BuildContext context,
    CreditTransaction txn,
    CustomerDetailProvider p,
  ) async {
    final result = await Navigator.push<CreditTransaction>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordPaymentScreen(
          customer: p.customer,
          type: txn.type,
          existing: txn,
        ),
      ),
    );
    if (result != null && context.mounted) {
      await p.updateTransaction(result);
    }
  }
}

class _ActivityItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final DateTime date;
  final String amount;
  final Color amountColor;
  final String? badge;

  _ActivityItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
    this.badge,
  });

  factory _ActivityItem.fromSale(Sale s) {
    return _ActivityItem(
      icon: Icons.receipt_long_rounded,
      iconBg: AppColors.goldDark.withOpacity(0.1),
      iconColor: AppColors.goldDark,
      title: 'Sale (Credit)',
      date: s.saleDate,
      amount: '+₹${s.totalAmount.toStringAsFixed(2)}',
      amountColor: AppColors.darkRed,
      badge: s.status == 'pending' ? 'PENDING' : null,
    );
  }

  factory _ActivityItem.fromTransaction(CreditTransaction t) {
    final isPayment = t.type == TransactionType.payment;
    return _ActivityItem(
      icon: isPayment
          ? Icons.payments_rounded
          : Icons.account_balance_wallet_rounded,
      iconBg: isPayment
          ? AppColors.darkGreen.withOpacity(0.1)
          : AppColors.goldDark.withOpacity(0.1),
      iconColor: isPayment ? AppColors.darkGreen : AppColors.goldDark,
      title: isPayment ? 'Payment Received' : 'Credit Added',
      date: t.date,
      amount: isPayment
          ? '-₹${t.amount.toStringAsFixed(2)}'
          : '+₹${t.amount.toStringAsFixed(2)}',
      amountColor: isPayment ? AppColors.darkGreen : AppColors.darkRed,
      badge: isPayment ? 'SETTLED' : null,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final p = context.read<CustomerDetailProvider>();

    Future<void> openScreen(TransactionType type) async {
      final result = await Navigator.push<CreditTransaction>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RecordPaymentScreen(customer: p.customer, type: type),
        ),
      );
      if (result != null && context.mounted) {
        await p.addTransaction(result);
        if (!context.mounted) return;
        final balance = context.read<CustomerProvider>().computeBalance(
          p.customer.id, p.customer.amountDue,
        );
        if (balance <= 0) {
          await context.read<CustomerProvider>().remove(p.customer.id);
          if (!context.mounted) return;
          AppSnackBar.success(context, 'Balance cleared — customer removed');
          Navigator.of(context).pop(); // back to CustomersScreen
        }
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GoldButton(
              label: 'Record Payment',
              outlined: true,
              onPressed: () => openScreen(TransactionType.payment),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GoldButton(
              label: 'Add Credit',
              icon: Icons.add_circle_outline_rounded,
              onPressed: () => openScreen(TransactionType.credit),
            ),
          ),
        ],
      ),
    );
  }
}