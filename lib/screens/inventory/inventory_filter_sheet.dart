import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/storage_service.dart';

enum SortOption {
  newlyAdded,
  qtyLowHigh,
  qtyHighLow,
  expirySoonest,
  priceLowHigh,
  priceHighLow,
}

class InventoryFilter {
  final SortOption sortBy;
  final Set<String> statuses;   // 'outOfStock', 'nearExpiry', 'lowStock'
  final Set<String> categories;
  final Set<String> brands;
  final double minPrice;
  final double maxPrice;

  const InventoryFilter({
    this.sortBy = SortOption.newlyAdded,
    this.statuses = const {},
    this.categories = const {},
    this.brands = const {},
    this.minPrice = 0,
    this.maxPrice = 10000,
  });

  InventoryFilter copyWith({
    SortOption? sortBy,
    Set<String>? statuses,
    Set<String>? categories,
    Set<String>? brands,
    double? minPrice,
    double? maxPrice,
  }) {
    return InventoryFilter(
      sortBy:     sortBy     ?? this.sortBy,
      statuses:   statuses   ?? this.statuses,
      categories: categories ?? this.categories,
      brands:     brands     ?? this.brands,
      minPrice:   minPrice   ?? this.minPrice,
      maxPrice:   maxPrice   ?? this.maxPrice,
    );
  }

  bool get isActive =>
      sortBy != SortOption.newlyAdded ||
      statuses.isNotEmpty ||
      categories.isNotEmpty ||
      brands.isNotEmpty ||
      minPrice != 0 ||
      maxPrice != 10000;
}

class InventoryFilterSheet extends StatefulWidget {
  final InventoryFilter current;
  final double maxProductPrice;

  const InventoryFilterSheet({
    super.key,
    required this.current,
    this.maxProductPrice = 10000,
  });

  @override
  State<InventoryFilterSheet> createState() => _InventoryFilterSheetState();
}

class _InventoryFilterSheetState extends State<InventoryFilterSheet> {
  final _storage = StorageService();

  late SortOption _sortBy;
  late Set<String> _statuses;
  late Set<String> _categories;
  late Set<String> _brands;
  late RangeValues _priceRange;

  List<String> _allCategories = [];
  List<String> _allBrands     = [];

  static const _sortLabels = {
    SortOption.newlyAdded:  'Newly Added',
    SortOption.qtyLowHigh:  'Quantity: Low to High',
    SortOption.qtyHighLow:  'Quantity: High to Low',
    SortOption.expirySoonest:'Expiry: Soonest First',
    SortOption.priceLowHigh: 'Price: Low to High',
    SortOption.priceHighLow: 'Price: High to Low',
  };

  @override
  void initState() {
    super.initState();
    final f = widget.current;
    _sortBy     = f.sortBy;
    _statuses   = Set.from(f.statuses);
    _categories = Set.from(f.categories);
    _brands     = Set.from(f.brands);
    _priceRange = RangeValues(f.minPrice, f.maxPrice);
    _allCategories = _storage.getCategories();
    _allBrands     = _storage.getBrands();
  }

  void _toggleStatus(String s) => setState(() {
        _statuses.contains(s) ? _statuses.remove(s) : _statuses.add(s);
      });

  void _toggleCategory(String c) => setState(() {
        _categories.contains(c) ? _categories.remove(c) : _categories.add(c);
      });

  void _toggleBrand(String b) => setState(() {
        _brands.contains(b) ? _brands.remove(b) : _brands.add(b);
      });

  void _reset() => setState(() {
        _sortBy     = SortOption.newlyAdded;
        _statuses   = {};
        _categories = {};
        _brands     = {};
        _priceRange = RangeValues(0, widget.maxProductPrice);
      });

