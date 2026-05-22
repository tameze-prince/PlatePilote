import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../shared/models/grocery_list.dart';
import 'app_card.dart';

class GroceryItemTile extends StatelessWidget {
  const GroceryItemTile({
    required this.item,
    this.onToggle,
    super.key,
  });

  final GroceryItem item;
  final void Function()? onToggle;

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity != null
        ? '${item.quantity} ${item.unit ?? ''}'.trim()
        : '';
    final price = item.estimatedPrice != null
        ? '\$${item.estimatedPrice!.toStringAsFixed(2)}'
        : '';

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.checked,
            onChanged: (_) => onToggle?.call(),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: context.text.bodyLarge?.copyWith(
                    decoration: item.checked ? TextDecoration.lineThrough : null,
                    color: item.checked ? context.text.bodyMedium?.color : null,
                  ),
                ),
                if (qty.isNotEmpty)
                  Text(
                    'Qty: $qty',
                    style: context.text.bodyMedium?.copyWith(
                      decoration: item.checked ? TextDecoration.lineThrough : null,
                      color: item.checked ? context.text.bodyMedium?.color : null,
                    ),
                  ),
              ],
            ),
          ),
          if (price.isNotEmpty)
            Text(
              price,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
