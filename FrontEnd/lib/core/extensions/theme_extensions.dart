import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Extension sur [BuildContext] pour un accès rapide au thème Material.
extension ThemeContext on BuildContext {
  /// Raccourci vers [Theme.of].
  ThemeData get theme => Theme.of(this);

  /// Raccourci vers le [TextTheme] du thème courant.
  TextTheme get text => theme.textTheme;

  /// Raccourci vers le [ColorScheme] du thème courant.
  ColorScheme get colors => theme.colorScheme;

  /// Vrai si le thème actuel est sombre.
  bool get isDark => theme.brightness == Brightness.dark;

  /// Raccourci vers les localisations de l'application.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
