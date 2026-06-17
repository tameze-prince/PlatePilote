import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';

/// État vide affiché lorsqu'aucune donnée n'est disponible.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  /// Icône affichée au centre.
  final IconData icon;

  /// Titre principal.
  final String title;

  /// Message descriptif.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.primaryLight),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: context.text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: context.text.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
