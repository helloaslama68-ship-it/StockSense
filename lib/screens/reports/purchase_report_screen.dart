import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../models/purchase_record.dart';
import '../../providers/purchase_filter_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../widgets/app_back_button.dart';
import 'purchase_report_filter_sheet.dart';

class PurchaseReportScreen extends StatelessWidget {
  const PurchaseReportScreen({super.key});

  void _openFilter(BuildContext context) {
    context.read<PurchaseFilterProvider>().initDraft();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PurchaseFilterProvider>(),
        child: const PurchaseReportFilterSheet(),
      ),
    );
  }

  String _inrFormat(double v) {
    final str = v.toStringAsFixed(2);
    final parts = str.split('.');
    String intPart = parts[0];
    final dec = parts[1];
    if (intPart.length > 3) {
      final last3 = intPart.substring(intPart.length - 3);
      final rest = intPart.substring(0, intPart.length - 3);
      final buf = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i != 0 && (rest.length - i) % 2 == 0) buf.write(',');
        buf.write(rest[i]);
      }
      intPart = '${buf.toString()},$last3';
    }
    return '$intPart.$dec';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;
    final shadowColor = AppColors.black.withOpacity(isDark ? 0.0 : 0.04);

    final purchaseProvider = context.watch<PurchaseProvider>();
    final filterProvider = context.watch<PurchaseFilterProvider>();

    final allPurchases = purchaseProvider.allPurchases;
    final filtered = filterProvider.apply(List.from(allPurchases));
    final filterCount = filterProvider.activeFilterCount;

    final totalSpent = filtered.fold(0.0, (s, p) => s + p.totalAmount);
    final totalCount = filtered.length;

    final lastMonthTotal = allPurchases.fold(0.0, (s, p) => s + p.totalAmount) * 0.83;
    final changePercent = lastMonthTotal == 0
        ? 0.0
        : ((totalSpent - lastMonthTotal) / lastMonthTotal * 100);
    final isUp = changePercent >= 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Purchase Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // FILTER BUTTON
                  GestureDetector(
                    onTap: () => _openFilter(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: filterCount > 0
                            ? AppColors.goldDark
                            : cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: filterCount > 0
                              ? AppColors.goldDark
                              : isDark
                                  ? AppColors.surfaceDark2
                                  : AppColors.creamBg,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(isDark ? 0.0 : 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 15,
                            color: filterCount > 0
                                ? AppColors.white
                                : isDark
                                    ? AppColors.white70
                                    : AppColors.nearBlack,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            filterCount > 0
                                ? 'FILTER ($filterCount)'
                                : 'FILTER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: filterCount > 0
                                  ? AppColors.white
                                  : isDark
                                      ? AppColors.white70
                                      : AppColors.nearBlack,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY ANALYTICS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmGrey,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Purchase Report',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SUMMARY ROW
                    Row(
                      children: [
                        // Gold card 
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.goldDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL AMOUNT SPENT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white.withOpacity(0.75),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${_inrFormat(totalSpent)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      isUp
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      color: AppColors.white.withOpacity(0.85),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${changePercent.abs().toStringAsFixed(0)}% from last month',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right column 
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: shadowColor,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL PURCHASES',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.warmGrey,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$totalCount',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: shadowColor,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ACTIVE STOCK\nCYCLE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.warmGrey,
                                        letterSpacing: 1.0,
                                        height: 1.4,
                                      ),
                                    ),
                                    Icon(
                                      Icons.loop_rounded,
                                      color: AppColors.goldDark,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // FILTER ACTIVE BANNER
                    if (filterCount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: filterProvider.reset,
                            child: Text(
                              'Clear filters',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 12),

                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: AppColors.warmGrey),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions match\nyour filters',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.warmGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filtered.map((p) => _PurchaseTile(
                            purchase: p,
                            isDark: isDark,
                            cardColor: cardColor,
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final PurchaseRecord purchase;
  final bool isDark;
  final Color cardColor;

  const _PurchaseTile({
    required this.purchase,
    required this.isDark,
    required this.cardColor,
  });

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    const isPaid = true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(isDark ? 0.0 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.goldDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.goldDark,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.supplierName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatDate(purchase.purchaseDate)}  •  Inv ${purchase.invoiceId}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.warmGrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${purchase.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.darkGreen.withOpacity(isDark ? 0.2 : 1.0)
                      : AppColors.goldDark.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'PENDING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isPaid
                        ? (isDark ? AppColors.successGreen : AppColors.darkGreen)
                        : AppColors.goldDark,
                    letterSpacing: 0.5,
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