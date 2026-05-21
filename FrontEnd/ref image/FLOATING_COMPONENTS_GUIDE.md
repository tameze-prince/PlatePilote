# PlatePilot Premium UI/UX Redesign Master Prompt
## Mature Glassmorphism Design System + Premium SaaS Experience
### Target: Codex / GPT-5 / Qwen 3 / Gemini / Claude
### Project: PlatePilot Flutter Frontend
### Framework: Flutter 3.x + Material 3
### Objective: Transform PlatePilot into a world-class premium AI-powered consumer application

---

# 1. Mission

You are a world-class:

- Senior Product Designer
- Senior Flutter Engineer
- Mobile UX Specialist
- Design System Architect

Your mission is to completely refine and elevate the visual identity of PlatePilot into a mature, premium, emotionally reassuring, and production-ready mobile experience.

The application must feel:

- Premium
- Calm
- Intelligent
- Sophisticated
- Trustworthy
- Modern
- Emotionally reassuring
- Highly polished

The final product should visually compete with:

- Apple Health
- Arc Browser
- Linear
- Headspace
- Airbnb
- Notion Calendar

The interface must make users instantly feel:

> “PlatePilot intelligently takes care of my meals, groceries, budget, and pantry organization.”

---

# 2. Reference Images

Use the following images as the primary visual references.

## Authentication Reference
- `login_register screen.png`

## Floating Navigation Reference
- `navigation bar.png`

## Onboarding References
- `baording 1.png`
- `baording 2.png`
- `baording 3.png`

## Main App References
- `home .png`
- `plan_pantry_grocery.png`

---

# 3. Current UI Problems That Must Be Fixed

The current UI is modern but still feels:

- too flat,
- too uniform,
- too green,
- too concept-like,
- not mature enough,
- lacking emotional sophistication,
- lacking visual hierarchy,
- lacking premium depth.

The redesign must significantly improve:

- contrast,
- depth,
- lighting,
- hierarchy,
- spacing,
- visual sophistication,
- motion,
- emotional feel.

---

# 4. New Visual Direction

## Design Philosophy
### “Premium Soft Depth”

The UI must feel like:

- floating intelligent layers,
- calm premium software,
- soft futuristic elegance,
- emotionally reassuring productivity.

Avoid:
- gaming aesthetics,
- crypto dashboard aesthetics,
- overdesigned Dribbble concepts,
- excessive glass everywhere,
- overly futuristic neon interfaces.

---

# 5. Visual Maturity Requirements

The redesign must introduce:

- stronger visual hierarchy,
- richer contrast,
- layered depth,
- selective glassmorphism,
- premium spacing,
- controlled highlights,
- soft ambient lighting,
- emotional calmness.

The green color must become:
- an accent color,
- not the dominant surface color.

The interface should feel:
- mature,
- premium,
- stable,
- high-end,
- sophisticated.

---

# 6. Color System

## Background Layers

### Primary Background
```css
#020617
```

### Secondary Background
```css
#06162A
```

### Standard Surface
```css
#0F172A
```

### Elevated Surface
```css
#162033
```

### Glass Surface
```css
rgba(255,255,255,0.08)
```

---

# 7. Brand Colors

## Primary Accent Green
```css
#22C55E
```

## Deep Green
```css
#16A34A
```

## Premium Cyan Accent
```css
#67E8F9
```

## Warm Accent
```css
#F59E0B
```

---

# 8. Text Colors

## Primary Text
```css
#FFFFFF
```

## Secondary Text
```css
rgba(255,255,255,0.75)
```

## Tertiary Text
```css
rgba(255,255,255,0.50)
```

---

# 9. Typography

Use Inter throughout the application.

## Typography Scale

- Display → 32 Bold
- H1 → 28 Bold
- H2 → 24 SemiBold
- H3 → 20 SemiBold
- Body → 16 Regular
- Caption → 14 Regular
- Small → 12 Medium

---

# 10. Glassmorphism Strategy

Glassmorphism must NOT be applied everywhere.

Use it strategically only for:

