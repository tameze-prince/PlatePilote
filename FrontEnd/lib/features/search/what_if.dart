import 'package:flutter/material.dart';

/// Substitut possible dans le mode What-If.
@immutable
class WhatIfSubstitute {
  const WhatIfSubstitute({
    required this.name,
    required this.costPerServing,
    required this.savingsPercent,
    required this.notes,
  });

  /// Nom de l'ingrédient substitut (ex: "Lentilles corail").
  final String name;

  /// Coût par portion après substitution.
  final double costPerServing;

  /// % d'économies vs original.
  final int savingsPercent;

  /// Note contextuelle ("continue de saison", "sans gluten"...).
  final String notes;
}

/// Résultat What-If pour une recette donnée.
@immutable
class WhatIfResult {
  const WhatIfResult({
    required this.originalCost,
    required this.substitutes,
  });

  final double originalCost;
  final List<WhatIfSubstitute> substitutes;

  /// Coût minimum atteignable en utilisant le meilleur substitut.
  double get bestCost => substitutes.isEmpty
      ? originalCost
      : substitutes
          .map((s) => s.costPerServing)
          .reduce((a, b) => a < b ? a : b);

  /// % d'économies maximal (par rapport au coût original).
  int get maxSavingsPercent {
    if (substitutes.isEmpty || originalCost <= 0) return 0;
    final delta = originalCost - bestCost;
    return (delta / originalCost * 100).round().clamp(0, 99);
  }

  /// Impact budget mensuel (pour 4 portions/semaine sur 4 semaines).
  double get monthlySavings =>
      (originalCost - bestCost).clamp(0, double.infinity) * 16;
}

/// Catalogue de suggestions What-If déterministes (offline).
///
/// Mappings simples, basé sur les catégories d'ingrédients les plus
/// courantes. Pas d'appel réseau — c'est du pur heuristique local
/// pour montrer la mécanique. Sera remplacé par les vraies suggestions
/// Apple intelligence (grocery_provider) quand le backend le supportera.
class WhatIfCatalog {
  WhatIfCatalog._();

  /// Table de substitution par mot-clé principal de recette.
  static const Map<String, List<WhatIfSubstitute>> _table = {
    'beef': [
      WhatIfSubstitute(
        name: 'Lentilles corail',
        costPerServing: 1.4,
        savingsPercent: 62,
        notes: 'Riche en protéines, faible coût',
      ),
      WhatIfSubstitute(
        name: 'Poulet fermier',
        costPerServing: 2.6,
        savingsPercent: 25,
        notes: 'Alternative maigre',
      ),
      WhatIfSubstitute(
        name: 'Tempeh',
        costPerServing: 2.2,
        savingsPercent: 36,
        notes: 'Végétal, fermenté',
      ),
    ],
    'chicken': [
      WhatIfSubstitute(
        name: 'Pois chiches',
        costPerServing: 1.1,
        savingsPercent: 65,
        notes: 'Riche en protéines végétales',
      ),
      WhatIfSubstitute(
        name: 'Œufs',
        costPerServing: 1.5,
        savingsPercent: 50,
        notes: 'Protéine économique',
      ),
    ],
    'salmon': [
      WhatIfSubstitute(
        name: 'Sardines',
        costPerServing: 1.3,
        savingsPercent: 70,
        notes: 'Oméga-3 similaires, plus durable',
      ),
      WhatIfSubstitute(
        name: 'Truite',
        costPerServing: 2.1,
        savingsPercent: 50,
        notes: 'Poisson d\u0027eau douce abordable',
      ),
    ],
    'rice': [
      WhatIfSubstitute(
        name: 'Boulgour',
        costPerServing: 0.5,
        savingsPercent: 55,
        notes: 'Plus de fibres, cuisson rapide',
      ),
      WhatIfSubstitute(
        name: 'Quinoa',
        costPerServing: 1.2,
        savingsPercent: 20,
        notes: 'Riche en protéines complètes',
      ),
    ],
    'pasta': [
      WhatIfSubstitute(
        name: 'Lentilles vertes',
        costPerServing: 0.7,
        savingsPercent: 70,
        notes: 'Sans gluten, plus rassasiant',
      ),
      WhatIfSubstitute(
        name: 'Coquillettes pois chiches',
        costPerServing: 1.4,
        savingsPercent: 40,
        notes: 'Végétales, riches en protéines',
      ),
    ],
    'cheese': [
      WhatIfSubstitute(
        name: 'Fromage fondu léger',
        costPerServing: 0.9,
        savingsPercent: 50,
        notes: 'Moins calorique',
      ),
    ],
    'milk': [
      WhatIfSubstitute(
        name: 'Lait avoine',
        costPerServing: 0.35,
        savingsPercent: 30,
        notes: 'Végétal, durable',
      ),
      WhatIfSubstitute(
        name: 'Lait concentré',
        costPerServing: 0.4,
        savingsPercent: 20,
        notes: 'Pour pâtisseries',
      ),
    ],
  };

  /// Retourne des substituts basés sur le nom de la recette.
  static List<WhatIfSubstitute> suggest(String recipeName) {
    final lower = recipeName.toLowerCase();
    for (final entry in _table.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    // Si rien ne matche, proposer un générique
    return const [
      WhatIfSubstitute(
        name: 'Version batch',
        costPerServing: 2.8,
        savingsPercent: 30,
        notes: 'Cuire en grande quantité / congeler',
      ),
    ];
  }
}

/// Widget compact affichant le résultat What-If en bas d'une carte résultat.
class WhatIfBadge extends StatelessWidget {
  const WhatIfBadge({super.key, required this.result});

  final WhatIfResult result;

  @override
  Widget build(BuildContext context) {
    final savings = result.maxSavingsPercent;
    final monthly = result.monthlySavings;
    final accent = const Color(0xFF1B7F3A);

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows, size: 14, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              savings > 0
                  ? 'What-If: -$savings% (-${monthly.toStringAsFixed(1)}€/mois)'
                  : 'What-If: explorez les substituts',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
