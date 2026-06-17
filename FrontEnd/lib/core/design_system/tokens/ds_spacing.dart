import '../../../app/theme/app_spacing.dart';

/// 8pt-grid helper: every gap/edge should snap to these values.
///
/// `DsSpacing` is a pure alias of `AppSpacing`; it exists so the rest of the
/// design system can read a single, predictable name.
abstract final class DsSpacing {
  DsSpacing._();

  static const double xxxs = AppSpacing.xxxs;
  static const double xxs = AppSpacing.xxs;
  static const double xs = AppSpacing.xs;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;
  static const double xxl = AppSpacing.xxl;
  static const double xxxl = AppSpacing.xxxl;
  static const double section = AppSpacing.section;
}
