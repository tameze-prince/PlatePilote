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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTokens.surface,
      selectedItemColor: ColorTokens.primaryGreen,
      unselectedItemColor: ColorTokens.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
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
    chipTheme: ChipThemeData(
      backgroundColor: ColorTokens.surfaceContainerLow,
      labelStyle: textTheme.labelSmall?.copyWith(color: ColorTokens.textPrimary),
      side: const BorderSide(color: ColorTokens.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return ColorTokens.primaryGreen;
        return ColorTokens.border;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return ColorTokens.textSecondary;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: ColorTokens.border,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ColorTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      titleTextStyle: textTheme.headlineSmall,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ColorTokens.textPrimary,
      contentTextStyle: textTheme.bodyLarge?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColorTokens.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
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
