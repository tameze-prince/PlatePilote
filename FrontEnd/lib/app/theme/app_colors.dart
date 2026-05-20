import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary brand colors
  static const primary = Color(0xFF006E2F);
  static const primaryLight = Color(0xFF22C55E);
  static const primaryDark = Color(0xFF16A34A);
  static const primaryContainer = Color(0xFFE8F5E9); // Light green container
  static const onPrimaryContainer = Color(0xFF006E2F);
  
  // Secondary/Accent colors
  static const secondary = Color(0xFFF59E0B);
  static const secondaryLight = Color(0xFFFBBF24);
  static const tertiary = Color(0xFF3B82F6);
  
  // Functional colors
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Light theme surfaces
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFF1F5F9);
  static const surfaceBright = Color(0xFFFFFFFF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F5F9);
  static const surfaceContainer = Color(0xFFE8F0E4);
  static const surfaceContainerHigh = Color(0xFFE2EBDE);
  static const surfaceContainerHighest = Color(0xFFD7E4D3);
  
  // Light theme text
  static const onBackground = Color(0xFF0F172A);
  static const onSurface = Color(0xFF0F172A);
  static const onSurfaceVariant = Color(0xFF64748B);
  static const inverseSurface = Color(0xFF0F172A);
  static const onInverseSurface = Color(0xFFF8FAFC);
  
  // Light theme other
  static const outline = Color(0xFFE2E8F0);
  static const outlineVariant = Color(0xFFCBD5E1);
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0x52000000);
  
  // Dark theme surfaces
  static const darkBackground = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF111827);
  static const darkSurfaceDim = Color(0xFF0F172A);
  static const darkSurfaceBright = Color(0xFF1E293B);
  static const darkSurfaceContainerLowest = Color(0xFF0B1220);
  static const darkSurfaceContainerLow = Color(0xFF111827);
  static const darkSurfaceContainer = Color(0xFF1F2937);
  static const darkSurfaceContainerHigh = Color(0xFF2A3441);
  static const darkSurfaceContainerHighest = Color(0xFF354052);
  
  // Dark theme text
  static const darkOnBackground = Color(0xFFF8FAFC);
  static const darkOnSurface = Color(0xFFF8FAFC);
  static const darkOnSurfaceVariant = Color(0xFF9CA3AF);
  static const darkInverseSurface = Color(0xFFF8FAFC);
  static const darkOnInverseSurface = Color(0xFF0B1220);
  
  // Dark theme other
  static const darkOutline = Color(0xFF374151);
  static const darkOutlineVariant = Color(0xFF4B5563);
  static const darkPrimaryContainer = Color(0xFF1B5E20); // Dark green container
  static const darkOnPrimaryContainer = Color(0xFF22C55E);
  
  // Gradient colors for premium features
  static const gradientStart = Color(0xFF006E2F);
  static const gradientEnd = Color(0xFF22C55E);
  
  // Category colors
  static const categoryProduce = Color(0xFF22C55E);
  static const categoryProtein = Color(0xFF3B82F6);
  static const categoryDairy = Color(0xFFF59E0B);
  static const categoryPantry = Color(0xFF8B5CF6);
  static const categoryBeverages = Color(0xFFEC4899);
  static const categorySnacks = Color(0xFFF97316);
  static const categoryFrozen = Color(0xFF06B6D4);
  static const categoryOther = Color(0xFF64748B);
}
