import 'package:flutter/material.dart';
import '../core/colors.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboard;
  final int maxLines;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppInputField({
    Key? key,
    required this.controller,
    this.hint,
    this.keyboard = TextInputType.text,
    this.maxLines = 1,
    this.prefix,
    this.validator,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                child: prefix,
              )
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.goldDark, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}