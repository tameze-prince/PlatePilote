# Migration Guide: PlatePilot Design System v2.0

## Overview
This guide helps you migrate from the old design system to the new Material 3-based design system.

## Breaking Changes

### 1. Color Tokens
**Old:**
```dart
import 'color_tokens.dart';
ColorTokens.primaryGreen
```

**New:**
```dart
import 'app_colors.dart';
AppColors.primaryLight
```

**Backward Compatibility:**
The old `ColorTokens` class still works but is deprecated. Migrate gradually.

### 2. Spacing
**Old:**
```dart
const EdgeInsets.all(AppSpacing.md)
```

**New:**
```dart
const EdgeInsets.all(AppSpacing.md) // Same values, new structure
```

**Note:** Values are the same, but the structure is now in `app_spacing.dart`.

### 3. Radius
**Old:**
```dart
BorderRadius.circular(AppRadius.card)
```

**New:**
```dart
BorderRadius.circular(AppRadius.card) // Same values, new structure
```

**Note:** Values are the same, but the structure is now in `app_radius.dart`.

### 4. Typography
**Old:**
```dart
context.text.headlineMedium
```

**New:**
```dart
AppTypography.headlineMedium
```

**Note:** Direct access to typography is now preferred over context extension.

### 5. Elevation
**Old:**
```dart
elevation: 2.0
```

**New:**
```dart
elevation: AppElevation.button
```

**Note:** Use semantic elevation values for consistency.

### 6. Animations
**Old:**
```dart
duration: Duration(milliseconds: 300)
```

**New:**
```dart
duration: AppAnimations.normal
```

**Note:** Use semantic animation durations for consistency.

## Step-by-Step Migration

### Step 1: Update Imports
Replace old imports with new ones:
```dart
// Old
import '../app/theme/color_tokens.dart';
import '../app/theme/spacing.dart';
import '../app/theme/radius.dart';

// New
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_radius.dart';
```

### Step 2: Update Color References
Replace color references:
```dart
// Old
ColorTokens.primaryGreen
ColorTokens.accentAmber

// New
AppColors.primaryLight
AppColors.secondary
```

### Step 3: Update Typography
Replace typography references:
```dart
// Old
context.text.headlineMedium?.copyWith(...)

// New
AppTypography.headlineMedium.copyWith(...)
```

### Step 4: Update Components
Replace old components with new ones:
```dart
// Old
AppCard(...)

// New
ModernCard(...)
```

### Step 5: Update Animations
Replace animation durations:
```dart
// Old
duration: Duration(milliseconds: 300)

// New
duration: AppAnimations.normal
```

## New Components

### ModernCard
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
```dart
AnimatedButton(
  onPressed: () {},
  child: Text('Click Me'),
)
```

### AnimatedCard
```dart
AnimatedCard(
  onTap: () {},
  child: Text('Hover me'),
)
```

### AnimatedListItem
```dart
AnimatedListItem(
  delay: index,
  child: ListTile(
    title: Text('Item $index'),
  ),
)
```

### AnimatedProgressIndicator
```dart
AnimatedProgressIndicator(
  value: 0.64,
  minHeight: 8,
)
```

### AnimatedCounter
```dart
AnimatedCounter(
  value: 142.50,
  style: AppTypography.headlineSmall,
)
```

### AnimatedIconButton
```dart
AnimatedIconButton(
  icon: Icons.favorite,
  onPressed: () {},
)
```

## Best Practices

### 1. Use Semantic Values
```dart
// Good
elevation: AppElevation.card
duration: AppAnimations.normal
borderRadius: AppRadius.card

// Bad
elevation: 2.0
duration: Duration(milliseconds: 300)
borderRadius: BorderRadius.circular(24)
```

### 2. Use Theme-Aware Colors
```dart
// Good
color: isDark ? AppColors.darkOnSurface : AppColors.onSurface

// Bad
color: Colors.black
```

### 3. Use Consistent Spacing
```dart
// Good
padding: const EdgeInsets.all(AppSpacing.md)
margin: const EdgeInsets.only(bottom: AppSpacing.sm)

// Bad
padding: const EdgeInsets.all(16)
margin: const EdgeInsets.only(bottom: 12)
```

### 4. Use Modern Components
```dart
// Good
ModernCard(...)
StatCard(...)
ProgressCard(...)

// Bad
Container(
  decoration: BoxDecoration(...),
  child: ...,
)
```

### 5. Use Animations
```dart
// Good
AnimatedButton(...)
AnimatedCard(...)
AnimatedListItem(...)

// Bad
GestureDetector(
  onTap: () {},
  child: Container(...),
)
```

## Testing

### 1. Visual Testing
- Run the app in both light and dark modes
- Check all screens for consistency
- Verify animations work smoothly
- Test on different screen sizes

### 2. Accessibility Testing
- Check contrast ratios
- Verify touch target sizes
- Test with screen readers
- Check color blindness compatibility

### 3. Performance Testing
- Monitor frame rates
- Check memory usage
- Verify animation smoothness
- Test on low-end devices

## Troubleshooting

### Issue: Colors look wrong
**Solution:** Ensure you're using theme-aware colors:
```dart
color: isDark ? AppColors.darkOnSurface : AppColors.onSurface
```

### Issue: Spacing looks inconsistent
**Solution:** Use the spacing system:
```dart
padding: const EdgeInsets.all(AppSpacing.md)
```

### Issue: Animations are janky
**Solution:** Use the animation system:
```dart
duration: AppAnimations.normal
```

### Issue: Components look outdated
**Solution:** Use modern components:
```dart
ModernCard(...)
```

## Resources

### Documentation
- Design System: `DESIGN_SYSTEM.md`
- Migration Guide: `MIGRATION_GUIDE.md`
- Component Reference: `lib/core/widgets/`

### Code Examples
- Demo Screen: `lib/features/design_system_demo/`
- Theme Files: `lib/app/theme/`
- Widget Library: `lib/core/widgets/`

### Support
- Figma Design: [Link to Figma]
- GitHub Issues: [Link to Issues]
- Team Chat: [Link to Chat]

## Version History

### v2.0.0 (Current)
- Complete Material 3 implementation
- New color system
- New typography system
- New spacing system
- New radius system
- New elevation system
- New animation system
- Modern components
- Backward compatibility layer

### v1.0.0 (Previous)
- Initial design system
- Basic color tokens
- Simple spacing system
- Basic component styles
