import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/repositories/recipe_repository.dart';
import '../../core/widgets/empty_state.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<RecipeDetail> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(recipeRepositoryProvider)
          .getFavoriteRecipes();
      setState(() {
        _favorites = response.content;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load favorites';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(RecipeDetail recipe) async {
    final success =
        await ref.read(recipeRepositoryProvider).unfavoriteRecipe(recipe.id!);
    if (success && mounted) {
      setState(() => _favorites.removeWhere((r) => r.id == recipe.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48,
                          color: Colors.red),
                      const SizedBox(height: AppSpacing.md),
                      Text(_error!),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: _loadFavorites,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _favorites.isEmpty
                  ? EmptyState(
                      icon: Icons.favorite_border,
                      title: 'No favorites yet',
                      message: 'Save recipes you love to find them quickly',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final recipe = _favorites[index];
                        return _buildFavoriteCard(recipe);
                      },
                    ),
    );
  }

  Widget _buildFavoriteCard(RecipeDetail recipe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.xl,
        elevated: true,
        child: InkWell(
          onTap: () => context.push('/recipe/${recipe.id}'),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.primaryAccentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${recipe.totalTimeMinutes ?? 0} min • ${recipe.mealType ?? ''}',
                      style: AppTypography.bodySmall.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.error),
                onPressed: () => _removeFavorite(recipe),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16,
                  color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
