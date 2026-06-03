import 'package:flutter/material.dart';

/// Définition des niveaux d'élévation de l'application.
abstract final class AppElevation {
  /// Aucune élévation.
  static const none = 0.0;

  /// Niveau 1 — Cartes, chips.
  static const level1 = 1.0;

  /// Niveau 2 — Boutons, FAB.
  static const level2 = 2.0;

  /// Niveau 3 — Barres d'application, navigation.
  static const level3 = 3.0;

  /// Niveau 4 — Boîtes de dialogue, modales.
  static const level4 = 4.0;

  /// Niveau 5 — Snackbars, tooltips.
  static const level5 = 5.0;

  // Semantic elevation values
  /// Élévation des cartes.
  static const card = level1;
  /// Élévation des boutons.
  static const button = level2;
  /// Élévation du FAB.
  static const fab = level3;
  /// Élévation de la barre d'application.
  static const appBar = level2;
  /// Élévation des boîtes de dialogue.
  static const dialog = level4;
  /// Élévation des snackbars.
  static const snackbar = level5;
  /// Élévation des bottom sheets.
  static const bottomSheet = level3;
  /// Élévation de la barre de navigation.
  static const navigationBar = level2;

  // Shadow colors
  /// Couleur d'ombre.
  static const shadowColor = Color(0x1A000000);
  /// Couleur d'ombre claire.
  static const shadowColorLight = Color(0x0D000000);

  /// Crée une liste d'ombres pour une élévation donnée.
  static List<BoxShadow> shadow({
    double elevation = level1,
    Color color = shadowColor,
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: elevation * 4,
        offset: Offset(0, elevation * 2),
        spreadRadius: elevation * -0.5,
      ),
    ];
  }

  /// Ombre de carte.
  static List<BoxShadow> get cardShadow => shadow(elevation: card);
  /// Ombre de bouton.
  static List<BoxShadow> get buttonShadow => shadow(elevation: button);
  /// Ombre de FAB.
  static List<BoxShadow> get fabShadow => shadow(elevation: fab);
  /// Ombre de barre d'application.
  static List<BoxShadow> get appBarShadow => shadow(elevation: appBar);
  /// Ombre de dialogue.
  static List<BoxShadow> get dialogShadow => shadow(elevation: dialog);
  /// Ombre de snackbar.
  static List<BoxShadow> get snackbarShadow => shadow(elevation: snackbar);
  /// Ombre de bottom sheet.
  static List<BoxShadow> get bottomSheetShadow => shadow(elevation: bottomSheet);
  /// Ombre de barre de navigation.
  static List<BoxShadow> get navigationBarShadow => shadow(elevation: navigationBar);
}
