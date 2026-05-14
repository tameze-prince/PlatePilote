import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'radius.dart';
import 'text_styles.dart';

ThemeData buildDarkTheme() {
  final textTheme = AppTextStyles.textTheme(
    ColorTokens.darkTextPrimary,
    ColorTokens.darkTextSecondary,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorTokens.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: ColorTokens.primaryGreen,
      secondary: ColorTokens.accentAmber,
      surface: ColorTokens.darkSurface,
      error: ColorTokens.error,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorTokens.darkSurface.withValues(alpha: 0.94),
      foregroundColor: ColorTokens.darkTextPrimary,
      elevation: 0,
      titleTextStyle: textTheme.headlineMedium?.copyWith(
        color: ColorTokens.primaryGreen,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: ColorTokens.darkSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: ColorTokens.darkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTokens.darkElevatedSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: ColorTokens.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: ColorTokens.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: ColorTokens.primaryGreen, width: 2),
      ),
    ),
  );
}
