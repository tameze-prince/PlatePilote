// Backward compatibility layer
// All new code should use app_radius.dart directly
// This file is deprecated and will be removed in a future version

import 'app_radius.dart' as new_radius;

abstract final class LegacyAppRadius {
  static const small = new_radius.AppRadius.sm;
  static const input = new_radius.AppRadius.md;
  static const button = new_radius.AppRadius.lg;
  static const card = new_radius.AppRadius.xl;
  static const modal = new_radius.AppRadius.xxl;
}

// Keep the old constants for backward compatibility
const small = new_radius.AppRadius.sm;
const input = new_radius.AppRadius.md;
const button = new_radius.AppRadius.lg;
const card = new_radius.AppRadius.xl;
const modal = new_radius.AppRadius.xxl;
