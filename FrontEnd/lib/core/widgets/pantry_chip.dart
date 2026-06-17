import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/extensions/theme_extensions.dart';

/// Chip de sélection pour les catégories du garde-manger.
class PantryChip extends StatelessWidget {
  const PantryChip({required this.label, this.selected = false, super.key});

  /// Texte du chip.
  final String label;

  /// État sélectionné (couleur pleine si vrai).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: context.text.labelSmall?.copyWith(
        color: selected ? Colors.white : context.text.bodyMedium?.color,
      ),
      backgroundColor: selected ? AppColors.primary : context.colors.surface,
      side: BorderSide(
        color: selected
            ? AppColors.primary
            : (context.isDark ? AppColors.darkOutline : AppColors.outline),
      ),
      shape: const StadiumBorder(),
    );
  }
}
