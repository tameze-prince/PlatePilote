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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorTokens.darkSurface,
      selectedItemColor: ColorTokens.primaryGreen,
      unselectedItemColor: ColorTokens.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
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
    chipTheme: ChipThemeData(
      backgroundColor: ColorTokens.darkElevatedSurface,
      labelStyle: textTheme.labelSmall?.copyWith(color: ColorTokens.darkTextPrimary),
      side: const BorderSide(color: ColorTokens.darkBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return ColorTokens.primaryGreen;
        return ColorTokens.darkBorder;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return ColorTokens.darkTextSecondary;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: ColorTokens.darkBorder,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ColorTokens.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      titleTextStyle: textTheme.headlineSmall,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ColorTokens.darkElevatedSurface,
      contentTextStyle: textTheme.bodyLarge?.copyWith(color: ColorTokens.darkTextPrimary),
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
