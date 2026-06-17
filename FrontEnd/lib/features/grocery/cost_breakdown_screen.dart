import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';

/// Écran de répartition des coûts des courses.
/// Affiche le total estimé, la répartition par catégorie et les articles les plus chers.
class GroceryCostBreakdownScreen extends ConsumerStatefulWidget {
  const GroceryCostBreakdownScreen({super.key});

  @override
  ConsumerState<GroceryCostBreakdownScreen> createState() =>
      _GroceryCostBreakdownScreenState();
}

class _GroceryCostBreakdownScreenState
    extends ConsumerState<GroceryCostBreakdownScreen> {
  /// Coût total estimé des courses.
  final double _totalCost = 142.85;

  /// Budget hebdomadaire défini.
  final double _budget = 400;

  /// Répartition des coûts par catégorie.
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Produce',
      'icon': Icons.eco,
      'color': AppColors.primaryLight,
      'items': 8,
      'cost': 45.50,
      'percentage': 0.32,
    },
    {
      'name': 'Protein',
      'icon': Icons.restaurant,
      'color': AppColors.tertiary,
      'items': 4,
      'cost': 52.30,
      'percentage': 0.37,
    },
    {
      'name': 'Dairy & Eggs',
      'icon': Icons.icecream,
      'color': AppColors.secondary,
      'items': 5,
      'cost': 28.75,
      'percentage': 0.20,
    },
    {
      'name': 'Pantry Staples',
      'icon': Icons.grain,
      'color': Color(0xFF8B5CF6),
      'items': 4,
      'cost': 12.30,
      'percentage': 0.09,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': AppColors.onSurfaceVariant,
      'items': 3,
      'cost': 4.00,
      'percentage': 0.02,
    },
  ];

  /// Articles les plus coûteux de la liste.
  final List<Map<String, dynamic>> _topItems = [
    {'name': 'Atlantic Salmon', 'cost': 19.48, 'quantity': '1.5 lb'},
    {'name': 'Chicken Breast', 'cost': 13.80, 'quantity': '2 lb'},
    {'name': 'Greek Yogurt', 'cost': 5.50, 'quantity': '1 tub'},
    {'name': 'Organic Apples', 'cost': 7.50, 'quantity': '5 count'},
    {'name': 'Baby Spinach', 'cost': 7.98, 'quantity': '2 bags'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Breakdown'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: AppColors.primaryLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Total',
                              style: context.text.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '\$${_totalCost.toStringAsFixed(2)}',
                              style: context.text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          'Within Budget',
                          style: context.text.bodySmall?.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: _totalCost / _budget,
                      backgroundColor: AppColors.surfaceContainerLow,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_categories.fold<int>(0, (sum, cat) => sum + cat['items'] as int)} items',
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '\$${(_budget - _totalCost).toStringAsFixed(2)} remaining',
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
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
                    'By Category',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._categories.map(
                    (cat) => _buildCategoryRow(cat),
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
                    'Top Items by Cost',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._topItems.asMap().entries.map(
                    (entry) => _buildTopItemRow(entry.key + 1, entry.value),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Savings Tips',
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTipItem(
                    'Buy chicken in bulk and freeze portions',
                    'Save ~\$5/week',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTipItem(
                    'Choose seasonal produce',
                    'Save ~\$8/week',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTipItem(
                    'Use pantry items first',
                    'Save ~\$12/week',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une ligne de catégorie avec sa barre de progression.
  Widget _buildCategoryRow(Map<String, dynamic> cat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: (cat['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              cat['icon'] as IconData,
              color: cat['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cat['name'] as String,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '(${cat['items']} items)',
                      style: context.text.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: cat['percentage'] as double,
                    backgroundColor: AppColors.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      cat['color'] as Color,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '\$${(cat['cost'] as double).toStringAsFixed(2)}',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une ligne d'article le plus coûteux.
  Widget _buildTopItemRow(int rank, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? AppColors.primaryLight.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: context.text.bodySmall?.copyWith(
                  color: rank <= 3
                      ? AppColors.primaryLight
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: context.text.bodyMedium,
                ),
                Text(
                  item['quantity'] as String,
                  style: context.text.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item['cost'] as double).toStringAsFixed(2)}',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une astuce d'économie.
  Widget _buildTipItem(String tip, String savings) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.primaryLight,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            tip,
            style: context.text.bodySmall,
          ),
        ),
        Text(
          savings,
          style: context.text.bodySmall?.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
