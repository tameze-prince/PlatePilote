import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_typography.dart';

/// Carte moderne avec fonctionnalités optionnelles (en-tête, badge, titre).
class ModernCard extends StatelessWidget {
  const ModernCard({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.badge,
    this.color,
    this.borderColor,
    this.elevation,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final String? subtitle;
  final Widget? badge;
  final Color? color;
  final Color? borderColor;
  final double? elevation;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: Material(
        color: color ?? (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(AppRadius.card),
        elevation: elevation ?? AppElevation.card,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? AppColors.darkOutline.withValues(alpha: 0.5)
                        : AppColors.outline.withValues(alpha: 0.5)),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || leading != null || trailing != null || badge != null)
                  _buildHeader(context),
                if (title != null || leading != null || trailing != null || badge != null)
                  const SizedBox(height: AppSpacing.sm),
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: AppSpacing.xs),
          badge!,
        ],
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.xs),
          trailing!,
        ],
      ],
    );
  }
}

/// Carte statistique pour afficher une métrique avec icône.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = color ??
        (isDark ? AppColors.primaryLight : AppColors.primary);
    
    return ModernCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Carte de progression avec barre de progression visuelle.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.label,
    required this.value,
    required this.progress,
    this.maxValue,
    this.color,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final double progress;
  final double? maxValue;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressColor = color ??
        (isDark ? AppColors.primaryLight : AppColors.primary);
    
    return ModernCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: progressColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: AppTypography.titleSmall.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark
                  ? AppColors.darkSurfaceContainerHigh
                  : AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
          if (maxValue != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'of ${maxValue!}',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Carte d'information avec icône, titre et description.
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    this.color,
    this.onTap,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = color ??
        (isDark ? AppColors.primaryLight : AppColors.primary);
    
    return ModernCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Carte d'alerte pour les avertissements et notifications.
class AlertCard extends StatelessWidget {
  const AlertCard({
    required this.type,
    required this.title,
    required this.message,
    this.actions,
    super.key,
  });

  final AlertType type;
  final String title;
  final String message;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final config = _getConfig(type, isDark);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                config.icon,
                color: config.iconColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: config.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: config.textColor.withValues(alpha: 0.8),
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }

  _AlertConfig _getConfig(AlertType type, bool isDark) {
    switch (type) {
      case AlertType.success:
        return _AlertConfig(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          textColor: isDark ? AppColors.success : AppColors.success,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          borderColor: AppColors.success.withValues(alpha: 0.3),
        );
      case AlertType.warning:
        return _AlertConfig(
          icon: Icons.warning_amber_outlined,
          iconColor: AppColors.warning,
          textColor: isDark ? AppColors.warning : AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
        );
      case AlertType.error:
        return _AlertConfig(
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          textColor: isDark ? AppColors.error : AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          borderColor: AppColors.error.withValues(alpha: 0.3),
        );
      case AlertType.info:
        return _AlertConfig(
          icon: Icons.info_outline,
          iconColor: AppColors.info,
          textColor: isDark ? AppColors.info : AppColors.info,
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          borderColor: AppColors.info.withValues(alpha: 0.3),
        );
    }
  }
}

/// Type d'alerte pour [AlertCard].
enum AlertType { success, warning, error, info }

class _AlertConfig {
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  _AlertConfig({
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

/// Composant d'état vide avec icône, titre, message et action optionnelle.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.image,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null)
            image!
          else
            Icon(
              icon,
              size: 64,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Squelette de chargement pour les placeholders de contenu.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    this.height,
    this.width,
    this.borderRadius,
    super.key,
  });

  final double? height;
  final double? width;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
      ),
    );
  }
}

/// Effet de chargement shimmer (simplifié, utiliser un package dédié en production).
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    required this.child,
    this.baseColor,
    this.highlightColor,
    super.key,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return child; // Simplified - would use shimmer package in production
  }
}

/// Composant badge avec libellé, couleur et icône optionnelle.
class Badge extends StatelessWidget {
  const Badge({
    required this.label,
    this.color,
    this.textColor,
    this.icon,
    super.key,
  });

  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final badgeColor = color ??
        (isDark ? AppColors.primaryLight : AppColors.primary);
    final labelColor = textColor ??
        (isDark ? AppColors.darkBackground : Colors.white);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: labelColor,
              size: 12,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Séparateur avec libellé optionnel au centre.
class LabeledDivider extends StatelessWidget {
  const LabeledDivider({
    this.label,
    this.color,
    this.thickness,
    super.key,
  });

  final String? label;
  final Color? color;
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = color ??
        (isDark ? AppColors.darkOutline : AppColors.outline);
    
    if (label == null) {
      return Divider(
        color: dividerColor,
        thickness: thickness ?? 1,
        height: 1,
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: thickness ?? 1,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label!,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: thickness ?? 1,
            height: 1,
          ),
        ),
      ],
    );
  }
}
