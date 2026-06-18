import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../providers/sale_filter_provider.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/app_sheet_handle.dart';
import '../../widgets/gold_button.dart';

class SaleFilterSheet extends StatelessWidget {
  const SaleFilterSheet({super.key});

  static const _sortMeta = <SaleSortOption, (String, IconData)>{
    SaleSortOption.newest:        ('Newest First',       Icons.arrow_downward_rounded),
    SaleSortOption.oldest:        ('Oldest First',       Icons.arrow_upward_rounded),
    SaleSortOption.amountHighLow: ('Amount: High → Low', Icons.trending_down_rounded),
    SaleSortOption.amountLowHigh: ('Amount: Low → High', Icons.trending_up_rounded),
  };

  Future<void> _pickDateRange(BuildContext context, SaleFilterProvider p) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: p.draftDateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.goldDark,
            onPrimary: AppColors.white,
            surface: AppColors.backgroundTop,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) p.setDraftDateRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SaleFilterProvider>().initDraft());

    return Consumer<SaleFilterProvider>(
      builder: (context, p, _) {
        final active = p.draftActiveCount;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const AppSheetHandle(),
              const SizedBox(height: 4),

              // Header
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: appCardDecoration(radius: 10),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.goldDark),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Row(
                        children: [
                           Text('Filters',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface)),
                          if (active > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.goldDark,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('$active',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (active > 0)
                      GestureDetector(
                        onTap: p.resetDraft,
                        child: const Text('Reset',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  Sort
                      const AppSectionLabel(label: 'SORT BY'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: SaleSortOption.values.map((opt) {
                          final (label, icon) = _sortMeta[opt]!;
                          final isActive = p.draftSortBy == opt;
                          return GestureDetector(
                            onTap: () => p.setDraftSort(opt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.goldDark : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive ? AppColors.goldDark : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, size: 14,
                                      color: isActive ? AppColors.white : Theme.of(context).colorScheme.onSurface),
                                  const SizedBox(width: 6),
                                  Text(label,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isActive ? AppColors.white : Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      //  Channel
                      const AppSectionLabel(label: 'CHANNEL'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          AppFilterChip(label: 'All',      active: p.draftChannel == '',         onTap: () => p.setDraftChannel('')),
                          AppFilterChip(label: 'In-Store', active: p.draftChannel == 'in-store', onTap: () => p.setDraftChannel('in-store')),
                          AppFilterChip(label: 'Online',   active: p.draftChannel == 'online',   onTap: () => p.setDraftChannel('online')),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Customer search
                      const AppSectionLabel(label: 'CUSTOMER'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: p.draftCustomerCtrl,
                        onChanged: p.setDraftCustomer,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search customer or receipt #…',
                          hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.goldDark),
                          suffixIcon: p.draftCustomerQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    p.draftCustomerCtrl.clear();
                                    p.setDraftCustomer('');
                                  },
                                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.grey),
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.goldDark, width: 1.5)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Date Range
                      const AppSectionLabel(label: 'DATE RANGE'),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _pickDateRange(context, p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: p.draftDateRange != null ? AppColors.goldDark : Theme.of(context).colorScheme.outline,
                              width: p.draftDateRange != null ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.date_range_rounded,
                                  size: 18,
                                  color: p.draftDateRange != null ? AppColors.goldDark : AppColors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.draftDateRange == null
                                      ? 'Select date range'
                                      : '${formatDate(p.draftDateRange!.start)}  →  ${formatDate(p.draftDateRange!.end)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: p.draftDateRange != null ? Theme.of(context).colorScheme.onSurface : AppColors.grey,
                                    fontWeight: p.draftDateRange != null ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (p.draftDateRange != null)
                                GestureDetector(
                                  onTap: () => p.setDraftDateRange(null),
                                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Amount Range
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppSectionLabel(label: 'AMOUNT RANGE'),
                          Text(
                            p.draftAmountRange.end >= SaleFilterProvider.kMaxAmount
                                ? '₹${p.draftAmountRange.start.toStringAsFixed(0)} – Any'
                                : '₹${p.draftAmountRange.start.toStringAsFixed(0)} – ₹${p.draftAmountRange.end.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.goldDark,
                          inactiveTrackColor: AppColors.goldDark.withOpacity(0.15),
                          thumbColor: AppColors.goldDark,
                          overlayColor: AppColors.goldDark.withOpacity(0.12),
                          rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: RangeSlider(
                          values: p.draftAmountRange,
                          min: 0,
                          max: SaleFilterProvider.kMaxAmount,
                          divisions: 200,
                          onChanged: p.setDraftAmountRange,
                        ),
                      ),

                      const SizedBox(height: 28),

                      GoldButton(
                        label: active > 0 ? 'Apply Filters ($active)' : 'Apply',
                        onPressed: () {
                          p.applyDraft();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
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