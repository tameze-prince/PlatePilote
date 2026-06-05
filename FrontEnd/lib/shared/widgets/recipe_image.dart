import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// Image de recette avec fallback par type de cuisine.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    this.imageUrl,
    this.width = 44,
    this.height = 44,
    this.borderRadius,
    this.cuisine,
    super.key,
  });

  /// URL de l'image.
  final String? imageUrl;
  /// Largeur du conteneur.
  final double width;
  /// Hauteur du conteneur.
  final double height;
  /// Rayon de bordure.
  final double? borderRadius;
  /// Type de cuisine pour le fallback.
  final String? cuisine;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  /// Affichage de secours quand l'image n'est pas disponible.
  Widget _fallback() {
    final icon = switch (cuisine?.toLowerCase()) {
      'italian' => Icons.local_pizza,
      'mexican' => Icons.lunch_dining,
      'japanese' => Icons.ramen_dining,
      'indian' => Icons.rice_bowl,
      'french' => Icons.dinner_dining,
      'american' => Icons.fastfood,
      _ => Icons.restaurant,
    };
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryAccentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
      ),
      child: Icon(icon, color: AppColors.primaryAccentGreen, size: width * 0.5),
    );
  }
}

/// Image hero d'une recette avec superposition.
class RecipeHeroImage extends StatelessWidget {
  const RecipeHeroImage({
    this.imageUrl,
    this.height = 220,
    this.cuisine,
    super.key,
  });

  /// URL de l'image.
  final String? imageUrl;
  /// Hauteur du conteneur.
  final double height;
  /// Type de cuisine pour le fallback.
  final String? cuisine;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _heroFallback(),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _heroFallback(),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _heroFallback(),
      ),
    );
  }

  /// Affichage de secours pour l'image hero.
  Widget _heroFallback() {
    final icon = switch (cuisine?.toLowerCase()) {
      'italian' => Icons.local_pizza,
      'mexican' => Icons.lunch_dining,
      'japanese' => Icons.ramen_dining,
      'indian' => Icons.rice_bowl,
      'french' => Icons.dinner_dining,
      'american' => Icons.fastfood,
      _ => Icons.restaurant,
    };
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryAccentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Center(
        child: Icon(icon, color: AppColors.primaryAccentGreen, size: 64),
      ),
    );
  }
}
