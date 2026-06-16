# Analyse statique Flutter — PlatePilote

**Date :** 2026-06-15
**Flutter :** 3.41.9 (stable) — Dart 3.11.5
**Commande :** `cd ~/Documents/PlatePilote/FrontEnd && flutter analyze`

## Résumé

**Nombre total de problèmes : 2**
- Erreurs (error) : **0**
- Warnings : **2**
- Infos : **0**

Le projet **passe l'analyse sans erreur bloquante**. Les deux problèmes restants sont des imports inutilisés, non bloquants pour le build release.

## Détail des diagnostics

| # | Sévérité | Code | Message | Fichier | Ligne | Colonne |
|---|----------|------|---------|---------|-------|---------|
| 1 | `warning` | `unused_import` | Unused import: `'dart:convert'` | `lib/features/onboarding/onboarding_state.dart` | 1 | 8 |
| 2 | `warning` | `unused_import` | Unused import: `'../../core/widgets/floating_components.dart'` | `lib/features/settings/language_settings_screen.dart` | 8 | 8 |

## Sortie brute (terminal)

```
Analyzing FrontEnd...

warning - Unused import: 'dart:convert' - lib\features\onboarding\onboarding_state.dart:1:8 - unused_import
warning - Unused import: '../../core/widgets/floating_components.dart' - lib\features\settings\language_settings_screen.dart:8:8 - unused_import

2 issues found. (ran in 135.1s)
```

## Notes

- Aucun diagnostic critique (`error`) — le build release APK peut procéder.
- Les 2 warnings sont triviaux : retrait de deux directives d'import. Action Prince : rapide mais **non bloquant**, ignoré pour ce livrable.
- Conformément à la mission, **aucune correction n'a été appliquée** ; seuls les diagnostics sont rapportés.
