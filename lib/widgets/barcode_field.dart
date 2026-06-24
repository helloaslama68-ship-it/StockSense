import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../screens/scanner/scanner_screen.dart';

/// Barcode input field with inline scanner button.
/// Usage:
///   BarcodeField(controller: _barcodeCtrl)
class BarcodeField extends StatelessWidget {
  final TextEditingController controller;
  /// Override the default scan behaviour (e.g. to fill multiple fields).
  /// If null, the default behaviour returns only the barcode string.
  final VoidCallback? onScanTap;

  const BarcodeField({super.key, required this.controller, this.onScanTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Scan or enter manual code',
                hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
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
                color: AppColors.black, // 
              ),
            ),
          ),
        ],
      ),
    );
  }
}