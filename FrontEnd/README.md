# PlatePilote — FrontEnd

Flutter mobile client for PlatePilote (iOS + Android via Flutter 3 / Dart,
Riverpod state management, go_router navigation, Dio HTTP).

## Quick Filters & Meal-Plan Modes (US-006 — Sprint 7.1a)

The weekly plan screen (`lib/features/meal_plan/weekly_plan_screen.dart`)
exposes two stacked controls:

1. **PRD-aligned Quick Filters** — three hero chips shown at the top:
   `Faster`, `Healthier`, `Cheaper`. Tapping one immediately triggers
   `generateNewPlan(...)` with the appropriate backend mode.
2. **Expert Mode Selector** — five chips (`Standard`, `Healthier`,
   `Cheaper`, `Faster`, `Family`) for power users. Behaves like before:
   switches the current plan in place via `setMode(...)` if one exists,
   otherwise regenerates.

### PRD ↔ Backend mode mapping

The frontend has its own vocabulary (PRD labels) that maps onto the
backend's mode codes. The mapping is fixed and lives next to the UI code:

| PRD label   | Backend mode | Intent                              |
| ----------- | ------------ | ----------------------------------- |
| `Faster`    | `BUSYWEEK`   | Recipes under 30 minutes            |
| `Healthier` | `WASTELESS`  | Uses pantry staples, less waste     |
| `Cheaper`   | `ENDOFMONTH` | Strict budget, low-cost recipes     |
| `Standard`  | `STANDARD`   | Balanced week (default)             |
| `Family`    | `FAMILY`     | Larger portions, kid-friendly       |

> See `lib/features/meal_plan/meal_mode_labels.dart` for the constants
> (`kMealModeMeta`, `kQuickFilters`) and the canonical label/icon/
> description for each mode.

### Wiring

- Repository: `MealPlanRepository.generateWeeklyPlanWithMode(...)`
  posts `{startDate, mode}` to `POST /meal-plans/generate`.
- Mutating only: `MealPlanRepository.setMode(planId, mode)` calls
  `PUT /meal-plans/{id}/mode?mode=…`.
- Provider: `MealPlanNotifier.generateNewPlan({String? mode})` covers
  both flows from a single entrypoint.

### Visual rules

- Quick filter chips use `GlassContainer` with a
  `primaryAccentGreen` border (35% alpha idle, 100% while generating).
- While `state.isGenerating` is `true`, the three chips are disabled and
  the triggering chip shows an inline spinner.
- Expert mode selector retains the existing active-state styling
  (`elevated: true` + `primaryAccentGreen` label text).
