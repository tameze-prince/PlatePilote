import 'package:flutter/material.dart';

import '../../premium_components.dart';
import '../tokens/ds_elevation.dart';
import '../tokens/ds_motion.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';

/// Detents exposed by [PpSheet]. The fractional detents map to Material's
/// scroll-controlled bottom sheet API.
enum PpSheetDetent { small, medium, large, full }

extension on PpSheetDetent {
  double get _fraction {
    switch (this) {
      case PpSheetDetent.small:
        return 0.28;
      case PpSheetDetent.medium:
        return 0.55;
      case PpSheetDetent.large:
        return 0.82;
      case PpSheetDetent.full:
        return 0.96;
    }
  }
}

/// Modal bottom sheet styled with the PlatePilote design system.
///
/// Wraps Material's `showModalBottomSheet` and applies:
///   * Rounded top corners with the DS radius ramp.
///   * A premium page gradient background.
///   * A 48dp drag handle.
///   * `BottomSheetThemeData` so material widgets inside the sheet honor it.
///
/// ```dart
/// await PpSheet.show(
///   context,
///   detent: PpSheetDetent.medium,
///   builder: (ctx) => const _Content(),
/// );
/// ```
class PpSheet {
  PpSheet._();

  /// Shows the sheet.
  ///
  /// Returns whatever `builder` resolves to (typically a `Navigator.pop`
  /// value). Returns `null` if the sheet was dismissed by tapping the
  /// scrim or dragging down.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    PpSheetDetent detent = PpSheetDetent.medium,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
  }) {
    final theme = Theme.of(context);
    final radius = BorderRadius.vertical(
      top: Radius.circular(DsRadius.xxl),
    );

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      barrierColor: barrierColor,
      backgroundColor: Colors.transparent,
      elevation: DsElevation.bottomSheet,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * detent._fraction,
      ),
      shape: RoundedRectangleBorder(borderRadius: radius),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: AppMotion.medium,
        reverseDuration: AppMotion.small,
        lowerBound: 0,
        upperBound: 1,
      ),
      builder: (ctx) {
        return Theme(
          data: theme.copyWith(
            bottomSheetTheme: theme.bottomSheetTheme.copyWith(
              shape: RoundedRectangleBorder(borderRadius: radius),
              backgroundColor: Colors.transparent,
              showDragHandle: false,
              elevation: DsElevation.bottomSheet,
            ),
          ),
          child: Builder(builder: builder),
        );
      },
    );
  }
}

/// Internal helper widget that paints the premium backdrop, the drag
/// handle, and a safe content slot. Exposed so callers can compose their
/// own sheet bodies that need to reuse the chrome.
class PpSheetContainer extends StatelessWidget {
  const PpSheetContainer({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      safeArea: false,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: DsSpacing.lg,
              vertical: DsSpacing.lg,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: DsSpacing.md),
                decoration: BoxDecoration(
                  color: PremiumTheme.border(context).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(DsRadius.full),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
