import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/design_system/components/pp_empty_state.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/premium_components.dart';
import '../../core/widgets/grocery_item_tile.dart';
import '../../shared/models/grocery_list.dart';
import '../../shared/widgets/shimmer_glass_skeleton.dart';
import '../budget/budget_provider.dart';
import 'grocery_provider.dart';

/// Écran principal de la liste de courses.
/// Affiche les articles groupés par catégorie avec progression et résumé budgétaire.
class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  /// Évite une double initialisation.
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

  /// Ouvre le dialogue d'ajout rapide d'article.
  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final unitCtrl = TextEditingController(text: 'unit');
    final priceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Item name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'Produce', child: Text('Produce')),
                    DropdownMenuItem(
                      value: 'Dairy & Eggs',
                      child: Text('Dairy & Eggs'),
                    ),
                    DropdownMenuItem(value: 'Protein', child: Text('Protein')),
                    DropdownMenuItem(
                      value: 'Pantry Staples',
                      child: Text('Pantry Staples'),
                    ),
                    DropdownMenuItem(value: 'Frozen', child: Text('Frozen')),
                    DropdownMenuItem(value: 'Bakery', child: Text('Bakery')),
                    DropdownMenuItem(value: 'Spices', child: Text('Spices')),
                    DropdownMenuItem(
                      value: 'Beverages',
                      child: Text('Beverages'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => selectedCategory = v),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
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
                        controller: unitCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Est. price (\$)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final qty = double.tryParse(qtyCtrl.text) ?? 1;
                final price = double.tryParse(priceCtrl.text);
                ref
                    .read(groceryProvider.notifier)
                    .addItem(
                      name: name,
                      category: selectedCategory,
                      quantity: qty,
                      unit: unitCtrl.text.trim().isEmpty
                          ? 'unit'
                          : unitCtrl.text.trim(),
                      estimatedPrice: price,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryAccentGreen,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  /// Ouvre le dialogue d'édition de la quantité d'un article.
  void _editItem(int index, GroceryItem item) {
    final qtyController = TextEditingController(
      text: item.quantity?.toStringAsFixed(1) ?? '1',
    );
    final unitController = TextEditingController(text: item.unit ?? 'unit');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
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
              ref
                  .read(groceryProvider.notifier)
                  .updateItemQuantity(
                    index,
                    qty,
                    unitController.text.trim().isEmpty
                        ? 'unit'
                        : unitController.text.trim(),
                  );
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryAccentGreen,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Affiche une confirmation avant de supprimer un article.
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
    final budgetState = ref.watch(budgetProvider);
    final textTheme = Theme.of(context).textTheme;
    final grouped = <String, List<GroceryItem>>{};
    final pinned = state.items.where(_isPinnedItem).toList();
    for (final item in state.items.where((item) => !_isPinnedItem(item))) {
      grouped.putIfAbsent(item.category ?? 'Other', () => []).add(item);
    }

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      extendBody: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: _showAddItemDialog,
          backgroundColor: AppColors.primaryAccentGreen,
          foregroundColor: PremiumTheme.isDark(context)
              ? AppColors.darkBackground
              : Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: PremiumBackground(
        safeArea: false,
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
                        width: double.infinity,
                        height: 72,
                      ),
                    ),
                  ),
                ],
              )
            : state.error != null
            ? _buildErrorView(context)
            : state.items.isEmpty
            ? _buildEmptyView(context)
            : _buildListView(
                context,
                state,
                budgetState,
                textTheme,
                grouped,
                pinned,
              ),
      ),
    );
  }

  /// Construit la vue liste complète avec les sections.
  Widget _buildListView(
    BuildContext context,
    GroceryListState state,
    BudgetState budgetState,
    TextTheme textTheme,
    Map<String, List<GroceryItem>> grouped,
    List<GroceryItem> pinned,
  ) {
    final total = state.totalEstimatedPrice;
    final overBudget =
        budgetState.weeklyBudget > 0 && total > budgetState.weeklyBudget;

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
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Purchase History',
                onPressed: () => context.push('/grocery/history'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryCard(context, state, budgetState, overBudget),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: state.isSaving ? 'Saving...' : 'Save List',
                  icon: Icons.save_outlined,
                  onPressed: state.isSaving
                      ? null
                      : () => ref.read(groceryProvider.notifier).saveList(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GlassButton(
                  label: 'Mark Bought',
                  icon: Icons.check_circle_outline,
                  variant: state.checkedCount == 0
                      ? GlassButtonVariant.outlined
                      : GlassButtonVariant.filled,
                  onPressed: state.checkedCount == 0
                      ? null
                      : () => ref
                            .read(groceryProvider.notifier)
                            .markItemsAsBought(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSwipeHint(context),
          const SizedBox(height: AppSpacing.md),
          if (pinned.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              icon: Icons.priority_high_rounded,
              title: 'Priority',
              count:
                  '${pinned.where((item) => item.checked).length}/${pinned.length}',
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.xs),
            ...pinned.map((item) {
              final index = state.items.indexOf(item);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: GroceryItemTile(
                  item: item.copyWith(isHighPriority: true),
                  onToggle: () =>
                      ref.read(groceryProvider.notifier).toggleItem(index),
                  onEdit: () => _editItem(index, item),
                  onDelete: () => _deleteItem(index, item),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final entry in grouped.entries) ...[
            _buildSectionHeader(
              context,
              icon: _categoryIcon(entry.key),
              title: entry.key,
              count:
                  '${entry.value.where((item) => item.checked).length}/${entry.value.length}',
            ),
            const SizedBox(height: AppSpacing.xs),
            ...entry.value.map((item) {
              final index = state.items.indexOf(item);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: GroceryItemTile(
                  item: item,
                  onToggle: () =>
                      ref.read(groceryProvider.notifier).toggleItem(index),
                  onEdit: () => _editItem(index, item),
                  onDelete: () => _deleteItem(index, item),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  /// Construit la carte de résumé (total, progression, budget).
  Widget _buildSummaryCard(
    BuildContext context,
    GroceryListState state,
    BudgetState budgetState,
    bool overBudget,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final total = state.totalEstimatedPrice;
    final checkedCount = state.checkedCount;
    final progress = state.items.isEmpty
        ? 0.0
        : checkedCount / state.items.length;
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
                    Text(
                      'Estimated Total',
                      style: textTheme.bodyMedium?.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.primaryAccentGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primaryAccentGreen,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: textTheme.labelLarge?.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w800,
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
              _buildChip(
                context,
                '$checkedCount/${state.items.length} items',
                AppColors.primaryAccentGreen,
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildChip(
                context,
                '${state.items.length - checkedCount} left',
                AppColors.info,
              ),
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
                      AppColors.primaryAccentGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$checkedCount of ${state.items.length} items checked',
                  style: textTheme.bodySmall?.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          if (overBudget) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Total exceeds your \$${budgetState.weeklyBudget.toStringAsFixed(0)} weekly budget by \$${(total - budgetState.weeklyBudget).toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit un chip coloré pour afficher un indicateur.
  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  /// Construit l'en-tête d'une section de catégorie.
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String count,
    Color? color,
  }) {
    final theme = Theme.of(context).textTheme;
    final accent = color ?? PremiumTheme.textPrimary(context);
    return Row(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            title,
            style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        _buildChip(context, count, color ?? AppColors.primaryAccentGreen),
      ],
    );
  }

  /// Construit l'indicateur de balayage pour les actions rapides.
  Widget _buildSwipeHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: 0.12),
            AppColors.primaryAccentGreen.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.swipe_left, color: AppColors.info, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Swipe an item left for quick quantity and delete actions.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PremiumTheme.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la vue lorsque la liste est vide.
  Widget _buildEmptyView(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        FloatingHeader(
          title: 'Grocery List',
          subtitle: 'Your shopping list',
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Purchase History',
              onPressed: () => context.push('/grocery/history'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PpEmptyState(
          icon: Icons.shopping_cart_outlined,
          title: l10n.emptyGroceryTitle,
          subtitle: l10n.emptyGrocerySubtitle,
          actionLabel: l10n.emptyGroceryCta,
          onAction: () => context.push('/plan'),
        ),
      ],
    );
  }

  /// Construit la vue d'erreur avec bouton de réessai.
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

  /// Retourne l'icône correspondant à une catégorie.
  IconData _categoryIcon(String category) {
    return switch (category) {
      'Produce' => Icons.eco,
      'Dairy & Eggs' => Icons.egg_alt,
      'Protein' => Icons.set_meal,
      'Pantry Staples' => Icons.inventory_2_outlined,
      _ => Icons.inventory_2_outlined,
    };
  }

  /// Vérifie si un article doit être épinglé en priorité.
  bool _isPinnedItem(GroceryItem item) {
    return item.isHighPriority || (item.notes?.trim().startsWith('!') ?? false);
  }
}
