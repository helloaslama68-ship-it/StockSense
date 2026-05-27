import 'package:flutter/material.dart';
import '../core/colors.dart';

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool dark;
  final Color? valueColor;
  final Color? labelColor;  
  final Color? unitColor;   
  final Color? bgColor;
  final IconData? watermarkIcon;

  const StatBox({
    Key? key,
    required this.label,
    required this.value,
    this.unit,
    this.dark = false,
    this.valueColor,
    this.labelColor,
    this.unitColor,
    this.bgColor,
    this.watermarkIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? (dark ? AppColors.black : AppColors.white);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: labelColor ??
                      (dark ? AppColors.white54 : AppColors.grey),
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
                  color: valueColor ?? (dark ? AppColors.white : AppColors.black),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(height: 2),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 11,
                    color: unitColor ??
                        (dark ? AppColors.white54 : AppColors.grey),
                  ),
                ),
              ],
            ],
          ),

          if (watermarkIcon != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                watermarkIcon,
                size: 48,
                color: (valueColor ?? AppColors.grey).withOpacity(0.12),
              ),
            ),
        ],
      ),
    );
  }
}