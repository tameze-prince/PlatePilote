import 'package:flutter/material.dart';

import '../../premium_components.dart';
import '../tokens/ds_motion.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';

/// Adaptive scaffold that wraps [Material]'s [Scaffold] with the design
/// system's premium defaults.
///
/// * The background uses the page gradient from [PremiumTheme] /
///   [PremiumBackground] unless explicitly overridden by [background].
/// * When [useGlass] is true, the body is wrapped in a [GlassContainer] so the
///   content area picks up the glass treatment.
/// * SafeArea is applied on top (and only top when
///   [extendBodyBehindAppBar] is true) so the app bar can paint edge-to-edge.
class PpScaffold extends StatelessWidget {
  const PpScaffold({
    required this.body,
    this.floatingAction,
    this.floatingActionButtonLocation,
    this.appBar,
    this.useGlass = false,
    this.background,
    this.extendBodyBehindAppBar = false,
    this.bottomNavigationBar,
    super.key,
  });

  /// Body of the scaffold.
  final Widget body;

  /// Optional FAB content.
  final Widget? floatingAction;

  /// FAB anchor location forwarded to the underlying [Scaffold].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional app bar.
  final PreferredSizeWidget? appBar;

  /// If true, the body is wrapped in a glass container for premium feel.
  final bool useGlass;

  /// Optional explicit background (defaults to the premium page gradient).
  final Color? background;

  /// Forwarded to the underlying [Scaffold] to allow edge-to-edge app bars.
  final bool extendBodyBehindAppBar;

  /// Optional bottom navigation slot.
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = background ?? PremiumTheme.background(context);

    Widget content = body;

    if (useGlass) {
      content = GlassContainer(
        padding: const EdgeInsets.all(DsSpacing.md),
        borderRadius: DsRadius.xl,
        blurSigma: 24,
        elevated: true,
        child: content,
      );
    }

    return PremiumBackground(
      padding: EdgeInsets.zero,
      child: Scaffold(
        backgroundColor: resolvedBackground,
        appBar: appBar,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        floatingActionButton: floatingAction,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        body: SafeArea(
          top: extendBodyBehindAppBar,
          bottom: false,
          child: AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: AppMotion.easeOutEmphasized,
            switchOutCurve: AppMotion.easeInEmphasized,
            child: KeyedSubtree(
              key: ValueKey<bool>(useGlass),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
