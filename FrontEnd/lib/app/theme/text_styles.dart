import 'package:flutter/material.dart';

import 'app_typography.dart';

// Backward compatibility layer
// All new code should use AppTypography directly
abstract final class AppTextStyles {
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
