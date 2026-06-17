import 'package:flutter/material.dart';

import '../../premium_components.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// Friendly zero-data / error screen block.
///
/// Centered icon (or custom illustration) on top, headline + supporting
/// text below, optional CTA at the bottom. All spacing and typography is
/// driven by the design tokens.
class PpEmptyState extends StatelessWidget {
  const PpEmptyState({
    required this.title,
    this.subtitle,
    this.icon,
    this.illustration,
    this.onAction,
    this.actionLabel,
    super.key,
  });

  /// Headline displayed beneath the icon/illustration.
  final String title;

  /// Optional supporting copy.
  final String? subtitle;

  /// Icon shown when no [illustration] is provided.
  final IconData? icon;

  /// Custom widget shown above [title] — typically a Kevin illustration
  /// delivered in Sprint 3.
  final Widget? illustration;

  /// Optional CTA tap handler. When provided, [actionLabel] must also be
  /// set.
  final VoidCallback? onAction;

  /// Optional CTA label.
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    assert(
      onAction == null || (actionLabel != null && actionLabel!.isNotEmpty),
      'PpEmptyState.actionLabel is required when onAction is provided.',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark
        ? DsColors.onSurfaceVariantDark
        : DsColors.onSurfaceVariant;
    final body = isDark ? DsColors.onSurfaceDark : DsColors.onSurface;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.xl,
          vertical: DsSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (illustration != null)
              illustration!
            else if (icon != null)
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: PremiumTheme.glass(context),
                  borderRadius: BorderRadius.circular(DsRadius.xl),
                  border: Border.all(color: PremiumTheme.border(context)),
                ),
                child: Icon(icon, size: 44, color: accent),
              ),
            SizedBox(
              height: illustration == null && icon == null
                  ? 0
                  : DsSpacing.lg,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DsTypography.titleLarge.copyWith(
                color: body,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DsSpacing.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: DsTypography.bodyMedium.copyWith(color: accent),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: DsSpacing.lg),
              _PpEmptyStateCta(
                label: actionLabel!,
                onPressed: () => onAction?.call(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PpEmptyStateCta extends StatelessWidget {
  const _PpEmptyStateCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DsRadius.full),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.lg,
            vertical: DsSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: DsColors.accent,
            borderRadius: BorderRadius.circular(DsRadius.full),
          ),
          child: Text(
            label,
            style: DsTypography.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
