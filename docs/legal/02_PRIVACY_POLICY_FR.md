# Politique de Confidentialité — PlatePilote

**Dernière mise à jour** : 28 juin 2026  
**Responsable** : Prince ZEUFACK TAMEZE — zeufacktameze@gmail.com

## 1. Données collectées

| Catégorie | Données | Base légale | Rétention max |
|---|---|---|---|
| Compte | Email (ou hash OAuth), nom d'affichage, langue | Art. 6(1)(b) exécution contrat | Durée du compte + 12 mois |
| Profil alimentaire | Préférences, allergies, nb personnes, budget hebdo | Art. 6(1)(b) | Durée du compte |
| Repas & courses | Plans repas générés, listes de courses, inventaire garde-manger | Art. 6(1)(b) | Durée du compte |
| Paiement | Stripe Customer ID (pas de CB stockée) | Art. 6(1)(b) | Durée du compte |
| Usage (analytics) | Pages vues, sessions, crash anonyme | Art. 6(1)(a) consentement | 24 mois |
| Push notification | FCM token | Art. 6(1)(a) consentement | Jusqu'à révocation |

## 2. Finalités

- Fournir le service de planification repas
- Améliorer l'application (stats anonymes)
- Envoyer des notifications push (si consentement)
- Paiement via Stripe

## 3. Sous-traitants

- **Hébergement backend** : Railway / Render (EU/US — DPA signé)
- **Base de données** : Neon (Postgres, EU)
- **Cache** : Upstash (Redis, EU)
- **Images** : Cloudflare R2 (EU)
- **Analytics** : PostHog Cloud EU
- **Paiement** : Stripe (certifié PCI DSS)
- **Notifications** : Firebase Cloud Messaging (USA — SCC signé)

## 4. Vos droits

Accès, rectification, effacement, portabilité, opposition, limitation.
Contacter : zeufacktameze@gmail.com — réponse sous 30 jours.

## 5. Cookies

Aucun cookie tiers. Session stockée via les tokens d'accès Stripe/JWT.

## 6. Transferts hors UE

Stripe (États-Unis) et FCM (États-Unis) — clauses contractuelles types (SCC) en place.

## 7. Sécurité

HTTPS partout, JWT court (15 min access, 7d refresh), chiffrement AES-256 tokens refresh.