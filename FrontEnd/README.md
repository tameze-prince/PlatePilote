# PlatePilot Design System

##  A Modern Material 3 Design System for Flutter

A comprehensive, production-ready design system built for PlatePilot, designed to create cohesive, accessible, and delightful user experiences across all platforms.

## ✨ Features

- **Material 3 Compliant**: Full implementation of Material Design 3 guidelines
- **Theme-Aware**: Automatic light/dark mode support
- **Accessible**: WCAG 2.1 AA compliant
- **Performant**: Optimized for 60fps animations
- **Consistent**: Unified patterns across all screens
- **Extensible**: Easy to customize and extend

## 📦 Installation

The design system is already integrated into the PlatePilot project. No additional installation required.

## 🚀 Quick Start

### 1. Use Theme-Aware Colors
```dart
import 'package:plate_pilote/app/theme/app_colors.dart';

// Light mode: #006E2F, Dark mode: #22C55E
final color = Theme.of(context).colorScheme.primary;

// Or use direct colors
final primary = AppColors.primary;
final primaryLight = AppColors.primaryLight;
```

### 2. Use Typography
```dart
import 'package:plate_pilote/app/theme/app_typography.dart';

Text(
  'Hello World',
  style: AppTypography.headlineMedium.copyWith(
    fontWeight: FontWeight.w600,
  ),
)
```

### 3. Use Spacing
```dart
import 'package:plate_pilote/app/theme/app_spacing.dart';

Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: Text('Content'),
)
```

### 4. Use Radius
```dart
import 'package:plate_pilote/app/theme/app_radius.dart';

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.card),
  ),
  child: Text('Card'),
)
```

### 5. Use Modern Components
```dart
import 'package:plate_pilote/core/widgets/modern_components.dart';

ModernCard(
  title: 'Card Title',
  subtitle: 'Card subtitle',
  child: Text('Content'),
  onTap: () {},
)
```

## 📚 Documentation

- [Design System Guide](DESIGN_SYSTEM.md) - Complete design system documentation
- [Migration Guide](MIGRATION_GUIDE.md) - How to migrate from v1 to v2
- [Component Reference](lib/core/widgets/) - All available components

## 🎯 Design Principles

### Clarity
Every element serves a purpose. No decorative elements without function.

### Consistency
Unified patterns across all screens. Same interaction, same result.

### Accessibility
WCAG 2.1 AA compliant. Works for everyone.

### Delight
Subtle animations and micro-interactions that make the app feel alive.

### Performance
Optimized for smooth 60fps experience on all devices.

## 🏗️ Architecture

```
lib/
├── app/
│   └── theme/
│       ├── app_colors.dart      # Color system
│       ├── app_typography.dart  # Typography system
│       ├── app_spacing.dart     # Spacing system
│       ├── app_radius.dart      # Radius system
│       ├── app_elevation.dart   # Elevation system
│       ├── app_animations.dart  # Animation system
│       ├── light_theme.dart     # Light theme
│       ├── dark_theme.dart      # Dark theme
│       └── app_theme.dart       # Theme provider
├── core/
│   └── widgets/
│       ├── modern_components.dart  # Modern UI components
│       ├── modern_animations.dart  # Animated components
│       └── modern_app_shell.dart   # App shell components
└── features/
    └── design_system_demo/         # Demo screen
```

## 🎨 Color System

### Primary Palette
| Role | Light | Dark |
|------|-------|------|
| Primary | `#006E2F` | `#22C55E` |
| Primary Container | `#22C55E` (10%) | `#006E2F` (20%) |

### Secondary Palette
| Role | Light | Dark |
|------|-------|------|
| Secondary | `#F59E0B` | `#FBBF24` |
| Tertiary | `#3B82F6` | `#3B82F6` |

### Functional Colors
| Role | Value |
|------|-------|
| Success | `#22C55E` |
| Warning | `#F59E0B` |
| Error | `#EF4444` |
| Info | `#3B82F6` |

## 🔤 Typography

### Type Scale
| Style | Size | Weight |
|-------|------|--------|
| Display Large | 32px | 800 |
| Display Medium | 28px | 700 |
| Display Small | 24px | 700 |
| Headline Large | 22px | 700 |
| Headline Medium | 20px | 600 |
| Headline Small | 18px | 600 |
| Title Large | 16px | 600 |
| Title Medium | 14px | 600 |
| Title Small | 12px | 600 |
| Body Large | 16px | 400 |
| Body Medium | 14px | 400 |
| Body Small | 12px | 400 |
| Label Large | 14px | 500 |
| Label Medium | 12px | 500 |
| Label Small | 11px | 500 |

## 📐 Spacing System

### Base Unit: 4px
| Token | Value |
|-------|-------|
| xxxs | 2px |
| xxs | 4px |
| xs | 8px |
| sm | 12px |
| md | 16px |
| lg | 24px |
| xl | 32px |
| xxl | 48px |
| xxxl | 64px |
| section | 80px |

## 🔲 Radius System

| Token | Value | Usage |
|-------|-------|-------|
| none | 0px | Sharp edges |
| xs | 4px | Small elements |
| sm | 8px | Chips, badges |
| md | 12px | Inputs, buttons |
| lg | 16px | Large buttons |
| xl | 24px | Cards, dialogs |
| xxl | 32px | Modals |
| full | 9999px | Pills, avatars |

