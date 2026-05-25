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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String query = '';
  List<RecipeDetail> _results = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _performSearch);
  }

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

  Widget _buildResultCard({
    required BuildContext context,
    required bool isDark,
    required RecipeDetail recipe,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Row(
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
    );
  }
}
