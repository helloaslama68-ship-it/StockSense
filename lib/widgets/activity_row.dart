import 'package:flutter/material.dart';
import '../core/colors.dart';

class ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color    iconBg;
  final Color    iconColor;
  final String   title;
  final String   subtitle;
  final String   time;
  final Color    timeColor;
  final String?  badge;
  final bool     isLast;

  const ActivityRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.timeColor,
    required this.isLast,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ?AppColors.dividerDark : AppColors.creamBg,
                  width: 1,
                ),
              ),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? AppColors.white : AppColors.nearBlack)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.midGrey : AppColors.charcoalGrey)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(time, style: TextStyle(fontSize: 11, color: timeColor)),
          if (badge != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.lightRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(badge!,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.darkRed, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
      ]),
    );
  }
}