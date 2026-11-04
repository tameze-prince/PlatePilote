# PlatePilote — Plan d'exécution vers une version publique

> Branche de travail : `release/public-beta-readiness`  
> Base de départ : `main` au commit `d5fab6b781b25426aa2c605cb51d2f7850ad65ef`  
> Statut : plan vivant ; une case ne passe à terminée qu'avec une preuve de test/build/runtime.

## Objectif de livraison

Livrer une application Android Flutter reliée à une API Spring Boot et à PostgreSQL, avec des parcours métier utilisables, une sécurité vérifiée, des données fiables, une configuration de production documentée et un APK release signé et testé.

Le dépôt ne sera pas déclaré « prêt grand public » sur la seule base d'un build réussi. La publication dépend également des services externes, de la signature, de la politique de confidentialité, des conditions d'utilisation, des sauvegardes et d'un test sur appareil.

## Hypothèses et limites

1. Le dépôt principal `tameze-prince/PlatePilote` contient le frontend Flutter et le backend Spring Boot ; le dépôt d'images est une ressource secondaire.
2. `main` est protégé par notre discipline de travail : les corrections sont faites sur cette branche dédiée, puis proposées à fusion.
3. Aucun secret réel (JWT, DB, Stripe, mail, Firebase, fournisseur IA, keystore) ne doit être commité.
4. Les secrets de signature et comptes tiers ne sont pas accessibles par le code source. Le pipeline peut être préparé, mais la signature de production et les appels réels ne peuvent être attestés sans les secrets et services correspondants.
5. Les fonctionnalités dépendant d'un fournisseur non configuré doivent afficher un état indisponible explicite et ne jamais retourner de faux résultats.
6. Les migrations déjà susceptibles d'avoir été exécutées en production ne doivent pas être réécrites ou supprimées : toute correction de données doit être additive et accompagnée d'un plan de rollback.

## Priorités

- **P0 — sécurité et intégrité** : empêcher l'utilisation d'un jeton refresh/reset comme jeton d'accès, refuser les comptes désactivés/supprimés, corriger l'accès aux recettes privées, empêcher les quantités négatives et retirer les identités de démonstration du périmètre production.
- **P1 — fiabilité métier** : cohérence des contrats API, gestion des erreurs, rotation de refresh token côté Flutter, migrations reproductibles, validation des données alimentaires et des références de recettes.
- **P1 — qualité de livraison** : CI bloquante, builds reproductibles, tests unitaires/intégration, Docker, health checks, configuration prod et procédure de rollback.
- **P2 — expérience publique** : parcours onboarding → compte → préférences → recettes → planning → garde-manger → courses → profil/droits des données, états vides/chargement/erreur, accessibilité et localisation.
- **P2 — publication** : signature APK/AAB, versionnement, notes de version, distribution, crash reporting et guide support.

## Lots et critères d'acceptation

### Lot 0 — Baseline et inventaire

- [x] Lire le contrat d'agent `AGENTS.md`, le README et le plan APK existant.
- [x] Créer la branche `release/public-beta-readiness` depuis `main`.
- [ ] Capturer l'arbre complet frontend/backend, endpoints et modules actifs.
- [ ] Relier chaque écran Flutter à son provider/repository et à un endpoint backend.
- [ ] Classer chaque fonctionnalité : opérationnelle, partielle, simulée, indisponible ou non testée.
- [ ] Capturer les versions SDK/JDK/Flutter et l'état réel des workflows.

**Gate :** matrice de couverture écran → repository → endpoint → service → tables → tests.

### Lot 1 — Sécurité P0 backend

- [ ] Ajouter un claim d'usage explicite aux JWT : access, refresh, password-reset.
- [ ] Le filtre HTTP n'accepte que les access tokens.
- [ ] Le refresh endpoint n'accepte que les refresh tokens persistés, non révoqués et non expirés.
- [ ] Les jetons reset ne sont acceptés que par le flux de réinitialisation.
- [ ] Le filtre refuse un compte désactivé ou supprimé et traite un JWT malformé comme non authentifié (pas comme erreur 500).
- [ ] Séparer strictement la lecture d'une recette publique et la lecture d'une recette personnelle.
- [ ] Bloquer l'ajout d'une recette privée d'un autre utilisateur dans un plan de repas.
- [ ] Valider la quantité consommée dans le garde-manger (strictement positive et cohérente avec le stock).
- [ ] Auditer les migrations de seed de comptes de test avant toute production. Ne pas réécrire une migration déjà exécutée ; préparer une migration additive et une stratégie de nettoyage si nécessaire.

**Tests exigés :** token access accepté ; refresh/reset refusés sur API ; refresh révoqué refusé ; compte désactivé/supprimé refusé ; recette privée inaccessible à un tiers ; recette publique accessible ; ajout d'une recette privée tierce refusé ; quantité nulle/négative/excessive refusée.

### Lot 2 — Fiabilité backend et données

- [ ] Définir un contrat d'erreur API stable et cohérent avec les parseurs Flutter.
- [ ] Vérifier validation des DTO, pagination, tri, limites de requêtes et erreurs métier.
- [ ] Vérifier toutes les opérations d'écriture par propriété utilisateur (IDOR).
- [ ] Vérifier les suppressions logiques et les filtres `deleted_at IS NULL`.
- [ ] Passer le schéma Hibernate en mode validation en production ; Flyway reste l'unique mécanisme de migration.
- [ ] Vérifier l'ordre, l'unicité et l'idempotence des migrations.
- [ ] Corriger la résolution des imports Maven/Docker et garder un build d'image déterministe.
- [ ] Vérifier les tâches asynchrones : proxy Spring, erreurs, retries, timeouts et absence de blocage des contrôleurs.
- [ ] Vérifier les services externes (mail, R2, Stripe, IA, Redis) : timeouts, configuration fail-fast, fallback explicite et observabilité.
- [ ] Valider le jeu de données : recettes non vides, images accessibles, source nutritionnelle/allergènes traçable, pas de fausse garantie allergène.

