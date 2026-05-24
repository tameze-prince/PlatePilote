# PlatePilot — Documentation Complète Produit & Architecture

## Vision Produit, Fonctionnement, Architecture et Stratégie Technique

---

# 1. Introduction

## 1.1 Qu’est-ce que PlatePilot ?

PlatePilot est une plateforme SaaS intelligente de planification alimentaire et de gestion des courses alimentée par l’IA et des moteurs de recommandation déterministes.

L’objectif principal du produit est de réduire la charge mentale liée à :

* la planification des repas, 
* les courses alimentaires,
* la gestion du budget,
* la gestion du pantry (stock alimentaire),
* le gaspillage alimentaire,
* les restrictions alimentaires,
* et les décisions quotidiennes liées à la nourriture.

PlatePilot agit comme un assistant personnel intelligent capable de recommander automatiquement des repas, générer des listes de courses et optimiser les dépenses alimentaires selon les contraintes réelles de l’utilisateur.

---

# 2. Le Problème

## 2.1 La Charge Mentale Alimentaire

Aujourd’hui, des millions de personnes passent énormément de temps à décider :

* quoi cuisiner,
* quoi acheter,
* comment respecter leur budget,
* comment éviter le gaspillage,
* comment manger plus sainement,
* comment respecter leurs allergies et contraintes alimentaires.

Cette problématique devient encore plus complexe lorsque l’utilisateur doit prendre en compte :

* la taille du foyer,
* le temps disponible,
* les préférences culinaires,
* les ingrédients déjà présents à la maison,
* le niveau de cuisine,
* les objectifs nutritionnels,
* les restrictions religieuses ou médicales.

---

## 2.2 Les Problèmes des Solutions Existantes

La majorité des applications existantes présentent plusieurs limites :

### Applications de recettes

* Ne prennent pas en compte le budget.
* Ne prennent pas en compte le pantry.
* Ne personnalisent pas réellement les recommandations.

### Applications de courses

* Ne génèrent pas intelligemment les repas.
* Ne comprennent pas les contraintes utilisateur.

### Applications nutritionnelles

* Souvent trop complexes.
* Peu orientées usage quotidien.
* Manque d’automatisation.

### Applications de meal planning

* Peu intelligentes.
* Peu flexibles.
* Expérience utilisateur souvent froide ou enterprise.

---

# 3. Notre Vision

## 3.1 Vision Produit

PlatePilot veut devenir :

> “Le copilote intelligent de l’alimentation quotidienne.”

L’application doit permettre à un utilisateur de recevoir en moins d’une minute :

* un plan de repas personnalisé,
* une liste de courses optimisée,
* des suggestions adaptées à son budget,
* des recommandations respectant toutes ses contraintes.

---

## 3.2 Notre Objectif

Nous voulons créer une application qui :

* simplifie radicalement les décisions alimentaires,
* réduit le stress lié aux repas,
* réduit le gaspillage alimentaire,
* optimise les dépenses,
* améliore l’organisation du foyer,
* et transforme la planification alimentaire en expérience simple et intelligente.

---

# 4. La Promesse de PlatePilot

## 4.1 Promesse Principale

> “En moins d’une minute, PlatePilot crée un plan de repas intelligent et une liste de courses personnalisée selon votre budget, vos goûts et les ingrédients déjà disponibles chez vous.”

---

## 4.2 Valeur Ajoutée

PlatePilot aide les utilisateurs à :

* économiser du temps,
* économiser de l’argent,
* réduire le gaspillage,
* mieux manger,
* automatiser l’organisation des repas,
* gérer les allergies et restrictions,
* simplifier les courses.

---

# 5. Comment PlatePilot Résout le Problème

## 5.1 Intelligence Personnalisée

PlatePilot ne fonctionne pas comme une simple application de recettes.

Le système utilise :

* les préférences utilisateur,
* les contraintes budgétaires,
* le pantry,
* les allergies,
* les objectifs,
* le temps disponible,
* les cuisines préférées,
* les habitudes utilisateur,
* et les données alimentaires structurées.

Toutes ces informations sont utilisées pour générer des recommandations cohérentes et réellement utiles.

---

