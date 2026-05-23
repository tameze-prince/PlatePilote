import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
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

  void _editItem(int index, GroceryItem item) {
    final qtyController = TextEditingController(
      text: item.quantity?.toStringAsFixed(1) ?? '1',
    );
    final unitController = TextEditingController(
      text: item.unit ?? 'unit',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text);
              if (qty == null || qty <= 0) return;
              ref.read(groceryProvider.notifier).updateItemQuantity(
                index,
                qty,
                unitController.text.trim().isEmpty ? 'unit' : unitController.text.trim(),
              );
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryAccentGreen),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int index, GroceryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "${item.name}" from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(groceryProvider.notifier).removeItem(index);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
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
      // backgroundColor: PremiumTheme.background(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => context.push('/grocery/add'),
          backgroundColor: AppColors.primaryAccentGreen,
          foregroundColor: PremiumTheme.isDark(context)
              ? AppColors.darkBackground
              : Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: PremiumBackground(
        child: state.isLoading
            ? ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  FloatingHeader(
                    title: 'Grocery List',
                    subtitle: 'Your shopping list',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(
                    6,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: ShimmerGlassSkeleton(
                        width: double.infinity, height: 72,
                      ),
                    ),
                  ),
                ],
              )
            : state.error != null
                ? _buildErrorView(context)
                : state.items.isEmpty
                    ? _buildEmptyView(context)
                    : _buildListView(context, state, textTheme, grouped),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    GroceryListState state,
    TextTheme textTheme,
    Map<String, List<GroceryItem>> grouped,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(groceryProvider.notifier).refresh(),
      child: ListView(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: 80,
        ),
        children: [
          FloatingHeader(
            title: 'Grocery List',
            subtitle: state.currentList?.name ?? 'Your shopping list',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryCard(context, state),
          const SizedBox(height: AppSpacing.lg),
          for (final entry in grouped.entries) ...[
            Row(
              children: [
                Icon(_categoryIcon(entry.key),
                    color: PremiumTheme.textPrimary(context)),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    entry.key,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${entry.value.length} items',
                  style: textTheme.bodySmall?.copyWith(
                      color: PremiumTheme.textSecondary(context)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ...entry.value.map(
              (item) {
                final index = state.items.indexOf(item);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: GroceryItemTile(
                    item: item,
                    onToggle: () => ref.read(groceryProvider.notifier).toggleItem(
                      index,
                    ),
                    onEdit: () => _editItem(index, item),
                    onDelete: () => _deleteItem(index, item),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, GroceryListState state) {
    final textTheme = Theme.of(context).textTheme;
    final total = state.items
        .fold<double>(0, (sum, item) => sum + (item.estimatedPrice ?? 0));
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
                        style: textTheme.bodyMedium?.copyWith(
                            color: PremiumTheme.textSecondary(context))),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: textTheme.displaySmall?.copyWith(
                            color: AppColors.primaryAccentGreen,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              _buildChip(
                  context, '${state.items.length} items', AppColors.primaryAccentGreen),
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
                    value: state.items.isEmpty
                        ? 0
                        : checkedCount / state.items.length,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.primaryAccentGreen),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$checkedCount of ${state.items.length} items checked',
                  style: textTheme.bodySmall?.copyWith(
                      color: PremiumTheme.textSecondary(context)),
                ),
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
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        FloatingHeader(
          title: 'Grocery List',
          subtitle: 'Your shopping list',
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 36,
                    color: AppColors.primaryAccentGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Your grocery list is empty',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap the + button below to add items',
                  style: AppTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load grocery list',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: PremiumTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: () => ref.read(groceryProvider.notifier).refresh(),
            ),
          ],
        ),
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
