import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../core/extensions/theme_extensions.dart';

class PantryChip extends StatelessWidget {
  const PantryChip({required this.label, this.selected = false, super.key});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: context.text.labelSmall?.copyWith(
        color: selected ? Colors.white : context.text.bodyMedium?.color,
      ),
      backgroundColor: selected ? ColorTokens.primary : context.colors.surface,
      side: BorderSide(
        color: selected
            ? ColorTokens.primary
            : (context.isDark ? ColorTokens.darkBorder : ColorTokens.border),
      ),
      shape: const StadiumBorder(),
    );
  }
}