## 5.2 Recommendation Engine

Le moteur de recommandation est le cœur du produit.

Il applique des règles déterministes afin de :

1. filtrer les recettes incompatibles,
2. estimer les coûts,
3. maximiser l’utilisation du pantry,
4. respecter le budget,
5. respecter les allergies,
6. respecter le temps disponible,
7. optimiser la variété des repas.

---

## 5.3 Pantry Intelligence

PlatePilot peut utiliser :

* des entrées manuelles,
* du scan OCR,
* du scan barcode,
* et des données alimentaires structurées.

Cela permet au système de comprendre :

* quels ingrédients sont déjà disponibles,
* quels ingrédients expirent bientôt,
* quels ingrédients doivent être utilisés rapidement.

---

## 5.4 Budget Optimization

Le moteur d’optimisation budgétaire permet de :

* rester dans un budget hebdomadaire,
* minimiser les dépenses,
* proposer des repas plus rentables,
* réduire les achats inutiles.

---

# 6. Comment Fonctionne PlatePilot

## 6.1 Workflow Global

Le fonctionnement du produit suit plusieurs étapes.

### Étape 1 — Onboarding

L’utilisateur fournit ses informations :

* taille du foyer,
* budget,
* allergies,
* cuisines préférées,
* niveau de cuisine,
* temps disponible,
* objectifs alimentaires.

---

### Étape 2 — Gestion du Pantry

L’utilisateur peut :

* ajouter des ingrédients,
* scanner des produits,
* modifier les quantités,
* suivre les dates d’expiration.

---

### Étape 3 — Génération du Meal Plan

Le moteur de recommandation :

* charge les recettes,
* applique les contraintes,
* estime les coûts,
* sélectionne les meilleures combinaisons.

---

### Étape 4 — Génération de la Grocery List

Le système compare :

* les ingrédients nécessaires,
* les ingrédients déjà disponibles.

Puis génère uniquement les produits manquants.

---

### Étape 5 — Optimisation Continue

PlatePilot peut ensuite :

* ajuster les recommandations,
* détecter le gaspillage,
* recalculer les suggestions,
* adapter les repas au budget restant.

---

# 7. Informations Nécessaires Pour des Recommandations Précises

## 7.1 Informations Personnelles

Certaines données personnelles permettent d’améliorer les recommandations.

### Informations utilisateur

* nom,
* âge,
* genre,
* taille,
* poids,
* photo de profil.

Ces données peuvent servir plus tard à :

* l’analyse nutritionnelle,
* l’estimation calorique,
* les objectifs santé.

---

## 7.2 Informations de Préférences

Le système a besoin de :

### Foyer

* nombre de personnes,
* adultes,
* enfants.

### Budget

* budget hebdomadaire,
* flexibilité budgétaire.

### Cuisine

* niveau de cuisine,
* temps maximum,
* complexité acceptable.

### Régimes alimentaires

* vegan,
* végétarien,
* halal,
* keto,
* low-carb,
* sans gluten,
* sans lactose.

### Allergies

* noix,
* poisson,
* lactose,
* gluten,
* soja,
* œufs,
* shellfish.

### Préférences culinaires

* cuisines africaines,
* asiatiques,
* européennes,
* méditerranéennes,
* américaines,
* indiennes.

### Objectifs

* perdre du poids,
* gagner du muscle,
* économiser,
* manger plus sainement,
* réduire le gaspillage.

---

# 8. Les Fonctionnalités Principales

## 8.1 Authentification

PlatePilot supporte :

* inscription,
* connexion,
* JWT,
* refresh tokens,
* OAuth2,
* vérification email,
* reset password.

---

## 8.2 Gestion du Profil

L’utilisateur peut :

* modifier son profil,
* modifier ses informations,
* gérer son avatar,
* supprimer son compte,
* se déconnecter.

---

## 8.3 Préférences Alimentaires

Toutes les préférences peuvent être :

* créées,
* modifiées,
* supprimées,
* mises à jour.

---

## 8.4 Gestion du Pantry

Le pantry permet :

* ajout manuel,
* scan,
* suivi des expirations,
* alertes,
* optimisation des ingrédients.

