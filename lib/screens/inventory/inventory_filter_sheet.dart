import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../widgets/app_sheet_handle.dart';
import '../../providers/inventory_filter_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/app_card.dart';
export '../../providers/inventory_filter_provider.dart'
    show InventoryFilter, SortOption;

class InventoryFilterSheet extends StatelessWidget {
  final InventoryFilter current;
  final double maxProductPrice;

  const InventoryFilterSheet({
    super.key,
    required this.current,
    this.maxProductPrice = 10000,
  });

  static const _sortLabels = {
    SortOption.newlyAdded:    ('Newly Added',        Icons.fiber_new_rounded),
    SortOption.qtyLowHigh:    ('Qty: Low → High',    Icons.arrow_upward_rounded),
    SortOption.qtyHighLow:    ('Qty: High → Low',    Icons.arrow_downward_rounded),
    SortOption.expirySoonest: ('Expiry: Soonest',    Icons.event_rounded),
    SortOption.priceLowHigh:  ('Price: Low → High',  Icons.trending_up_rounded),
    SortOption.priceHighLow:  ('Price: High → Low',  Icons.trending_down_rounded),
  };

  void _init(BuildContext context) {
    final inv = context.read<InventoryProvider>();
    context.read<InventoryFilterProvider>().init(
      current,
      inv.categories,
      inv.brands,
    );
  }

  void _apply(BuildContext context) {
    Navigator.pop(
      context,
      context.read<InventoryFilterProvider>().toFilter(),
    );
  }

