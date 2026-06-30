# Politique de Confidentialité — PlatePilot

**Effective date : 2026-07-01**
**Dernière mise à jour : 2026-07-01**

## 1. Qui sommes-nous

PlatePilot est édité par **PlatePilote SAS**, société par actions simplifiée de droit français.
Contact DPO / délégué à la protection des données : **dpo@platepilote.app**
Siège social : à compléter (RCS Paris).

## 2. Quelles données collectons-nous

Nous collectons les catégories de données suivantes :

- **Données de compte** : email, mot de passe (haché BCrypt), pseudonyme, date d'inscription.
- **Préférences alimentaires** : régime (omnivore, végétarien, végétalien, sans gluten, sans lactose), allergies déclarées, nombre de personnes dans le foyer, niveau culinaire.
- **Plan de repas** : recettes enregistrées, planning hebdomadaire, repas consommés, courses générées.
- **Garde-manger** : ingrédients stockés, dates d'ajout, quantités.
- **Données d'usage** : événements applicatifs anonymisés (analytics opt-in), logs techniques (IP tronquée, horodatage, codes erreur), version de l'app, plateforme (iOS / Android).
- **Notifications push** : token FCM (Firebase Cloud Messaging) si vous activez les rappels.

## 3. Pourquoi nous les utilisons (finalités)

- Fourniture du service principal de meal-planning et de gestion de garde-manger.
- Personnalisation des recommandations selon vos préférences et votre historique.
- Amélioration du produit (analytics agrégées, détection de bugs, mesures de performance).
- Envoi de notifications push de rappel (uniquement si vous y avez consenti).
- Respect de nos obligations légales et comptables.

## 4. Base légale du traitement

- **Exécution du contrat** (CGU PlatePilot) : pour le service meal-planning, la gestion de compte, le stockage de vos données préférences et garde-manger.
- **Consentement** (RGPD art. 6.1.a) : pour les analytics, les notifications push, et tout traitement basé sur un opt-in explicite.
- **Intérêt légitime** (RGPD art. 6.1.f) : pour la sécurité (prévention des abus, journalisation), limité et proportionné.

## 5. Qui peut y accéder (sous-traitants et destinataires)

Accès restreint au personnel technique habilité de PlatePilote. Sous-traitants actuels :

- **Neon** — hébergement base de données PostgreSQL (UE).
- **Firebase Cloud Messaging (Google)** — envoi de notifications push.
- **Stripe** — gestion des paiements (uniquement pour les futurs plans payants).
- **OpenAI / fournisseurs LLM** — *uniquement si activé ultérieurement* (Sprint 9+) pour des fonctionnalités IA génératives, sous accord de traitement conforme RGPD.

Aucun transfert vers des pays tiers hors UE sans garanties adéquates (clauses contractuelles types, décision d'adéquation).

## 6. Durée de rétention

- **Compte actif** : données conservées tant que votre compte est actif.
- **Suppression douce (soft-delete)** : à la demande de suppression, vos données passent en état « supprimé » et sont **gracieusement conservées 30 jours** (cf. BR-008 — fenêtre de récupération anti-impulsion). Passé ce délai, **hard-purge** définitif (suppression irréversible de la base et des sauvegardes).
- **Logs techniques** : 90 jours glissants.
- **Données comptables / facturation** : 10 ans (obligation légale française).

## 7. Vos droits RGPD

Vous disposez des droits suivants, exercables à **dpo@platepilote.app** :

| Droit | Référence RGPD | Endpoint / action |
|---|---|---|
| Droit d'accès | art. 15 | `GET /api/v1/me/data-export` |
| Droit de rectification | art. 16 | `PATCH /api/v1/me/profile` |
| Droit à l'effacement | art. 17 | `DELETE /api/v1/me/account` (déclenche soft-delete 30j) |
| Droit à la limitation | art. 18 | `POST /api/v1/me/restrict-processing` |
| Droit à la portabilité | art. 20 | `GET /api/v1/me/data-export` (export JSON structuré) |
| Droit d'opposition | art. 21 | `POST /api/v1/me/opt-out-analytics` |

Réponse sous **30 jours**. En cas de doute sur l'identité, une vérification pourra être demandée.

## 8. Sécurité

- **Mots de passe** hachés via BCrypt (cost factor ≥ 12).
- **Authentification** par JWT signé, rotation de clés planifiée.
- **Communications** chiffrées en transit (HTTPS / TLS 1.3).
- **Audit log** des accès aux données personnelles.
- **Tests de sécurité** automatisés intégrés au CI (cf. BR-007).
- **Journalisation** des événements de sécurité dans `analytics_events` avec catégorie `security`.

## 9. Cookies et traceurs

PlatePilot est une application mobile. Nous utilisons uniquement des traceurs techniques strictement nécessaires au service (jeton d'authentification, préférences locales). Aucun cookie publicitaire, aucun traceur tiers de profilage.

## 10. Modifications de la présente politique

Toute modification sera publiée sur cette page avec mise à jour de la date en en-tête. En cas de changement substantiel, vous serez informé·e par email et/ou notification in-app au moins **30 jours** avant l'entrée en vigueur.

---

*Ce document est fourni à titre informatif et ne constitue pas un conseil juridique. Pour toute question, contactez votre DPO ou consultez la CNIL (www.cnil.fr).*
