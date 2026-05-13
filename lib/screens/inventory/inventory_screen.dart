import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'inventory_filter_sheet.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  InventoryFilter _filter = const InventoryFilter();

  Future<void> _openFilter(List<Product> allProducts) async {
    final maxPrice = allProducts.isEmpty
        ? 10000.0
        : allProducts
            .map((p) => p.sellingPrice)
            .reduce((a, b) => a > b ? a : b);

    final result = await showModalBottomSheet<InventoryFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => InventoryFilterSheet(
          current: _filter,
          maxProductPrice: maxPrice,
        ),
      ),
    );

    if (result != null) setState(() => _filter = result);
  }

  List<Product> _applyFilter(List<Product> products) {
    var list = List<Product>.from(products);

    if (_filter.statuses.isNotEmpty) {
      list = list.where((p) {
        if (_filter.statuses.contains('outOfStock') && p.quantity == 0)
          return true;
        if (_filter.statuses.contains('lowStock') &&
            p.quantity > 0 &&
            p.quantity <= p.lowStockThreshold) return true;
        if (_filter.statuses.contains('nearExpiry') &&
            p.expiryDate != null) {
          final exp = DateTime.tryParse(p.expiryDate!);
          if (exp != null) {
            final days = exp.difference(DateTime.now()).inDays;
            if (days >= 0 && days <= 7) return true;
          }
        }
        return false;
      }).toList();
    }

    if (_filter.categories.isNotEmpty) {
      list = list
          .where((p) => _filter.categories.contains(p.category))
          .toList();
    }

    list = list
        .where((p) =>
            p.sellingPrice >= _filter.minPrice &&
            p.sellingPrice <= _filter.maxPrice)
        .toList();

    switch (_filter.sortBy) {
      case SortOption.newlyAdded:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.qtyLowHigh:
        list.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case SortOption.qtyHighLow:
        list.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case SortOption.expirySoonest:
        list.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return DateTime.parse(a.expiryDate!)
              .compareTo(DateTime.parse(b.expiryDate!));
        });
        break;
      case SortOption.priceLowHigh:
        list.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case SortOption.priceHighLow:
        list.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.goldDark,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddProductScreen())),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // APP BAR 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Inventory',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black)),
                  const Spacer(),
                  if (_filter.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Filtered',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),

            // SEARCH + FILTER 
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Consumer<ProductProvider>(
                builder: (_, provider, __) => Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppColors.lightGrey.withOpacity(0.5)),
                        ),
                        child: TextField(
                          onChanged: provider.setSearch,
                          decoration: InputDecoration(
                            hintText: 'Search inventory',
                            hintStyle: TextStyle(
                                color: AppColors.grey, fontSize: 13),
                            prefixIcon: Icon(Icons.search,
                                color: AppColors.grey, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _openFilter(provider.allProducts),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: _filter.isActive
                              ? AppColors.goldDark
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _filter.isActive
                                  ? AppColors.goldDark
                                  : AppColors.lightGrey.withOpacity(0.5)),
                        ),
                        child: Icon(Icons.tune_rounded,
                            color: _filter.isActive
                                ? Colors.white
                                : AppColors.black,
                            size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PRODUCT LIST 
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (_, provider, __) {
                  final products =
                      _applyFilter(provider.filteredProducts);

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: AppColors.lightGrey),
                          const SizedBox(height: 12),
                          Text(
                            _filter.isActive
                                ? 'No products match filters'
                                : 'No products yet',
                            style: TextStyle(
                                color: AppColors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _filter.isActive
                                ? () => setState(
                                    () => _filter = const InventoryFilter())
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const AddProductScreen())),
                            child: Text(
                              _filter.isActive
                                  ? 'Clear filters'
                                  : 'Add your first product ',
                              style: TextStyle(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      ...products
                          .take(products.length > 2
                              ? products.length - 2
                              : products.length)
                          .map((p) => _LargeProductCard(product: p))
                          .toList(),
                      if (products.length >= 2)
                        Row(
                          children: products
                              .skip(products.length > 2
                                  ? products.length - 2
                                  : products.length)
                              .take(2)
                              .map((p) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              products.last == p ? 0 : 8),
                                      child:
                                          _SmallProductCard(product: p),
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
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

//  HELPERS 
Widget _productImage({
  String? imagePath,
  double size = 72,
  double radius = 12,
}) {
  final hasImage = imagePath != null && imagePath.isNotEmpty;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.lightGrey.withOpacity(0.3),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: hasImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.file(File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.grey,
                    size: size * 0.42)),
          )
        : Icon(Icons.inventory_2_rounded,
            color: AppColors.grey, size: size * 0.42),
  );
}

// 
// LARGE PRODUCT CARD
// 
class _LargeProductCard extends StatelessWidget {
  final Product product;
  const _LargeProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final status = _getStatus(product);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _productImage(imagePath: product.imagePath, size: 72, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (status != null)
                      _badge(status['label']!, status['color']!),
                    const SizedBox(width: 6),
                    _categoryBadge(product.category),
                  ],
                ),
                const SizedBox(height: 6),
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('₹${product.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.black)),
                    const SizedBox(width: 10),
                    if (product.expiryDate != null)
                      Text('Exp. ${_formatDate(product.expiryDate!)}',
                          style: TextStyle(
                              color: AppColors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Text(product.quantity.toString().padLeft(2, '0'),
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black)),
                  Text('UNITS\nLEFT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 8,
                          color: AppColors.grey,
                          letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                EditProductScreen(product: product))),
                    child: Icon(Icons.edit_rounded,
                        color: AppColors.goldDark, size: 18),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => context
                        .read<ProductProvider>()
                        .deleteProduct(product.id),
                    child: Icon(Icons.delete_rounded,
                        color: AppColors.darkRed, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _getStatus(Product p) {
    if (p.expiryDate != null) {
      final expiry = DateTime.tryParse(p.expiryDate!);
      if (expiry != null) {
        final days = expiry.difference(DateTime.now()).inDays;
        if (days < 0) return {'label': 'EXPIRED', 'color': Colors.red};
        if (days <= 3)
          return {'label': 'NEAR EXPIRY', 'color': Colors.orange};
      }
    }
    if (p.quantity == 0)
      return {'label': 'OUT OF STOCK', 'color': Colors.red};
    if (p.quantity <= p.lowStockThreshold)
      return {'label': 'LOW STOCK', 'color': Colors.orange};
    return null;
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return '';
    }
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3)),
      );

  Widget _categoryBadge(String category) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6)),
        child: Text(category.toUpperCase(),
            style: TextStyle(
                color: AppColors.grey,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3)),
      );
}

// 
// SMALL PRODUCT CARD
// 
class _SmallProductCard extends StatelessWidget {
  final Product product;
  const _SmallProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _productImage(
                  imagePath: product.imagePath, size: 40, radius: 8),
              Text(product.quantity.toString().padLeft(2, '0'),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4)),
            child: Text(product.category.toUpperCase(),
                style: TextStyle(
                    fontSize: 8,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          Text(product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${product.sellingPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                EditProductScreen(product: product))),
                    child: Icon(Icons.edit_rounded,
                        color: AppColors.goldDark, size: 14),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context
                        .read<ProductProvider>()
                        .deleteProduct(product.id),
                    child: Icon(Icons.delete_rounded,
                        color: Colors.red, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}