import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/premium_components.dart';
import '../../shared/models/pantry_item.dart';
import '../../shared/widgets/shimmer_glass_skeleton.dart';
import 'pantry_provider.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All Items';
  bool _didInit = false;

  static const _categories = [
    'All Items', 'Vegetables', 'Fruits', 'Dairy', 'Meat',
    'Grains', 'Spices', 'Frozen', 'Pantry Staples',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pantryProvider.notifier).refresh();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PantryItem> _filteredItems(List<PantryItem> items) {
    final query = _searchController.text.toLowerCase();
    var result = items;
    if (query.isNotEmpty) {
      result = result.where((i) => i.name.toLowerCase().contains(query)).toList();
    }
    if (_selectedFilter != 'All Items') {
      result = result.where((i) =>
        i.category?.toLowerCase() == _selectedFilter.toLowerCase()
      ).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pantryProvider);
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filteredItems(state.items);
    final expiring = state.items.where((i) => i.isExpired || i.expirationDate != null).take(5).toList();

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        child: RefreshIndicator(
          onRefresh: () => ref.read(pantryProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              FloatingHeader(title: 'Pantry', subtitle: 'Your kitchen inventory'),
              const SizedBox(height: AppSpacing.md),
              GlassTextField(
                hintText: 'Search ingredients...',
                prefixIcon: Icons.search,
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.isLoading)
                ...List.generate(6, (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: ShimmerGlassSkeleton(width: double.infinity, height: 72),
                ))
              else if (state.error != null)
                _buildErrorCard(context)
              else ...[
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: _categories.map((label) => _FilterChip(
                    label: label, selected: _selectedFilter == label,
                    onTap: () => setState(() => _selectedFilter = label),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassButton(
                  label: 'Add to Pantry', icon: Icons.add_circle_outline,
                  onPressed: () => context.push('/pantry/add'),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (expiring.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.priority_high, color: AppColors.error, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Use Soon',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...expiring.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PantryItemCard(item: item),
                  )),
                  const SizedBox(height: AppSpacing.md),
                ],
                ...filtered.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _PantryItemCard(item: item),
                )),
                PremiumCard(
                  variant: PremiumCardVariant.glass,
                  child: Row(
                    children: [
                      Icon(Icons.recycling, color: AppColors.primaryAccentGreen),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Track expiring items to reduce waste and save money.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: PremiumTheme.textSecondary(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
                  child: Text('Failed to load pantry',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Retry', icon: Icons.refresh,
                onPressed: () => ref.read(pantryProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label, required this.selected, required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected ? AppColors.primaryAccentGreen : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: selected ? AppColors.primaryAccentGreen : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : PremiumTheme.textSecondary(context),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        )),
      ),
    );
  }
}

class _PantryItemCard extends StatelessWidget {
  const _PantryItemCard({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUrgent = item.isExpired;
    final qty = item.quantity != null ? '${item.quantity} ${item.unit ?? ''}'.trim() : '';
    final expiry = item.expirationDate != null ? 'Exp: ${item.expirationDate}' : '';
    final icon = _itemIcon(item.category);

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppColors.primaryAccentGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: isUrgent ? AppColors.error : AppColors.primaryAccentGreen),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                if (expiry.isNotEmpty)
                  Text(expiry, style: textTheme.bodySmall?.copyWith(
                    color: isUrgent ? AppColors.error : PremiumTheme.textSecondary(context))),
              ],
            ),
          ),
          if (qty.isNotEmpty) Text(qty, style: textTheme.bodySmall),
        ],
      ),
    );
  }

  IconData _itemIcon(String? category) {
    return switch (category?.toLowerCase()) {
      'vegetables' => Icons.eco,
      'fruits' => Icons.apple,
      'dairy' => Icons.egg_alt,
      'meat' => Icons.set_meal,
      'grains' => Icons.grain,
      'spices' => Icons.blender,
      'frozen' => Icons.ac_unit,
      _ => Icons.inventory_2_outlined,
    };
  }
}
