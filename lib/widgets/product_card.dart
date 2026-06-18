import 'dart:io';
import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imagePath != null &&
        product.imagePath!.isNotEmpty;
    final isLow = product.quantity <= product.lowStockThreshold;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // image
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.lightGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                          File(product.imagePath!),
                          fit: BoxFit.cover),
                    )
                  : Icon(Icons.inventory_2_rounded,
                      color: AppColors.goldDark, size: 26),
            ),
            const SizedBox(width: 12),

            // name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(product.category,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 11,
                          color: isLow ? AppColors.red : AppColors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${product.quantity} units',
                        style: TextStyle(
                          fontSize: 11,
                          color: isLow ? AppColors.red : AppColors.grey,
                          fontWeight: isLow
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (isLow) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('LOW',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}