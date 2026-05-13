import 'package:flutter/material.dart';
import '../core/colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBg;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBg,
    this.buttonLabel,
    this.onButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.lightGrey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 48, color: iconColor ?? AppColors.grey),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.grey),
                textAlign: TextAlign.center),
            if (buttonLabel != null && onButton != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                onPressed: onButton,
                child: Text(buttonLabel!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}