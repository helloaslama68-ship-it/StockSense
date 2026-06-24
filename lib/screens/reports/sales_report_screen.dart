import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/sale.dart';
import '../../providers/sale_filter_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/empty_state.dart';
import 'sales_report_filter_sheet.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  void _openFilter(BuildContext context) {
    context.read<SaleFilterProvider>().initDraft();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SaleFilterProvider>(),
        child: const SalesReportFilterSheet(),
      ),
    );
  }

  // group sales by day, sorted newest first
  List<_PeriodSummary> _dailyBreakdown(List<Sale> sales) {
    final map = <String, _PeriodSummary>{};
    for (final s in sales) {
      final key =
          '${s.saleDate.year}-${s.saleDate.month.toString().padLeft(2, '0')}-${s.saleDate.day.toString().padLeft(2, '0')}';
      final existing = map[key];
      if (existing != null) {
        map[key] = existing.copyWith(
          total: existing.total + s.totalAmount,
          txCount: existing.txCount + 1,
        );
      } else {
        map[key] = _PeriodSummary(
          sortKey: DateTime(s.saleDate.year, s.saleDate.month, s.saleDate.day),
          primaryLabel: formatDate(
              DateTime(s.saleDate.year, s.saleDate.month, s.saleDate.day)),
          total: s.totalAmount,
          txCount: 1,
        );
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => b.sortKey.compareTo(a.sortKey));
    return list;
  }

  // group sales by calendar month, sorted newest first
  List<_PeriodSummary> _monthlyBreakdown(List<Sale> sales) {
    final map = <String, _PeriodSummary>{};
    for (final s in sales) {
      final key = '${s.saleDate.year}-${s.saleDate.month.toString().padLeft(2, '0')}';
      final existing = map[key];
      if (existing != null) {
        map[key] = existing.copyWith(
          total: existing.total + s.totalAmount,
          txCount: existing.txCount + 1,
        );
      } else {
        map[key] = _PeriodSummary(
          sortKey: DateTime(s.saleDate.year, s.saleDate.month, 1),
          primaryLabel: _monthLabel(s.saleDate.year, s.saleDate.month),
          total: s.totalAmount,
          txCount: 1,
        );
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => b.sortKey.compareTo(a.sortKey));
    return list;
  }

  List<_DayBar> _last7Days(List<Sale> sales) {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final total = sales
          .where((s) =>
              s.saleDate.year == day.year &&
              s.saleDate.month == day.month &&
              s.saleDate.day == day.day)
          .fold(0.0, (sum, s) => sum + s.totalAmount);
      return _DayBar(day: day, total: total);
    });
  }

  // last 6 calendar months including current, oldest first
  List<_MonthBar> _last6Months(List<Sale> sales) {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final monthIndex = now.month - (5 - i);
      final year = now.year + ((monthIndex - 1) ~/ 12) - (monthIndex <= 0 ? 1 : 0);
      final month = ((monthIndex - 1) % 12 + 12) % 12 + 1;
      final total = sales
          .where((s) => s.saleDate.year == year && s.saleDate.month == month)
          .fold(0.0, (sum, s) => sum + s.totalAmount);
      return _MonthBar(year: year, month: month, total: total);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final saleProvider = context.watch<SaleProvider>();
    final filterProvider = context.watch<SaleFilterProvider>();

    final allSales = saleProvider.allSales;
    final filtered = filterProvider.apply(List.from(allSales));
    final filterCount = filterProvider.activeFilterCount;
    final period = filterProvider.reportPeriod;

    final totalRevenue = filtered.fold(0.0, (s, e) => s + e.totalAmount);
    final txCount = filtered.length;
    final avgTicket = txCount == 0 ? 0.0 : totalRevenue / txCount;

    final bars = _last7Days(allSales);
    final maxBar =
        bars.map((b) => b.total).fold(0.0, (a, b) => a > b ? a : b);

    final monthBars = _last6Months(allSales);
    final maxMonthBar =
        monthBars.map((b) => b.total).fold(0.0, (a, b) => a > b ? a : b);

    final breakdownRows = period == ReportPeriod.daily
        ? _dailyBreakdown(filtered)
        : _monthlyBreakdown(filtered);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sales Report',
                      style: TextStyle(
                        fontSize: r.sp(18),
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // Filter button
                  GestureDetector(
                    onTap: () => _openFilter(context),
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
                          )
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
                                  child: Text(
                                    '$filterCount',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: r.constrain(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOTAL SALES HERO CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5E00), Color(0xFFB07D1A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldDark.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOTAL SALES',
                                  style: TextStyle(
                                    fontSize: r.sp(10),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white.withOpacity(0.75),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (filterCount > 0)
                                  GestureDetector(
                                    onTap: () => filterProvider.reset(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).colorScheme.surface.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.tune_rounded,
                                              size: 12,
                                              color: AppColors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            'FILTER ($filterCount)',
                                            style: TextStyle(
                                              fontSize: r.sp(9),
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context).colorScheme.surface,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${formatCompact(totalRevenue)}',
                              style: TextStyle(
                                fontSize: r.sp(34),
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.surface,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color:Theme.of(context).colorScheme.surface.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up_rounded,
                                      size: 13, color: AppColors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    saleProvider.salesChangeLabel,
                                    style: TextStyle(
                                      fontSize: r.sp(11),
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TRANSACTIONS + AVG TICKET
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'TRANSACTIONS',
                              value: txCount.toString(),
                              r: r,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'AVG. TICKET SIZE',
                              value: '₹${avgTicket.toStringAsFixed(0)}',
                              r: r,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // PERIOD TOGGLE
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _PeriodTab(
                                label: 'Daily',
                                selected: period == ReportPeriod.daily,
                                onTap: () => filterProvider.setReportPeriod(ReportPeriod.daily),
                                r: r,
                              ),
                            ),
                            Expanded(
                              child: _PeriodTab(
                                label: 'Monthly',
                                selected: period == ReportPeriod.monthly,
                                onTap: () => filterProvider.setReportPeriod(ReportPeriod.monthly),
                                r: r,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // VELOCITY CHART — switches with toggle
                      if (period == ReportPeriod.daily)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: appCardDecoration(context: context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Weekly Velocity',
                                    style: TextStyle(
                                      fontSize: r.sp(15),
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    _weekRangeLabel(),
                                    style: TextStyle(
                                      fontSize: r.sp(10),
                                      color: AppColors.warmGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Bar chart
                              SizedBox(
                                height: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: bars.map((b) {
                                    final frac = maxBar == 0
                                        ? 0.05
                                        : (b.total / maxBar).clamp(0.05, 1.0);
                                    final isToday =
                                        b.day.day == DateTime.now().day &&
                                            b.day.month ==
                                                DateTime.now().month &&
                                            b.day.year == DateTime.now().year;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (isToday)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Container(
                                                  width: 5,
                                                  height: 5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.goldDark,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              height: 90 * frac,
                                              decoration: BoxDecoration(
                                                color: isToday
                                                    ? AppColors.goldDark
                                                    : AppColors.goldDark
                                                        .withOpacity(0.18),
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Day labels
                              Row(
                                children: bars.map((b) {
                                  final isToday =
                                      b.day.day == DateTime.now().day &&
                                          b.day.month == DateTime.now().month &&
                                          b.day.year == DateTime.now().year;
                                  return Expanded(
                                    child: Text(
                                      _dayLabel(b.day),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: r.sp(10),
                                        fontWeight: isToday
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isToday
                                            ? AppColors.goldDark
                                            : AppColors.warmGrey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: appCardDecoration(context: context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Velocity',
                                style: TextStyle(
                                  fontSize: r.sp(15),
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                height: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: monthBars.map((b) {
                                    final frac = maxMonthBar == 0
                                        ? 0.05
                                        : (b.total / maxMonthBar)
                                            .clamp(0.05, 1.0);
                                    final isCurrent =
                                        b.year == DateTime.now().year &&
                                            b.month == DateTime.now().month;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (isCurrent)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Container(
                                                  width: 5,
                                                  height: 5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.goldDark,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              height: 90 * frac,
                                              decoration: BoxDecoration(
                                                color: isCurrent
                                                    ? AppColors.goldDark
                                                    : AppColors.goldDark
                                                        .withOpacity(0.18),
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: monthBars.map((b) {
                                  final isCurrent =
                                      b.year == DateTime.now().year &&
                                          b.month == DateTime.now().month;
                                  return Expanded(
                                    child: Text(
                                      _monthShortLabel(b.month),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: r.sp(10),
                                        fontWeight: isCurrent
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isCurrent
                                            ? AppColors.goldDark
                                            : AppColors.warmGrey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // BREAKDOWN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            period == ReportPeriod.daily
                                ? 'Daily Breakdown'
                                : 'Monthly Breakdown',
                            style: TextStyle(
                              fontSize: r.sp(15),
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (breakdownRows.isEmpty)
                        const EmptyState(
                          icon: Icons.receipt_outlined,
                          title: 'No sales data',
                          subtitle: 'Sales will appear here once recorded.',
                        )
                      else
                        Container(
                          decoration: appCardDecoration(context: context),
                          child: Column(
                            children: List.generate(breakdownRows.length, (i) {
                              final row = breakdownRows[i];
                              // % change vs next row (the previous period)
                              double? pct;
                              if (i + 1 < breakdownRows.length) {
                                final prev = breakdownRows[i + 1].total;
                                if (prev > 0) {
                                  pct = ((row.total - prev) / prev) * 100;
                                }
                              }
                              final isLast = i == breakdownRows.length - 1;
                              return _BreakdownRow(
                                summary: row,
                                pct: pct,
                                isLast: isLast,
                                r: r,
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekRangeLabel() {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 6));
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return 'Last 7 Days (${months[start.month - 1]} ${start.day} - ${today.day})';
  }

  String _dayLabel(DateTime d) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[d.weekday - 1];
  }

  static const _monthNames = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];
  static const _monthShort = [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  static String _monthLabel(int year, int month) => '${_monthNames[month - 1]} $year';
  static String _monthShortLabel(int month) => _monthShort[month - 1];
}

// PERIOD TOGGLE TAB

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Responsive r;

  const _PeriodTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.goldDark
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: r.sp(12),
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// STAT CARD

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Responsive r;

  const _StatCard({
    required this.label,
    required this.value,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: r.sp(9),
              fontWeight: FontWeight.w700,
              color: AppColors.warmGrey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: r.sp(22),
              fontWeight: FontWeight.w800,
              color:  Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// BREAKDOWN ROW (used for both daily and monthly)

class _BreakdownRow extends StatelessWidget {
  final _PeriodSummary summary;
  final double? pct;
  final bool isLast;
  final Responsive r;

  const _BreakdownRow({
    required this.summary,
    required this.pct,
    required this.isLast,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = pct == null || pct! >= 0;
    final pctLabel = pct == null
        ? null
        : '${isPositive ? '+' : ''}${pct!.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                )),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.primaryLabel,
                  style: TextStyle(
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${summary.txCount} Transaction${summary.txCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: r.sp(11),
                    color: AppColors.warmGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${summary.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: r.sp(14),
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (pctLabel != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.lightGreen
                        : AppColors.lightRed,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    pctLabel,
                    style: TextStyle(
                      fontSize: r.sp(10),
                      fontWeight: FontWeight.w700,
                      color: isPositive
                          ? AppColors.forestGreen
                          : AppColors.darkRed,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// DATA CLASSES

class _DayBar {
  final DateTime day;
  final double total;
  _DayBar({required this.day, required this.total});
}

class _MonthBar {
  final int year;
  final int month;
  final double total;
  _MonthBar({required this.year, required this.month, required this.total});
}

class _PeriodSummary {
  final DateTime sortKey;
  final String primaryLabel;
  final double total;
  final int txCount;

  _PeriodSummary({
    required this.sortKey,
    required this.primaryLabel,
    required this.total,
    required this.txCount,
  });

  _PeriodSummary copyWith({double? total, int? txCount}) => _PeriodSummary(
        sortKey: sortKey,
        primaryLabel: primaryLabel,
        total: total ?? this.total,
        txCount: txCount ?? this.txCount,
      );
}