import 'package:flutter/material.dart';

/// Tokens motion unifiés PlatePilote.
/// Source: Iris Motion Principles v1.
///
/// Ce fichier est la **source unique de vérité** pour les durées et courbes
/// d'animation de l'application. Les widgets doivent consommer ces tokens
/// via les helpers [effective] / [effectiveCurve] pour respecter la
/// préférence système `prefers-reduced-motion`.
class AppAnimations {
  AppAnimations._();

  // -- Durations canoniques (millisecondes) --
  /// Tap feedback (ripple, button press).
  static const Duration micro = Duration(milliseconds: 100);

  /// Sheet slide, chip toggle, switch state.
  static const Duration small = Duration(milliseconds: 180);

  /// Page transitions (Hero, default GoRouter push).
  static const Duration medium = Duration(milliseconds: 280);

  /// Onboarding reveal, celebration, success states.
  static const Duration large = Duration(milliseconds: 460);

  // -- Easings canoniques --
  /// Sortie emphatique, courbe signature PlatePilote.
  static const Curve easeOutEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Entrée emphatique.
  static const Curve easeInEmphasized = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Standard (équivalent Material).
  static const Curve standardEasing = easeOutEmphasized;

  /// Spring-like bounce pour célébration.
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1.0);

  // -- Stagger --
  /// Délai entre items d'une liste réanimée.
  static const Duration staggerStep = Duration(milliseconds: 24);

  /// Maximum items staggered avant de tronquer.
  static const int maxStaggerItems = 3;

  // -- Reduced motion fallback --
  /// Opacity-only fallback quand prefersReducedMotion est actif.
  static const Duration reducedMotion = Duration(milliseconds: 120);

  /// Retourne une durée réduite si l'utilisateur préfère moins de motion.
  ///
  /// À utiliser côté widget:
  /// ```dart
  /// AnimatedContainer(
  ///   duration: AppAnimations.effective(AppAnimations.medium, reduced: reduce),
  /// )
  /// ```
  static Duration effective(Duration duration, {bool reduced = false}) =>
      reduced ? reducedMotion : duration;

  /// Retourne la courbe standard, ou linéaire en reduced motion.
  ///
  /// À utiliser côté widget:
  /// ```dart
  /// CurvedAnimation(
  ///   parent: controller,
  ///   curve: AppAnimations.effectiveCurve(reduced: reduce),
  /// )
  /// ```
  static Curve effectiveCurve({bool reduced = false}) =>
      reduced ? Curves.linear : easeOutEmphasized;

  // ============================================================
  // Rétro-compatibilité — API historique (Iris v0)
  // Les noms ci-dessous sont conservés pour ne casser aucun screen
  // existant. Préférez les noms canoniques ci-dessus pour le nouveau code.
  // ============================================================

  /// Rétro-compat : ancien token rapide (150ms).
  /// @deprecated Utiliser [micro] (100ms) ou [small] (180ms).
  static const Duration fast = micro;

  /// Rétro-compat : ancien token normal (300ms).
  /// @deprecated Utiliser [medium] (280ms).
  static const Duration normal = medium;

  /// Rétro-compat : ancien token lent (500ms).
  /// @deprecated Utiliser [large] (460ms) pour les célébrations ou [slow] pour les cas étendus.
  static const Duration slow = Duration(milliseconds: 500);

  /// Rétro-compat : ancien token très lent (800ms).
  /// @deprecated Réservé aux cas très spécifiques (ex. splash étendu).
  static const Duration verySlow = Duration(milliseconds: 800);

  // -- Courbes rétro-compat --
  /// Rétro-compat : courbe standard historique.
  /// @deprecated Utiliser [standardEasing] ou [easeOutEmphasized].
  static const Curve standard = Curves.easeInOut;

  /// Rétro-compat : décélération.
  /// @deprecated Utiliser [easeOutEmphasized].
  static const Curve decelerate = Curves.easeOut;

  /// Rétro-compat : accélération.
  /// @deprecated Utiliser [easeInEmphasized].
  static const Curve accelerate = Curves.easeIn;

  /// Rétro-compat : élastique.
  /// @deprecated Utiliser [spring] pour les bounces.
  static const Curve elastic = Curves.elasticOut;

  /// Rétro-compat : rebond.
  /// @deprecated Utiliser [spring].
  static const Curve bounce = Curves.bounceOut;

  // -- Tokens sémantiques rétro-compat (noms historiques) --
  /// Transition de page — alias historique de [medium].
  static const Duration pageTransition = medium;

  /// Transition modale — alias historique de [medium].
  static const Duration modalTransition = medium;

  /// Appui bouton — alias historique de [micro].
  static const Duration buttonPress = micro;

  /// Swap de carte — alias historique de [medium].
  static const Duration cardSwap = medium;

  /// Apparition d'item de liste — alias historique de [medium].
  static const Duration listItem = medium;

  /// Animation shimmer — conservé (charge -> état).
  static const Duration shimmer = slow;

  /// Animation hero — alias historique de [medium].
  static const Duration hero = medium;

  /// Affichage snackbar — alias historique de [medium].
  static const Duration snackbar = medium;

  /// Affichage tooltip — alias historique de [micro].
  static const Duration tooltip = micro;

  /// Animation de progression — conservé.
  static const Duration progress = slow;

  /// Célébration de succès — alias historique de [large].
  static const Duration successCelebration = large;

  /// Crée une [Animation] standardisée.
  ///
  /// Conservé pour rétro-compat ; préférez construire un
  /// `CurvedAnimation` côté widget en utilisant [effectiveCurve].
  static Animation<double> createAnimation({
    required AnimationController controller,
    Curve curve = standard,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  /// Builder de transition de page — conservé pour rétro-compat.
  static PageRouteBuilder<T> pageRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
        );

        return SlideTransition(
          position: tween,
          child: child,
        );
      },
      transitionDuration: pageTransition,
    );
  }

  /// Builder de transition modale — conservé pour rétro-compat.
  static Route<T> modalRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: builder(context),
          ),
        );
      },
    );
  }
}
