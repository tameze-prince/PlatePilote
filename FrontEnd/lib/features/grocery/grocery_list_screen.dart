import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/premium_components.dart';
import '../../core/widgets/grocery_item_tile.dart';
import '../../shared/models/grocery_list.dart';
import '../../shared/widgets/shimmer_glass_skeleton.dart';
import 'grocery_provider.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(groceryProvider.notifier).refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groceryProvider);
    final textTheme = Theme.of(context).textTheme;
    final grouped = <String, List<GroceryItem>>{};
    for (final item in state.items) {
      grouped.putIfAbsent(item.category ?? 'Other', () => []).add(item);
    }

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        child: RefreshIndicator(
          onRefresh: () => ref.read(groceryProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              FloatingHeader(
                title: 'Grocery List',
                subtitle: state.currentList?.name ?? 'Your shopping list',
                actions: [
                  IconButton(
                    onPressed: () => context.push('/grocery/add'),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.isLoading)
                ...List.generate(6, (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: ShimmerGlassSkeleton(
                    width: double.infinity, height: 72,
                  ),
                ))
              else if (state.error != null)
                _buildErrorCard(context)
              else if (state.useDemoFallback && state.items.isEmpty)
                _buildEmptyState(context)
              else ...[
                _buildSummaryCard(context, state),
                const SizedBox(height: AppSpacing.lg),
                for (final entry in grouped.entries) ...[
                  Row(
                    children: [
                      Icon(_categoryIcon(entry.key), color: PremiumTheme.textPrimary(context)),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${entry.value.length} items',
                        style: textTheme.bodySmall?.copyWith(color: PremiumTheme.textSecondary(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...entry.value.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: GroceryItemTile(
                        item: item,
                        onToggle: () => ref.read(groceryProvider.notifier).toggleItem(
                          state.items.indexOf(item),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, GroceryListState state) {
    final textTheme = Theme.of(context).textTheme;
    final total = state.items.fold<double>(0, (sum, item) => sum + (item.estimatedPrice ?? 0));
    final checkedCount = state.items.where((i) => i.checked).length;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Total',
                      style: textTheme.bodyMedium?.copyWith(color: PremiumTheme.textSecondary(context))),
                    Text('\$${total.toStringAsFixed(2)}',
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.primaryAccentGreen, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              _buildChip(context, '${state.items.length} items', AppColors.primaryAccentGreen),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.items.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.items.isEmpty ? 0 : checkedCount / state.items.length,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryAccentGreen),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('$checkedCount of ${state.items.length} items checked',
                  style: textTheme.bodySmall?.copyWith(color: PremiumTheme.textSecondary(context))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PremiumCard(
        variant: PremiumCardVariant.accent,
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Failed to load grocery list',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Retry', icon: Icons.refresh,
                onPressed: () => ref.read(groceryProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: PremiumTheme.textSecondary(context)),
          const SizedBox(height: AppSpacing.md),
          Text('No grocery list yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Text('Generate a list from your meal plan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PremiumTheme.textSecondary(context))),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Produce' => Icons.eco,
      'Dairy & Eggs' => Icons.egg_alt,
      'Protein' => Icons.set_meal,
      'Pantry Staples' => Icons.inventory_2_outlined,
      _ => Icons.inventory_2_outlined,
    };
  }
}
