import 'package:flutter/material.dart';
import '../core/colors.dart';

/// Snackbar helpers. 
///
/// Usage:
///   AppSnackBar.success(context, 'Product saved!');
///   AppSnackBar.error(context, 'Something went wrong.');
class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) {
    successWith(ScaffoldMessenger.of(context), message);
  }

  static void error(BuildContext context, String message) {
    errorWith(ScaffoldMessenger.of(context), message);
  }

  /// Use when context may be unmounted after a pop (eg delete-then-navigateflows) — capture the messenger before popping, then call this.
  static void successWith(ScaffoldMessengerState messenger, String message) {
    _showOn(
      messenger,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppColors.darkGreen,
    );
  }

  static void errorWith(ScaffoldMessengerState messenger, String message) {
    _showOn(
      messenger,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.darkRed,
    );
  }

  static void _showOn(
    ScaffoldMessengerState messenger, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}