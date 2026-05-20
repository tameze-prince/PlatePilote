import 'package:flutter/material.dart';

import 'app_colors.dart';

// Backward compatibility layer
// All new code should use AppColors directly
abstract final class ColorTokens {
  // Primary colors
  static const primary = AppColors.primary;
  static const primaryGreen = AppColors.primaryLight;
  static const primaryDark = AppColors.primaryDark;
  
  // Accent colors
  static const accentAmber = AppColors.secondary;
  static const accentBlue = AppColors.tertiary;
  
  // Functional colors
  static const error = AppColors.error;
  static const success = AppColors.success;
  static const warning = AppColors.warning;
  static const info = AppColors.info;
  
  // Light theme surfaces
  static const background = AppColors.background;
  static const surface = AppColors.surface;
  static const surfaceContainerLow = AppColors.surfaceContainerLow;
  static const surfaceContainer = AppColors.surfaceContainer;
  static const surfaceContainerHigh = AppColors.surfaceContainerHigh;
  
  // Light theme borders
  static const border = AppColors.outline;
  
  // Light theme text
  static const textPrimary = AppColors.onBackground;
  static const textSecondary = AppColors.onSurfaceVariant;
  
  // Dark theme surfaces
  static const darkBackground = AppColors.darkBackground;
  static const darkSurface = AppColors.darkSurface;
  static const darkElevatedSurface = AppColors.darkSurfaceContainerHigh;
  
  // Dark theme borders
  static const darkBorder = AppColors.darkOutline;
  
  // Dark theme text
  static const darkTextPrimary = AppColors.darkOnBackground;
  static const darkTextSecondary = AppColors.darkOnSurfaceVariant;
  
  // Category colors
  static const categoryProduce = AppColors.categoryProduce;
  static const categoryProtein = AppColors.categoryProtein;
  static const categoryDairy = AppColors.categoryDairy;
  static const categoryPantry = AppColors.categoryPantry;
  static const categoryBeverages = AppColors.categoryBeverages;
  static const categorySnacks = AppColors.categorySnacks;
  static const categoryFrozen = AppColors.categoryFrozen;
  static const categoryOther = AppColors.categoryOther;
}
