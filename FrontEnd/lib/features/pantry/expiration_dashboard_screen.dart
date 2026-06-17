import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../shared/models/demo_data.dart';

/// Écran du tableau de bord des expirations.
/// Affiche les articles périmés et ceux qui expirent bientôt.
class PantryExpirationScreen extends ConsumerStatefulWidget {
  const PantryExpirationScreen({super.key});

  @override
  ConsumerState<PantryExpirationScreen> createState() =>
      _PantryExpirationScreenState();
}

class _PantryExpirationScreenState
    extends ConsumerState<PantryExpirationScreen> {
  /// Articles sur le point d'expirer.
  List<PantryItem> _expiringItems = [];

  /// Articles déjà périmés.
  List<PantryItem> _expiredItems = [];

  /// Indique si le chargement est en cours.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpirationData();
  }

  /// Charge les données d'expiration (simulées pour l'instant).
  Future<void> _loadExpirationData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _expiringItems = [
        const PantryItem(
          name: 'Fresh Spinach',
          quantity: '200g',
          expires: 'Expires in 2 days',
          category: 'Produce',
          icon: Icons.eco,
          urgent: true,
        ),
        const PantryItem(
          name: 'Whole Milk',
          quantity: '1L',
          expires: 'Expires in 4 days',
          category: 'Dairy',
          icon: Icons.icecream,
          urgent: true,
        ),
        const PantryItem(
          name: 'Greek Yogurt',
          quantity: '500g',
          expires: 'Expires in 5 days',
          category: 'Dairy',
          icon: Icons.icecream,
          urgent: false,
        ),
      ];
      _expiredItems = [
        const PantryItem(
          name: 'Heavy Cream',
          quantity: '250ml',
          expires: 'Expired 2 days ago',
          category: 'Dairy',
          icon: Icons.icecream,
          urgent: true,
        ),
      ];
      _isLoading = false;
    });
  }

  /// Supprime un article de la liste d'expiration.
  Future<void> _removeItem(PantryItem item) async {
    setState(() {
      _expiringItems.remove(item);
      _expiredItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiration Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expiringItems.isEmpty && _expiredItems.isEmpty
              ? EmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'All clear!',
                  message: 'No items are expiring soon',
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (_expiredItems.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.error_outline,
                        title: 'Expired',
                        count: _expiredItems.length,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ..._expiredItems.map(
                        (item) => _buildExpirationCard(
                          item,
                          isExpired: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (_expiringItems.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.warning_amber_outlined,
                        title: 'Expiring Soon',
                        count: _expiringItems.length,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ..._expiringItems.map(
                        (item) => _buildExpirationCard(
                          item,
                          isExpired: false,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.input,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.eco,
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
                                      'Waste Prevention',
                                      style: context.text.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Track and reduce food waste',
                                      style: context.text.bodySmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
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
                              Expanded(
                                child: _buildStatItem(
                                  label: 'Items tracked',
                                  value: '${_expiringItems.length + _expiredItems.length}',
                                  color: AppColors.tertiary,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  label: 'Saved this month',
                                  value: '\$24.50',
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  /// Construit l'en-tête d'une section (expiré / expire bientôt).
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            '$count',
            style: context.text.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit une carte d'article avec son état d'expiration.
  Widget _buildExpirationCard(PantryItem item, {required bool isExpired}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isExpired
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(
                item.icon,
                color: isExpired ? AppColors.error : AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${item.quantity} • ${item.category}',
                    style: context.text.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    item.expires,
                    style: context.text.bodySmall?.copyWith(
                      color: isExpired
                          ? AppColors.error
                          : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'use':
                    break;
                  case 'remove':
                    _removeItem(item);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'use',
                  child: Text('Mark as used'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construit un élément de statistique.
  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
