# Conformité EU AI Act — PlatePilot

**Effective date : 2026-07-01**
**Dernière mise à jour : 2026-07-01**

## 1. Périmètre du système IA

PlatePilot intègre un **RecommendationEngine algorithmique** (812 lignes de code, in-memory, multi-critères scoring). Ce moteur attribue à chaque recette candidate un score composé à partir de critères déterministes : adéquation aux préférences alimentaires déclarées par l'utilisateur, présence d'allergènes exclus, fraîcheur des ingrédients du garde-manger, diversité sur la semaine, équilibre nutritionnel approximatif, complétude du plan de repas.

## 2. Classification de risque (EU AI Act — Règlement (UE) 2024/1689)

**Classe de risque retenue : LIMITED RISK** (risque limité, art. 50 — obligations de transparence).

### 2.1 Pourquoi LIMITED RISK et non HIGH-RISK

- Le système **ne prend aucune décision produisant des effets juridiques ou significatifs** sur une personne (art. 6 et annexe III non déclenchés).
- Le système **n'est pas un système d'IA à usage général** (GGP) au sens de l'art. 51.
- Le système **ne traite pas de données biométriques**, ne profile pas à des fins d'évaluation de crédit, d'emploi, d'éducation ou d'accès à des services essentiels.
- Le système **n'appartient à aucune catégorie d'usage interdit** listée à l'art. 5 (ni subliminal, ni manipulateur, ni exploitation de vulnérabilités, ni scoring social, ni reconnaissance faciale non consensuelle, etc.) — **confirmé**.

### 2.2 Statut LLM / modèles génératifs

**Aucun LLM externe n'est actuellement utilisé** par PlatePilot. Le moteur de recommandation est un algorithme de scoring mathématique pur, déterministe et explicable, sans appel réseau à un modèle génératif.

## 3. Mesures de transparence (art. 50)

- **Explainable scoring** : chaque recommandation expose ses scores composants dans le payload de réponse (`recommendation_explanation.criteria_scores`), permettant à l'utilisateur de comprendre **pourquoi** une recette a été suggérée.
- **Logging** : chaque interaction avec le moteur est journalisée dans `analytics_events` (catégorie `recommendation`) à des fins de débogage et d'amélioration.
- **Documentation interne** : ce document + ADR-0014 (choix de no-LLM par défaut) + audit trail Sprint 7.2.
- **Information utilisateur** : les présentes CGU/Privacy Policy exposent clairement la présence d'un système algorithmique et son rôle de recommandation — et non de décision automatique aux effets contraignants.

## 4. High-risk AI (art. 6 + annexe III) — Non applicable

PlatePilot **n'entre pas** dans le champ des systèmes à haut risque :
- Pas d'usage critique en santé / sécurité / emploi / justice / migration.
- Pas de prise de décision automatisée produisant des effets significatifs sur les droits d'une personne.
- Recommandations purement culinaires, révisables à tout moment par l'utilisateur.

## 5. Position future-proofing — LLM Sprint 9+

Si un modèle LLM externe (NVIDIA NIM, ou équivalent) est introduit dans PlatePilot en **Sprint 9** ou au-delà :

1. **Re-classification** préalable du risque selon l'usage effectif (chatbot nutritionnel, génération libre de recettes, parsing d'instcription vocale, etc.).
2. **Conformité élargie** : obligations de transparence renforcées (marquage du contenu généré par IA, art. 50), documentation technique (art. 11), gestion des risques (art. 9), qualité des données d'entrée (art. 10), supervision humaine (art. 14), logging (art. 12).
3. **Mise à jour du présent document** avant déploiement utilisateur.
4. **Évaluation de l'impact sur les droits fondamentaux** si le LLM traite des données sensibles (données de santé, allergies alimentaires interprétées médicalement).

## 6. Mise à jour continue

PlatePilot suivra l'évolution des guidelines EU AI Office et des actes d'exécution délégués. Toute évolution de l'architecture IA déclenchera une revue de cette classification de risque **avant** mise en production.

---

*Ce document est fourni à titre informatif et ne constitue pas un conseil juridique. Il reflète l'état du produit au 2026-07-01 et la lecture par PlatePilot des textes en vigueur à cette date. Pour une analyse certifiable, consultez un conseil spécialisé en AI Act.*
