import 'package:flutter/material.dart';
import 'colors.dart';

//  DATE HELPER

const List<String> kMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) =>
    '${kMonthNames[d.month - 1]} ${d.day}, ${d.year}';
    String formatDateTime(DateTime d) {
  final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  final min = d.minute.toString().padLeft(2, '0');
  return '${kMonthNames[d.month - 1]} ${d.day}, ${d.year} · $h:$min $ampm';
}

String formatShortDate(DateTime d) =>
    '${kMonthNames[d.month - 1]} ${d.day}';

String formatTime(DateTime d) {
  final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  final min = d.minute.toString().padLeft(2, '0');
  return '$h:$min $ampm';
}

// COMMON DECORATION HELPERS

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

/// Pass [context] for theme-aware card color (dark mode support).
/// Falls back to white when context is null (legacy call sites).
BoxDecoration appCardDecoration({double radius = 16, BuildContext? context}) {
  final isDark = context != null &&
      Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? const Color(0xFF1E1E1E) : AppColors.white;
  return BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withOpacity(isDark ? 0.0 : 0.04),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

// COMMON WIDGETS

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

// DATE HELPERS

/// Parses ISO-8601 string and formats as "Jan 1, 2024".
String formatDateFromString(String iso) => formatDate(DateTime.parse(iso));

/// Returns "January 2024" — used for audit period labels.
String formatMonthYear(DateTime d) {
  const full = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${full[d.month - 1]} ${d.year}';
}

// DECORATION HELPERS

/// White/dark box with border — used for input-like containers.
BoxDecoration appOutlineBoxDecoration({double radius = 12, BuildContext? context}) {
  final isDark = context != null &&
      Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0DDD8),
      width: 1,
    ),
  );
}

/// Themed date picker — applies goldDark accent consistently.
Future<DateTime?> appShowDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) =>
    showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.goldDark),
        ),
        child: child!,
      ),
    );

// TEXT STYLES

const TextStyle appPageTitleStyle = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.w800,
  color: Color(0xFF1A1A1A),
  letterSpacing: -0.5,
);

const TextStyle appPageCategoryStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: Color(0xFF888780),
  letterSpacing: 1.4,
);

const TextStyle appFieldLabelStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1A1A1A),
);

// UNIT CONSTANTS

const List<String> kPurchaseUnits = [
  'units', 'kg', 'g', 'L', 'ml', 'pcs', 'boxes', 'bags', 'pack',
];