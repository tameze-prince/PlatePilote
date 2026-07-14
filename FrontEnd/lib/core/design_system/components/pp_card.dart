import 'package:flutter/material.dart';

import '../../premium_components.dart';
import '../tokens/ds_motion.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';

/// Card variant for [PpCard].
enum PpCardVariant { flat, elevated, glass, outline }

/// Surface-level press scale used across card variants.
const double _kCardPressScale = 0.985;

/// Standardized card for the design system.
///
/// Variants:
///
/// * [PpCardVariant.flat]     → plain surface card, no shadow.
/// * [PpCardVariant.elevated] → elevated surface + soft shadow.
/// * [PpCardVariant.glass]    → blurred glass card via [GlassContainer].
/// * [PpCardVariant.outline]  → transparent surface, accent-color border.
///
/// When [onTap] is provided, the card responds to presses with a subtle
/// scale animation and applies a 48dp+ tap ripple.
class PpCard extends StatefulWidget {
  const PpCard({
    required this.child,
    this.variant = PpCardVariant.flat,
    this.padding,
    this.onTap,
    this.margin,
    super.key,
  });

  final Widget child;
  final PpCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  State<PpCard> createState() => _PpCardState();
}

class _PpCardState extends State<PpCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    Widget card;
    if (widget.variant == PpCardVariant.glass) {
      card = GlassContainer(
        margin: widget.margin,
        borderRadius: DsRadius.xl,
        elevated: true,
        shadows: widget.onTap == null
            ? null
            : PremiumTheme.floatingShadow(context),
        child: _buildBody(context),
      );
    } else {
      card = _buildSurfaceCard(context);
    }

    return AnimatedScale(
      scale: _pressed ? _kCardPressScale : 1.0,
      duration: AppMotion.micro,
      curve: AppMotion.easeOutEmphasized,
      child: card,
    );
  }

  Widget _buildBody(BuildContext context) {
    final body = Padding(
      padding: widget.padding ?? const EdgeInsets.all(DsSpacing.md),
      child: widget.child,
    );

    if (widget.onTap == null) return body;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: body,
      ),
    );
  }

  Widget _buildSurfaceCard(BuildContext context) {
    final surface = widget.variant == PpCardVariant.elevated
        ? PremiumTheme.elevatedSurface(context)
        : PremiumTheme.surface(context);
    final borderColor = widget.variant == PpCardVariant.outline
        ? PremiumTheme.border(context)
        : Colors.transparent;
    final shadow = widget.variant == PpCardVariant.elevated
        ? PremiumTheme.softShadow(context)
        : <BoxShadow>[];

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(DsRadius.xl),
        border: Border.all(color: borderColor),
        boxShadow: shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DsRadius.xl),
        child: _buildBody(context),
      ),
    );
  }
}
