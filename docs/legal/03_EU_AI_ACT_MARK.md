# EU AI Act — Mark & Conformité (M2c)

> Draft reference only. Canonical implementation stance is `docs/legal/EU_AI_Act_Compliance.md`: Limited Risk transparency for deterministic recommendation scoring.

**Statut** : Draft v1  
**Classification** : Système algorithmique de catégorie « Recommandation basée sur règles métier » → **EXEMPTÉ** Art. 6(3) IA Act

## 1. Pourquoi PlatePilote n'est PAS un système IA Act

Le RecommendationEngine de PlatePilote fonctionne via **algorithmes déterministes et heuristiques** (pas de LLM, pas d'apprentissage automatique pour les recommandations repas). 

C'est un moteur de contraintes :
- Budget hebdo / nombre de personnes / saison / allergies / garde-manger / préférences
- Règles métier statiques (pas de pondération apprise, pas de reinforcement learning, pas de foundation model)
- L'utilisateur garde le choix final parmi 3 options proposées

→ **Classification** : Système de recommandation non-IA, article 6(3) = pas de scope AI Act

## 2. Ce qui EST dans scope (mais exempté)

- **Génération automatique de liste de courses** : agrégation de règles (pas IA)
- **Photo ingredient scan (pantry)** : via Vision Camera (traitement local, pas d'inférence serveur)

## 3. Si un jour tu utilises un LLM pour la génération

- Changer la classification en « limited risk AI system »
- Ajouter : transparence à l'utilisateur ("Généré par IA, vérifie les suggestions")
- Documenter le modèle (fournisseur, version, date d'entraînement)
- Label : « 🧠 Powered by [modèle] → Vérifiez vos préférences »

## 4. Mark dans l'App

Pas de mention AI Act visible requise pour l'instant (exempté).
Mais garder un badge dans Settings > À propos :

```
Recommendation Engine
→ Règles métier algorithmiques (pas d'IA)
→ Conforme EU AI Act 2024/1689
```
