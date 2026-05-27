import 'package:flutter/material.dart';

/// White shadow card — default for most cards.
BoxDecoration appCard({Color color = Colors.white, double radius = 18}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );

/// Dark (near-black) card — hero stats, CTA buttons.
BoxDecoration appDarkCard({double radius = 18}) => appCard(
      color: const Color(0xFF1A1A1A),
      radius: radius,
    );

/// Colored card with matching color shadow — AI prediction, alerts.
BoxDecoration appColorCard({required Color color, double radius = 18}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.28),
          blurRadius: 14,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
    );