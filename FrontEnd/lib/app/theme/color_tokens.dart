import 'app_colors.dart';

// Backward compatibility layer
// All new code should use AppColors directly

/// Tokens de couleurs (couche de compatibilité avec [AppColors]).
abstract final class ColorTokens {
  // Primary colors
  /// Couleur primaire.
  static const primary = AppColors.primary;
  /// Vert primaire.
  static const primaryGreen = AppColors.primaryLight;
  /// Primaire foncé.
  static const primaryDark = AppColors.primaryDark;

  // Accent colors
  /// Accent ambré.
  static const accentAmber = AppColors.secondary;
  /// Accent bleu.
  static const accentBlue = AppColors.tertiary;

  // Functional colors
  /// Erreur.
  static const error = AppColors.error;
  /// Succès.
  static const success = AppColors.success;
  /// Avertissement.
  static const warning = AppColors.warning;
  /// Information.
  static const info = AppColors.info;

  // Light theme surfaces
  /// Fond clair.
  static const background = AppColors.background;
  /// Surface claire.
  static const surface = AppColors.surface;
  /// Conteneur surface bas.
  static const surfaceContainerLow = AppColors.surfaceContainerLow;
  /// Conteneur surface.
  static const surfaceContainer = AppColors.surfaceContainer;
  /// Conteneur surface haut.
  static const surfaceContainerHigh = AppColors.surfaceContainerHigh;

  // Light theme borders
  /// Bordure claire.
  static const border = AppColors.outline;

  // Light theme text
  /// Texte primaire clair.
  static const textPrimary = AppColors.onBackground;
  /// Texte secondaire clair.
  static const textSecondary = AppColors.onSurfaceVariant;

  // Dark theme surfaces
  /// Fond sombre.
  static const darkBackground = AppColors.darkBackground;
  /// Surface sombre.
  static const darkSurface = AppColors.darkSurface;
  /// Surface élevée sombre.
  static const darkElevatedSurface = AppColors.darkSurfaceContainerHigh;

  // Dark theme borders
  /// Bordure sombre.
  static const darkBorder = AppColors.darkOutline;

  // Dark theme text
  /// Texte primaire sombre.
  static const darkTextPrimary = AppColors.darkOnBackground;
  /// Texte secondaire sombre.
  static const darkTextSecondary = AppColors.darkOnSurfaceVariant;

  // Category colors
  /// Catégorie Produits frais.
  static const categoryProduce = AppColors.categoryProduce;
  /// Catégorie Protéines.
  static const categoryProtein = AppColors.categoryProtein;
  /// Catégorie Produits laitiers.
  static const categoryDairy = AppColors.categoryDairy;
  /// Catégorie Épicerie.
  static const categoryPantry = AppColors.categoryPantry;
  /// Catégorie Boissons.
  static const categoryBeverages = AppColors.categoryBeverages;
  /// Catégorie Snacks.
  static const categorySnacks = AppColors.categorySnacks;
  /// Catégorie Surgelés.
  static const categoryFrozen = AppColors.categoryFrozen;
  /// Catégorie Autre.
  static const categoryOther = AppColors.categoryOther;
}
