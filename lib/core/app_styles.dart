import 'package:flutter/material.dart';
import 'colors.dart';

// ── DATE HELPERS ──────────────────────────────────────────────

const List<String> kMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) =>
    '${kMonthNames[d.month - 1]} ${d.day}, ${d.year}';

// ── COMMON DECORATION HELPERS ─────────────────────────────────

InputDecoration appInputDeco(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.lightGrey.withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.goldDark, width: 1.5)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );

BoxDecoration appCardDecoration({double radius = 16}) => BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

// ── COMMON WIDGETS ────────────────────────────────────────────

Widget appSectionLabel(String label) => Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 1.2,
        color: AppColors.grey,
        fontWeight: FontWeight.w600,
      ),
    );

Widget appTotalRow(String label, String value) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: AppColors.grey)),
        Text(value,
            style:
                const TextStyle(fontSize: 13, color: AppColors.grey)),
      ],
    );

// ── UNIT CONSTANTS ────────────────────────────────────────────

const List<String> kPurchaseUnits = [
  'units', 'kg', 'g', 'L', 'ml', 'pcs', 'boxes', 'bags',
];