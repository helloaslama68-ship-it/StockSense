import 'package:flutter/material.dart';
import '../core/colors.dart';

class ManageCountLabel extends StatelessWidget {
  final int total;
  final int filtered;
  final String label;
  final bool isFiltering;

  const ManageCountLabel({
    super.key,
    required this.total,
    required this.filtered,
    required this.label,
    required this.isFiltering,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          isFiltering ? '$filtered of $total $label' : '$total $label',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.grey,
            letterSpacing: 1.2,
          ),
        ),
      );
}