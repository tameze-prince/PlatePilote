import 'package:flutter/material.dart';

/// Palette de couleurs de l'application PlatePilot.
abstract final class AppColors {
  // Brand
  /// Vert accent principal.
  static const primaryAccentGreen = Color(0xFF22C55E);
  /// Vert foncé (couleur primaire).
  static const deepGreen = Color(0xFF16A34A);
  /// Cyan accent (premium).
  static const premiumCyanAccent = Color(0xFF67E8F9);
  /// Accent ambré/chaud.
  static const warmAccent = Color(0xFFF59E0B);

  // Compatibility names used across the app.
  /// Couleur primaire (alias deepGreen).
  static const primary = deepGreen;
  /// Vert clair (alias primaryAccentGreen).
  static const primaryLight = primaryAccentGreen;
  /// Vert foncé.
  static const primaryDark = Color(0xFF087A32);
  /// Conteneur primaire semi-transparent.
  static const primaryContainer = Color(0x3322C55E);
  /// Conteneur primaire sombre.
  static const darkPrimaryContainer = Color(0x3322C55E);
  /// Couleur secondaire.
  static const secondary = warmAccent;
  /// Secondaire clair.
  static const secondaryLight = Color(0xFFFBBF24);
  /// Couleur tertiaire.
  static const tertiary = premiumCyanAccent;

  // Semantic colors
  /// Couleur de succès.
  static const success = primaryAccentGreen;
  /// Couleur d'avertissement.
  static const warning = warmAccent;
  /// Couleur d'erreur.
  static const error = Color(0xFFEF4444);
  /// Couleur d'information.
  static const info = Color(0xFF38BDF8);

  // Dark theme surfaces
  /// Fond sombre principal.
  static const darkBackground = Color(0xFF020617);
  /// Fond sombre secondaire.
  static const darkSecondaryBackground = Color(0xFF06162A);
  /// Surface sombre.
  static const darkSurface = Color(0xFF0F172A);
  /// Surface sombre élevée.
  static const darkElevatedSurface = Color(0xFF162033);
  /// Surface verre sombre.
  static const darkGlassSurface = Color.fromRGBO(255, 255, 255, 0.08);
  /// Surface sombre faible luminosité.
  static const darkSurfaceDim = Color(0xFF020617);
  /// Surface sombre haute luminosité.
  static const darkSurfaceBright = Color(0xFF1E293B);
  /// Conteneur surface sombre le plus bas.
  static const darkSurfaceContainerLowest = Color(0xFF020617);
  /// Conteneur surface sombre bas.
  static const darkSurfaceContainerLow = Color(0xFF06162A);
  /// Conteneur surface sombre.
  static const darkSurfaceContainer = Color(0xFF0F172A);
  /// Conteneur surface sombre haut.
  static const darkSurfaceContainerHigh = Color(0xFF162033);
  /// Conteneur surface sombre le plus haut.
  static const darkSurfaceContainerHighest = Color(0xFF1E293B);

  // Light theme surfaces
  /// Fond clair principal.
  static const background = Color(0xFFF8FAFC);
  /// Fond clair secondaire.
  static const secondaryBackground = Color(0xFFEEF2F7);
  /// Surface claire.
  static const surface = Color(0xFFFFFFFF);
  /// Surface claire élevée.
  static const elevatedSurface = Color(0xFFF9FBFD);
  /// Surface verre claire.
  static const lightGlassSurface = Color.fromRGBO(255, 255, 255, 0.65);
  /// Surface claire faible luminosité.
  static const surfaceDim = Color(0xFFEEF2F7);
  /// Surface claire haute luminosité.
  static const surfaceBright = Color(0xFFFFFFFF);
  /// Conteneur surface clair le plus bas.
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  /// Conteneur surface clair bas.
  static const surfaceContainerLow = Color(0xFFF8FAFC);
  /// Conteneur surface clair.
  static const surfaceContainer = Color(0xFFF1F5F9);
  /// Conteneur surface clair haut.
  static const surfaceContainerHigh = Color(0xFFE2E8F0);
  /// Conteneur surface clair le plus haut.
  static const surfaceContainerHighest = Color(0xFFCBD5E1);

