import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'radius.dart';
import 'text_styles.dart';

ThemeData buildLightTheme() {
  final textTheme = AppTextStyles.textTheme(
    ColorTokens.textPrimary,
    ColorTokens.textSecondary,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ColorTokens.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorTokens.primaryGreen,
      primary: ColorTokens.primary,
      secondary: ColorTokens.accentAmber,
      surface: ColorTokens.surface,
      error: ColorTokens.error,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorTokens.surface.withValues(alpha: 0.94),
      foregroundColor: ColorTokens.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineMedium?.copyWith(
        color: ColorTokens.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: ColorTokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: ColorTokens.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorTokens.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: ColorTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: ColorTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: ColorTokens.primaryGreen, width: 2),
      ),
    ),
  );
}
