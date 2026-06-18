import 'package:flutter/material.dart';
import '../core/colors.dart';

class ManageAddCard extends StatelessWidget {
  final TextEditingController controller;
  final String sectionLabel;
  final String hintText;
  final VoidCallback onAdd;

  const ManageAddCard({
    super.key,
    required this.controller,
    required this.sectionLabel,
    required this.hintText,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(isDark ? 0.0 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white54 : AppColors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => onAdd(),
                  style: TextStyle(color: isDark ? AppColors.white : AppColors.black),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                        color: isDark ? AppColors.white38 : AppColors.grey,
                        fontSize: 14),
                    filled: true,
                    fillColor: isDark ? AppColors.dividerDark: AppColors.backgroundTop,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.goldDark, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.goldLight],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: AppColors.white, size: 22),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}