import 'package:flutter/material.dart';
import '../core/colors.dart';

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final bool outlined;
  final IconData? icon;

  const GoldButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 52,
    this.outlined = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.goldDark, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: loading ? null : onPressed,
          child: Text(label,
              style: TextStyle(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
            colors: [AppColors.goldDark, AppColors.goldLight]),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldDark.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.transparent,
          shadowColor: AppColors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
      ),
    );
  }
}