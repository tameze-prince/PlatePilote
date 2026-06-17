import 'package:flutter/material.dart';

import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// Semantic variants for [PpChip]. Each variant maps to a single intent so
/// callers never have to pick raw colors.
enum PpChipVariant { filter, info, action, removable }

/// Compact, semantic chip for the design system.
///
/// Variants:
///   * [PpChipVariant.filter]    — selectable filter pill with on/off state.
///   * [PpChipVariant.info]      — read-only badge conveying a piece of info.
///   * [PpChipVariant.action]    — tappable action pill (e.g. "Add", "Skip").
///   * [PpChipVariant.removable] — info chip with a trailing close button.
///
/// Honors the 48dp minimum touch target on tappable variants.
class PpChip extends StatelessWidget {
  const PpChip({
    required this.label,
    this.variant = PpChipVariant.info,
    this.selected = false,
    this.onPressed,
    this.onRemoved,
    this.icon,
    super.key,
  });

  /// Text displayed inside the chip.
  final String label;

  /// Visual / behavioral variant.
  final PpChipVariant variant;

  /// Selected state for [PpChipVariant.filter].
  final bool selected;

  /// Tap handler. Required for [PpChipVariant.filter] and
  /// [PpChipVariant.action]; ignored for the other variants.
  final VoidCallback? onPressed;

  /// Removal handler for [PpChipVariant.removable]. When `null` the chip
  /// falls back to a read-only info chip.
  final VoidCallback? onRemoved;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _resolvePalette(variant, selected, isDark);

    final isInteractive =
        variant == PpChipVariant.filter || variant == PpChipVariant.action;
    final isRemovable = variant == PpChipVariant.removable && onRemoved != null;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: palette.foreground),
          const SizedBox(width: DsSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: DsTypography.labelMedium.copyWith(
              color: palette.foreground,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isRemovable) ...[
          const SizedBox(width: DsSpacing.xxs),
          Icon(Icons.close_rounded, size: 16, color: palette.foreground),
        ],
      ],
    );

    final container = Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.md,
        vertical: DsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(DsRadius.full),
        border: Border.all(
          color: palette.border,
          width: selected && variant == PpChipVariant.filter ? 1.5 : 1,
        ),
      ),
      child: row,
    );

    if (isInteractive) {
      return Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(DsRadius.full),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DsRadius.full),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DsSpacing.xs),
              child: container,
            ),
          ),
        ),
      );
    }

    if (isRemovable) {
      return Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(DsRadius.full),
        child: InkWell(
          onTap: onRemoved,
          borderRadius: BorderRadius.circular(DsRadius.full),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DsSpacing.xs),
              child: container,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: label,
      container: true,
      child: container,
    );
  }

  _PpChipPalette _resolvePalette(
    PpChipVariant variant,
    bool isSelected,
    bool isDark,
  ) {
    switch (variant) {
      case PpChipVariant.filter:
        if (isSelected) {
          return _PpChipPalette(
            background: DsColors.accent.withValues(alpha: 0.14),
            foreground:
                isDark ? DsColors.onSurfaceDark : DsColors.onSurface,
            border: DsColors.accent,
          );
        }
        return _PpChipPalette(
          background: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          foreground: isDark
              ? DsColors.onSurfaceVariantDark
              : DsColors.onSurfaceVariant,
          border: isDark
              ? DsColors.outlineVariantDark
              : DsColors.outlineVariant,
        );

      case PpChipVariant.info:
        return _PpChipPalette(
          background: DsColors.info.withValues(alpha: 0.12),
          foreground:
              isDark ? DsColors.onSurfaceDark : DsColors.onSurface,
          border: DsColors.info.withValues(alpha: 0.40),
        );

      case PpChipVariant.action:
        return _PpChipPalette(
          background: DsColors.accent,
          foreground: Colors.white,
          border: Colors.transparent,
        );

      case PpChipVariant.removable:
        return _PpChipPalette(
          background: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          foreground: isDark
              ? DsColors.onSurfaceVariantDark
              : DsColors.onSurfaceVariant,
          border: isDark
              ? DsColors.outlineVariantDark
              : DsColors.outlineVariant,
        );
    }
  }
}

class _PpChipPalette {
  const _PpChipPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
