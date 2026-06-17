import 'package:flutter/material.dart';
import '../core/colors.dart';

/// A toggle chip used in filter rows throughout the app.
/// Active state = goldDark fill. Inactive = surface-aware with border.
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.margin = const EdgeInsets.only(right: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.goldDark
              : (isDark ? const Color(0xFF2C2C2C) : AppColors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? AppColors.goldDark
                : (isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0DDD8)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF1A1A1A)),
          ),
        ),
      ),
    );
  }
}