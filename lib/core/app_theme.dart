import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundTop,
        primaryColor: AppColors.primary,
        cardColor: AppColors.white,
        dividerColor: AppColors.warmSurface,
        colorScheme: ColorScheme.light(
          primary: AppColors.goldDark,
          secondary: AppColors.goldLight,
          surface: AppColors.backgroundTop,
          onSurface: AppColors.nearBlack,
          onSurfaceVariant: AppColors.charcoalGrey,
          error: AppColors.darkRed2,
          onError: AppColors.white,
          outline: AppColors.warmSurface,
          outlineVariant: AppColors.lightGrey,
          surfaceContainerHighest: AppColors.warmSurface,
          surfaceContainerHigh: AppColors.creamBg,
          surfaceContainer: AppColors.warmWhite,
          surfaceContainerLow: AppColors.backgroundTop,
          inverseSurface: AppColors.nearBlack,
          onInverseSurface: AppColors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundTop,
          foregroundColor: AppColors.nearBlack,
          elevation: 0,
        ),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primary,
        cardColor: AppColors.cardDark,
        dividerColor: AppColors.dividerDark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.goldLight,
          secondary: AppColors.goldDark,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.white,
          onSurfaceVariant: AppColors.mutedGrey,
          error: AppColors.redAccent,
          onError: AppColors.white,
          outline: AppColors.dividerDark,
          outlineVariant: AppColors.surfaceDark2,
          surfaceContainerHighest: AppColors.dividerDark,
          surfaceContainerHigh: AppColors.surfaceDark2,
          surfaceContainer: AppColors.surfaceDark,
          surfaceContainerLow: AppColors.backgroundDark,
          inverseSurface: AppColors.white,
          onInverseSurface: AppColors.nearBlack,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
      );
}