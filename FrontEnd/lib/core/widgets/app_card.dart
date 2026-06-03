import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../premium_components.dart';

/// Carte réutilisable avec padding, tap et couleur personnalisable.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.color,
    super.key,
  });

  /// Contenu de la carte.
  final Widget child;

  /// Padding interne.
  final EdgeInsetsGeometry padding;

  /// Callback de tap optionnel.
  final VoidCallback? onTap;

  /// Couleur de fond optionnelle.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isAccent = color == ColorTokens.primaryGreen ||
        color == context.colors.primary ||
        color == ColorTokens.primaryGreen.withValues(alpha: 0.16) ||
        color == ColorTokens.primaryGreen.withValues(alpha: 0.08);

    return PremiumCard(
      padding: padding,
      onTap: onTap,
      color: color,
      variant:
          isAccent ? PremiumCardVariant.accent : PremiumCardVariant.elevated,
      borderRadius: AppRadius.card,
      child: child,
    );
  }
}
