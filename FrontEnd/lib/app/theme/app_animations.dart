import 'package:flutter/material.dart';

/// Définition des animations et transitions de l'application.
abstract final class AppAnimations {
  // Durations
  /// Rapide (150ms).
  static const fast = Duration(milliseconds: 150);
  /// Normal (300ms).
  static const normal = Duration(milliseconds: 300);
  /// Lent (500ms).
  static const slow = Duration(milliseconds: 500);
  /// Très lent (800ms).
  static const verySlow = Duration(milliseconds: 800);

  // Curves
  /// Courbe standard.
  static const standard = Curves.easeInOut;
  /// Courbe de décélération.
  static const decelerate = Curves.easeOut;
  /// Courbe d'accélération.
  static const accelerate = Curves.easeIn;
  /// Courbe élastique.
  static const elastic = Curves.elasticOut;
  /// Courbe de rebond.
  static const bounce = Curves.bounceOut;

  // Semantic animations
  /// Durée de transition de page.
  static const pageTransition = normal;
  /// Durée de transition modale.
  static const modalTransition = normal;
  /// Durée d'appui sur bouton.
  static const buttonPress = fast;
  /// Durée d'apparition d'élément de liste.
  static const listItem = normal;
  /// Durée d'animation shimmer.
  static const shimmer = slow;
  /// Durée d'animation hero.
  static const hero = normal;
  /// Durée d'affichage snackbar.
  static const snackbar = normal;
  /// Durée d'affichage tooltip.
  static const tooltip = fast;
  /// Durée d'animation de progression.
  static const progress = slow;

  /// Crée une [Animation] standardisée.
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

  /// Builder de transition de page.
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

  /// Builder de transition modale.
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
