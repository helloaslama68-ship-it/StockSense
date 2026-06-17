import 'package:flutter/material.dart';
import '../core/colors.dart';

class AppSectionLabel extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showBar;

  const AppSectionLabel({
    Key? key,
    required this.label,
    this.actionLabel,
    this.onAction,
    this.showBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (showBar) ...[
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.goldDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
             style: TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Theme.of(context).hintColor,
  letterSpacing: 1.2,
),
            ),
          ],
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
          ),
      ],
    );
  }
}