**Gate :** `./mvnw verify` vert avec rapports archivés ; migrations validées sur PostgreSQL propre et sur copie de schéma existant ; smoke tests HTTP.

### Lot 3 — Flutter et parcours Android

- [ ] Rendre la configuration API explicite par flavor/dart-define ; ne pas dépendre d'un fichier `.env` absent dans le dépôt.
- [ ] Ajouter un verrou single-flight pour la rotation du refresh token ; les requêtes concurrentes partagent le même refresh.
- [ ] Ne pas journaliser de jeton ni d'URL contenant des identifiants.
- [ ] Vérifier stockage natif Android (Keystore via FlutterSecureStorage), déconnexion, expiration et nettoyage des sessions.
- [ ] Vérifier navigation, deep links, reprise après arrêt, erreurs réseau, timeout, mode hors ligne et accessibilité.
- [ ] Corriger les boutons/écrans Settings qui ne font rien et retirer les utilisateurs de démonstration codés en dur.
- [ ] Vérifier onboarding, authentification, vérification email, mot de passe oublié, préférences, recettes, planification, garde-manger, courses, profil, export et suppression de compte.
- [ ] Ajouter/compléter tests unitaires, widget et integration_test exécutés sur émulateur Android réel dans CI.
- [ ] Vérifier que les données d'allergènes ne sont jamais présentées comme garanties si elles sont estimées ou inconnues.

**Gate :** `flutter analyze` sans erreur ni warning ignoré ; `flutter test` vert ; tests d'intégration Android exécutés ; parcours utilisateur de bout en bout validé sur APK.

### Lot 4 — CI, build et infrastructure

- [ ] Retirer `|| true` de l'analyse Flutter.
- [ ] Corriger les chemins/conditions de workflows et les badges README.
- [ ] Déclencher CI sur les changements frontend/backend et sur pull requests.
- [ ] Ajouter build APK release et AAB ; ne pas exposer les secrets dans les logs.
- [ ] Configurer signing via secrets GitHub (keystore encodé, store password, key alias, key password).
- [ ] Corriger la construction Docker et vérifier le démarrage de l'image.
- [ ] Ajouter un environnement PostgreSQL/Redis reproductible pour tests.
- [ ] Définir variables de production, domaines CORS, TLS, stockage, backups, restore drill et monitoring.
- [ ] Vérifier les règles de branche et rendre obligatoires les checks CI avant merge.

**Gate :** PR avec tous les checks verts ; APK release et AAB produits comme artefacts ; image backend construite et smoke-testée.

### Lot 5 — Conformité, exploitation et distribution

- [ ] Vérifier les textes légaux, politique de confidentialité, conditions d'utilisation et coordonnées de l'éditeur.
- [ ] Documenter finalités, durées de conservation, sous-traitants, transfert de données et droits utilisateur.
- [ ] Vérifier export/suppression/limitation et exécution effective de la purge annoncée.
- [ ] Ajouter télémétrie uniquement après consentement et crash reporting sans données sensibles.
- [ ] Configurer alertes, logs structurés, métriques, health checks et runbook incident.
- [ ] Produire notes de version, guide testeurs, procédure rollback et support.
- [ ] Vérifier les exigences Google Play (signature, target SDK, Data safety, contenu, permissions et tests requis).

**Gate :** checklist de publication approuvée ; secrets configurés ; version release signée ; test d'installation/mise à jour sur appareils ; backend de production disponible et sauvegardes restaurables.

## Matrice de risque connue au démarrage

| Risque | Sévérité | Traitement |
|---|---:|---|
| Confusion access/refresh/reset JWT | Critique | Lot 1 |
| Recettes privées exposées via endpoint de détail | Critique | Lot 1 |
| Référence à une recette privée tierce dans un plan | Élevée | Lot 1 |
| Comptes désactivés pouvant conserver un accès JWT | Élevée | Lot 1 |
| Quantité consommée non strictement positive | Élevée | Lot 1 |
| Refresh concurrent côté Flutter | Élevée | Lot 3 |
| Tokens web stockés dans SharedPreferences | Élevée pour le web | Web non inclus dans la livraison APK ; architecture cookie/BFF avant lancement web public |
| Seed de comptes test/admin dans migration Flyway | Élevée | Lot 1/2, migration additive après vérification d'environnement |
| Dataset recettes incomplet / allergènes non fiables | Critique pour les recommandations allergènes | Lot 2 |
| CI Flutter masque les erreurs d'analyse | Élevée | Lot 4 |
| Signature Android non configurée | Bloquant publication | Lot 4 |
| Services externes sans secrets de déploiement | Bloquant pour fonctionnalités concernées | Lot 2/5 |

## Politique de changement

- Un commit = un changement logique.
- Ne pas modifier `main` directement pendant le travail.
- Ne jamais supprimer/réécrire une migration déjà potentiellement appliquée.
- Ne pas commiter secrets, données personnelles, fichiers `.env`, keystores ou clés privées.
- Les endpoints et schémas publics changés doivent être documentés.
- Les fonctionnalités non disponibles doivent être désactivées proprement ou afficher un état explicite.
- Tout correctif doit être accompagné d'un test qui échoue avant le correctif et passe après.

## Journal d'exécution

| Date | Lot | Changement | Commit | Vérification |
|---|---|---|---|---|
| 2026-11-04 | 0 | Branche de livraison créée depuis main | pending | Branche GitHub confirmée |
