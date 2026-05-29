# PlatePilot Project Audit

## Synthese

PlatePilot a une base solide: backend DDD, Flutter modulaire, auth, profile, preferences, recipes, meal plans, grocery, pantry, budget, notifications, premium et admin. La valeur la plus vendable reste le chemin court: planifier la semaine, generer les courses, utiliser le pantry, respecter le budget.

## Ce qui est deja bon

- Backend bien separe par domaines.
- API v1 large et coherente.
- Recommendation engine deja batch sur plusieurs points critiques.
- Frontend Riverpod/GoRouter propre.
- UX premium deja presente.
- Dataset alimentaire important avec recettes, ingredients, prix, alias, images.
- Migrations idempotentes via `ON CONFLICT` sur les gros seeds.

## Optimisations appliquees

- Home allege: plus de moteur de recommandation complet dans `/dashboard/home`.
- Dashboard recipes filtre maintenant les recettes plus presentables: publiques, actives, image, donnees nutritionnelles non nulles.
- Plan hebdo charge le detail complet du plan.
- Entries du meal plan exposent temps, calories, cout estime, image.
- Weekly plan affiche une synthese valeur: nombre de repas, temps moyen, estimation budget.
- Bouton Grocery genere la liste depuis le plan avant navigation.
- Grocery provider charge le detail de liste pour recuperer les items.
- Pricing batch pour `BudgetOptimizer` et `GroceryService`.
- Index workflow ajoutes dans `V112`: plans actifs, listes actives, entries, grocery items, preferences, subscriptions, recommendation pool, dashboard quality.
- Profile row responsive pour eviter les overflows.

## Audit migrations / seeds

### Points positifs

- `V1` pose les tables principales clairement.
- `V100` est transactionnel (`BEGIN/COMMIT`) et idempotent.
- `V111` est idempotent sur recettes, ingredients de recette et steps.
- `V109` contient deja une bonne base d'index de performance.

### Points a surveiller

- `V100__seed_food_intelligence.sql` fait environ 4.3 MB et `V111__merge_food_dataset.sql` environ 7.1 MB: Flyway local/CI peut devenir lent.
- `V111` commence par un commentaire `V101__merge_food_dataset.sql`, incoherent avec son nom reel.
- `V111` n'est pas enveloppe dans un `BEGIN/COMMIT`, contrairement a `V100`.
- `V111` utilise `ON CONFLICT (id) DO NOTHING` pour ingredients/steps: si le seed evolue, les lignes existantes ne seront pas corrigees.
- `V111` met a jour beaucoup de champs recette mais pas `source_url`.
- Les fichiers Python dans `db/migration` ne sont pas des migrations Flyway, mais ils brouillent le dossier. Mieux les deplacer vers `scripts/`.
- Les gros seeds contiennent des recettes avec `calories_per_serving = 0` ou images nulles: OK en base, mais a filtrer pour les surfaces premium.

### Optimisations conseillees

- Ne plus modifier `V1` a `V111` si deja appliques: creer uniquement des migrations nouvelles.
- Ajouter un seed de qualite progressive: `recipe_quality_score`, `content_status`, `image_quality`.
- Separrer datasets massifs en fichiers repetables ou scripts d'import admin hors Flyway pour la production.
- Garder Flyway pour schema + seeds minimum, pas pour tout le catalogue long terme.
- Ajouter un job de validation dataset: image presente, nutrition plausible, allergenes coherents, cout non nul.

## Audit logique metier

### Fort

- Budget, pantry, allergies et preferences sont les vrais differentiants.
- Checkout grocery met a jour budget et pantry: excellent pour fermer la boucle.
- Feedback recommendation existe deja.

### A renforcer

- Eviter de generer plusieurs grocery lists actives pour le meme plan.
- Ajouter une notion `meal_plan_id` sur `grocery_lists` pour tracer la source.
- Persister les achats reels dans une vraie table `purchase_records`.
- Ajouter leftovers/batch cooking pour reduire cout et temps.
- Ajouter un score visible: `planCost`, `avgMealTime`, `pantryCoverage`, `estimatedSavings`.
- Ajouter mode budget impossible: proposer un plan moins varie ou plus pantry au lieu d'echouer.

## Audit UI/UX

### Fort

- Navigation complete.
- Design premium.
- Ecrans core presents.

### A renforcer

- Home doit rester un cockpit d'action, pas un catalogue.
- Afficher systematiquement le gain concret: temps gagne, argent estime, gaspillage evite.
- Grocery doit etre un mode magasin: categories, progression, total restant.
- Pantry doit permettre ajout ultra rapide: paste, autocomplete, recents.
- Onboarding doit finir sur un plan exemple ou un CTA unique.
- Corriger les textes encodes en mojibake (`FranÃ§ais`, `â€”`) dans UI/docs.

## Priorites suivantes

1. Ajouter `meal_plan_id` sur `grocery_lists` et reutiliser/remplacer la liste active d'un plan.
2. Creer `purchase_records` persistant.
3. Ajouter score de qualite recette + migration de backfill.
4. Deplacer scripts Python hors `db/migration`.
5. Ajouter tests d'integration sur flow: generate plan -> generate grocery -> checkout -> pantry/budget update.