  // Text
  /// Texte principal (blanc).
  static const primaryText = Color(0xFFFFFFFF);
  /// Texte principal (alias, pour compat avec onBoarding).
  static const textPrimary = onSurface;
  /// Texte secondaire.
  static const secondaryText = Color.fromRGBO(255, 255, 255, 0.75);
  /// Texte tertiaire.
  static const tertiaryText = Color.fromRGBO(255, 255, 255, 0.50);
  /// Texte sur fond clair.
  static const onBackground = Color(0xFF0F172A);
  /// Texte sur surface claire.
  static const onSurface = Color(0xFF0F172A);
  /// Texte variant sur surface claire.
  static const onSurfaceVariant = Color.fromRGBO(15, 23, 42, 0.72);
  /// Texte tertiaire sur surface claire.
  static const onSurfaceTertiary = Color.fromRGBO(15, 23, 42, 0.48);
  /// Texte sur fond sombre.
  static const darkOnBackground = Color(0xFFFFFFFF);
  /// Texte sur surface sombre.
  static const darkOnSurface = Color(0xFFFFFFFF);
  /// Texte variant sur surface sombre.
  static const darkOnSurfaceVariant = Color.fromRGBO(255, 255, 255, 0.75);
  /// Texte tertiaire sur surface sombre.
  static const darkOnSurfaceTertiary = Color.fromRGBO(255, 255, 255, 0.50);

  // Utility
  /// Surface verre (blanche transparente).
  static const glassWhite = Color.fromRGBO(255, 255, 255, 0.65);
  /// Bordure (clair).
  static const outline = Color(0xFFE2E8F0);
  /// Bordure variante (clair).
  static const outlineVariant = Color(0xFFCBD5E1);
  /// Bordure (sombre).
  static const darkOutline = Color.fromRGBO(255, 255, 255, 0.08);
  /// Bordure variante (sombre).
  static const darkOutlineVariant = Color.fromRGBO(255, 255, 255, 0.04);
  /// Ombre.
  static const shadow = Color(0xFF000000);
  /// Ombre sombre.
  static const darkShadow = Color(0xFF000000);
  /// Scrim.
  static const scrim = Color(0x52000000);
  /// Scrim sombre.
  static const darkScrim = Color(0x52000000);
  /// Surface inversée.
  static const inverseSurface = Color(0xFF0F172A);
  /// Texte sur surface inversée.
  static const onInverseSurface = Color(0xFFF8FAFC);
  /// Surface inversée sombre.
  static const darkInverseSurface = Color(0xFFF8FAFC);
  /// Texte sur surface inversée sombre.
  static const darkOnInverseSurface = Color(0xFF0F172A);

  // Gradients
  /// Début du gradient.
  static const gradientStart = Color(0xFF087A32);
  /// Fin du gradient.
  static const gradientEnd = primaryAccentGreen;

  // Category colors
  /// Couleur catégorie Produits frais.
  static const categoryProduce = primaryAccentGreen;
  /// Couleur catégorie Protéines.
  static const categoryProtein = Color(0xFF3B82F6);
  /// Couleur catégorie Produits laitiers.
  static const categoryDairy = warmAccent;
  /// Couleur catégorie Épicerie.
  static const categoryPantry = Color(0xFF8B5CF6);
  /// Couleur catégorie Boissons.
  static const categoryBeverages = Color(0xFFEC4899);
  /// Couleur catégorie Snacks.
  static const categorySnacks = Color(0xFFF97316);
  /// Couleur catégorie Surgelés.
  static const categoryFrozen = Color(0xFF06B6D4);
  /// Couleur catégorie Autre.
  static const categoryOther = Color(0xFF64748B);
}
