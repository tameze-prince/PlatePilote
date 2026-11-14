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


# PlatePilot UX/Design Audit Report

**Date**: June 2026  
**Auditor**: Carol Produit  
**Scope**: Design System, Onboarding UX, Premium Conversion, Accessibility

---

## Executive Summary

PlatePilote has a well-documented Design System v2.0 with Material 3 foundation and premium glassmorphism components. However, **incomplete migration** from the old system, **friction in the onboarding-to-activation funnel**, and **accessibility gaps** are likely costing conversions. 10 priority actions identified below.

---

## 1. Design System Audit

### 1.1 Color Tokens

| Token | File | Status |
|-------|------|--------|
| `AppColors` | `lib/app/theme/app_colors.dart` | ✅ Implemented |
| `ColorTokens` (deprecated) | `lib/app/theme/color_tokens.dart` | ⚠️ Legacy wrapper still used |
| Light theme colors | `lib/app/theme/light_theme.dart` | ✅ Aligned with spec |
| Dark theme colors | `lib/app/theme/dark_theme.dart` | ✅ Aligned with spec |

**Gap**: `premium_upgrade_screen.dart` uses deprecated `ColorTokens` instead of `AppColors`.

```dart
// PROBLEMATIC: premium_upgrade_screen.dart line 37
color: ColorTokens.primaryGreen  // Should use AppColors.primaryAccentGreen
```

### 1.2 Theme Architecture Duality

Two distinct visual systems exist:

1. **Standard Material 3** (`light_theme.dart`, `dark_theme.dart`) - for generic screens
2. **Premium Theme** (`premium_components.dart` with `PremiumTheme` class) - for onboarding, home

The premium theme provides:
- Glassmorphism (`GlassContainer`, `PremiumCard` variant=glass)
- Ambient glow effects
- Floating shadows with green tint

**Gap**: These premium visual effects are NOT available in standard Material theme. Screens not using `PremiumBackground` look inconsistent.

### 1.3 Typography

Typography tokens in `app_typography.dart` follow the scale in DESIGN_SYSTEM.md. However:

- **Inter font** documented as loaded via Google Fonts, but not verified in `main.dart`
- `AppTypography` used in premium_components.dart and modern_components.dart
- Inconsistent use of `context.text` extension mentioned in MIGRATION_GUIDE (not found in codebase)

### 1.4 Spacing & Radius

✅ Properly implemented in `app_spacing.dart` and `app_radius.dart` with semantic names.

### 1.5 Animation Tokens

`AppAnimations` defined in `app_animations.dart` but **NOT used consistently**:
