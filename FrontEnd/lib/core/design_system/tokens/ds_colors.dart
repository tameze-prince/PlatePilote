import '../../../app/theme/app_colors.dart';

/// DS-friendly aliases for the most common token reads.
///
/// These are pure re-exports: the underlying constants still live in
/// `app_colors.dart` to avoid breaking any existing call site.
abstract final class DsColors {
  DsColors._();

  /// Brand accent (green).
  static const accent = AppColors.primaryAccentGreen;

  /// Primary brand color (deep green).
  static const brand = AppColors.deepGreen;

  /// Premium cyan accent.
  static const cyan = AppColors.premiumCyanAccent;

  /// Warm accent (amber).
  static const warm = AppColors.warmAccent;

  /// Adaptive background for the current brightness.
  static const background = AppColors.background;
  static const backgroundDark = AppColors.darkBackground;
  static const secondaryBackground = AppColors.secondaryBackground;
  static const secondaryBackgroundDark = AppColors.darkSecondaryBackground;

  /// Adaptive elevated surface.
  static const surface = AppColors.surface;
  static const surfaceDark = AppColors.darkSurface;
  static const elevatedSurface = AppColors.elevatedSurface;
  static const elevatedSurfaceDark = AppColors.darkElevatedSurface;

  /// Glass surfaces.
  static const glassLight = AppColors.lightGlassSurface;
  static const glassDark = AppColors.darkGlassSurface;

  /// Adaptive on-surface text colors.
  static const onSurface = AppColors.onSurface;
  static const onSurfaceDark = AppColors.darkOnSurface;
  static const onSurfaceVariant = AppColors.onSurfaceVariant;
  static const onSurfaceVariantDark = AppColors.darkOnSurfaceVariant;
  static const onSurfaceTertiary = AppColors.onSurfaceTertiary;
  static const onSurfaceTertiaryDark = AppColors.darkOnSurfaceTertiary;

  /// Adaptive outline colors.
  static const outline = AppColors.outline;
  static const outlineDark = AppColors.darkOutline;
  static const outlineVariant = AppColors.outlineVariant;
  static const outlineVariantDark = AppColors.darkOutlineVariant;

  /// Semantic status.
  static const success = AppColors.success;
  static const warning = AppColors.warning;
  static const error = AppColors.error;
  static const info = AppColors.info;
}
