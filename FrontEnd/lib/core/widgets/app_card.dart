import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';

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
    final borderColor = context.isDark
        ? ColorTokens.darkBorder
        : ColorTokens.border;
    return Material(
      color: color ?? context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: borderColor),
            boxShadow: context.isDark
                ? null
                : [
                    BoxShadow(
                      color: ColorTokens.textPrimary.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}
