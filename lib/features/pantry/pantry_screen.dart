import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pantry_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlateScaffold(
      title: 'PlatePilot',
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search ingredients...',
              prefixIcon: Icon(
                Icons.search,
                color: context.text.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              PantryChip(label: 'All Items', selected: true),
              PantryChip(label: 'Produce'),
              PantryChip(label: 'Dairy & Eggs'),
              PantryChip(label: 'Proteins'),
              PantryChip(label: 'Staples'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Scan or Add to Pantry',
            icon: Icons.add_circle_outline,
            onPressed: () {},
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
          ...pantryItems.map(
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
                const Icon(Icons.recycling, color: ColorTokens.primaryGreen),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Use spinach in tonight’s frittata to prevent waste and save about \$4.',
                    style: context.text.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
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
