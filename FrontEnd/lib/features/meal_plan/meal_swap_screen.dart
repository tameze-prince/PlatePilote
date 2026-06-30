import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/analytics/event_payload.dart';
import '../../core/premium_components.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/models/meal_plan.dart';
import '../../shared/widgets/shimmer_glass_skeleton.dart';
import 'meal_plan_provider.dart';
import 'meal_plan_repository.dart';

/// Écran d'échange de repas.
/// Permet de remplacer un repas par une alternative dans le plan hebdomadaire.
class MealSwapScreen extends ConsumerStatefulWidget {
  /// Repas actuel à remplacer.
  final Meal currentMeal;

  /// Index du jour dans le plan.
  final int dayIndex;

  /// Type de repas (petit-déjeuner, déjeuner, dîner, etc.).
  final String mealType;

  /// Entrée de plan correspondante (optionnelle).
  final MealPlanEntry? currentEntry;

  const MealSwapScreen({
    super.key,
    required this.currentMeal,
    required this.dayIndex,
    required this.mealType,
    this.currentEntry,
  });

  @override
  ConsumerState<MealSwapScreen> createState() => _MealSwapScreenState();
}

class _MealSwapScreenState extends ConsumerState<MealSwapScreen> {
  /// Liste des alternatives disponibles pour l'échange.
  List<_SwapOption> _alternatives = [];

  /// Indique si le chargement est en cours.
  bool _isLoading = true;

  /// Dernière erreur rencontrée lors du chargement.
  Object? _error;

  /// Alternative sélectionnée par l'utilisateur.
  _SwapOption? _selectedMeal;

  @override
  void initState() {
    super.initState();
    _loadAlternatives();
  }

