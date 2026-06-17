import 'package:flutter/material.dart';

import '../../premium_components.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// Semantic intent for [PpToast].
enum PpToastVariant { success, error, info, warning }

/// Duration presets for [PpToast.show].
enum PpToastDuration { short, medium, long }

extension on PpToastDuration {
  Duration get _duration {
    switch (this) {
      case PpToastDuration.short:
        return const Duration(milliseconds: 2200);
      case PpToastDuration.medium:
        return const Duration(milliseconds: 3500);
      case PpToastDuration.long:
        return const Duration(seconds: 6);
    }
  }
}

/// In-app toast/snackbar that replaces Material's default `SnackBar`.
///
/// Smooth slide-in from the bottom, semantic colors and an optional
/// inline action. Pure presentational widget — internally relies on
/// `ScaffoldMessenger` so it plays well with `PpScaffold`.
class PpToast {
  PpToast._();

  /// Shows a toast.
  ///
  /// Returns the underlying `ScaffoldFeatureController` so callers can
  /// programmatically dismiss the toast (e.g. when navigating). Most
  /// call sites can just `unawaited(PpToast.show(...))`.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    PpToastVariant variant = PpToastVariant.info,
    PpToastDuration duration = PpToastDuration.short,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    final controller = messenger.showSnackBar(
      SnackBar(
        duration: duration._duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(
          DsSpacing.md,
          0,
          DsSpacing.md,
          DsSpacing.md,
        ),
        padding: EdgeInsets.zero,
        content: _PpToastBody(
          message: message,
          variant: variant,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );

    return controller;
  }
}

class _PpToastBody extends StatelessWidget {
  const _PpToastBody({
    required this.message,
    required this.variant,
    required this.actionLabel,
    required this.onAction,
    required this.icon,
  });

  final String message;
  final PpToastVariant variant;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  IconData get _resolvedIcon {
    if (icon != null) return icon!;
    switch (variant) {
      case PpToastVariant.success:
        return Icons.check_circle_rounded;
      case PpToastVariant.error:
        return Icons.error_rounded;
      case PpToastVariant.warning:
        return Icons.warning_amber_rounded;
      case PpToastVariant.info:
        return Icons.info_rounded;
    }
  }

  Color get _accent {
    switch (variant) {
      case PpToastVariant.success:
        return DsColors.success;
      case PpToastVariant.error:
        return DsColors.error;
      case PpToastVariant.warning:
        return DsColors.warning;
      case PpToastVariant.info:
        return DsColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground =
        isDark ? DsColors.onSurfaceDark : DsColors.onSurface;

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.md,
        vertical: DsSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.elevatedSurface(context),
        borderRadius: BorderRadius.circular(DsRadius.lg),
        border: Border.all(color: PremiumTheme.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_resolvedIcon, size: 20, color: _accent),
          const SizedBox(width: DsSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: DsTypography.bodyMedium.copyWith(
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: DsSpacing.sm),
            _PpToastAction(
              label: actionLabel!,
              onPressed: onAction!,
              color: _accent,
            ),
          ],
        ],
      ),
    );
  }
}

class _PpToastAction extends StatelessWidget {
  const _PpToastAction({
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DsRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.sm,
            vertical: DsSpacing.xs,
          ),
          child: Text(
            label,
            style: DsTypography.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
