// Backward compatibility layer
// All new code should use app_spacing.dart directly
// This file is deprecated and will be removed in a future version

import 'app_spacing.dart' as new_spacing;

abstract final class LegacyAppSpacing {
  static const xxs = new_spacing.AppSpacing.xxs;
  static const xs = new_spacing.AppSpacing.xs;
  static const sm = new_spacing.AppSpacing.sm;
  static const md = new_spacing.AppSpacing.md;
  static const lg = new_spacing.AppSpacing.lg;
  static const xl = new_spacing.AppSpacing.xl;
  static const xxl = new_spacing.AppSpacing.xxl;
}

// Keep the old class name for backward compatibility
// but point to the new values
const xxs = new_spacing.AppSpacing.xxs;
const xs = new_spacing.AppSpacing.xs;
const sm = new_spacing.AppSpacing.sm;
const md = new_spacing.AppSpacing.md;
const lg = new_spacing.AppSpacing.lg;
const xl = new_spacing.AppSpacing.xl;
const xxl = new_spacing.AppSpacing.xxl;
