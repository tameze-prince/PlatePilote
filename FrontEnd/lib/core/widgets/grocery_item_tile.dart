import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../shared/models/demo_data.dart';
import 'app_card.dart';

class GroceryItemTile extends StatefulWidget {
  const GroceryItemTile({required this.item, super.key});

  final GroceryItem item;

  @override
  State<GroceryItemTile> createState() => _GroceryItemTileState();
}

class _GroceryItemTileState extends State<GroceryItemTile> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.item.checked;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Checkbox(
            value: _checked,
            onChanged: (v) => setState(() => _checked = v ?? false),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: context.text.bodyLarge?.copyWith(
                    decoration: _checked ? TextDecoration.lineThrough : null,
                    color: _checked ? context.text.bodyMedium?.color : null,
                  ),
                ),
                Text(
                  'Qty: ${widget.item.quantity}',
                  style: context.text.bodyMedium?.copyWith(
                    decoration: _checked ? TextDecoration.lineThrough : null,
                    color: _checked ? context.text.bodyMedium?.color : null,
                  ),
                ),
              ],
            ),
          ),
          Text(
            widget.item.price,
            style: context.text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
