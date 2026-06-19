import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../providers/customer_provider.dart';
import '../../models/credit_transaction.dart';
import '../../widgets/app_back_button.dart';

class CreditReportScreen extends StatelessWidget {
  const CreditReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark: AppColors.white;
    final shadowColor = AppColors.black.withOpacity(isDark ? 0.0 : 0.04);

    final provider = context.watch<CustomerProvider>();
    final customers = provider.customers;

    // Sum all credit transactions ever issued
    final allTxns = customers.expand((c) => provider.transactionsFor(c.id)).toList();

    // totalGiven = initial amountDue on each customer + additional credit txns added later
    final initialDueTotal = customers.fold<double>(0, (s, c) => s + c.amountDue);
    final additionalCreditTxns = allTxns
        .where((t) => t.type == TransactionType.credit)
        .fold<double>(0, (s, t) => s + t.amount);
    final totalGiven = initialDueTotal + additionalCreditTxns;

    final totalCollected = allTxns
        .where((t) => t.type == TransactionType.payment)
        .fold<double>(0, (s, t) => s + t.amount);

    final recoveryRate =
        totalGiven > 0 ? (totalCollected / totalGiven * 100).clamp(0.0, 100.0) : 0.0;

    final activeBalances = customers
        .where((c) => provider.computeBalance(c.id, c.amountDue) > 0)
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // APP BAR
              Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 8),
                  Text(
                    'Credit Report',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text('FINANCIAL OVERSIGHT', style: appPageCategoryStyle),

              const SizedBox(height: 4),

              
              
              Text(
                'Customer Credit',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 20),

              // SUMMARY CARDS ROW
              Row(
                children: [
                  // Total Credit Given
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL CREDIT GIVEN',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${_formatAmount(totalGiven)}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Decorative bars
                          Row(
                            children: [
                              _Bar(color: AppColors.goldDark, width: 28),
                              const SizedBox(width: 4),
                              _Bar(
                                color: isDark
                                    ? AppColors.surfaceDark2
                                    : AppColors.lightGrey,
                                width: 18,
                              ),
                              const SizedBox(width: 4),
                              _Bar(
                                color: isDark
                                    ? AppColors.surfaceDark2
                                    : AppColors.lightGrey,
                                width: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Total Collected 
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL COLLECTED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '₹${_formatAmount(totalCollected)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.show_chart_rounded,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${recoveryRate.toStringAsFixed(1)}% Recovery Rate',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
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

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$activeBalances Active Balances',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // CUSTOMER LIST
              if (customers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No customers yet',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                )
              else
                ...customers.map((c) {
                  final balance = provider.computeBalance(c.id, c.amountDue);
                  final txns = provider.transactionsFor(c.id);
                  final lastTxn = txns.isNotEmpty
                      ? (txns..sort((a, b) => b.date.compareTo(a.date))).first
                      : null;

                  final tag = _resolveTag(c, balance);

                  return _CustomerCreditRow(
                    name: c.name,
                    balance: balance,
                    lastPaymentDate:
                        lastTxn != null ? formatDate(lastTxn.date) : null,
                    tag: tag,
                    isDark: isDark,
                    cardColor: cardColor,
                  );
                }).toList(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  _CreditTag _resolveTag(customer, double balance) {
    if (balance <= 0) return _CreditTag.none;
    if (customer.statusIndex == 0) return _CreditTag.criticalLimit; // highDue
    if (customer.statusIndex == 1) return _CreditTag.overdue;       // pending
    return _CreditTag.currentBalance;                                // noDue with balance
  }

  String _formatAmount(double v) {
    if (v >= 1000) {
      final s = v.toStringAsFixed(2);
      final parts = s.split('.');
      final intPart = parts[0];
      final decPart = parts[1];
      final formatted = _addCommas(intPart);
      return '$formatted.$decPart';
    }
    return v.toStringAsFixed(2);
  }

  String _addCommas(String n) {
    if (n.length <= 3) return n;
    final last3 = n.substring(n.length - 3);
    final rest = n.substring(0, n.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }
}

enum _CreditTag { overdue, currentBalance, criticalLimit, none }

class _CustomerCreditRow extends StatelessWidget {
  final String name;
  final double balance;
  final String? lastPaymentDate;
  final _CreditTag tag;
  final bool isDark;
  final Color cardColor;

  const _CustomerCreditRow({
    required this.name,
    required this.balance,
    required this.tag,
    required this.isDark,
    required this.cardColor,
    this.lastPaymentDate,
  });

  @override
  Widget build(BuildContext context) {
    if (balance <= 0 && tag == _CreditTag.none) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: tag == _CreditTag.criticalLimit
            ? Border(
                left: BorderSide(color: AppColors.darkRed, width: 3),
              )
            : tag == _CreditTag.overdue
                ? Border(
                    left: BorderSide(color: AppColors.orange, width: 3),
                  )
                : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(isDark ? 0.0 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tag != _CreditTag.none) ...[
                Text(
                  _tagLabel(tag),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _tagColor(tag),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  
                ),
              ),
              if (lastPaymentDate != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Last payment: $lastPaymentDate',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.warmGrey,
                  ),
                ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PENDING AMOUNT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${_fmt(balance)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _tagLabel(_CreditTag t) {
    switch (t) {
      case _CreditTag.overdue:
        return 'OVERDUE 30+ DAYS';
      case _CreditTag.criticalLimit:
        return 'CRITICAL LIMIT';
      case _CreditTag.currentBalance:
        return 'CURRENT BALANCE';
      case _CreditTag.none:
        return '';
    }
  }

  Color _tagColor(_CreditTag t) {
    switch (t) {
      case _CreditTag.overdue:
        return AppColors.orange;
      case _CreditTag.criticalLimit:
        return AppColors.darkRed;
      case _CreditTag.currentBalance:
        return AppColors.grey;
      case _CreditTag.none:
        return AppColors.grey;
    }
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    return '${parts[0]}.${parts[1]}';
  }
}

class _Bar extends StatelessWidget {
  final Color color;
  final double width;

  const _Bar({required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}