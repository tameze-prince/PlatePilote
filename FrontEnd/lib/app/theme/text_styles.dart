import 'package:flutter/material.dart';

import 'app_typography.dart';

// Backward compatibility layer
// All new code should use AppTypography directly

/// Styles de texte (couche de compatibilité avec [AppTypography]).
abstract final class AppTextStyles {
  /// Crée un [TextTheme] avec les couleurs spécifiées.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return AppTypography.createTextTheme(
      primary: primary,
      secondary: secondary,
    );
  }
}
