import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primaryAccentGreen = Color(0xFF22C55E);
  static const deepGreen = Color(0xFF16A34A);
  static const premiumCyanAccent = Color(0xFF67E8F9);
  static const warmAccent = Color(0xFFF59E0B);

  // Compatibility names used across the app.
  static const primary = deepGreen;
  static const primaryLight = primaryAccentGreen;
  static const primaryDark = Color(0xFF087A32);
  static const primaryContainer = Color(0x3322C55E);
  static const darkPrimaryContainer = Color(0x3322C55E);
  static const secondary = warmAccent;
  static const secondaryLight = Color(0xFFFBBF24);
  static const tertiary = premiumCyanAccent;

  // Semantic colors
  static const success = primaryAccentGreen;
  static const warning = warmAccent;
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF38BDF8);

  // Dark theme surfaces
  static const darkBackground = Color(0xFF020617);
  static const darkSecondaryBackground = Color(0xFF06162A);
  static const darkSurface = Color(0xFF0F172A);
  static const darkElevatedSurface = Color(0xFF162033);
  static const darkGlassSurface = Color.fromRGBO(255, 255, 255, 0.08);
  static const darkSurfaceDim = Color(0xFF020617);
  static const darkSurfaceBright = Color(0xFF1E293B);
  static const darkSurfaceContainerLowest = Color(0xFF020617);
  static const darkSurfaceContainerLow = Color(0xFF06162A);
  static const darkSurfaceContainer = Color(0xFF0F172A);
  static const darkSurfaceContainerHigh = Color(0xFF162033);
  static const darkSurfaceContainerHighest = Color(0xFF1E293B);

  // Light theme surfaces
  static const background = Color(0xFFF8FAFC);
  static const secondaryBackground = Color(0xFFEEF2F7);
  static const surface = Color(0xFFFFFFFF);
  static const elevatedSurface = Color(0xFFF9FBFD);
  static const lightGlassSurface = Color.fromRGBO(255, 255, 255, 0.65);
  static const surfaceDim = Color(0xFFEEF2F7);
  static const surfaceBright = Color(0xFFFFFFFF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF8FAFC);
  static const surfaceContainer = Color(0xFFF1F5F9);
  static const surfaceContainerHigh = Color(0xFFE2E8F0);
  static const surfaceContainerHighest = Color(0xFFCBD5E1);

  // Text
  static const primaryText = Color(0xFFFFFFFF);
  static const secondaryText = Color.fromRGBO(255, 255, 255, 0.75);
  static const tertiaryText = Color.fromRGBO(255, 255, 255, 0.50);
  static const onBackground = Color(0xFF0F172A);
  static const onSurface = Color(0xFF0F172A);
  static const onSurfaceVariant = Color.fromRGBO(15, 23, 42, 0.72);
  static const onSurfaceTertiary = Color.fromRGBO(15, 23, 42, 0.48);
  static const darkOnBackground = Color(0xFFFFFFFF);
  static const darkOnSurface = Color(0xFFFFFFFF);
  static const darkOnSurfaceVariant = Color.fromRGBO(255, 255, 255, 0.75);
  static const darkOnSurfaceTertiary = Color.fromRGBO(255, 255, 255, 0.50);

  // Utility
  static const outline = Color(0xFFE2E8F0);
  static const outlineVariant = Color(0xFFCBD5E1);
  static const darkOutline = Color.fromRGBO(255, 255, 255, 0.08);
  static const darkOutlineVariant = Color.fromRGBO(255, 255, 255, 0.04);
  static const shadow = Color(0xFF000000);
  static const darkShadow = Color(0xFF000000);
  static const scrim = Color(0x52000000);
  static const darkScrim = Color(0x52000000);
  static const inverseSurface = Color(0xFF0F172A);
  static const onInverseSurface = Color(0xFFF8FAFC);
  static const darkInverseSurface = Color(0xFFF8FAFC);
  static const darkOnInverseSurface = Color(0xFF0F172A);

  // Gradients
  static const gradientStart = Color(0xFF087A32);
  static const gradientEnd = primaryAccentGreen;

  // Category colors
  static const categoryProduce = primaryAccentGreen;
  static const categoryProtein = Color(0xFF3B82F6);
  static const categoryDairy = warmAccent;
  static const categoryPantry = Color(0xFF8B5CF6);
  static const categoryBeverages = Color(0xFFEC4899);
  static const categorySnacks = Color(0xFFF97316);
  static const categoryFrozen = Color(0xFF06B6D4);
  static const categoryOther = Color(0xFF64748B);
}
