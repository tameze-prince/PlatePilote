import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../shared/models/demo_data.dart';

class PantryExpirationScreen extends ConsumerStatefulWidget {
  const PantryExpirationScreen({super.key});

  @override
  ConsumerState<PantryExpirationScreen> createState() =>
      _PantryExpirationScreenState();
}

class _PantryExpirationScreenState
    extends ConsumerState<PantryExpirationScreen> {
  List<PantryItem> _expiringItems = [];
  List<PantryItem> _expiredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpirationData();
  }

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
                        color: ColorTokens.error,
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
                        color: ColorTokens.accentAmber,
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
                                  color: ColorTokens.primaryGreen.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.input,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.eco,
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
                                      'Waste Prevention',
                                      style: context.text.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Track and reduce food waste',
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
                              Expanded(
                                child: _buildStatItem(
                                  label: 'Items tracked',
                                  value: '${_expiringItems.length + _expiredItems.length}',
                                  color: ColorTokens.accentBlue,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  label: 'Saved this month',
                                  value: '\$24.50',
                                  color: ColorTokens.primaryGreen,
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
            color: color.withOpacity(0.1),
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
                    ? ColorTokens.error.withOpacity(0.1)
                    : ColorTokens.accentAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(
                item.icon,
                color: isExpired ? ColorTokens.error : ColorTokens.accentAmber,
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
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                  Text(
                    item.expires,
                    style: context.text.bodySmall?.copyWith(
                      color: isExpired
                          ? ColorTokens.error
                          : ColorTokens.accentAmber,
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
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
