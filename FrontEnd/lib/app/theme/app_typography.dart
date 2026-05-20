import 'package:flutter/material.dart';

abstract final class AppTypography {
  // Font family - using system default for performance
  static const fontFamily = 'Inter';
  
  // Display styles (largest)
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );
  
  static const displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  // Headline styles
  static const headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
  );
  
  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // Title styles
  static const titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  // Body styles
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  // Label styles
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  // Helper method to create text theme
  static TextTheme createTextTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primary),
      displayMedium: displayMedium.copyWith(color: primary),
      displaySmall: displaySmall.copyWith(color: primary),
      headlineLarge: headlineLarge.copyWith(color: primary),
      headlineMedium: headlineMedium.copyWith(color: primary),
      headlineSmall: headlineSmall.copyWith(color: primary),
      titleLarge: titleLarge.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      titleSmall: titleSmall.copyWith(color: primary),
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: primary),
      bodySmall: bodySmall.copyWith(color: secondary),
      labelLarge: labelLarge.copyWith(color: primary),
      labelMedium: labelMedium.copyWith(color: secondary),
      labelSmall: labelSmall.copyWith(color: secondary),
    );
  }
}
