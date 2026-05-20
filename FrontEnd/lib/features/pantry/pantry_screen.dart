import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pantry_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'pantry_provider.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All Items';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  List<PantryItem> _filteredItems(List<PantryItem> items) {
    if (_selectedFilter == 'All Items') return items;
    return items
        .where(
          (item) =>
              item.category.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final pantryState = ref.watch(pantryProvider);
    final filteredItems = _filteredItems(pantryState.items);

    return PlateScaffold(
      title: 'PlatePilot',
      child: _isLoading
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                LoadingSkeletonCard(),
                SizedBox(height: AppSpacing.md),
                LoadingSkeletonCard(),
                SizedBox(height: AppSpacing.md),
                LoadingSkeletonCard(),
                SizedBox(height: AppSpacing.md),
                LoadingSkeletonCard(),
              ],
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ingredients...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.text.bodyMedium?.color,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final label in [
                        'All Items',
                        'Produce',
                        'Dairy & Eggs',
                        'Proteins',
                        'Staples',
                      ])
                        GestureDetector(
                          onTap: () => setState(() => _selectedFilter = label),
                          child: PantryChip(
                            label: label,
                            selected: _selectedFilter == label,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Scan or Add to Pantry',
                    icon: Icons.add_circle_outline,
                    onPressed: () => context.push('/pantry/add'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Icon(Icons.priority_high, color: ColorTokens.error),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Use Soon', style: context.text.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isTablet)
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: filteredItems
                          .map(
                            (item) => SizedBox(
                              width: screenWidth >= 900 ? 280 : 220,
                              child: _PantryItemCard(item: item),
                            ),
                          )
                          .toList(),
                    )
                  else
                    ...filteredItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _PantryItemCard(item: item),
                      ),
                    ),
                  AppCard(
                    color: ColorTokens.primaryGreen.withValues(
                      alpha: context.isDark ? 0.16 : 0.08,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.recycling,
                          color: ColorTokens.primaryGreen,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Use spinach in tonight\'s frittata to prevent waste and save about \$4.',
                            style: context.text.bodyLarge,
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

class _PantryItemCard extends StatelessWidget {
  const _PantryItemCard({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.urgent
                  ? ColorTokens.error.withValues(alpha: 0.12)
                  : ColorTokens.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: item.urgent ? ColorTokens.error : ColorTokens.primaryGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.expires,
                  style: context.text.bodyMedium?.copyWith(
                    color: item.urgent ? ColorTokens.error : null,
                  ),
                ),
              ],
            ),
          ),
          Text(item.quantity, style: context.text.labelSmall),
        ],
      ),
    );
  }
}
