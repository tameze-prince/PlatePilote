# PlatePilot Agent Context

PlatePilot est une app web/mobile de planification repas: profil, préférences, recommandations recettes, génération de meal plans, pantry, grocery list, budget, notifications et premium.

## Stack
- `BackEnd/`: Spring Boot 3.2.5, Java 21, Maven, PostgreSQL, Redis, Flyway.
- `FrontEnd/`: Flutter, Riverpod, GoRouter, Dio.
- API locale: `http://localhost:8081/api/v1`; frontend Chrome: port `3000`.

## Architecture
- Backend monolithe modulaire DDD: `presentation/`, `application/`, `domain/`.
- Frontend: `apiClientProvider -> repositoryProvider -> provider -> screen`.
- Session frontend: `appSessionProvider` pilote les redirects GoRouter.

## Points critiques
- Ne pas soft-delete puis réinsérer les préférences uniques; utiliser `deleteAll()`.
- `AuthNotifier.checkSession()` doit signer aussi `appSessionProvider` si refresh échoue.
- Éviter les appels lourds dans `/dashboard/home`.
- Recommandations/meal plans: surveiller les N+1 sur prix, ingrédients, pantry.

## Optimisations appliquées
- `HomeScreen` ne déclenche plus un deuxième appel `/dashboard/home`.
- `DashboardService` ne lance plus le moteur de recommandations complet; il renvoie 3 recettes publiques rapides.
- `BudgetOptimizer.estimateMultipleRecipeCosts()` utilise un batch de prix.
- `_EditableRow` du profil tronque label/value pour éviter les `RenderFlex overflow`.
- Le plan hebdo charge maintenant le détail complet du plan, expose temps/coût/image dans les entries, affiche une synthèse valeur, et le bouton Grocery génère la liste avant navigation.
- `GroceryService.generateFromMealPlan()` utilise un batch de prix pour éviter les lookups ingrédient par ingrédient.
- Audit projet complet sauvegardé dans `PROJECT_AUDIT.md`.

## Commandes
- Backend: `cd BackEnd && mvn test`
- Frontend analyse ciblée: `cd FrontEnd && dart analyze lib/chemin/fichier.dart`
- Frontend tests: `cd FrontEnd && flutter test`
