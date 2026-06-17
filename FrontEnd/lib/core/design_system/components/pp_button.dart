import 'package:flutter/material.dart';

import '../tokens/ds_motion.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';
import '../tokens/ds_colors.dart';

/// Visual variant for [PpButton].
enum PpButtonVariant { primary, secondary, ghost, glass }

/// Size ramp for [PpButton]. All sizes guarantee a minimum 48dp touch target.
enum PpButtonSize { sm, md, lg }

/// Press scale on tap-down — kept subtle so the button still feels solid.
const double _kButtonPressScale = 0.97;

/// Primary, secondary, ghost and glass button for the design system.
///
/// Variants:
///
/// * [PpButtonVariant.primary]   → solid brand-green pill, glow shadow.
/// * [PpButtonVariant.secondary] → outlined accent pill on transparent bg.
/// * [PpButtonVariant.ghost]     → text-only button, no chrome.
/// * [PpButtonVariant.glass]     → blurred glass pill (light/dark adaptive).
class PpButton extends StatefulWidget {
  const PpButton({
    required this.label,
    required this.onPressed,
    this.variant = PpButtonVariant.primary,
    this.size = PpButtonSize.md,
    this.icon,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final PpButtonVariant variant;
  final PpButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  bool get _isEnabled => onPressed != null && !loading;

  double get _minimumHeight {
    return switch (size) {
      PpButtonSize.sm => 48.0,
      PpButtonSize.md => 52.0,
      PpButtonSize.lg => 56.0,
    };
  }

  EdgeInsets get _padding {
    final horizontal = switch (size) {
      PpButtonSize.sm => DsSpacing.md,
      PpButtonSize.md => DsSpacing.lg,
      PpButtonSize.lg => DsSpacing.lg,
    };
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  TextStyle get _textStyle {
    return switch (size) {
      PpButtonSize.sm => DsTypography.labelMedium,
      PpButtonSize.md => DsTypography.labelLarge,
      PpButtonSize.lg => DsTypography.titleMedium,
    };
  }

  @override
  State<PpButton> createState() => _PpButtonState();
}

class _PpButtonState extends State<PpButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget._isEnabled) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _resolveColors(isDark);
    final button = _buildButton(context, colors);

    if (!widget.expand) return button;

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }

  Widget _buildButton(BuildContext context, _PpButtonColors colors) {
    final minHeight = widget._minimumHeight;
    final radius = BorderRadius.circular(DsRadius.full);

    final child = AnimatedScale(
      scale: _pressed ? _kButtonPressScale : 1.0,
      duration: AppMotion.micro,
      curve: AppMotion.easeOutEmphasized,
      child: Material(
        color: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: colors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.loading ? null : widget.onPressed,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: widget._padding,
              child: Row(
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.foreground,
                        ),
                      ),
                    )
                  else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: colors.foreground),
                      const SizedBox(width: DsSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: widget._textStyle.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return child;
  }

  _PpButtonColors _resolveColors(bool isDark) {
    if (widget.variant == PpButtonVariant.glass) {
      final glassFill = isDark
          ? const Color.fromRGBO(255, 255, 255, 0.10)
          : const Color.fromRGBO(255, 255, 255, 0.65);
      final border = isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.85);
      return _PpButtonColors(
        background: glassFill,
        foreground:
            isDark ? DsColors.onSurfaceDark : DsColors.onSurface,
        border: border,
        foregroundMuted:
            isDark ? DsColors.onSurfaceVariantDark : DsColors.onSurfaceVariant,
      );
    }

    if (widget.variant == PpButtonVariant.primary) {
      return _PpButtonColors(
        background: DsColors.accent,
        foreground: Colors.white,
        border: Colors.transparent,
        foregroundMuted: Colors.white.withValues(alpha: 0.45),
      );
    }

    if (widget.variant == PpButtonVariant.secondary) {
      return _PpButtonColors(
        background: Colors.transparent,
        foreground: DsColors.accent,
        border: DsColors.accent.withValues(alpha: 0.55),
        foregroundMuted: DsColors.accent.withValues(alpha: 0.45),
      );
    }

    // ghost
    return _PpButtonColors(
      background: Colors.transparent,
      foreground: isDark ? DsColors.onSurfaceDark : DsColors.onSurface,
      border: Colors.transparent,
      foregroundMuted:
          isDark ? DsColors.onSurfaceVariantDark : DsColors.onSurfaceVariant,
    );
  }
}

class _PpButtonColors {
  const _PpButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.foregroundMuted,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color foregroundMuted;
}
