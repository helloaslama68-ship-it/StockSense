import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/enums.dart';
import '../../providers/sale_filter_provider.dart';
import '../../widgets/gold_button.dart';

class SalesReportFilterSheet extends StatelessWidget {
  const SalesReportFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final provider = context.watch<SaleFilterProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            //TOP BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded,
                      size: 22, color: Theme.of(context).colorScheme.onSurface),
                ),
                Text(
                  'Filter Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    provider.resetDraft();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            //  DATE RANGE
            _SectionLabel(label: 'Date Range', r: r),
            const SizedBox(height: 10),

            // Presets grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.6,
              children: [
                _DatePreset(
                  title: 'Today',
                  subtitle: 'REAL-TIME',
                  selected: provider.draftDateRange != null &&
                      _isToday(provider.draftDateRange!),
                  onTap: () => provider.setDraftDateRange(DateTimeRange(
                    start: _startOfDay(DateTime.now()),
                    end: _endOfDay(DateTime.now()),
                  )),
                  r: r,
                ),
                _DatePreset(
                  title: 'Yesterday',
                  subtitle: '24H HISTORY',
                  selected: provider.draftDateRange != null &&
                      _isYesterday(provider.draftDateRange!),
                  onTap: () {
                    final y =
                        DateTime.now().subtract(const Duration(days: 1));
                    provider.setDraftDateRange(DateTimeRange(
                      start: _startOfDay(y),
                      end: _endOfDay(y),
                    ));
                  },
                  r: r,
                ),
                _DatePreset(
                  title: 'Last 7 Days',
                  subtitle: 'WEEKLY SCAN',
                  selected: provider.draftDateRange != null &&
                      _isLast7(provider.draftDateRange!),
                  onTap: () => provider.setDraftDateRange(DateTimeRange(
                    start: _startOfDay(
                        DateTime.now().subtract(const Duration(days: 6))),
                    end: _endOfDay(DateTime.now()),
                  )),
                  r: r,
                ),
                _DatePreset(
                  title: 'Last 30 Days',
                  subtitle: 'MONTHLY PEAK',
                  selected: provider.draftDateRange != null &&
                      _isLast30(provider.draftDateRange!),
                  onTap: () => provider.setDraftDateRange(DateTimeRange(
                    start: _startOfDay(
                        DateTime.now().subtract(const Duration(days: 29))),
                    end: _endOfDay(DateTime.now()),
                  )),
                  r: r,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Custom range row
            GestureDetector(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: provider.draftDateRange,
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: AppColors.goldDark),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) provider.setDraftDateRange(picked);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 18, color: AppColors.goldDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.draftDateRange != null &&
                                !_isPreset(provider.draftDateRange!)
                            ? '${formatShortDate(provider.draftDateRange!.start)} – ${formatShortDate(provider.draftDateRange!.end)}'
                            : 'Custom Range',
                        style: TextStyle(
                          fontSize: r.sp(13),
                          fontWeight: FontWeight.w600,
                          color: provider.draftDateRange != null &&
                                  !_isPreset(provider.draftDateRange!)
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.warmGrey,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.warmGrey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            //  CHANNEL
            _SectionLabel(label: 'Channel', r: r),
            const SizedBox(height: 10),

            Row(
              children: [
                _ChannelChip(
                  label: 'All',
                  selected: provider.draftChannel == null,
                  onTap: () => provider.setDraftChannel(null),
                  r: r,
                ),
                const SizedBox(width: 8),
                _ChannelChip(
                  label: 'In-Store',
                  selected: provider.draftChannel == SaleChannel.inStore,
                  onTap: () => provider.setDraftChannel(SaleChannel.inStore),
                  r: r,
                ),
                const SizedBox(width: 8),
                _ChannelChip(
                  label: 'Online',
                  selected: provider.draftChannel == SaleChannel.online,
                  onTap: () => provider.setDraftChannel(SaleChannel.online),
                  r: r,
                ),
              ],
            ),

            const SizedBox(height: 24),

            //  AMOUNT RANGE
            _SectionLabel(label: 'Amount Range', r: r),
            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${provider.draftAmountRange.start.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: r.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDark,
                  ),
                ),
                Text(
                  provider.draftAmountRange.end >=
                          SaleFilterProvider.kMaxAmount
                      ? '₹${SaleFilterProvider.kMaxAmount.toStringAsFixed(0)}+'
                      : '₹${provider.draftAmountRange.end.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: r.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.goldDark,
                inactiveTrackColor: AppColors.goldDark.withOpacity(0.15),
                thumbColor: AppColors.goldDark,
                overlayColor: AppColors.goldDark.withOpacity(0.12),
                rangeThumbShape:
                    const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: RangeSlider(
                values: provider.draftAmountRange,
                min: 0,
                max: SaleFilterProvider.kMaxAmount,
                divisions: 100,
                onChanged: (v) => provider.setDraftAmountRange(v),
              ),
            ),

            const SizedBox(height: 16),

            // INSIGHT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.goldDark.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.goldDark.withOpacity(0.2), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.goldDark.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        size: 14, color: AppColors.goldDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STOCKSENSE INSIGHT',
                          style: TextStyle(
                            fontSize: r.sp(9),
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldDark,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Narrowing your search improves dashboard performance by 26%.',
                          style: TextStyle(
                            fontSize: r.sp(12),
                            color: AppColors.charcoalGrey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // APPLY
            GoldButton(
              label: 'Apply Filters',
              icon: Icons.check_circle_outline_rounded,
              onPressed: () {
                provider.applyDraft();
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 12),

            //  CLEAR
            GestureDetector(
              onTap: () {
                provider.resetDraft();
                provider.reset();
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  'Clear all preferences',
                  style: TextStyle(
                    fontSize: r.sp(12),
                    color: AppColors.warmGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helpers
  static DateTime _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);
  static DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);

  static bool _isToday(DateTimeRange r) {
    final t = DateTime.now();
    return r.start.year == t.year &&
        r.start.month == t.month &&
        r.start.day == t.day &&
        r.end.day == t.day &&
        r.end.hour == 23;
  }

  static bool _isYesterday(DateTimeRange r) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return r.start.day == y.day &&
        r.start.month == y.month &&
        r.end.day == y.day;
  }

  static bool _isLast7(DateTimeRange r) {
    final start =
        _startOfDay(DateTime.now().subtract(const Duration(days: 6)));
    return r.start.year == start.year &&
        r.start.month == start.month &&
        r.start.day == start.day;
  }

  static bool _isLast30(DateTimeRange r) {
    final start =
        _startOfDay(DateTime.now().subtract(const Duration(days: 29)));
    return r.start.year == start.year &&
        r.start.month == start.month &&
        r.start.day == start.day;
  }

  static bool _isPreset(DateTimeRange r) =>
      _isToday(r) || _isYesterday(r) || _isLast7(r) || _isLast30(r);
}

// DATE PRESET CHIP

class _DatePreset extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Responsive r;

  const _DatePreset({
    required this.title,
    required this.subtitle,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDark : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.goldDark
                : Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: r.sp(12),
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: r.sp(9),
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.white.withOpacity(0.7)
                    : AppColors.warmGrey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CHANNEL CHIP

class _ChannelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Responsive r;

  const _ChannelChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDark : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.goldDark : Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: r.sp(12),
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// SECTION LABEL

class _SectionLabel extends StatelessWidget {
  final String label;
  final Responsive r;

  const _SectionLabel({required this.label, required this.r});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: r.sp(13),
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}