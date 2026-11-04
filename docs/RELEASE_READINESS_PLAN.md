# PlatePilote — Plan de résolution et de mise en production

**Branche :** `release/production-readiness`  
**PR :** [#3 — Release readiness](https://github.com/tameze-prince/PlatePilote/pull/3)  
**Cible :** application Android Flutter, API Spring Boot et PostgreSQL.  
**Règle de sortie :** aucune publication publique tant que les critères bloquants ne sont pas validés.

## 1. Objectif produit

Livrer un parcours Android réellement utilisable :
1. inscription, vérification e-mail, connexion et récupération d'accès ;
2. onboarding et préférences alimentaires ;
3. consultation de recettes avec ingrédients, étapes, nutrition et coût disponibles ;
4. création et consultation de plans de repas ;
5. gestion du garde-manger et des courses ;
6. profil, paramètres, confidentialité, export et suppression de compte ;
7. fonctionnement contre une API réellement déployée en HTTPS.

L'architecture reste un monolithe modulaire Spring Boot. Une migration vers des microservices n'est pas un prérequis.

## 2. Changements engagés sur la branche

Ces changements ne sont pas encore fusionnés dans `main`.

### Sécurité et intégrité
- JWT séparés par usage : access, refresh et reset password ; le filtre HTTP refuse les tokens non-access.
- Les comptes désactivés ou supprimés logiquement ne doivent plus être authentifiés par un ancien JWT.
- Les recettes privées sont contrôlées par propriétaire ; les recettes privées d'un autre utilisateur ne peuvent pas être ajoutées à un plan.
- Les recettes désactivées/supprimées sont exclues des listes et recherches publiques.
- Correction de la précédence AND/OR dans la recherche publique.
- Quantités consommées dans le garde-manger strictement positives.
- Rate limiting : en-têtes IP acceptés uniquement depuis des proxys explicitement configurés ; cache borné et nettoyé.
- Refresh tokens envoyés dans le corps POST, pas dans l'URL.
- Comptes QA `@platepilote.test` ignorés sur une installation production neuve ; comptes déjà présents désactivés par migration.

### Base de données
- Hibernate en mode `validate` en production ; Flyway reste l'unique mécanisme de migration.
- Suppression de la réparation Flyway automatique en production.
- Migration `V120` : allergènes recalculés depuis les métadonnées des ingrédients ; les données manquantes restent `NULL`, jamais une fausse valeur négative.
- Le générateur de recettes utilise la prochaine version Flyway libre, n'invente plus d'étapes génériques, désactive les recettes sans ingrédients ou instructions et marque les données importées non vérifiées.

### Flutter / Android
- Renouvellement des tokens mutualisé entre les 401 simultanés ; une réponse tardive réutilise le token récent.
- Les logs réseau ne révèlent plus les URI complètes avec paramètres sensibles.
- L'URL API est une configuration explicite ; les builds release exigent HTTPS.
- Le fichier `.env` asset est un placeholder vide, sans secret ni URL de production supposée.
- Gradle utilise un keystore release dédié, sans fallback vers la clé debug.
- Le workflow Android de release construit APKs et AAB signés, vérifie les signatures et génère des checksums.

## 3. Plan de résolution par priorité

### P0 — Sécurité et confidentialité
| Travail | Composants | Acceptation |
|---|---|---|
| Usages JWT | `JwtService`, `JwtAuthenticationFilter`, `AuthService` | Refresh/reset token jamais accepté comme bearer access ; compte désactivé rejeté |
| Isolation recettes | `RecipeService`, `RecipeController`, `RecipeRepository` | Aucun accès à la recette privée d'un autre utilisateur |
| Plans de repas | `MealPlanService` | Recette privée inaccessible, supprimée ou désactivée refusée |
| Garde-manger | `PantryController`, `PantryService` | Null, zéro et négatif rejetés HTTP + service |
| Rate limiting | `RateLimitingFilter` | XFF ignoré depuis un pair non fiable ; mémoire bornée |
| Migrations production | `application-prod.yml`, Flyway | Pas de comptes QA actifs ; schéma validé |
| Refresh token | `AuthController`, Flutter `ApiClient` | Token uniquement dans le corps POST |

### P1 — Fonctionnalités essentielles et qualité des données
| Travail | Composants | Acceptation |
|---|---|---|
| Détail recette | `RecipeResponse`, `RecipeService`, modèle Flutter | Nutrition, provenance et incertitude allergène visibles |
| Allergènes | migration `V120`, `RecommendationEngine` | Inconnu n'est jamais assimilé à « sans allergène » ; avertissement visible |
| Générateur catalogue | `food_dataset_v2/generate_v101.py` | Migration Flyway libre, pas de fausses étapes, recettes incomplètes désactivées |
| Contrats API | repositories Flutter + controllers Spring | Requêtes/réponses vérifiées ; aucun endpoint fictif |
| Sessions Flutter | `api_client.dart` | Les 401 simultanés ne déconnectent pas aléatoirement |
| Configuration | `.env.example`, profils Spring, `--dart-define` | DB, SMTP, R2, Redis, Stripe et services externes documentés |
| Droits utilisateurs | module `me` | Export complet ou limites annoncées ; suppression et rétention réellement exécutées |

**Sécurité alimentaire :** les recettes importées ne sont pas certifiées par un professionnel. Les allergènes sont dérivés automatiquement des ingrédients et doivent être vérifiés sur les emballages. L'application ne doit jamais garantir qu'une recette est sûre pour une personne allergique. Les 101 lignes du CSV sans ingrédients ou instructions sont désactivées par le générateur ; les autres restent non vérifiées.

### P2 — Expérience Android et fiabilité
- Vérifier tous les boutons et liens : aucun `onPressed: () {}` ni action sans effet.
- Tester inscription, vérification, connexion, reset password, onboarding, planification, recettes, garde-manger, courses, profil et droits utilisateurs sur Android réel.
- Tester chargement, erreur, vide, réseau absent et reprise après reconnexion.
- Vérifier images, permissions, notifications, navigation et états de formulaire.
- Une intégration externe optionnelle indisponible ne doit pas faire planter le parcours principal.
- Confirmer icône, nom affiché, applicationId, version, langues et thème.

### P3 — Distribution
- Créer le keystore d'upload sous le contrôle du propriétaire et le sauvegarder chiffré hors dépôt.
- Configurer les secrets et variables GitHub listés dans `build/SIGNING.md`.
- Construire APKs split par ABI et AAB signé.
- Vérifier signatures, checksums, installation, mise à jour et réinstallation.
- Préparer fiche Play Store, confidentialité, support, captures et rollback.

## 4. CI et critères de validation

### Backend
- `python -m py_compile` et tests unitaires/intégration du générateur de données.
- Maven validate, compilation et tests.
- Build Docker sur les pull requests.
- Les tests nécessitant Docker/PostgreSQL doivent réellement tourner ; un test ignoré n'est pas une validation.

### Flutter
- Formatage strict des fichiers Dart modifiés.
- `flutter analyze` sans erreur.
- `flutter test` sans échec.
- Build APK de validation.
- L'artefact du workflow debug n'est pas un artefact de publication.

### Release Android
Le workflow `.github/workflows/android-release.yml` exige :
- Variable GitHub `PLATEPILOT_API_BASE_URL` avec l'URL HTTPS réellement déployée.
- Secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.

Il construit les APKs et l'AAB signés avec le keystore fourni. Ne jamais coller les secrets ou le keystore dans le chat ni les commiter.

## 5. Intégrations à valider sur l'environnement déployé

| Service | Contrôles |
|---|---|
| PostgreSQL | URL, identifiants, sauvegardes et migrations Flyway |
| Redis | disponibilité et comportement en cas de panne |
| SMTP/Brevo | vérification e-mail, reset password, limites d'envoi |
| Cloudflare R2 | upload, lecture, suppression et URL HTTPS |
| Firebase/FCM | options Android réelles, notifications et crash reporting |
| Stripe | webhook HTTPS, signature et événements en mode test/production |
| Service IA | URL/fournisseur réels ; feature flag ou message clair si indisponible |
| CORS/proxy | origines autorisées et proxys de confiance exacts |

Aucune URL ou intégration n'est considérée opérationnelle avant un test sur l'environnement déployé.

## 6. Définition de « prêt pour le grand public »

- [ ] PR revue et fusionnée après CI verte.
- [ ] Backend déployé, migrations appliquées, health checks verts.
- [ ] Parcours complet testé sur appareils Android réels.
- [ ] Aucun bug P0/P1 ouvert.
- [ ] Tests backend, Flutter et Docker verts.
- [ ] Catalogue et avertissements allergènes validés.
- [ ] URLs et secrets externes configurés.
- [ ] APK release signé par le vrai keystore du propriétaire.
- [ ] AAB signé et vérifié.
- [ ] Confidentialité, consentement, support et fiche de distribution validés.
- [ ] Sauvegardes, monitoring et rollback opérationnels.

**État : en cours.** Les premières corrections et les workflows sont sur la branche de travail. Aucun APK signé avec un vrai keystore ni aucun test contre un backend de production n'est encore attesté. La publication reste bloquée jusqu'à validation de toutes les cases ci-dessus.
