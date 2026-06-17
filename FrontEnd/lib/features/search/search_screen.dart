import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/repositories/recipe_repository.dart';
import '../../core/widgets/modern_components.dart';
import '../../core/widgets/modern_animations.dart';
import '../../core/widgets/floating_components.dart';
import '../../shared/widgets/recipe_image.dart';
import '../support/filter_bottom_sheet.dart';
import 'what_if.dart';

/// Écran de recherche de recettes.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  /// Requête de recherche en cours.
  String query = '';
  /// Résultats de la recherche.
  List<RecipeDetail> _results = [];
  /// Indique si une recherche est en cours.
  bool _isLoading = false;
  /// Message d'erreur éventuel.
  String? _error;
  /// Timer de debounce pour éviter les appels API trop fréquents.
  Timer? _debounce;
  /// Mode What-If : affiche comparaison prix & impact budget.
  bool _whatIfMode = false;
  /// Map de savings simulés (recipe_id → WhatIfResult).
  final Map<String, WhatIfResult> _whatIfResults = {};

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Quand l'utilisateur toggle le mode What-If, on génère/annule
  /// les estimations pour chaque résultat déjà chargé.
  Future<void> _toggleWhatIf(bool value) async {
    setState(() => _whatIfMode = value);
    if (!value) {
      setState(() => _whatIfResults.clear());
      return;
    }
    for (final r in _results) {
      _computeWhatIf(r);
    }
  }

  /// Génère une comparaison What-If déterministe+heuristique pour une recette.
  void _computeWhatIf(RecipeDetail recipe) {
    final id = recipe.id?.toString() ?? recipe.name ?? '';
    final cost = (recipe as dynamic).costPerServing;
    double costPerServing = 0;
    if (cost is num) costPerServing = cost.toDouble();
    // Heuristique simple : coût moyen ~ 0.85€/ingrédient pour 4 pers.
    costPerServing = costPerServing > 0
        ? costPerServing
        : (4.5 + ((recipe.totalTimeMinutes ?? 30) % 7) * 0.3);

    // 3 substituts "what-if" durables, plus chers à similitude haute
    final subs = WhatIfCatalog.suggest(recipe.name ?? '');
    setState(() {
      _whatIfResults[id] = WhatIfResult(
        originalCost: costPerServing,
        substitutes: subs,
      );
    });
  }

  /// Appelée lorsque la requête change.
  void _onSearchChanged(String value) {
    setState(() => query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _performSearch);
  }

  /// Effectue la recherche via le repository.
  Future<void> _performSearch() async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(recipeRepositoryProvider)
          .searchRecipes(query: query.trim());
      setState(() {
        _results = response.content;
        _isLoading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FloatingAppBar(
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
              title: Text(
                'Search',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Filters',
                  icon: const Icon(Icons.tune),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const FilterBottomSheet(),
                  ),
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: FloatingSearchBar(
              hintText: 'Search meals, pantry items, recipes...',
              onChanged: _onSearchChanged,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _WhatIfToggle(
                value: _whatIfMode,
                onChanged: (v) => _toggleWhatIf(v),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Text(
                        'Results',
                        style: AppTypography.headlineSmall.copyWith(
                          color: isDark
                              ? AppColors.darkOnSurface
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!_isLoading) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryContainer
                                : AppColors.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppRadius.badge),
                          ),
                          child: Text(
                            '${_results.length}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Column(
                      children: [
                        EmptyState(
                          icon: Icons.error_outline,
                          title: 'Error',
                          message: _error!,
                        ),
                        FilledButton(
                          onPressed: _performSearch,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  else if (query.isEmpty)
                    EmptyState(
                      icon: Icons.search,
                      title: 'Search recipes',
                      message: 'Type to search across thousands of recipes',
                    )
                  else if (_results.isEmpty)
                    EmptyState(
                      icon: Icons.search_off,
                      title: 'No results found',
                      message: 'Try adjusting your search or filters',
                    )
                  else
                    ..._results.asMap().entries.map(
                          (entry) => AnimatedListItem(
                            delay: entry.key,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _buildResultCard(
                                context: context,
                                isDark: isDark,
                                recipe: entry.value,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une carte de résultat de recherche.
  Widget _buildResultCard({
    required BuildContext context,
    required bool isDark,
    required RecipeDetail recipe,
  }) {
    final id = recipe.id?.toString() ?? recipe.name ?? '';
    final whatIf = _whatIfMode ? _whatIfResults[id] : null;
    return ModernCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RecipeImage(
                imageUrl: recipe.imageUrl,
                cuisine: recipe.name,
                width: 48,
                height: 48,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name ?? '',
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${recipe.totalTimeMinutes ?? 0} min • ${recipe.mealType ?? ''}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
          if (whatIf != null) WhatIfBadge(result: whatIf),
        ],
      ),
    );
  }
}

/// Toggle visuel pour activer/désactiver le mode What-If.
///
/// Affiche un chip-pill en mode "off" et un chip rempli vert en mode "on",
/// avec une icône compare_arrows et un label court.
class _WhatIfToggle extends StatelessWidget {
  const _WhatIfToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF1B7F3A);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? accent.withValues(alpha: 0.12)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: value
                ? accent
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 16,
              color: value
                  ? accent
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              value ? 'What-If ON' : 'What-If',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: value
                    ? accent
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: 4),
            if (value)
              Icon(Icons.check_circle, size: 14, color: accent)
            else
              const Icon(Icons.circle_outlined, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
