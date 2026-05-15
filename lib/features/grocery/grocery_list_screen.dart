import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/budget_meter.dart';
import '../../core/widgets/grocery_item_tile.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<GroceryItem>>{};
    for (final item in groceryItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return PlateScaffold(
      title: 'PlatePilot',
      trailing: IconButton(
        onPressed: () => context.push('/grocery/add'),
        icon: const Icon(Icons.add_circle_outline),
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Total',
                            style: context.text.bodyMedium,
                          ),
                          Text(
                            r'$142.85',
                            style: context.text.displaySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      avatar: const Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                      ),
                      label: const Text('Within Budget'),
                      backgroundColor: ColorTokens.surfaceContainerHigh,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const BudgetMeter(
                  progress: 0.72,
                  caption: '24 items to buy - 8 items in pantry',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final entry in grouped.entries) ...[
            Row(
              children: [
                Icon(_categoryIcon(entry.key), color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(entry.key, style: context.text.headlineSmall),
                ),
                Text(
                  '${entry.value.length} items',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ...entry.value.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: GroceryItemTile(item: item),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Produce' => Icons.eco,
      'Dairy & Eggs' => Icons.egg_alt,
      'Protein' => Icons.set_meal,
      _ => Icons.inventory_2_outlined,
    };
  }
}
