import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/repositories/recipe_repository.dart';
import '../../core/widgets/hero_flight.dart';
import '../../shared/widgets/recipe_image.dart';

/// Écran des détails d'une recette.
class RecipeDetailsScreen extends ConsumerStatefulWidget {
  const RecipeDetailsScreen({required this.recipeId, super.key});

  /// Identifiant de la recette.
  final String recipeId;

  @override
  ConsumerState<RecipeDetailsScreen> createState() =>
      _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends ConsumerState<RecipeDetailsScreen> {
  /// Recette chargée depuis l'API.
  RecipeDetail? _recipe;

  /// Indique si le chargement est en cours.
  bool _isLoading = true;

  /// Message d'erreur éventuel.
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  /// Charge les détails de la recette depuis l'API.
  Future<void> _loadRecipe() async {
    setState(() => _isLoading = true);
    try {
      final recipe = await ref
          .read(recipeRepositoryProvider)
          .getRecipeDetail(widget.recipeId);
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load recipe';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? _buildLoading()
              : _error != null
              ? _buildError()
              : _buildContent(),
        ),
      ),
    );
  }

  /// Affiche l'état de chargement.
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Affiche l'état d'erreur.
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: AppTypography.bodyLarge.copyWith(
              color: PremiumTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: _loadRecipe, child: const Text('Retry')),
        ],
      ),
    );
  }

  /// Affiche le contenu de la recette.
  Widget _buildContent() {
    final recipe = _recipe!;
    final heroTag = PlatePilotHeroTags.recipe(recipe.id);
    final heroChild = RecipeHeroImage(
      imageUrl: recipe.imageUrl,
      cuisine: recipe.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                0,
              ),
              child: heroTag == null
                  ? heroChild
                  : PlatePilotHero(tag: heroTag, child: heroChild),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  borderRadius: AppRadius.full,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              Text(
                recipe.name ?? '',
                style: AppTypography.headlineLarge.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: recipe.totalTimeMinutes != null
                        ? '${recipe.totalTimeMinutes} min'
                        : 'N/A',
                  ),
                  if (recipe.servings != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: '${recipe.servings} servings',
                    ),
                  ],
                  if (recipe.difficulty != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _InfoChip(
                      icon: Icons.signal_cellular_alt,
                      label: recipe.difficulty!,
                    ),
                  ],
                ],
              ),
              if (recipe.description != null &&
                  recipe.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  recipe.description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
              _buildNutritionInfo(recipe),
              _buildAllergenInfo(recipe),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Ingredients',
                style: AppTypography.titleLarge.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final ingredient in recipe.ingredients)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: PremiumTheme.glass(context, elevated: true),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryAccentGreen,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            ingredient.quantity != null
                                ? '${ingredient.name} — ${ingredient.quantity} ${ingredient.unit ?? ''}'
                                : ingredient.name ?? '',
                            style: AppTypography.bodyLarge.copyWith(
                              color: PremiumTheme.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (recipe.ingredients.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: PremiumTheme.glass(context, elevated: true),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryAccentGreen,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'No ingredients listed',
                            style: AppTypography.bodyLarge.copyWith(
                              color: PremiumTheme.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Steps',
                style: AppTypography.titleLarge.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (recipe.steps.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'No steps available',
                    style: AppTypography.bodyMedium.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                ),
              for (final step in recipe.steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: PremiumTheme.glass(context, elevated: true),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primaryAccentGreen,
                          child: Text(
                            '${step.stepNumber ?? (recipe.steps.indexOf(step) + 1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            step.instruction ?? '',
                            style: AppTypography.bodyLarge.copyWith(
                              color: PremiumTheme.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionInfo(RecipeDetail recipe) {
    final hasNutrition =
        recipe.caloriesPerServing != null ||
        recipe.proteinPerServing != null ||
        recipe.carbsPerServing != null ||
        recipe.fatPerServing != null ||
        recipe.fiberPerServing != null;
    if (!hasNutrition) return const SizedBox.shrink();

    String grams(double? value) =>
        value == null ? '—' : '${value.toStringAsFixed(1)} g';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: PremiumTheme.glass(context, elevated: true),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition per serving',
              style: AppTypography.titleLarge.copyWith(
                color: PremiumTheme.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${recipe.caloriesPerServing ?? '—'} kcal',
              style: AppTypography.headlineMedium.copyWith(
                color: PremiumTheme.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Protein ${grams(recipe.proteinPerServing)}  •  '
              'Carbs ${grams(recipe.carbsPerServing)}  •  '
              'Fat ${grams(recipe.fatPerServing)}  •  '
              'Fiber ${grams(recipe.fiberPerServing)}',
              style: AppTypography.bodySmall.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
            if (recipe.nutritionSource != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Source: ${recipe.nutritionSource}',
                style: AppTypography.bodySmall.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
              ),
            ],
            if (recipe.confidenceScore == null ||
                recipe.confidenceScore! < 0.7) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Nutrition values are estimates and have not been independently verified.',
                style: AppTypography.bodySmall.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllergenInfo(RecipeDetail recipe) {
    final statuses = <String, bool?>{
      'Gluten': recipe.containsGluten,
      'Dairy / lactose': recipe.containsLactose,
      'Nuts': recipe.containsNuts,
      'Soy': recipe.containsSoy,
      'Eggs': recipe.containsEggs,
      'Fish': recipe.containsFish,
      'Shellfish': recipe.containsShellfish,
    };
    final present = statuses.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
    final unknown = statuses.entries
        .where((entry) => entry.value == null)
        .map((entry) => entry.key)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: PremiumTheme.glass(context, elevated: true),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Allergen information',
                  style: AppTypography.titleLarge.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (present.isNotEmpty)
              Text(
                'Ingredient data indicates: ${present.join(', ')}.',
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                ),
              ),
            if (unknown.isNotEmpty)
              Text(
                'Unknown: ${unknown.join(', ')}.',
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                ),
              ),
            if (present.isEmpty && unknown.isEmpty)
              Text(
                'No listed allergens were detected in the available ingredient metadata. This does not guarantee the recipe is allergen-free.',
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Do not rely on this information for allergy safety. Check product packaging and confirm ingredients with the food provider.',
              style: AppTypography.bodySmall.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
            if (recipe.verified != true)
              Text(
                'This recipe has not been professionally verified.',
                style: AppTypography.bodySmall.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
              ),
            if (recipe.allergenSource != null)
              Text(
                'Data source: ${recipe.allergenSource}',
                style: AppTypography.bodySmall.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pastille d'information pour une recette.
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  /// Icône de la pastille.
  final IconData icon;

  /// Libellé de la pastille.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.glass(context, elevated: true),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryAccentGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: PremiumTheme.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}