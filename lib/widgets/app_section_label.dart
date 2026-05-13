import 'package:flutter/material.dart';
import '../core/colors.dart';

class AppSectionLabel extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppSectionLabel({
    Key? key,
    required this.label,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.grey,
            letterSpacing: 1.2,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
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