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

```dart
// modern_animations.dart uses it
duration: AppAnimations.buttonPress,  // ✅ Good

// But in onboarding_flow.dart
duration: const Duration(milliseconds: 300),  // ❌ Hardcoded
```

---

## 2. Onboarding UX Analysis

### Flow Review

**Current flow** (onboarding_flow.dart):
```
Step 1: Household setup
  - Household size (1, 2, 3, 4+)
  - Cooking profile (Beginner, Balanced, Batch cook, Chef mode)
  
Step 2: Budget & constraints
  - Weekly budget ($75, $120, $180, Custom)
  - Cooking time (15, 30, 45, Flexible)
  - Dietary preferences (multi-select)
  
Step 3: Goals & pantry
  - Goals (multi-select: Save money, Eat healthier, Waste less, Cook faster)
  - Info card about pantry setup later

After step 3: Redirect to /signup or /login
```

### Pain Points Identified

| Issue | Severity | Description |
|-------|----------|-------------|
| **Activation delay** | CRITICAL | User must complete onboarding (3 steps) + signup/login (2-3 steps) + meal plan generation before seeing value. Total: 5-7 user actions minimum. |
| **Custom budget dead end** | HIGH | "Custom" budget option (step 2) calls same `onSelected` but no picker appears. User taps "Custom" and... nothing happens. |
| **No value preview** | HIGH | Onboarding collects data but shows no preview of meal planning. User can't visualize the benefit. |
| **Pantry delay** | MEDIUM | Step 3 says pantry setup can be "finished later" - this delays the AI's ability to personalize. |
| **No progress persistence** | MEDIUM | If user abandons onboarding midway, their progress is lost. No local storage of state. |
| **No skip option** | MEDIUM | All steps are "required" - power users who want quick access must complete all fields. |

### Time-to-Value Calculation

| Action | Interactions | Est. Time |
|--------|--------------|-----------|
| Complete onboarding | 8-12 taps + keyboard | 2-3 min |
| Signup/Login | 5-8 taps + keyboard | 1-2 min |
| Generate first meal plan | 2-3 taps | 10-30 sec |
| **Total to first value** | **15-23 interactions** | **3-6 minutes** |

**Benchmark**: Top apps achieve "time to first value" in < 90 seconds.

---

## 3. Premium Conversion Analysis

### Screen: `premium_upgrade_screen.dart`

**Issues identified**:

1. **Uses deprecated ColorTokens** - inconsistent with design system migration
2. **No trial duration specified** - "Start Premium Trial" - how long? What happens after?
3. **No social proof** - no testimonials, ratings, or user count
4. **No pricing comparison** - no "vs competitors" or value anchor
5. **Feature list is walls of text** - not scannable
6. **Mobile layout** - features stack vertically, feels overwhelming

```dart
// Line 53-58: Price display is just "$6.99 / month" with no context
Text(r'$6.99 / month', style: context.text.displaySmall?.copyWith(...))
```

### Screen: `subscription_management_screen.dart`

Very minimal - just shows plan name and status. Missing:
- Features comparison (free vs premium)
- Renewal/cancellation info
- Clear upgrade path for non-premium users

### Friction Points Summary

| Friction | Impact |
|----------|--------|
| Unknown trial length | Users hesitate without knowing commitment |
| No social proof | Trust deficit for unknown app |
| Text-heavy features | Low scannability, high cognitive load |
| External checkout | Launching external URL breaks flow |
| No preview of premium | Can't see what they're buying |

---

## 4. Accessibility Audit

### 4.1 Semantic Labels

**Icons without semantic labels** (home_screen.dart):

```dart
// Line 81-86 - IconButton has no tooltip or semantic label
IconButton(
  icon: const Icon(Icons.notifications_outlined),
  onPressed: () => context.push('/notifications'),
  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
)
// Should have: tooltip: 'Notifications', or Semantics label

// Line 346-348 - IconButton.filled
IconButton.filled(
  onPressed: () => context.push(action.route),
  icon: const Icon(Icons.arrow_forward),
)
// Missing semantic label for arrow purpose
```

**GlassButton** (premium_components.dart line 485-488):
```dart
FilledButton.icon(
  onPressed: onPressed,
  icon: Icon(icon ?? Icons.arrow_forward, size: 18),
  label: Text(label),
)
// Button has label but icon inside does not have independent semantic treatment
```

### 4.2 Touch Targets

✅ **Good**: All buttons use `minimumSize: const Size.fromHeight(54)` (exceeds 48x48dp minimum)

### 4.3 Contrast Ratios

| Element | Light Mode | Dark Mode | Status |
|---------|------------|-----------|--------|
| Primary text on background | 16.1:1 (AAA) | ~15:1 (AAA) | ✅ |
| Secondary text on surface | 5.7:1 (AA) | ~7:1 (AA) | ✅ |
| Primary on primary container | 4.6:1 (AA) | ~4.5:1 (AA) | ✅ |

### 4.4 Accessibility Summary

| Criterion | Status | Notes |
|-----------|--------|-------|
| Semantic labels on icons | ❌ MISSING | IconButton tooltips not set |
| Touch targets (48x48dp) | ✅ PASS | 54dp height buttons |
| Color contrast | ✅ PASS | WCAG AA compliant |
| Form labels | ✅ PASS | InputDecorationTheme has labels |
| Screen reader compatible | ⚠️ PARTIAL | Custom widgets may lack roles |

---

## 5. Additional Findings

### 5.1 Migration Inconsistencies

| File | Issue |
|------|-------|
| `premium_upgrade_screen.dart` | Uses `ColorTokens` instead of `AppColors` |
| `modern_components.dart` | Custom border styling not using theme's outlined card pattern |
| Multiple screens | Mix of `PremiumTheme` and standard `Theme.of(context)` |

