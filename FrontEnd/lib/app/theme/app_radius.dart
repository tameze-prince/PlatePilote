import 'package:flutter/material.dart';

/// Définition des rayons de bordure de l'application.
abstract final class AppRadius {
  /// Aucun rayon.
  static const none = 0.0;

  /// Très petit (4px).
  static const xs = 4.0;

  /// Petit (8px).
  static const sm = 8.0;

  /// Moyen (12px).
  static const md = 12.0;

  /// Grand (16px).
  static const lg = 16.0;

  /// Très grand (24px).
  static const xl = 24.0;

  /// Extra large (32px).
  static const xxl = 32.0;

  /// Plein (cercle/pill).
  static const full = 9999.0;

  // Semantic radius values
  /// Rayon des inputs.
  static const input = md;
  /// Rayon des boutons.
  static const button = lg;
  /// Rayon des cartes.
  static const card = xl;
  /// Rayon des modales.
  static const modal = xxl;
  /// Rayon des chips.
  static const chip = sm;
  /// Rayon des badges.
  static const badge = full;
  /// Rayon des avatars.
  static const avatar = full;

  /// Retourne un [BorderRadius] circulaire.
  static BorderRadius circular(double value) =>
      BorderRadius.circular(value);

  /// Rayon de bordure pour les inputs.
  static BorderRadius get inputRadius => circular(input);
  /// Rayon de bordure pour les boutons.
  static BorderRadius get buttonRadius => circular(button);
  /// Rayon de bordure pour les cartes.
  static BorderRadius get cardRadius => circular(card);
  /// Rayon de bordure pour les modales.
  static BorderRadius get modalRadius => circular(modal);
  /// Rayon de bordure pour les chips.
  static BorderRadius get chipRadius => circular(chip);
  /// Rayon de bordure pour les badges.
  static BorderRadius get badgeRadius => circular(badge);
  /// Rayon de bordure pour les avatars.
  static BorderRadius get avatarRadius => circular(avatar);
}
