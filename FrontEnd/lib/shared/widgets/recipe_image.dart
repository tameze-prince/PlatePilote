import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    this.imageUrl,
    this.width = 44,
    this.height = 44,
    this.borderRadius,
    this.cuisine,
    super.key,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double? borderRadius;
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
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _fallback(),
              )
            : _fallback(),
      ),
    );
  }

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
        color: AppColors.primaryAccentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
      ),
      child: Icon(icon, color: AppColors.primaryAccentGreen, size: width * 0.5),
    );
  }
}

class RecipeHeroImage extends StatelessWidget {
  const RecipeHeroImage({
    this.imageUrl,
    this.height = 220,
    this.cuisine,
    super.key,
  });

  final String? imageUrl;
  final double height;
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
                    errorBuilder: (_, __, ___) => _heroFallback(),
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
                            Colors.black.withOpacity(0.4),
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
        color: AppColors.primaryAccentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Center(
        child: Icon(icon, color: AppColors.primaryAccentGreen, size: 64),
      ),
    );
  }
}