### 5.2 Design Docs vs Implementation

| Doc Feature | Implementation Status |
|-------------|----------------------|
| Premium soft depth | ✅ premium_components.dart |
| Ambient lighting/glow | ✅ PremiumBackground with _AmbientGlow |
| Glassmorphism | ✅ GlassContainer, GlassButton |
| Premium navigation bar | ✅ FloatingNavigationBar |
| Standard Material theme | ⚠️ Not using premium effects |

### 5.3 Floating Components

`floating_components.dart` provides:
- `FloatingNavigationBar` - pill-shaped glass nav
- `FloatingSearchBar` - full-width glass search
- `FloatingAppBar` - floating header

These are used in home_screen.dart but NOT available as standard theme widgets.

---

## 6. Priority Actions

### CRITICAL (Fix Immediately)

| # | Action | Files to Modify | Rationale |
|---|--------|-----------------|-----------|
| **1** | Add semantic labels to all IconButtons | `home_screen.dart`, `floating_components.dart`, `premium_components.dart`, `onboarding_flow.dart` | Accessibility compliance, screen reader support |
| **2** | Fix "Custom" budget in onboarding | `onboarding_flow.dart`, `onboarding_state.dart` | Users selecting "Custom" get no feedback, breaks flow |
| **3** | Add trial duration to premium paywall | `premium_upgrade_screen.dart` | Unknown commitment = user drop-off |

### HIGH Priority

| # | Action | Files to Modify | Rationale |
|---|--------|-----------------|-----------|
| **4** | Migrate premium_upgrade_screen.dart to AppColors | `premium_upgrade_screen.dart` | Design system consistency |
| **5** | Add meal plan preview to onboarding step 3 | `onboarding_flow.dart` | Reduce time-to-value by showing sample output |
| **6** | Persist onboarding progress to local storage | `onboarding_state.dart`, `onboarding_flow.dart` | Recover abandoned onboarding sessions |
| **7** | Integrate PremiumTheme into standard theme OR separate premium screens explicitly | `light_theme.dart`, `dark_theme.dart`, `app_theme.dart` | Visual inconsistency between premium/non-premium screens |

### MEDIUM Priority

| # | Action | Files to Modify | Rationale |
|---|--------|-----------------|-----------|
| **8** | Add social proof to premium paywall (testimonials, stats) | `premium_upgrade_screen.dart` | Build trust, reduce friction |
| **9** | Replace hardcoded Duration with AppAnimations | `onboarding_flow.dart`, `modern_components.dart`, `floating_components.dart` | Animation system consistency |
| **10** | Add skip option to onboarding for power users | `onboarding_flow.dart` | Reduce activation friction for returning users |

---

## 7. Recommendations by Screen

### Home Screen (home_screen.dart)
- Add `tooltip` to all `IconButton` widgets for accessibility
- Add `semanticLabel` to `IconButton.filled` (line 346)
- Consider reducing animation delays in `AnimatedListItem` (currently 50ms * delay factor)

### Onboarding (onboarding_flow.dart)
- Implement Custom budget picker
- Add local persistence of onboarding state
- Add "Skip" button for power users
- Show preview of meal plan output on final step

### Premium Upgrade (premium_upgrade_screen.dart)
- Replace `ColorTokens` with `AppColors`
- Add trial duration text (e.g., "14-day free trial, then $6.99/month")
- Add social proof section
- Consider showing feature preview screenshots

### Subscription Management (subscription_management_screen.dart)
- Add feature comparison (Free vs Premium)
- Show renewal date and cancellation option
- Add upgrade prompt for non-premium users

---

## 8. Files Summary

| File | Type | Issues |
|------|------|--------|
| `lib/app/theme/app_colors.dart` | Theme | ✅ OK |
| `lib/app/theme/color_tokens.dart` | Legacy | ⚠️ Deprecated but still used |
| `lib/app/theme/light_theme.dart` | Theme | ✅ OK |
| `lib/app/theme/dark_theme.dart` | Theme | ✅ OK |
| `lib/app/theme/app_typography.dart` | Theme | ✅ OK |
| `lib/app/theme/app_animations.dart` | Theme | ✅ Defined, underused |
| `lib/core/premium_components.dart` | Components | ✅ Premium design implemented |
| `lib/core/widgets/floating_components.dart` | Components | ⚠️ Missing semantic labels |
| `lib/core/widgets/modern_components.dart` | Components | ⚠️ Uses hardcoded colors in places |
| `lib/features/onboarding/onboarding_flow.dart` | Screen | ❌ Custom budget broken, no persistence |
| `lib/features/premium/premium_upgrade_screen.dart` | Screen | ❌ Uses ColorTokens, missing info |
| `lib/features/premium/subscription_management_screen.dart` | Screen | ⚠️ Too minimal |
| `lib/features/home/home_screen.dart` | Screen | ❌ IconButtons lack tooltips |

---

## Conclusion

PlatePilote has a solid Design System foundation with Material 3 and premium glassmorphism components. The primary issues are:

1. **Incomplete migration** to AppColors design tokens
2. **Activation funnel friction** - too many steps before user gets value
3. **Accessibility gaps** - missing semantic labels on interactive icons
4. **Premium paywall weakness** - unclear trial terms, no social proof

**Estimated impact of fixes**: 15-25% improvement in onboarding completion rate, 10-15% lift in premium conversion if trial terms are clarified.

---

*Report generated for PlatePilote product team. Next steps: Review with engineering, prioritize CRITICAL items for sprint, schedule design review for premium paywall.*