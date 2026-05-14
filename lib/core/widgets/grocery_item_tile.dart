import 'package:flutter/material.dart';

import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../shared/models/demo_data.dart';
import 'app_card.dart';

class GroceryItemTile extends StatelessWidget {
  const GroceryItemTile({required this.item, super.key});

  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Checkbox(value: item.checked, onChanged: (_) {}),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: context.text.bodyLarge),
                Text('Qty: ${item.quantity}', style: context.text.bodyMedium),
              ],
            ),
          ),
          Text(
            item.price,
            style: context.text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
