import 'package:flutter/material.dart';
import '../core/colors.dart';

class ManageEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const ManageEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.lightGrey),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  color: AppColors.grey, fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style:
                    const TextStyle(color: AppColors.lightGrey, fontSize: 12),
              ),
            ],
          ],
        ),
      );
}