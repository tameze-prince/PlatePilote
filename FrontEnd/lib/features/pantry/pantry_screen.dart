import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/widgets/expiry_badge.dart';
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
    'All Items',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Grains',
    'Spices',
    'Frozen',
    'Pantry Staples',
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
      result = result
          .where((i) => i.name.toLowerCase().contains(query))
          .toList();
    }
    if (_selectedFilter != 'All Items') {
      result = result
          .where(
            (i) => i.category?.toLowerCase() == _selectedFilter.toLowerCase(),
          )
          .toList();
    }
    return result;
  }

  void _editItem(int index, PantryItem item) {
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
                  .read(pantryProvider.notifier)
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

  void _deleteItem(int index, PantryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "${item.name}" from pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(pantryProvider.notifier).deleteItem(index);
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
    final state = ref.watch(pantryProvider);
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filteredItems(state.items);
    final expiring = state.items.where((i) => i.isExpiringSoon).toList()
      ..sort(
        (a, b) => (a.daysToExpiry ?? 999).compareTo(b.daysToExpiry ?? 999),
      );
    final isEmpty = !state.isLoading && state.items.isEmpty;

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      extendBody: true,
      body: PremiumBackground(
        safeArea: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(pantryProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  0,
                ),
                sliver: SliverList.list(
                  children: [
                    FloatingHeader(
                      title: 'Pantry',
                      subtitle: 'Your kitchen inventory',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassTextField(
                      hintText: 'Search ingredients...',
                      prefixIcon: Icons.search,
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
              if (state.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverList.builder(
                    itemCount: 6,
                    itemBuilder: (_, _) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: ShimmerGlassSkeleton(
                        width: double.infinity,
                        height: 72,
                      ),
                    ),
                  ),
                )
              else if (state.error != null)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(child: _buildErrorCard(context)),
                )
              else if (isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(child: _buildEmptyState()),
                )
              else ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterHeaderDelegate(
                    child: _buildFilterBar(context),
                    height: 76,
                  ),
                ),
                if (expiring.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    sliver: SliverList.list(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.priority_high,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Use Soon',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...expiring.take(5).map((item) {
                          final index = state.items.indexOf(item);
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: _PantryItemCard(
                              item: item,
                              onIncrement: () =>
                                  _changeQuantity(index, item, 1),
                              onDecrement: () =>
                                  _changeQuantity(index, item, -1),
                              onEdit: () => _editItem(index, item),
                              onDelete: () => _deleteItem(index, item),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                if (filtered.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverToBoxAdapter(
                      child: _buildFilteredEmptyState(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      80,
                    ),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, itemIndex) {
                        final item = filtered[itemIndex];
                        final index = state.items.indexOf(item);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _PantryItemCard(
                            item: item,
                            onIncrement: () => _changeQuantity(index, item, 1),
                            onDecrement: () => _changeQuantity(index, item, -1),
                            onEdit: () => _editItem(index, item),
                            onDelete: () => _deleteItem(index, item),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _changeQuantity(int index, PantryItem item, double delta) {
    final current = item.quantity ?? 0;
    final next = (current + delta).clamp(0, double.infinity).toDouble();
    ref
        .read(pantryProvider.notifier)
        .updateItemQuantity(index, next, item.unit ?? 'unit');
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      color: PremiumTheme.background(context),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((label) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _FilterChip(
                label: label,
                selected: _selectedFilter == label,
                onTap: () => setState(() => _selectedFilter = label),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return PremiumCard(
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            color: PremiumTheme.textTertiary(context),
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No items in $_selectedFilter',
            style: AppTypography.titleSmall.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try another category or add a new pantry item.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: PremiumTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryAccentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.kitchen_outlined,
              size: 36,
              color: AppColors.primaryAccentGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Your pantry is empty',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: PremiumTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add ingredients to get started',
            style: AppTypography.bodyMedium.copyWith(
              color: PremiumTheme.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ActionCard(
            icon: Icons.edit_note_rounded,
            title: 'Add Manually',
            subtitle: 'Enter ingredient details by hand',
            onTap: () => context.push('/pantry/add'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionCard(
            icon: Icons.explore_outlined,
            title: 'Browse Ingredients',
            subtitle: 'Search our ingredient database',
            onTap: () => context.push('/pantry/add'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionCard(
            icon: Icons.qr_code_scanner,
            title: 'Scan Barcode',
            subtitle: 'Coming soon - scan product barcodes to auto-fill',
            badge: 'Soon',
          ),
        ],
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
                  child: Text(
                    'Failed to load pantry',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: () => ref.read(pantryProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        elevated: true,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryAccentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primaryAccentGreen, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: PremiumTheme.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  badge!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
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
    required this.label,
    required this.selected,
    required this.onTap,
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
          color: selected
              ? AppColors.primaryAccentGreen
              : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: selected
                ? AppColors.primaryAccentGreen
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : PremiumTheme.textSecondary(context),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}

class _PantryItemCard extends StatefulWidget {
  const _PantryItemCard({
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onEdit,
    this.onDelete,
  });

  final PantryItem item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends State<_PantryItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragStartX = 0;
  bool _isOpen = false;

  static const double _actionWidth = 60;
  static const double _totalActions = 2;
  static const double _revealWidth = _actionWidth * _totalActions;
  static const double _dragThreshold = 30;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-(_revealWidth / MediaQuery.of(context).size.width), 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    if (!_isOpen) {
      _isOpen = true;
      _controller.forward();
    }
  }

  void _close() {
    if (_isOpen) {
      _isOpen = false;
      _controller.reverse();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isOpen && details.localPosition.dx < _dragStartX - _dragThreshold) {
      _open();
    }
  }

  void _onTap() {
    if (_isOpen) _close();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final textTheme = Theme.of(context).textTheme;
    final isUrgent = item.isUrgent;
    final isSoon = item.isExpiringSoon;
    final qty = item.quantity != null
        ? '${item.quantity} ${item.unit ?? ''}'.trim()
        : '';
    final icon = _itemIcon(item.category);

    final cardContent = PremiumCard(
      color: isUrgent
          ? AppColors.error.withValues(alpha: 0.08)
          : isSoon
          ? AppColors.warning.withValues(alpha: 0.07)
          : null,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppColors.primaryAccentGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isUrgent ? AppColors.error : AppColors.primaryAccentGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    ExpiryBadge(
                      daysToExpiry: item.daysToExpiry,
                      isExpired: item.isExpired,
                    ),
                    if (item.isLowStock)
                      _SmallBadge(label: 'Low', color: AppColors.warning),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (qty.isNotEmpty)
                Text(
                  qty,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(icon: Icons.remove, onTap: widget.onDecrement),
                  const SizedBox(width: 4),
                  _QtyButton(icon: Icons.add, onTap: widget.onIncrement),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final hasActions = widget.onEdit != null || widget.onDelete != null;
    if (!hasActions) return cardContent;

    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _onTap,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onEdit != null)
                    _actionButton(
                      icon: Icons.edit_outlined,
                      label: 'Qty',
                      color: AppColors.info,
                      onTap: () {
                        _close();
                        widget.onEdit?.call();
                      },
                    ),
                  if (widget.onDelete != null)
                    _actionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: AppColors.error,
                      onTap: () {
                        _close();
                        widget.onDelete?.call();
                      },
                    ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_slideAnimation.value.dx * screenWidth, 0),
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: cardContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _actionWidth,
        decoration: BoxDecoration(color: color),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryAccentGreen.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.primaryAccentGreen),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
