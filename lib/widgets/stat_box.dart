import 'package:flutter/material.dart';
import '../core/colors.dart';

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool dark;
  final Color? valueColor;

  const StatBox({
    Key? key,
    required this.label,
    required this.value,
    this.unit,
    this.dark = false,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? AppColors.black : AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: dark ? Colors.white54 : AppColors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor ??
                  (dark ? Colors.white : AppColors.black),
            ),
          ),
          if (unit != null)
            Text(
              unit!,
              style: TextStyle(
                fontSize: 11,
                color: dark ? Colors.white54 : AppColors.grey,
              ),
            ),
        ],
      ),
    );
  }
}