## 📊 Elevation System

| Level | Value | Usage |
|-------|-------|-------|
| none | 0 | Flat elements |
| level1 | 1 | Cards, chips |
| level2 | 2 | Buttons, app bars |
| level3 | 3 | FABs, navigation |
| level4 | 4 | Dialogs, modals |
| level5 | 5 | Snackbars, tooltips |

## 🎬 Animation System

### Durations
| Token | Value | Usage |
|-------|-------|-------|
| fast | 150ms | Micro-interactions |
| normal | 300ms | Standard transitions |
| slow | 500ms | Progress indicators |
| verySlow | 800ms | Hero animations |

### Curves
| Token | Curve | Usage |
|-------|-------|-------|
| standard | `Curves.easeInOut` | Default transitions |
| decelerate | `Curves.easeOut` | Enter animations |
| accelerate | `Curves.easeIn` | Exit animations |
| elastic | `Curves.elasticOut` | Playful interactions |
| bounce | `Curves.bounceOut` | Success states |

## 🧩 Components

### ModernCard
A versatile card component with optional header, badge, and actions.

```dart
ModernCard(
  title: 'Card Title',
  subtitle: 'Card subtitle',
  leading: Icon(Icons.eco),
  trailing: Icon(Icons.arrow_forward),
  badge: Badge(label: 'New'),
  child: Text('Card content'),
  onTap: () {},
)
```

### StatCard
A card for displaying metrics with icon, label, and value.

```dart
StatCard(
  icon: Icons.savings,
  label: 'Total Saved',
  value: '\$142.50',
  color: AppColors.primaryLight,
  onTap: () {},
)
```

### ProgressCard
A card with visual progress indicator.

```dart
ProgressCard(
  icon: Icons.account_balance_wallet,
  label: 'Weekly Budget',
  value: '\$256 / \$400',
  progress: 0.64,
  maxValue: 400,
)
```

### InfoCard
A card with icon, title, and description.

```dart
InfoCard(
  icon: Icons.eco,
  title: 'Pantry Optimization',
  description: 'Use what you have first',
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {},
)
```

### AlertCard
A card for warnings and notifications.

```dart
AlertCard(
  type: AlertType.success,
  title: 'Success',
  message: 'Operation completed',
  actions: [
    TextButton(
      onPressed: () {},
      child: Text('OK'),
    ),
  ],
)
```

### AnimatedButton
A button with press animation.

```dart
AnimatedButton(
  onPressed: () {},
  child: Text('Click Me'),
)
```

### AnimatedCard
A card with hover animation.

```dart
AnimatedCard(
  onTap: () {},
  child: Text('Hover me'),
)
```

### AnimatedListItem
A list item with slide-in animation.

```dart
AnimatedListItem(
  delay: index,
  child: ListTile(
    title: Text('Item $index'),
  ),
)
```

### AnimatedProgressIndicator
A progress indicator with smooth animation.

```dart
AnimatedProgressIndicator(
  value: 0.64,
  minHeight: 8,
)
```

### AnimatedCounter
A counter with smooth animation.

```dart
AnimatedCounter(
  value: 142.50,
  style: AppTypography.headlineSmall,
)
```

### AnimatedIconButton
An icon button with press animation.

```dart
AnimatedIconButton(
  icon: Icons.favorite,
  onPressed: () {},
)
```

## 🌗 Dark Mode

The design system automatically adapts to dark mode. All colors, surfaces, and text are theme-aware.

```dart
final theme = Theme.of(context);
final isDark = theme.brightness == Brightness.dark;

// Theme-aware color
final color = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
```

## ♿ Accessibility

### Contrast Ratios
- Primary text on surface: 16.1:1 (AAA)
- Secondary text on surface: 5.7:1 (AA)
- Primary on primary container: 4.6:1 (AA)
- Error on surface: 4.5:1 (AA)

### Touch Targets
- Minimum size: 48x48px
- Spacing between targets: 8px
- Icon buttons: 48x48px minimum

### Semantic Labels
- All icons have semantic labels
- Form inputs have associated labels
- Buttons have descriptive text
- Images have alt text

## 📱 Responsive Design

### Breakpoints
| Name | Width | Usage |
|------|-------|-------|
| Phone | < 600px | Single column, bottom navigation |
| Tablet | 600-840px | Two columns, optional side navigation |
| Desktop | > 840px | Three columns, side navigation |

## 🧪 Testing

### Visual Testing
- Run the app in both light and dark modes
- Check all screens for consistency
- Verify animations work smoothly
- Test on different screen sizes

### Accessibility Testing
- Check contrast ratios
- Verify touch target sizes
- Test with screen readers
- Check color blindness compatibility

### Performance Testing
- Monitor frame rates
- Check memory usage
- Verify animation smoothness
- Test on low-end devices

##  Contributing

1. Follow the design system guidelines
2. Use semantic values (spacing, radius, elevation)
3. Use theme-aware colors
4. Add animations where appropriate
5. Test in both light and dark modes
6. Ensure accessibility compliance

## 📝 License

This design system is part of the PlatePilot project and is proprietary.

## 🙏 Acknowledgments

- Material Design 3 guidelines
- Figma community designs
- Flutter team for the amazing framework

---

Built with ❤️ by the PlatePilot team