  int _activeCount(InventoryFilterProvider p) {
    int c = 0;
    if (p.sortBy != SortOption.newlyAdded) c++;
    c += p.statuses.length + p.categories.length + p.brands.length;
    final maxP = maxProductPrice < 1 ? 10000.0 : maxProductPrice;
    if (p.priceRange.start != 0 || p.priceRange.end != maxP) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    // Init provider with current filter + inventory data once
    WidgetsBinding.instance.addPostFrameCallback((_) => _init(context));

    final maxP = maxProductPrice < 1 ? 10000.0 : maxProductPrice;

    return Consumer<InventoryFilterProvider>(
      builder: (context, p, _) {
        final activeCount = _activeCount(p);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundTop,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle 
              const SizedBox(height: 12),
              const AppSheetHandle(),
              const SizedBox(height: 4),

              // Header 
              Container(
                color: AppColors.backgroundTop,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
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
                                  color: AppColors.black)),
                          if (activeCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.goldDark, AppColors.goldLight],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('$activeCount',
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: p.reset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.goldDark.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.goldDark.withOpacity(0.25)),
                        ),
                        child: Text('Reset all',
                            style: TextStyle(
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: AppColors.lightGrey.withOpacity(0.6)),

              // Scrollable body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //Sort By 
                      AppSectionLabel(label: 'SORT BY'),
                      const SizedBox(height: 10),
                      AppCard(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: SortOption.values.map((opt) {
                            final info     = _sortLabels[opt]!;
                            final selected = p.sortBy == opt;
                            return GestureDetector(
                              onTap: () => p.setSortBy(opt),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.goldDark.withOpacity(0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: selected
                                      ? Border.all(
                                          color: AppColors.goldDark.withOpacity(0.3),
                                          width: 1)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.goldDark.withOpacity(0.12)
                                            : AppColors.backgroundTop,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(info.$2,
                                          size: 16,
                                          color: selected
                                              ? AppColors.goldDark
                                              : AppColors.warmGrey),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(info.$1,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: selected
                                                  ? AppColors.black
                                                  : AppColors.warmGrey)),
                                    ),
                                    if (selected)
                                      Container(
                                        width: 20, height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.goldDark,
                                              AppColors.goldLight
                                            ],
                                          ),
                                        ),
                                        child: const Icon(Icons.check_rounded,
                                            size: 12, color: Colors.white),
                                      )
                                    else
                                      Container(
                                        width: 20, height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.lightGrey,
                                              width: 1.5),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Product Stat
                      AppSectionLabel(label: 'PRODUCT STATUS'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _statusCard(p, 'outOfStock', 'Out of Stock', Icons.warning_rounded,      AppColors.red)),
                          const SizedBox(width: 8),
                          Expanded(child: _statusCard(p, 'nearExpiry',  'Near Expiry',  Icons.hourglass_bottom_rounded, AppColors.orange)),
                          const SizedBox(width: 8),
                          Expanded(child: _statusCard(p, 'lowStock',    'Low Stock',    Icons.inventory_2_rounded,   AppColors.black)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Category
                      AppSectionLabel(label: 'CATEGORY'),
                      const SizedBox(height: 10),
                      p.allCategories.isEmpty
                          ? _emptyChipHint('No categories added yet')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: p.allCategories
                                  .map((c) => _filterChip(
                                        label: c,
                                        selected: p.categories.contains(c),
                                        onTap: () => p.toggleCategory(c),
                                      ))
                                  .toList(),
                            ),

                      const SizedBox(height: 20),

                      // Brand 
                      AppSectionLabel(label: 'BRAND'),
                      const SizedBox(height: 10),
                      p.allBrands.isEmpty
                          ? _emptyChipHint('No brands added yet')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: p.allBrands
                                  .map((b) => _filterChip(
                                        label: b,
                                        selected: p.brands.contains(b),
                                        onTap: () => p.toggleBrand(b),
                                      ))
                                  .toList(),
                            ),

                      const SizedBox(height: 20),

                      // Price Range 
                      AppSectionLabel(label: 'PRICE RANGE'),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _priceBox(
                                      'MIN', '₹${p.priceRange.start.toInt()}'),
                                ),
                                Container(
                                  width: 1, height: 36,
                                  color: AppColors.lightGrey,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                Expanded(
                                  child: _priceBox(
                                      'MAX', '₹${p.priceRange.end.toInt()}',
                                      align: CrossAxisAlignment.end),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.goldDark,
                                inactiveTrackColor: AppColors.lightGrey,
                                thumbColor: AppColors.goldDark,
                                overlayColor: AppColors.goldDark.withOpacity(0.12),
                                rangeThumbShape: const RoundRangeSliderThumbShape(
                                    enabledThumbRadius: 11),
                                trackHeight: 4,
                              ),
                              child: RangeSlider(
                                values: RangeValues(
                                  p.priceRange.start.clamp(0, maxP),
                                  p.priceRange.end.clamp(0, maxP),
                                ),
                                min: 0,
                                max: maxP,
                                divisions: maxP > 100 ? 100 : maxP.toInt(),
                                onChanged: p.setPriceRange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Footer Buttons 
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GoldButton(
                        label: 'Cancel',
                        outlined: true,
                        height: 50,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GoldButton(
                        label: 'Apply Filters',
                        height: 50,
                        icon: Icons.tune_rounded,
                        onPressed: () => _apply(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusCard(InventoryFilterProvider p,
      String key, String label, IconData icon, Color color) {
    final selected = p.statuses.contains(key);
    return GestureDetector(
      onTap: () => p.toggleStatus(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.10) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.lightGrey,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
              : [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppColors.warmGrey, size: 22),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : AppColors.warmGrey)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDark.withOpacity(0.10) : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.goldDark : AppColors.lightGrey,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.goldDark.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded, size: 13, color: AppColors.goldDark),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.goldDark : AppColors.warmGrey)),
          ],
        ),
      ),
    );
  }

  Widget _priceBox(String label, String value,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.warmGrey,
                letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black)),
      ],
    );
  }

  Widget _emptyChipHint(String msg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lightGrey.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: AppColors.warmGrey),
            const SizedBox(width: 6),
            Text(msg, style: TextStyle(color: AppColors.warmGrey, fontSize: 13)),
          ],
        ),
      );
}