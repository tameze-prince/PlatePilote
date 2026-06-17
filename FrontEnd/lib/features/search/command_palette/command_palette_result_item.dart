import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// A single row in the command palette list.
///
/// Renders an icon avatar, a label, an optional subtitle and a category
/// pill. The whole row is tappable; callers receive the tap through
/// [onTap] and the focus / hover state through [highlighted].
class CommandPaletteResultItem extends StatelessWidget {
  const CommandPaletteResultItem({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.category,
    required this.onTap,
    this.subtitle,
    this.highlighted = false,
    super.key,
  });

  /// Primary label shown on the row.
  final String label;

  /// Optional supporting text shown below the label.
  final String? subtitle;

  /// Icon shown in the leading avatar.
  final IconData icon;

  /// Foreground color of the leading icon avatar.
  final Color iconColor;

  /// Pre-translated category label (Pages / Recipes / Pantry).
  final String category;

  /// Tap handler — usually navigates to the result route.
  final VoidCallback onTap;

  /// Whether the row is the keyboard-highlighted entry.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subtitleColor =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;

    final background = highlighted
        ? (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04))
        : Colors.transparent;

    return Semantics(
      button: true,
      selected: highlighted,
      label: '$category — $label',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  _Avatar(icon: icon, color: iconColor, isDark: isDark),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: labelColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _CategoryPill(label: category, isDark: isDark),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: subtitleColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tint =
        isDark ? AppColors.primaryLight : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: tint.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Convenience: maps a category enum value to a localized label.
extension CommandPaletteResultItemCategoryX on String {
  /// Returns the localized label for one of the three palette categories.
  static String categoryLabelFor(
    BuildContext context,
    CommandPaletteCategory category,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case CommandPaletteCategory.pages:
        return l10n.cmdPalettePages;
      case CommandPaletteCategory.recipes:
        return l10n.cmdPaletteRecipes;
      case CommandPaletteCategory.pantry:
        return l10n.cmdPalettePantry;
    }
  }
}

/// Categories returned by the [commandPaletteProvider]. Kept in a single
/// file so the import path stays short for consumers.
enum CommandPaletteCategory { pages, recipes, pantry }
