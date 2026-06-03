// Backward compatibility layer
// All new code should use app_radius.dart directly
// This file is deprecated and will be removed in a future version

import 'app_radius.dart' as new_radius;

/// Rayons de bordure (couche de compatibilité dépréciée).
abstract final class LegacyAppRadius {
  /// Petit.
  static const small = new_radius.AppRadius.sm;
  /// Input.
  static const input = new_radius.AppRadius.md;
  /// Bouton.
  static const button = new_radius.AppRadius.lg;
  /// Carte.
  static const card = new_radius.AppRadius.xl;
  /// Modal.
  static const modal = new_radius.AppRadius.xxl;
}

// Keep the old constants for backward compatibility
/// Constantes de rayon dépréciées.
const small = new_radius.AppRadius.sm;
const input = new_radius.AppRadius.md;
const button = new_radius.AppRadius.lg;
const card = new_radius.AppRadius.xl;
const modal = new_radius.AppRadius.xxl;
