import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../screens/scanner/scanner_screen.dart';


class BarcodeField extends StatelessWidget {
  final TextEditingController controller;
  
  final VoidCallback? onScanTap;

  const BarcodeField({super.key, required this.controller, this.onScanTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.dividerDark : AppColors.backgroundBottom;
    final textColor = isDark ? AppColors.white : AppColors.black;

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Scan or enter manual code',
                hintStyle: TextStyle(color: AppColors.warmGrey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: onScanTap ?? () async {
              final code = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ScannerScreen(returnBarcodeOnly: true),
                ),
              );
              if (code != null) controller.text = code;
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                'assets/icons/barcodeicon .png',
                width: 22,
                height: 22,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}