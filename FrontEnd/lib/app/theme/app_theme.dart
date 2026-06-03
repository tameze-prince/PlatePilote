import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

/// Thèmes clair et sombre de l'application.
abstract final class AppTheme {
  /// Thème clair.
  static ThemeData get light => buildLightTheme();
  /// Thème sombre.
  static ThemeData get dark => buildDarkTheme();
}
