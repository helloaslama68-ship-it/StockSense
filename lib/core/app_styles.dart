import 'package:flutter/material.dart';
import 'colors.dart';

//  date and time helpers,common functions used for formatting dates and time

const List<String> kMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

//returns date and time in the format:jan1,2026
String formatDate(DateTime d) =>
    '${kMonthNames[d.month - 1]} ${d.day}, ${d.year}';
//returns date and time in the format:
//jan1/2026 .10:30 Am
  String formatDateTime(DateTime d) {
  final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  final min = d.minute.toString().padLeft(2, '0');
  return '${kMonthNames[d.month - 1]} ${d.day}, ${d.year} · $h:$min $ampm';
}
//returns date without year
//eg-jan1
String formatShortDate(DateTime d) =>
    '${kMonthNames[d.month - 1]} ${d.day}';
//returns time in 12-hour format
//eg-10:30 Am
String formatTime(DateTime d) {
  final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  final min = d.minute.toString().padLeft(2, '0');
  return '$h:$min $ampm';
}

// COMMON DECORATION HELPERS-reusable decorations for text field and cards

//automatically adapts to light and dark themes
InputDecoration appInputDeco(String hint, {BuildContext? context}) {
  final isDark = context != null &&
      Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark
          ? AppColors.white.withOpacity(0.06)
          : AppColors.lightGrey.withOpacity(0.3),
      hintStyle: TextStyle(
        color: isDark ? AppColors.grey : AppColors.grey,
      ),
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
}


BoxDecoration appCardDecoration({double radius = 16, BuildContext? context}) {
  final isDark = context != null &&
      Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? AppColors.surfaceDark: AppColors.white;
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

/// converts ISO-8601 string and formats to jan1,2026.
String formatDateFromString(String iso) => formatDate(DateTime.parse(iso));

/// Returns "January 2026" — used for audit period labels.
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
    color: isDark ?  AppColors.surfaceDark : AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark ? AppColors.dividerDark : AppColors.warmSurface,
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
  color: AppColors.nearBlack,
  letterSpacing: -0.5,
);

const TextStyle appPageCategoryStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: AppColors.charcoalGrey,
  letterSpacing: 1.4,
);

const TextStyle appFieldLabelStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: AppColors.nearBlack,
);

// UNIT CONSTANTS

const List<String> kPurchaseUnits = [
  'units', 'kg', 'g', 'L', 'ml', 'pcs', 'boxes', 'bags', 'pack',
];

const List<String> kProductUnits = [
  'kg', 'g', 'mg',
  'litre', 'ml',
  'pcs', 'box', 'dozen',
  'pack', 'bag', 'bottle',
  'strip', 'tablet',
];
// number formatting-formats large numbers using indian notation,eg-100000-1.00L
String formatCompact(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)} L';
  if (v >= 1000) {
    final s = v.toStringAsFixed(0);
    if (s.length > 3) {
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      final buf = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
        buf.write(rest[i]);
      }
      return '${buf.toString()},$last3';
    }
    return s;
  }
  return v.toStringAsFixed(0);
}

/// eg today - 3:45 PM, yesterday - Yesterday, <7d - 2 days ago, else 12/6/2026
String formatRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(dt.year, dt.month, dt.day);
  if (d == today) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }
  if (d == yesterday) return 'Yesterday';
  final diff = today.difference(d).inDays;
  if (diff < 7) return '$diff days ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}