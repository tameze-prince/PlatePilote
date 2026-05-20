import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/color_tokens.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../shared/models/demo_data.dart';

class PlanAcceptanceScreen extends ConsumerStatefulWidget {
  final List<Meal> meals;

  const PlanAcceptanceScreen({super.key, required this.meals});

  @override
  ConsumerState<PlanAcceptanceScreen> createState() =>
      _PlanAcceptanceScreenState();
}

class _PlanAcceptanceScreenState extends ConsumerState<PlanAcceptanceScreen> {
  bool _isGenerating = false;
  bool _isAccepted = false;

  Future<void> _acceptPlan() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isGenerating = false;
      _isAccepted = true;
    });
  }

  Future<void> _regeneratePlan() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Your Weekly Plan',
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: ColorTokens.primaryGreen.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.input,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: ColorTokens.primaryGreen,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '7 Days • 21 Meals',
                                      style: context.text.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Personalized for your preferences',
                                      style: context.text.bodySmall?.copyWith(
                                        color: ColorTokens.textSecondary,
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
                                value: '22 min',
                                color: ColorTokens.accentBlue,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              _buildStatItem(
                                icon: Icons.local_fire_department_outlined,
                                label: 'Avg Calories',
                                value: '450 kcal',
                                color: ColorTokens.accentAmber,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              _buildStatItem(
                                icon: Icons.attach_money_outlined,
                                label: 'Est. Cost',
                                value: '\$142',
                                color: ColorTokens.primaryGreen,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sample Meals',
                            style: context.text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...widget.meals.take(3).map(
                            (meal) => _buildMealPreview(meal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What you\'ll get',
                            style: context.text.titleMedium?.copyWith(
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
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: ColorTokens.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
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
                          child: SecondaryButton(
                            label: 'Regenerate',
                            onPressed: _regeneratePlan,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: PrimaryButton(
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
    );
  }

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
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPreview(Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: meal.tint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(meal.icon, color: meal.tint, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              meal.title,
              style: context.text.bodyMedium,
            ),
          ),
          Text(
            '${meal.minutes}m',
            style: context.text.bodySmall?.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

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
            color: ColorTokens.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            color: ColorTokens.primaryGreen,
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
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: context.text.bodySmall?.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
