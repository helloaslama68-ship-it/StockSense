import 'package:flutter/material.dart';
import '../core/colors.dart';

class AppDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const AppDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
          isExpanded: true,
          dropdownColor: cs.surfaceContainerHigh,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: cs.onSurfaceVariant),
          style: TextStyle(color: cs.onSurface, fontSize: 14),
          items: items
              .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: TextStyle(fontSize: 14, color: cs.onSurface))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class AppDropdownEmpty extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const AppDropdownEmpty({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.goldDark.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: AppColors.goldDark, size: 16),
            const SizedBox(width: 8),
            Text(message,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}