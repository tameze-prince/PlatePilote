import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../premium_components.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
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
