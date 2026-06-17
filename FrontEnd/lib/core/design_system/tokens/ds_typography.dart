import '../../../app/theme/app_typography.dart';

/// DS-friendly aliases for the type ramp.
abstract final class DsTypography {
  DsTypography._();

  static const String fontFamily = AppTypography.fontFamily;

  static const displayLarge = AppTypography.displayLarge;
  static const displayMedium = AppTypography.displayMedium;
  static const displaySmall = AppTypography.displaySmall;

  static const headlineLarge = AppTypography.headlineLarge;
  static const headlineMedium = AppTypography.headlineMedium;
  static const headlineSmall = AppTypography.headlineSmall;

  static const titleLarge = AppTypography.titleLarge;
  static const titleMedium = AppTypography.titleMedium;
  static const titleSmall = AppTypography.titleSmall;

  static const bodyLarge = AppTypography.bodyLarge;
  static const bodyMedium = AppTypography.bodyMedium;
  static const bodySmall = AppTypography.bodySmall;

  static const labelLarge = AppTypography.labelLarge;
  static const labelMedium = AppTypography.labelMedium;
  static const labelSmall = AppTypography.labelSmall;
}