- floating navigation,
- floating header,
- modals,
- onboarding action cards,
- elevated widgets.

---

# 11. Glass Surface Specifications

## Blur
Use `BackdropFilter`.

```dart
sigmaX: 20–30
sigmaY: 20–30
```

---

## Surface Opacity

### Light Glass
```css
0.08–0.12
```

### Elevated Glass
```css
0.14–0.18
```

---

## Borders

```css
rgba(255,255,255,0.08)
```

Thin subtle borders only.

---

# 12. Depth System

Create clear visual depth layers.

| Layer | Purpose |
|---|---|
| Background | Main dark canvas |
| Surface | Standard cards |
| Elevated Surface | Important widgets |
| Floating Glass | Navigation / Header |
| Glow Layer | Premium highlights |

---

# 13. Shadows & Lighting

## Soft Shadow

```css
0 8px 30px rgba(0,0,0,0.25)
```

## Floating Shadow

```css
0 12px 40px rgba(0,0,0,0.35)
```

## Premium Glow

```css
0 0 20px rgba(34,197,94,0.25)
```

---

# 14. Ambient Lighting

Add:
- soft radial gradients,
- subtle corner glow,
- background lighting layers,
- premium atmospheric depth.

The UI should never feel flat.

---

# 15. Authentication Screens

Use `login_register screen.png` as the exact visual foundation.

## Requirements

### Background
- soft dark gradient,
- subtle warm glow,
- atmospheric blur.

### Authentication Card
- centered floating glass panel,
- 32px radius,
- subtle reflections,
- premium depth.

### Social Buttons
- pill-shaped,
- soft translucent surfaces,
- premium hover/press effects.

### Input Fields
- floating glass fields,
- soft borders,
- premium spacing,
- subtle focus glow.

### Primary CTA
- large pill button,
- solid bright surface,
- premium depth.

### Footer Links
Minimal and elegant.

---

# 16. Floating Navigation Bar

Use `navigation bar.png` as the exact visual reference.

## Requirements

- floating above content,
- centered horizontally,
- transparent glass,
- heavy blur,
- premium shadows,
- soft glow,
- rounded pill shape.

## Active Item

- highlighted capsule,
- brighter surface,
- green accent,
- subtle glow.

## Inactive Items

- reduced opacity,
- elegant minimal style.

---

# 17. Floating Static Header

The header must use the same premium floating effect.

## Requirements

- fixed position,
- non-scrollable,
- transparent blur,
- subtle separation,
- elegant spacing.

## Content

- logo,
- title,
- action icons,
- optional notifications badge.

---

# 18. Onboarding Screens

Use:
- `baording 1.png`
- `baording 2.png`
- `baording 3.png`

## Selection Cards

Cards must:
- float visually,
- use subtle glass,
- have layered shadows,
- animate on selection.

## Selected State

- primary green fill,
- glow effect,
- scale animation,
- subtle bounce.

---

# 19. Onboarding Buttons

All onboarding buttons must visually match the floating navigation language.

## Continue Button

- green accent,
- premium glow,
- pill shape,
- elevated surface.

## Back Button

- transparent glass outline,
- subtle blur,
- green border.

---

# 20. Modern Progress Bar

The onboarding progress bar must be fully redesigned.

## Requirements

- capsule track,
- animated gradient fill,
- soft glow,
- shimmer effect optional,
- fluid motion.

## Animation

```dart
Duration: 600–900ms
Curve: Curves.easeOutCubic
```

The progress bar must feel:
- alive,
- fluid,
- modern,
- premium.

---

# 21. Cards & Widgets

All application cards must feel:
- elevated,
- premium,
- layered,
- breathable.

Avoid:
- flat cards,
- identical surfaces,
- uniform opacity everywhere.

Use:
- layered borders,
- subtle highlights,
- depth separation,
- premium spacing.

---

# 22. Home, Pantry, Grocery & Plan Screens

Apply the same premium visual language consistently.

## Important Widgets

- budget cards,
- pantry alerts,
- meal cards,
- grocery summaries,
- savings widgets,
- quick meal widgets

