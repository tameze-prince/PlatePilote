# Telemetry PostHog — S8.M4a + M4b

**Décision** : PostHog Cloud EU (recommandé Bob, validé Prince)

## Setup FrontEnd Flutter

### 1. Installation
```yaml
# pubspec.yaml — ajouter sous dependencies:
  posthog_flutter: ^4.0.0
```

### 2. Initialisation dans main()
```dart
// Dans main.dart, après consent vérifié
import 'package:posthog_flutter/posthog_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Charger le consent de l'utilisateur
  final prefs = await SharedPreferences.getInstance();
  final analyticsConsent = prefs.getBool('analytics_consent_granted') ?? false;
  
  if (analyticsConsent) {
    await Posthog().init(
      apiKey: dotenv.env['POSTHOG_API_KEY']!,
      host: 'https://eu.posthog.com',
      captureScreenViewsDefault: false,
    );
  }
  
  runApp(ProviderScope(child: PlatePilotApp()));
}
```

### 3. Events à envoyer (PRD §5.7)

| Event | Condition | Data |
|---|---|---|
| `app_launch` | Démarrage | platform, lang, build |
| `signup_completed` | Compte créé | method (email/google/apple) |
| `onboarding_step` | Étape onboarding | step_num, total_steps |
| `meal_plan_generated` | Plan généré | items_count, budget_match% |
| `grocery_list_created` | Liste générée | items_count, cost_estimation |
| `pantry_item_added` | Scan ou ajout manuel | source (scan/manual) |
| `subscription_activated` | Premium activé | plan (monthly/yearly) |
| `session_end` | 30 min idle | duration_min, screens_visited |

### 4. Settings UI

Dans Settings → Analytics : toggle bouton pour révoquer le consentement
```dart
Switch.adaptive(
  value: analyticsConsent,
  onChanged: (value) async {
    await prefs.setBool('analytics_consent_granted', value);
    ref.invalidate(posthogProvider);
  },
)
```

## Setup Backend (M4a)

### Backend events (server-side)

```kotlin
// BillingService — Stripe webhook
telemetry.track("payment_completed", mapOf(
  "amount" to payment.amount,
  "plan" to payment.planType.name,
  "currency" to payment.currency,
))

// MealPlanGeneratorService
telemetry.track("meal_plan_generated", mapOf(
  "items" to plan.meals.size,
  "budget_match" to plan.budgetCompliance,
  "pantry_items_used" to plan.pantryItemsUsed,
))
```

## Dashboard PostHog

Créer 3 dashboards :
1. **Activation** — signups, onboarding completion, activation rate
2. **Engagement** — plans/jour, retention D1/D7, pantry usage
3. **Revenue** — stripe events, premium conversion, churn