import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final String       iconPath;
  final String       label;
  final VoidCallback onTap;
  final Color        bgColor;
  final Color?       iconColor;

  const QuickActionButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    required this.bgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 22, height: 22,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize:      10,
              color:         Color(0xFF555452),
              fontWeight:    FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ]),
      );
}