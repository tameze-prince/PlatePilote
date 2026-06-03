// Backward compatibility layer
// All new code should use app_spacing.dart directly
// This file is deprecated and will be removed in a future version

import 'app_spacing.dart' as new_spacing;

/// Espacements (couche de compatibilité dépréciée).
abstract final class LegacyAppSpacing {
  /// xxs.
  static const xxs = new_spacing.AppSpacing.xxs;
  /// xs.
  static const xs = new_spacing.AppSpacing.xs;
  /// sm.
  static const sm = new_spacing.AppSpacing.sm;
  /// md.
  static const md = new_spacing.AppSpacing.md;
  /// lg.
  static const lg = new_spacing.AppSpacing.lg;
  /// xl.
  static const xl = new_spacing.AppSpacing.xl;
  /// xxl.
  static const xxl = new_spacing.AppSpacing.xxl;
}

// Keep the old class name for backward compatibility
// but point to the new values
/// Constantes d'espacement dépréciées.
const xxs = new_spacing.AppSpacing.xxs;
const xs = new_spacing.AppSpacing.xs;
const sm = new_spacing.AppSpacing.sm;
const md = new_spacing.AppSpacing.md;
const lg = new_spacing.AppSpacing.lg;
const xl = new_spacing.AppSpacing.xl;
const xxl = new_spacing.AppSpacing.xxl;
