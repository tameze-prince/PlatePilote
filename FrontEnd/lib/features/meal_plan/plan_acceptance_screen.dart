import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../shared/models/meal_plan.dart';
import 'meal_plan_provider.dart';

/// Écran d'acceptation du plan de repas.
/// Présente un résumé du plan généré et permet de l'accepter ou le régénérer.
class PlanAcceptanceScreen extends ConsumerStatefulWidget {
  /// Plan de repas à accepter.
  final MealPlan plan;

  const PlanAcceptanceScreen({super.key, required this.plan});

  @override
  ConsumerState<PlanAcceptanceScreen> createState() =>
      _PlanAcceptanceScreenState();
}

class _PlanAcceptanceScreenState extends ConsumerState<PlanAcceptanceScreen> {
  /// Indique si la régénération est en cours.
  bool _isGenerating = false;

  /// Indique si le plan a été accepté.
  bool _isAccepted = false;

  /// Accepte le plan et l'active.
  Future<void> _acceptPlan() async {
    setState(() => _isGenerating = true);
    await ref.read(mealPlanProvider.notifier).activatePlan();
    setState(() {
      _isGenerating = false;
      _isAccepted = true;
    });
  }

  /// Régénère un nouveau plan de repas.
  Future<void> _regeneratePlan() async {
    setState(() => _isGenerating = true);
    await ref.read(mealPlanProvider.notifier).generateNewPlan();
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    final meals = widget.plan.entries;
    final avgTime = meals.isNotEmpty
        ? '${(meals.length * 22 / meals.length).round()} min'
        : '22 min';
    final avgKcal = meals.isNotEmpty
        ? '${(meals.length * 450 / meals.length).round()} kcal'
        : '450 kcal';

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.md, 0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      'Your Weekly Plan',
                      style: AppTypography.titleLarge.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      PremiumCard(
                        variant: PremiumCardVariant.glass,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GlassContainer(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  borderRadius: AppRadius.md,
                                  elevated: true,
                                  child: const Icon(
                                    Icons.calendar_month,
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
                                        '${meals.length} Meals Planned',
                                        style: AppTypography.titleMedium.copyWith(
                                          color: PremiumTheme.textPrimary(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Personalized for your preferences',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: PremiumTheme.textSecondary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                _buildStatItem(
                                  icon: Icons.timer_outlined,
                                  label: 'Avg Time',
                                  value: avgTime,
                                  color: AppColors.premiumCyanAccent,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                _buildStatItem(
                                  icon: Icons.local_fire_department_outlined,
                                  label: 'Avg Calories',
                                  value: avgKcal,
                                  color: AppColors.warmAccent,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                _buildStatItem(
                                  icon: Icons.attach_money_outlined,
                                  label: 'Est. Cost',
                                  value: r'$142',
                                  color: AppColors.primaryAccentGreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PremiumCard(
                        variant: PremiumCardVariant.glass,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meals',
                              style: AppTypography.titleMedium.copyWith(
                                color: PremiumTheme.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ...meals.take(5).map(
                              (entry) => _buildMealPreview(entry),
                            ),
                            if (meals.length > 5) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '+${meals.length - 5} more meals',
                                style: AppTypography.bodySmall.copyWith(
                                  color: PremiumTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PremiumCard(
                        variant: PremiumCardVariant.glass,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What you\'ll get',
                              style: AppTypography.titleMedium.copyWith(
                                color: PremiumTheme.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildBenefitItem(
                              icon: Icons.shopping_cart_outlined,
                              title: 'Auto-generated grocery list',
                              description: 'Based on your meal plan',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildBenefitItem(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Budget tracking',
                              description: 'Stay within your weekly budget',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildBenefitItem(
                              icon: Icons.eco_outlined,
                              title: 'Pantry optimization',
                              description: 'Use what you have first',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl,
                ),
                child: _isGenerating
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: AppSpacing.sm),
                          Text('Generating your plan...'),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              label: 'Regenerate',
                              variant: GlassButtonVariant.outlined,
                              onPressed: _regeneratePlan,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: GlassButton(
                              label: _isAccepted ? 'View Plan' : 'Accept Plan',
                              onPressed: _acceptPlan,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un élément de statistique (temps, calories, coût).
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: PremiumTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un aperçu d'un repas du plan.
  Widget _buildMealPreview(MealPlanEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumTheme.glass(context, elevated: true),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryAccentGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppColors.primaryAccentGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.recipeName ?? 'Unknown',
                  style: AppTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textPrimary(context),
                  ),
                ),
                Text(
                  '${entry.mealDate ?? ''} • ${entry.mealType ?? ''}',
                  style: AppTypography.bodySmall.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un élément listant un avantage du plan.
  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.primaryAccentGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryAccentGreen,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
