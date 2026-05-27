import 'package:flutter/material.dart';
import '../../core/colors.dart';


class ExpiryDatePicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const ExpiryDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(primary: AppColors.goldDark),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: AppColors.goldDark, size: 18),
            const SizedBox(width: 10),
            Text(
              value == null
                  ? 'mm/dd/yyyy'
                  : '${value!.month.toString().padLeft(2, '0')}/'
                      '${value!.day.toString().padLeft(2, '0')}/'
                      '${value!.year}',
              style: TextStyle(
                color: value == null ? AppColors.grey : AppColors.black,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close,
                    size: 16, color: AppColors.darkRed),
              ),
          ],
        ),
      ),
    );
  }
}