  /// Charge les alternatives depuis l'API uniquement (pas de fallback démo).
  Future<void> _loadAlternatives() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final entryId = widget.currentEntry?.id;
      if (entryId == null) {
        throw StateError('No meal-plan entry attached for swap.');
      }
      final repo = ref.read(mealPlanRepositoryProvider);
      final options = await repo.getSwapOptions(entryId, 10);
      setState(() {
        _alternatives = options.map((o) => _SwapOption.fromJson(o)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _alternatives = [];
        _isLoading = false;
      });
    }
  }

  /// Construit 3 skeleton cards (food-card mock) pendant le chargement.
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: PremiumTheme.glass(context, elevated: true),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: PremiumTheme.border(context)),
          ),
          child: Row(
            children: [
              ShimmerGlassSkeleton(
                width: 44,
                height: 44,
                borderRadius: AppRadius.md,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerGlassSkeleton(
                      width: double.infinity,
                      height: 14,
                      borderRadius: AppRadius.sm,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ShimmerGlassSkeleton(
                      width: 120,
                      height: 10,
                      borderRadius: AppRadius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Applique l'échange du repas sélectionné.
  Future<void> _swapMeal() async {
    if (_selectedMeal == null) return;
    if (widget.currentEntry?.id != null && _selectedMeal!.recipeId != null) {
      try {
        final repo = ref.read(mealPlanRepositoryProvider);
        await repo.applySwap(widget.currentEntry!.id!, _selectedMeal!.recipeId!);
        await ref.read(mealPlanProvider.notifier).refresh();
        ref.read(analyticsServiceProvider).trackPayload(
          PlateEvents.mealSwapped,
          payload: EventPayload(
            source: 'manual',
            meta: <String, Object>{
              'mealType': widget.mealType,
              'fromRecipeId': widget.currentEntry?.recipeId ?? '',
              'toRecipeId': _selectedMeal!.recipeId ?? '',
            },
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal swapped successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (_) {
        final newEntry = MealPlanEntry(
          recipeId: _selectedMeal!.recipeId,
          recipeName: _selectedMeal!.name,
          mealDate: widget.currentEntry!.mealDate,
          mealType: widget.mealType,
          servings: widget.currentEntry!.servings,
        );
        await ref
            .read(mealPlanProvider.notifier)
            .replaceEntry(widget.dayIndex, newEntry);
      }
    }
    if (mounted) context.pop();
  }

  /// Régénère l'intégralité du plan de repas.
  Future<void> _regenerateAll() async {
    await ref.read(mealPlanProvider.notifier).generateNewPlan();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Swap Meal',
                      style: AppTypography.titleLarge.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _regenerateAll,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Regenerate All'),
                    ),
                  ],
                ),
              ),
            ),
            GlassContainer(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.xl,
              elevated: true,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: widget.currentMeal.tint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      widget.currentMeal.icon,
                      color: widget.currentMeal.tint,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current ${widget.mealType}',
                          style: AppTypography.bodySmall.copyWith(
                            color: PremiumTheme.textTertiary(context),
                          ),
                        ),
                        Text(
                          widget.currentMeal.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: PremiumTheme.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.currentMeal.minutes} min \u2022 ${widget.currentMeal.kcal} kcal',
                          style: AppTypography.bodySmall.copyWith(
                            color: PremiumTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_downward,
                    color: AppColors.primaryAccentGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Choose an alternative',
                style: AppTypography.titleMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _isLoading
                  ? _buildSkeletonList()
                  : _error != null
                      ? _SwapErrorState(
                          onRetry: _loadAlternatives,
                          onCancel: () => context.pop(),
                        )
                      : _alternatives.isEmpty
                          ? _SwapEmptyState(
                              onCancel: () => context.pop(),
                              onRegenerate: _regenerateAll,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              itemCount: _alternatives.length,
                              itemBuilder: (context, index) {
                                final meal = _alternatives[index];
                                final isSelected = _selectedMeal == meal;

                                IconData icon = Icons.restaurant;
                                Color tint = Colors.green;
                                switch (widget.mealType.toLowerCase()) {
                                  case 'breakfast':
                                    icon = Icons.wb_sunny; tint = Colors.orange; break;
                                  case 'lunch':
                                    icon = Icons.lunch_dining; tint = Colors.amber; break;
                                  case 'dinner':
                                    icon = Icons.dinner_dining; tint = Colors.deepPurple; break;
                                  case 'snack':
                                    icon = Icons.cookie; tint = Colors.brown; break;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedMeal = meal);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.sm,
                                    ),
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryAccentGreen.withValues(alpha: 0.12)
                                          : PremiumTheme.glass(context, elevated: true),
                                      borderRadius: BorderRadius.circular(AppRadius.xl),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryAccentGreen
                                            : PremiumTheme.border(context),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(AppSpacing.sm),
                                          decoration: BoxDecoration(
                                            color: tint.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                          ),
                                          child: Icon(icon, color: tint, size: 22),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meal.name,
                                                style: AppTypography.bodyMedium.copyWith(
                                                  color: PremiumTheme.textPrimary(context),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '${meal.minutes ?? "?"} min \u2022 ${meal.calories ?? "?"} kcal',
                                                style: AppTypography.bodySmall.copyWith(
                                                  color: PremiumTheme.textSecondary(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.primaryAccentGreen,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Cancel',
                      variant: GlassButtonVariant.outlined,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Swap Meal',
                      onPressed: _selectedMeal != null ? _swapMeal : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Option d'échange de repas.
class _SwapOption {
  /// Identifiant de la recette alternative.
  final String? recipeId;

  /// Nom du repas.
  final String name;

  /// Temps de préparation en minutes.
  final int? minutes;

  /// Calories par portion.
  final int? calories;

  /// URL de l'image du repas.
  final String? imageUrl;

  _SwapOption({
    this.recipeId,
    required this.name,
    this.minutes,
    this.calories,
    this.imageUrl,
  });

  /// Crée une instance depuis une réponse JSON de l'API.
  factory _SwapOption.fromJson(Map<String, dynamic> json) {
    return _SwapOption(
      recipeId: json['recipeId']?.toString(),
      name: json['name'] as String? ?? 'Unknown',
      minutes: json['totalTimeMinutes'] as int?,
      calories: json['caloriesPerServing'] as int?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// État vide — affiché quand l'API renvoie une liste vide.
class _SwapEmptyState extends StatelessWidget {
  const _SwapEmptyState({
    required this.onCancel,
    required this.onRegenerate,
  });

  final VoidCallback onCancel;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_meals_outlined,
                size: 64,
                color: AppColors.primaryAccentGreen,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No alternatives available',
                style: AppTypography.titleLarge.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Try regenerating your plan or adjusting your preferences',
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Cancel',
                      variant: GlassButtonVariant.outlined,
                      onPressed: onCancel,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Regenerate Plan',
                      onPressed: onRegenerate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// État d'erreur — affiché si `getSwapOptions` lève une exception.
class _SwapErrorState extends StatelessWidget {
  const _SwapErrorState({
    required this.onRetry,
    required this.onCancel,
  });

  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: AppColors.primaryAccentGreen,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Couldn't load alternatives",
                style: AppTypography.titleLarge.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Check your connection and try again.',
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Cancel',
                      variant: GlassButtonVariant.outlined,
                      onPressed: onCancel,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Retry',
                      onPressed: onRetry,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
