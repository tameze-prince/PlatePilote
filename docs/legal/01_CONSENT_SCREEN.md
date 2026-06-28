# RGPD Consent Screen — PlatePilote (M2a)

**Statut** : Draft v1  
**Next** : Relecture Pierre (AppSec) + Yara (Legal) avant dev

## 1. Collecte explicite (2 briques disjointes)

- [ ] **Analytics opt-in** (PostHog Cloud EU)
  - But : améliorer l'app (pages fréquentes, crash stats anonymes, temps moyen de plan)
  - RGPD art. 6(1)(a) : consentement explicite. Pas d'hit PostHog avant ce toggle.
- [ ] **Push notifications opt-in** (Firebase Cloud Messaging)
  - But : rappel meal prep, alerte promo Premium (après consentement)
  - Double opt-in : consent in-app + iOS/Android system dialog

## 2. Wording FR

```
AVANT DE COMMENCER

PlatePilote respecte votre vie privée.

Nous utilisons des données anonymes (pages visitées, temps d'usage)
pour améliorer l'application — jamais vos recettes, vos photos
ou vos préférences alimentaires.

Ces données restent en Europe et ne sont jamais revendues.

Activez-vous les statistiques d'usage anonymisées ?
→ Oui, j'aide à améliorer PlatePilote
→ Non, pas maintenant (paramétrable dans Réglages)

[Continuer vers PlatePilote]
```

## 3. Wording EN

```
BEFORE YOU START

PlatePilot respects your privacy.

We use anonymous usage data (pages visited, session duration)
to improve the app — never your recipes, photos or food preferences.

This data stays in the EU and is never sold.

Enable anonymized usage statistics?
→ Yes, help improve PlatePilot
→ Not now (change anytime in Settings)

[Continue to PlatePilot]
```

## 4. Implémentation Flutter

- Fichier : `FrontEnd/lib/features/consent/consent_screen.dart`
- Store : `consent_provider.dart` (StateProvider<bool> analyticsConsent + pushConsent)
- Hook dans `main.dart` : si consent non donné → route vers `/consent` avant `/`
- SharedPreferences key : `analytics_consent_granted` (boolean, false par défaut)