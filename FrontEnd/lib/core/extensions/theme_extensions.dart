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

  /// Raccourci vers les localisations de l'application (peut être null si la
  /// locale n'est pas chargée, ex. tests sans `LocalizationsDelegate`).
  AppLocalizations? get l10n => AppLocalizations.of(this);

  /// Variante non-null qui lève une erreur explicite si les localisations
  /// ne sont pas disponibles. Utile pour les BuildContext qui ne sont pas
  /// sous un `LocalizationsScope` (par ex. certains tests).
  AppLocalizations get l10nOrThrow {
    // ignore: unnecessary_null_comparison
    final loc = AppLocalizations.of(this);
    return loc;
  }

  /// Variante sécurisée qui retourne les localisations ou `null`.
  /// À utiliser quand le caller ne peut pas garantir que le `BuildContext`
  /// est sous un `LocalizationsScope` (tests, contextes ambigus).
  AppLocalizations? get l10nOrFallback => AppLocalizations.of(this);
}
