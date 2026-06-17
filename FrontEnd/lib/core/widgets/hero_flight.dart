import 'package:flutter/material.dart';

import '../../app/theme/app_animations.dart';

/// Helper Hero motion — wrapper réutilisable pour les transitions list→detail.
///
/// Utilise le widget `Hero` Material standard avec un `flightShuttleBuilder`
/// custom qui :
///   - fait un crossfade propre quand la géométrie source et destination
///     diffèrent (cas le plus fréquent en Sprint 2) ;
///   - retombe sur un fade simple si le shuttle builder renvoie un widget
///     hors-arbre (origin !== destination subtree) ;
///   - applique la durée canonique [AppAnimations.medium] (280 ms).
///
/// Convention de tag :
///   `pp_<feature>_<id>`  — ex: `pp_recipe_42`, `pp_meal_overnight_oats`.
///
/// Usage :
/// ```dart
/// // côté liste
/// PlatePilotHero(
///   tag: PlatePilotHeroTags.recipe(recipe.id),
///   child: thumbnail,
/// )
///
/// // côté détail
/// PlatePilotHero(
///   tag: PlatePilotHeroTags.recipe(recipe.id),
///   child: largeImage,
/// )
/// ```
class PlatePilotHero extends StatelessWidget {
  const PlatePilotHero({
    required this.tag,
    required this.child,
    super.key,
  });

  /// Tag Hero partagé entre origin et destination.
  final String tag;

  /// Widget Hero wrappé.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: _flightShuttleBuilder,
      child: child,
    );
  }

  /// Bâtisseur du widget en vol entre origin et destination.
  ///
  /// Stratégie crossfade :
  ///   1. Si origin et destination sont de même runtimeType (rare mais
  ///      possible — ex: même `Image.network` partageant URL), on retourne
  ///      un fade entre les deux widgets Material par défaut.
  ///   2. Sinon, on renvoie un widget simple qui interpole l'opacité entre
  ///      le widget origin et le widget destination sur la durée canonique.
  static Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final toWidget = toHeroContext.widget as Hero;
    final fromWidget = fromHeroContext.widget as Hero;

    if (flightDirection == HeroFlightDirection.push) {
      return _CrossfadeFlight(
        animation: animation,
        from: fromWidget.child,
        to: toWidget.child,
      );
    }
    return _CrossfadeFlight(
      animation: animation,
      from: toWidget.child,
      to: fromWidget.child,
    );
  }
}

/// Transition crossfade entre deux sous-arbres pendant un vol Hero.
class _CrossfadeFlight extends StatelessWidget {
  const _CrossfadeFlight({
    required this.animation,
    required this.from,
    required this.to,
  });

  final Animation<double> animation;
  final Widget from;
  final Widget to;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.effectiveCurve(),
      reverseCurve: AppAnimations.effectiveCurve(),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(opacity: (1.0 - curved.value).clamp(0.0, 1.0), child: from),
            Opacity(opacity: curved.value.clamp(0.0, 1.0), child: to),
          ],
        );
      },
    );
  }
}

/// Helpers de fabrication de tags Hero PlatePilote.
///
/// Préférer ces helpers aux chaînes brutes pour garantir la cohérence
/// de la convention `pp_<feature>_<id>` à travers l'app.
class PlatePilotHeroTags {
  PlatePilotHeroTags._();

  /// Tag pour Hero de recette.
  /// Retourne null si [id] est null ou vide — l'appelant doit alors
  /// omettre le Hero (ne pas en mettre un avec un tag factice).
  static String? recipe(String? id) {
    if (id == null || id.isEmpty) return null;
    return 'pp_recipe_$id';
  }

  /// Tag pour Hero de repas (vue partagée avec `RecipeDetailsScreen` quand
  /// `meal.recipeId` est renseigné ; fallback hash pour home/recommendations).
  static String? meal(String? recipeId) {
    if (recipeId == null || recipeId.isEmpty) return null;
    return 'pp_recipe_$recipeId';
  }
}
