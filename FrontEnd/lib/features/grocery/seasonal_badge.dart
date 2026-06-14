import 'package:flutter/material.dart';

/// Saisons applicables pour la saisonnalité des produits (hémisphère nord par défaut).
enum Season { winter, spring, summer, autumn }

extension SeasonX on Season {
  String get fr {
    switch (this) {
      case Season.winter:
        return 'Hiver';
      case Season.spring:
        return 'Printemps';
      case Season.summer:
        return 'Été';
      case Season.autumn:
        return 'Automne';
    }
  }

  String get emoji {
    switch (this) {
      case Season.winter:
        return '❄️';
      case Season.spring:
        return '🌸';
      case Season.summer:
        return '☀️';
      case Season.autumn:
        return '🍂';
    }
  }
}

/// Helpers saisonniers pour les badges « de saison ».
class SeasonalCatalog {
  SeasonalCatalog._();

  /// Map ingrédient (lowercase) → saisons où il est de saison en France/Europe.
  static const Map<String, List<Season>> _byIngredient = {
    // hiver
    'orange': [Season.winter],
    'mandarine': [Season.winter],
    'clémentine': [Season.winter],
    'pomme': [Season.winter, Season.autumn],
    'poire': [Season.autumn, Season.winter],
    'poireau': [Season.winter],
    'chou': [Season.winter, Season.autumn],
    'chou frisé': [Season.winter],
    'endive': [Season.winter],
    'salsifis': [Season.winter],
    'potiron': [Season.autumn, Season.winter],
    'potimarron': [Season.autumn, Season.winter],
    // printemps
    'asperge': [Season.spring],
    'radis': [Season.spring],
    'épinard': [Season.spring],
    'petits pois': [Season.spring],
    'fraise': [Season.spring],
    'cerise': [Season.spring, Season.summer],
    'artichaut': [Season.spring],
    // été
    'tomate': [Season.summer],
    'courgette': [Season.summer],
    'aubergine': [Season.summer],
    'poivron': [Season.summer],
    'concombre': [Season.summer],
    'melon': [Season.summer],
    'pastèque': [Season.summer],
    'pêche': [Season.summer],
    'abricot': [Season.summer],
    'framboise': [Season.summer],
    'myrtille': [Season.summer],
    // automne
    'champignon': [Season.autumn],
    'girolle': [Season.autumn],
    'céleri': [Season.autumn],
    'betterave': [Season.autumn],
    'noix': [Season.autumn],
    'châtaigne': [Season.autumn],
    'raisin': [Season.autumn],
    'figue': [Season.autumn],
  };

  /// Renvoie la saison courante (hémisphère nord).
  static Season current(DateTime now) {
    final m = now.month;
    if (m >= 12 || m <= 2) return Season.winter;
    if (m >= 3 && m <= 5) return Season.spring;
    if (m >= 6 && m <= 8) return Season.summer;
    return Season.autumn;
  }

  /// Renvoie les saisons où [ingredient] est en saison.
  static List<Season> seasonsFor(String ingredient) {
    final key = ingredient.toLowerCase().trim();
    return _byIngredient[key] ?? const [];
  }

  /// Indique si [ingredient] est de saison [season].
  static bool isInSeason(String ingredient, Season season) {
    return seasonsFor(ingredient).contains(season);
  }
}

/// Badge compact affiché à côté d'un ingrédient de saison.
///
/// Variante optionnelle [forceSeason] pour tester hors-saison en démo.
class SeasonalBadge extends StatelessWidget {
  const SeasonalBadge({
    super.key,
    required this.ingredient,
    this.forceSeason,
    this.dense = true,
  });

  final String ingredient;
  final Season? forceSeason;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final now = forceSeason ?? SeasonalCatalog.current(DateTime.now());
    if (!SeasonalCatalog.isInSeason(ingredient, now)) {
      return const SizedBox.shrink();
    }
    final tint = const Color(0xFF1B7F3A);
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tint.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(now.emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            'De saison',
            style: TextStyle(
              fontSize: dense ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: tint,
            ),
          ),
        ],
      ),
    );
  }
}