---

## 8.5 Meal Planning

Le système génère :

* breakfast,
* lunch,
* dinner,
* quick meals.

---

## 8.6 Grocery Generation

Le système génère automatiquement :

* les listes de courses,
* les quantités,
* les catégories,
* les coûts estimés.

---

## 8.7 Budget Management

Le système permet :

* définir un budget,
* ajuster un budget,
* remplacer un budget,
* suivre les dépenses,
* suivre l’historique.

---

## 8.8 Notifications

PlatePilot envoie :

* alertes d’expiration,
* alertes budget,
* rappels de meal planning,
* rappels de courses.

---

## 8.9 Premium

Les fonctionnalités premium incluent :

* meal plans illimités,
* recommandations avancées,
* pantry automation,
* analytics avancées,
* household sharing,
* optimisation budgétaire avancée.

---

# 9. Le Frontend Actuel

## 9.1 État du Frontend

Le frontend actuel est déjà structuré de manière moderne.

Le projet utilise :

* Flutter 3.x,
* Material 3,
* architecture modulaire,
* Riverpod,
* GoRouter,
* Dio,
* design system moderne,
* support light/dark mode.

---

## 9.2 Direction UX/UI

Le frontend suit une direction premium orientée :

* glassmorphism,
* profondeur visuelle,
* animations fluides,
* floating navigation,
* expérience émotionnelle rassurante.

Le frontend actuel ne sera pas restructuré fondamentalement pour le moment.

L’objectif actuel est :

* raffinement,
* stabilisation,
* cohérence visuelle,
* intégration backend.

---

# 10. Architecture Technique Globale

## 10.1 Architecture Générale

PlatePilot utilise une architecture :

> Modular Monolith + Domain-Driven Design (DDD)

Cette architecture permet :

* modularité,
* évolutivité,
* maintenabilité,
* rapidité de développement,
* faible coût d’infrastructure.

---

# 11. Stack Technique Backend

## 11.1 Technologies Principales

Le backend utilise :

* Java 21,
* Spring Boot 3.x,
* PostgreSQL,
* Redis,
* Flyway,
* Spring Security,
* JWT,
* OpenAPI,
* Docker,
* AWS.

---

## 11.2 Base de Données

Le système utilise PostgreSQL comme base transactionnelle principale.

La base contient notamment :

* utilisateurs,
* préférences,
* pantry,
* recettes,
* meal plans,
* grocery lists,
* budgets,
* notifications,
* analytics.

---

## 11.3 Redis

Redis est utilisé pour :

* le cache,
* les sessions,
* les rate limits,
* les meal plans générés,
* les recommandations.

---

# 12. Architecture Backend

## 12.1 Bounded Contexts

Le backend est divisé en plusieurs modules métier.

### Modules principaux

* Auth
* User Profile
* Preferences
* Budget
* Pantry
* Recipes
* Meal Planning
* Grocery
* Recommendation
* Notifications
* Subscription
* Analytics

---

## 12.2 Structure Interne

Chaque module contient :

* domain/
* application/
* infrastructure/
* api/

---

## 12.3 Domain Layer

Le domain layer contient :

* les règles métier,
* les entités,
* les value objects,
* les services métier,
* les événements métier.

---

## 12.4 Application Layer

L’application layer orchestre les cas d’usage.

Exemples :

* GenerateMealPlanUseCase,
* RegisterUserUseCase,
* GenerateGroceryListUseCase.

---

## 12.5 Infrastructure Layer

L’infrastructure layer contient :

* repositories JPA,
* intégrations Redis,
* OpenAI adapters,
* stockage S3,
* providers notifications.

---

# 13. Recommendation Engine

## 13.1 Le Cœur de PlatePilot

Le Recommendation Engine est le système décisionnel principal.

Il utilise :

* les contraintes utilisateur,
* le budget,
* le pantry,
* les recettes,
* les allergies,
* les objectifs.

---

## 13.2 Pipeline de Recommandation

Le pipeline suit plusieurs étapes.

### 1. Chargement des recettes

### 2. Filtrage des recettes incompatibles

### 3. Estimation des coûts

### 4. Scoring pantry

