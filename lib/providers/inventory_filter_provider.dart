import 'package:flutter/material.dart';

enum SortOption { newlyAdded, qtyLowHigh, qtyHighLow, expirySoonest, priceLowHigh, priceHighLow }

class InventoryFilter {
  final SortOption  sortBy;
  final Set<String> statuses, categories, brands;
  final double      minPrice, maxPrice;

  const InventoryFilter({
    this.sortBy = SortOption.newlyAdded,
    this.statuses = const {}, this.categories = const {}, this.brands = const {},
    this.minPrice = 0, this.maxPrice = 10000,
  });

  InventoryFilter copyWith({SortOption? sortBy, Set<String>? statuses,
      Set<String>? categories, Set<String>? brands, double? minPrice, double? maxPrice}) =>
    InventoryFilter(
      sortBy: sortBy ?? this.sortBy, statuses: statuses ?? this.statuses,
      categories: categories ?? this.categories, brands: brands ?? this.brands,
      minPrice: minPrice ?? this.minPrice, maxPrice: maxPrice ?? this.maxPrice,
    );

  bool get isActive => sortBy != SortOption.newlyAdded || statuses.isNotEmpty ||
      categories.isNotEmpty || brands.isNotEmpty || minPrice != 0 || maxPrice != 10000;
}

class InventoryFilterProvider extends ChangeNotifier {
  SortOption   _sortBy     = SortOption.newlyAdded;
  Set<String>  _statuses   = {}, _categories = {}, _brands = {};
  RangeValues  _priceRange = const RangeValues(0, 10000);
  List<String> _allCategories = [], _allBrands = [];

  SortOption   get sortBy        => _sortBy;
  Set<String>  get statuses      => _statuses;
  Set<String>  get categories    => _categories;
  Set<String>  get brands        => _brands;
  RangeValues  get priceRange    => _priceRange;
  List<String> get allCategories => _allCategories;
  List<String> get allBrands     => _allBrands;

  void init(InventoryFilter f, List<String> cats, List<String> brands) {
    _sortBy = f.sortBy; _statuses = Set.from(f.statuses);
    _categories = Set.from(f.categories); _brands = Set.from(f.brands);
    _priceRange = RangeValues(f.minPrice, f.maxPrice);
    _allCategories = cats; _allBrands = brands;
    notifyListeners();
  }

  void setSortBy(SortOption opt)   { _sortBy = opt; notifyListeners(); }
  void toggleStatus(String s)      { _statuses.contains(s) ? _statuses.remove(s) : _statuses.add(s); notifyListeners(); }
  void toggleCategory(String c)    { _categories.contains(c) ? _categories.remove(c) : _categories.add(c); notifyListeners(); }
  void toggleBrand(String b)       { _brands.contains(b) ? _brands.remove(b) : _brands.add(b); notifyListeners(); }
  void setPriceRange(RangeValues v) { _priceRange = v; notifyListeners(); }

  void reset() {
    _sortBy = SortOption.newlyAdded; _statuses = {}; _categories = {}; _brands = {};
    _priceRange = const RangeValues(0, 10000); notifyListeners();
  }

  InventoryFilter toFilter() => InventoryFilter(
    sortBy: _sortBy, statuses: Set.from(_statuses), categories: Set.from(_categories),
    brands: Set.from(_brands), minPrice: _priceRange.start, maxPrice: _priceRange.end,
  );
}