  void _apply() {
    Navigator.pop(
      context,
      InventoryFilter(
        sortBy:     _sortBy,
        statuses:   _statuses,
        categories: _categories,
        brands:     _brands,
        minPrice:   _priceRange.start,
        maxPrice:   _priceRange.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxP = widget.maxProductPrice < 1 ? 10000.0 : widget.maxProductPrice;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // HANDLE 
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 4),

          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_back, color: AppColors.goldDark, size: 20),
                    const SizedBox(width: 8),
                    Text('Filters',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black)),
                  ],
                ),
                GestureDetector(
                  onTap: _reset,
                  child: Text('Reset',
                      style: TextStyle(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.lightGrey.withOpacity(0.5)),

          // SCROLLABLE BODY 
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // SORT BY
                  _sectionLabel('SORT BY'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTop,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: SortOption.values.map((opt) {
                        final isSelected = _sortBy == opt;
                        return GestureDetector(
                          onTap: () => setState(() => _sortBy = opt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: opt != SortOption.values.last
                                    ? BorderSide(
                                        color: AppColors.lightGrey
                                            .withOpacity(0.4),
                                        width: 0.5)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_sortLabels[opt]!,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.black
                                            : AppColors.grey)),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.goldDark
                                          : AppColors.lightGrey,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? AppColors.goldDark
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          size: 10, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PRODUCT STATUS
                  _sectionLabel('PRODUCT STATUS'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusChip('outOfStock', '⚠ Out of Stock', Colors.red),
                      _statusChip('nearExpiry',  'Near Expiry',    Colors.orange),
                      _statusChip('lowStock',    'Low Stock',      AppColors.black),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // CATEGORY
                  _sectionLabel('CATEGORY'),
                  const SizedBox(height: 10),
                  _allCategories.isEmpty
                      ? Text('No categories added yet.',
                          style: TextStyle(
                              color: AppColors.grey, fontSize: 13))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allCategories
                              .map((c) => _filterChip(
                                    label: c,
                                    selected: _categories.contains(c),
                                    onTap: () => _toggleCategory(c),
                                  ))
                              .toList(),
                        ),

                  const SizedBox(height: 20),

                  // BRAND
                  _sectionLabel('BRAND'),
                  const SizedBox(height: 10),
                  _allBrands.isEmpty
                      ? Text('No brands added yet.',
                          style: TextStyle(
                              color: AppColors.grey, fontSize: 13))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allBrands
                              .map((b) => _filterChip(
                                    label: b,
                                    selected: _brands.contains(b),
                                    onTap: () => _toggleBrand(b),
                                  ))
                              .toList(),
                        ),

                  const SizedBox(height: 20),

                  // PRICE RANGE
                  _sectionLabel('PRICE RANGE'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MIN PRICE',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.grey,
                                  letterSpacing: 0.8)),
                          Text('₹${_priceRange.start.toInt()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('MAX PRICE',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.grey,
                                  letterSpacing: 0.8)),
                          Text('₹${_priceRange.end.toInt()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.goldDark,
                      inactiveTrackColor: AppColors.lightGrey,
                      thumbColor: AppColors.goldDark,
                      overlayColor: AppColors.goldDark.withOpacity(0.15),
                      rangeThumbShape:
                          const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                      trackHeight: 4,
                    ),
                    child: RangeSlider(
                      values: RangeValues(
                        _priceRange.start.clamp(0, maxP),
                        _priceRange.end.clamp(0, maxP),
                      ),
                      min: 0,
                      max: maxP,
                      divisions: maxP > 100 ? 100 : maxP.toInt(),
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // BOTTOM BUTTONS 
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: Row(
              children: [
                // Cancel
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.lightGrey, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Apply
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.goldDark, AppColors.goldLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _apply,
                      child: const Text('Apply Filters',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
          letterSpacing: 1.2,
        ),
      );

  Widget _statusChip(String key, String label, Color color) {
    final selected = _statuses.contains(key);
    return GestureDetector(
      onTap: () => _toggleStatus(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : AppColors.backgroundTop,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.lightGrey,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? color : AppColors.grey,
          ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.goldDark.withOpacity(0.1)
              : AppColors.backgroundTop,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.goldDark : AppColors.lightGrey,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.goldDark : AppColors.grey,
          ),
        ),
      ),
    );
  }
}