### 5. Ranking

### 6. Optimisation variété

### 7. Génération finale du plan

---

## 13.3 Critères de Scoring

Le moteur prend en compte :

* compatibilité budget,
* utilisation du pantry,
* temps de préparation,
* niveau de cuisine,
* préférences,
* variété.

---

# 14. Food Intelligence Database

## 14.1 Base de Connaissances Alimentaires

PlatePilot construit progressivement une base alimentaire intelligente.

Elle contient :

* ingrédients,
* alias,
* nutrition,
* allergènes,
* tags alimentaires,
* prix,
* recettes,
* barcode mappings.

---

## 14.2 Sources de Données

Le système peut utiliser :

* USDA,
* Open Food Facts,
* TheMealDB,
* Spoonacular,
* datasets internes.

---

# 15. Sécurité

## 15.1 Sécurité Backend

Le backend implémente :

* JWT,
* refresh tokens,
* RBAC,
* rate limiting,
* HTTPS,
* BCrypt,
* audit logs.

---

## 15.2 Rôles

Le système supporte :

* USER,
* PREMIUM_USER,
* ADMIN,
* SUPER_ADMIN,
* SUPPORT_AGENT,
* ANALYST,
* CONTENT_MANAGER,
* SYSTEM.

---

# 16. Dashboard Administrateur

## 16.1 Objectif

Le dashboard admin permet :

* gestion des utilisateurs,
* gestion des abonnements,
* suivi analytics,
* gestion des recettes,
* gestion des ingrédients,
* contrôle IA,
* monitoring système.

---

## 16.2 Modules Admin

* Overview
* Users
* Revenue
* Recipes
* Ingredients
* Analytics
* AI Usage
* Feature Flags
* Audit Logs
* System Health

---

# 17. Infrastructure Cloud

## 17.1 MVP Infrastructure

Le système peut fonctionner avec :

* Render,
* Neon PostgreSQL,
* Upstash Redis,
* Cloudinary,
* GitHub Actions,
* Firebase Cloud Messaging.

---

## 17.2 Infrastructure Production

L’architecture cible utilise :

* AWS App Runner,
* Amazon ECS,
* Amazon RDS,
* Amazon ElastiCache,
* Amazon S3,
* CloudWatch,
* Sentry,
* Prometheus,
* Grafana.

---

# 18. Architecture Frontend ↔ Backend

## 18.1 Communication

Le frontend communique avec le backend via :

* HTTPS,
* REST API,
* JSON.

---

## 18.2 Architecture Flutter

Le frontend suit le pattern :

Screen → Provider → Repository → ApiClient → Backend

---

## 18.3 Gestion Auth

Le frontend utilise :

* Flutter Secure Storage,
* interceptors Dio,
* refresh token automatique,
* Riverpod.

---

# 19. Localisation

PlatePilot supporte :

* anglais,
* français,
* architecture extensible multilingue.

---

# 20. Vision Long Terme

## 20.1 Objectif Final

PlatePilot veut devenir :

* une plateforme mondiale,
* un assistant alimentaire intelligent,
* un copilote nutritionnel,
* un système d’automatisation alimentaire.

---

## 20.2 Futures Évolutions

Évolutions possibles :

* household collaboration,
* nutrition avancée,
* AI coaching,
* marketplace alimentaire,
* intégration objets connectés,
* analytics santé.

---

# 21. Conclusion

PlatePilot est conçu comme une plateforme SaaS moderne, intelligente et évolutive permettant de résoudre l’un des problèmes quotidiens les plus universels :

> décider quoi manger tout en respectant son budget, ses contraintes et son temps.

Grâce à :

* une architecture backend robuste,
* un moteur de recommandation intelligent,
* une base alimentaire structurée,
* une expérience utilisateur premium,
* et une approche fortement centrée utilisateur,

PlatePilot possède aujourd’hui une fondation technique et stratégique capable d’évoluer vers une plateforme alimentaire mondiale.

L’objectif n’est pas seulement de recommander des repas.

L’objectif est de construire :

> “un système intelligent qui comprend réellement les habitudes alimentaires de l’utilisateur et simplifie durablement sa vie quotidienne.”
