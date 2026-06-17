import 'package:flutter/animation.dart';

/// Unified motion tokens used across the design system.
///
/// Durations map to the Material 3 / Apple-style emphasis ramp
/// (`micro` < `small` < `medium` < `large`). Easings are explicit
/// `Cubic` definitions rather than the generic `Curves.easeInOut` so the
/// design intent is preserved across platforms.
///
/// Existing screens that still use `AppAnimations` from `app_animations.dart`
/// remain untouched; new design-system components should consume `AppMotion`.
class AppMotion {
  AppMotion._();

  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------

  /// 100ms — tap feedback, ripple, micro state changes.
  static const Duration micro = Duration(milliseconds: 100);

  /// 180ms — bottom-sheet slide, dropdown, small element enter/exit.
  static const Duration small = Duration(milliseconds: 180);

  /// 280ms — screen push/pop, hero, primary container transitions.
  static const Duration medium = Duration(milliseconds: 280);

  /// 460ms — celebration, success burst, onboarding reveal.
  static const Duration large = Duration(milliseconds: 460);

  // ---------------------------------------------------------------------------
  // Easings (Material 3 emphasized)
  // ---------------------------------------------------------------------------

  /// Material 3 emphasized decelerate — for elements entering or settling.
  static const Curve easeOutEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Material 3 emphasized accelerate — for elements leaving.
  static const Curve easeInEmphasized = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Standard curve for cross-direction transitions (in & out balanced).
  static const Curve standardEasing = Cubic(0.2, 0.0, 0.0, 1.0);

  // ---------------------------------------------------------------------------
  // Stagger
  // ---------------------------------------------------------------------------

  /// Delay between staggered children in a list/grid reveal.
  static const Duration staggerStep = Duration(milliseconds: 24);

  /// Maximum number of staggered items — additional items cap the delay to
  /// prevent the animation from feeling sluggish on long lists.
  static const int maxStaggerItems = 3;

  /// Returns the stagger delay for a given index, clamped at [maxStaggerItems].
  static Duration staggerDelay(int index) {
    final i = index.clamp(0, maxStaggerItems);
    return staggerStep * i;
  }

  // ---------------------------------------------------------------------------
  // Reduced-motion fallback
  // ---------------------------------------------------------------------------

  /// Reduced-motion variant: cap any non-trivial transition at this duration.
  static const Duration reducedMotion = Duration(milliseconds: 120);
}
