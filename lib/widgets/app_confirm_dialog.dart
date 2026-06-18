import 'package:flutter/material.dart';
import '../core/colors.dart';


class AppConfirmDialog {
  const AppConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String deleteLabel = 'Delete',
    String cancelLabel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              deleteLabel,
              style: const TextStyle(color: AppColors.darkRed),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}