must visually stand out through:
- elevation,
- contrast,
- spacing,
- controlled highlights.

---

# 23. Motion System

The entire application must feel fluid and alive.

---

# 24. Screen Transitions

Use:
- fade transitions,
- subtle slide,
- soft spring motion.

## Duration

```dart
250–350ms
```

## Curves

```dart
Curves.easeOutCubic
Curves.easeInOut
```

---

# 25. Micro-Interactions

Add:
- press shrink,
- hover glow,
- soft scale feedback,
- loading shimmer,
- animated counters,
- subtle selection bounce.

---

# 26. Motion Philosophy

Animations must feel:
- calm,
- premium,
- soft,
- intelligent.

Never:
- flashy,
- exaggerated,
- gaming-like.

---

# 27. Reusable Flutter Components

Create reusable widgets:

- GlassContainer
- FloatingHeader
- FloatingBottomNavigation
- GlassButton
- GlassOutlinedButton
- GlassTextField
- AnimatedProgressBar
- SelectableGlassCard
- GlowBadge
- PremiumCard

---

# 28. Navigation Hierarchy

The UI must clearly emphasize:

1. Primary Action
2. Current Focus
3. Important Information
4. Secondary Actions

Avoid equal visual weight everywhere.

---

# 29. Accessibility

Ensure:

- WCAG AA contrast,
- minimum 44px touch targets,
- readable typography,
- dynamic text scaling,
- screen reader compatibility.

---

# 30. Performance Requirements

Maintain:
- 60 FPS minimum,
- optimized blur rendering,
- minimal repainting.

Use:
- `RepaintBoundary`,
- efficient animations,
- cached blur layers.

---

# 31. Recommended Flutter Packages

Use if necessary:

- flutter_animate
- animations
- glassmorphism
- blur
- lottie

---

# 32. Emotional Outcome

When users open PlatePilot they must instantly feel:

- “This app is premium.”
- “This app is trustworthy.”
- “This app is intelligently designed.”
- “This app reduces my stress.”
- “This app simplifies my life.”

---

# 33. Final Visual Goal


The final result must feel like:

> “Apple Health meets Linear meets Headspace for intelligent meal planning.”

The application should visually communicate:

- intelligence,
- calmness,
- optimization,
- reliability,
- premium quality.

# 34. Full Dual Theme System (MANDATORY)

The application MUST support:

- Dark Mode
- Light Mode
- System Theme Synchronization

The UI must feel premium in BOTH themes.

---

## Dark Mode Philosophy

Dark mode is the primary premium identity:
- immersive,
- atmospheric,
- glassmorphic,
- emotionally calm.

---

## Light Mode Philosophy

Light mode must feel:
- clean,
- breathable,
- intelligent,
- productivity-oriented,
- premium,
- modern SaaS.

Avoid:
- pure white everywhere,
- flat surfaces,
- sterile enterprise feeling.

---

## Light Theme Color System

### Primary Background
#F8FAFC

### Secondary Background
#EEF2F7

### Standard Surface
#FFFFFF

### Elevated Surface
#F9FBFD

### Primary Text
#0F172A

### Secondary Text
rgba(15,23,42,0.72)

### Tertiary Text
rgba(15,23,42,0.48)

### Glass Surface
rgba(255,255,255,0.65)

---

## Theme Architecture

Implement:

- ThemeData lightTheme
- ThemeData darkTheme
- ThemeMode.system

Persist user preference locally.

---

## Adaptive Components

All reusable widgets must automatically adapt:
- shadows,
- glow,
- borders,
- glass opacity,
- text colors,
- gradients,
- highlights.

No hardcoded colors allowed.

Use Material 3 ColorScheme everywhere.

---

## Light Mode Depth System

Even in light mode:
- maintain layered depth,
- soft ambient shadows,
- premium elevation,
- subtle gradients,
- calm visual hierarchy.

The UI must NEVER feel flat.

Above all:

> “PlatePilot feels like a world-class product I want to use every single day.”