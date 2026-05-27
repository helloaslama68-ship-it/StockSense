import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_badge.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'inventory_filter_sheet.dart';
import 'product_details_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  Future<void> _openFilter(
      BuildContext context, List<Product> allProducts) async {
    final provider = context.read<ProductProvider>();
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
          current: provider.filter,
          maxProductPrice: maxPrice,
        ),
      ),
    );
    if (result != null) provider.setFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.backgroundTop,
        floatingActionButton: _GoldFAB(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddProductScreen())),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _InventoryHeader(onFilterTap: _openFilter),

              // STATS STRIP
              const _StatsStrip(),

              // SEARCH BAR
              _SearchBar(onFilterTap: _openFilter),

              // LIST
              const Expanded(child: _ProductList()),
            ],
          ),
        ),
      ),
    );
  }
}


// HEADER


class _InventoryHeader extends StatelessWidget {
  final Future<void> Function(BuildContext, List<Product>) onFilterTap;
  const _InventoryHeader({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Consumer<ProductProvider>(
        builder: (_, provider, __) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVENTORY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldLight,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'My Products',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldDark,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (provider.filter.isActive)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.goldDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_alt_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    const Text('Filtered',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                  ],
                ),
              ),
            // Total count badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldDark.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.goldDark.withOpacity(0.15), width: 1),
              ),
              child: Text(
                '${provider.allProducts.length} items',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// STATS STRIP


class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        final all = provider.allProducts;
        final outOfStock = all.where((p) => p.quantity == 0).length;
        final lowStock =
            all.where((p) => p.quantity > 0 && p.quantity <= p.lowStockThreshold).length;
        final totalValue =
            all.fold<double>(0, (sum, p) => sum + p.sellingPrice * p.quantity);

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.goldDark, const Color(0xFFB87C1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldDark.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _StatItem(
                label: 'Total Value',
                value: '₹${_formatValue(totalValue)}',
                icon: Icons.account_balance_wallet_rounded,
              ),
              _divider(),
              _StatItem(
                label: 'Low Stock',
                value: '$lowStock',
                icon: Icons.warning_amber_rounded,
                valueColor: lowStock > 0
                    ? const Color(0xFFFFE082)
                    : Colors.white,
              ),
              _divider(),
              _StatItem(
                label: 'Out of Stock',
                value: '$outOfStock',
                icon: Icons.remove_shopping_cart_rounded,
                valueColor: outOfStock > 0
                    ? const Color(0xFFFF8A80)
                    : Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white.withOpacity(0.2),
      );

  String _formatValue(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor ?? Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}


// SEARCH BAR


class _SearchBar extends StatelessWidget {
  final Future<void> Function(BuildContext, List<Product>) onFilterTap;
  const _SearchBar({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Consumer<ProductProvider>(
        builder: (_, provider, __) => Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldDark.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: provider.setSearch,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search products…',
                    hintStyle: TextStyle(
                        color: AppColors.warmGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.goldLight, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => onFilterTap(context, provider.allProducts),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: provider.filter.isActive
                      ? AppColors.goldDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: provider.filter.isActive
                          ? AppColors.goldDark.withOpacity(0.35)
                          : AppColors.goldDark.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.tune_rounded,
                    color: provider.filter.isActive
                        ? Colors.white
                        : AppColors.goldDark,
                    size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// PRODUCT LIST


class _ProductList extends StatelessWidget {
  const _ProductList();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        final products = provider.filteredAndSorted;

        if (products.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: provider.filter.isActive
                ? 'No products match filters'
                : 'No products yet',
            subtitle: provider.filter.isActive
                ? 'Try adjusting your filters'
                : 'Tap to add your first product',
            iconColor: AppColors.lightGrey,
            buttonLabel:
                provider.filter.isActive ? 'Clear Filters' : 'Add Product',
            onButton: provider.filter.isActive
                ? provider.clearFilter
                : () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AddProductScreen())),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _ProductCard(product: products[index], index: index);
          },
        );
      },
    );
  }
}


// PRODUCT CARD


class _ProductCard extends StatelessWidget {
  final Product product;
  final int index;
  const _ProductCard({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final status = _getStatus(product);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldDark.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4,
                  color: status != null
                      ? (status['color'] as Color)
                      : AppColors.goldLight,
                ),
                // Image
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _productImage(
                      imagePath: product.imagePath, size: 64, radius: 10),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            if (status != null) ...[
                              _StatusChip(
                                  label: status['label'] as String,
                                  color: status['color'] as Color),
                              const SizedBox(width: 6),
                            ],
                            CategoryBadge(category: product.category),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Name
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Price + Expiry
                        Row(
                          children: [
                            Text(
                              '₹${product.sellingPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.goldDark,
                              ),
                            ),
                            if (product.expiryDate != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.warmGrey.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Exp ${_formatDate(product.expiryDate!)}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.warmGrey,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Right: qty + actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Quantity
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            product.quantity.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: product.quantity == 0
                                  ? AppColors.darkRed
                                  : product.quantity <= product.lowStockThreshold
                                      ? AppColors.orange
                                      : AppColors.goldDark,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'units',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.warmGrey,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Actions
                      Row(
                        children: [
                          _ActionBtn(
                            icon: Icons.edit_rounded,
                            color: AppColors.goldDark,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EditProductScreen(product: product))),
                          ),
                          const SizedBox(width: 8),
                          _ActionBtn(
                            icon: Icons.delete_rounded,
                            color: AppColors.darkRed,
                            onTap: () => context
                                .read<ProductProvider>()
                                .deleteProduct(product.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _getStatus(Product p) {
    if (p.expiryDate != null) {
      final expiry = DateTime.tryParse(p.expiryDate!);
      if (expiry != null) {
        final days = expiry.difference(DateTime.now()).inDays;
        if (days < 0) return {'label': 'EXPIRED', 'color': AppColors.darkRed};
        if (days <= 3)
          return {'label': 'NEAR EXPIRY', 'color': AppColors.orange};
      }
    }
    if (p.quantity == 0)
      return {'label': 'OUT OF STOCK', 'color': AppColors.darkRed};
    if (p.quantity <= p.lowStockThreshold)
      return {'label': 'LOW STOCK', 'color': AppColors.orange};
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
}


// HELPERS & MICRO WIDGETS


class _GoldFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _GoldFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.goldLight, AppColors.goldDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.goldDark.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}

Widget _productImage({
  String? imagePath,
  double size = 64,
  double radius = 10,
}) {
  final hasImage = imagePath != null && imagePath.isNotEmpty;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.backgroundTop,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
          color: AppColors.goldLight.withOpacity(0.2), width: 1),
    ),
    child: hasImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius - 1),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.inventory_2_rounded,
                color: AppColors.warmGrey,
                size: size * 0.4,
              ),
            ),
          )
        : Icon(Icons.inventory_2_rounded,
            color: AppColors.warmGrey, size: size * 0.4),
  );
}