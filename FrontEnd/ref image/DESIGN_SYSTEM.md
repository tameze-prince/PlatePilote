# PlatePilot Design System

## Overview
A comprehensive Material 3-based design system for PlatePilot, designed to create a cohesive, accessible, and delightful user experience across all platforms.

## Design Philosophy
- **Clarity**: Every element serves a purpose
- **Consistency**: Unified patterns across all screens
- **Accessibility**: WCAG 2.1 AA compliant
- **Delight**: Subtle animations and micro-interactions
- **Performance**: Optimized for smooth 60fps experience

## Color System

### Primary Palette
| Role | Light | Dark | Usage |
|------|-------|------|-------|
| Primary | `#006E2F` | `#22C55E` | Main brand color, primary actions |
| Primary Container | `#22C55E` (10%) | `#006E2F` (20%) | Selected states, highlights |
| On Primary | `#FFFFFF` | `#0B1220` | Text on primary backgrounds |

### Secondary Palette
| Role | Light | Dark | Usage |
|------|-------|------|-------|
| Secondary | `#F59E0B` | `#FBBF24` | Warnings, savings, highlights |
| Tertiary | `#3B82F6` | `#3B82F6` | Info, secondary actions |

### Functional Colors
| Role | Value | Usage |
|------|-------|-------|
| Success | `#22C55E` | Positive feedback, completed states |
| Warning | `#F59E0B` | Caution, expiring items |
| Error | `#EF4444` | Errors, destructive actions |
| Info | `#3B82F6` | Informational messages |

### Surface Colors
| Role | Light | Dark | Usage |
|------|-------|------|-------|
| Background | `#F8FAFC` | `#0B1220` | App background |
| Surface | `#FFFFFF` | `#111827` | Cards, dialogs |
| Surface Container Low | `#F1F5F9` | `#111827` | Inputs, subtle backgrounds |
| Surface Container | `#E8F0E4` | `#1F2937` | Medium emphasis |
| Surface Container High | `#E2EBDE` | `#2A3441` | High emphasis |

### Text Colors
| Role | Light | Dark | Usage |
|------|-------|------|-------|
| On Background | `#0F172A` | `#F8FAFC` | Primary text |
| On Surface Variant | `#64748B` | `#9CA3AF` | Secondary text |

### Category Colors
| Category | Color | Usage |
|----------|-------|-------|
| Produce | `#22C55E` | Fruits, vegetables |
| Protein | `#3B82F6` | Meat, fish, eggs |
| Dairy | `#F59E0B` | Milk, cheese, yogurt |
| Pantry | `#8B5CF6` | Grains, spices |
| Beverages | `#EC4899` | Drinks |
| Snacks | `#F97316` | Snacks |
| Frozen | `#06B6D4` | Frozen items |

## Typography

### Font Family
- **Primary**: System default (San Francisco on iOS, Roboto on Android)
- **Fallback**: Inter (loaded via Google Fonts)

### Type Scale
| Style | Size | Weight | Letter Spacing | Line Height | Usage |
|-------|------|--------|----------------|-------------|-------|
| Display Large | 32px | 800 | -0.5 | 1.2 | Hero text, major announcements |
| Display Medium | 28px | 700 | -0.3 | 1.2 | Screen titles |
| Display Small | 24px | 700 | -0.2 | 1.3 | Section headers |
| Headline Large | 22px | 700 | -0.1 | 1.3 | Card titles |
| Headline Medium | 20px | 600 | 0 | 1.3 | Subsection headers |
| Headline Small | 18px | 600 | 0 | 1.4 | Item titles |
| Title Large | 16px | 600 | 0 | 1.4 | List item titles |
| Title Medium | 14px | 600 | 0 | 1.4 | Chip labels |
| Title Small | 12px | 600 | 0.1 | 1.4 | Badges |
| Body Large | 16px | 400 | 0 | 1.5 | Paragraph text |
| Body Medium | 14px | 400 | 0 | 1.5 | Standard text |
| Body Small | 12px | 400 | 0.1 | 1.5 | Captions, hints |
| Label Large | 14px | 500 | 0.1 | 1.4 | Button text |
| Label Medium | 12px | 500 | 0.2 | 1.4 | Navigation labels |
| Label Small | 11px | 500 | 0.3 | 1.4 | Small labels |

## Spacing System

### Base Unit: 4px
| Token | Value | Usage |
|-------|-------|-------|
| xxxs | 2px | Micro spacing |
| xxs | 4px | Tight spacing |
| xs | 8px | Small spacing |
| sm | 12px | Compact spacing |
| md | 16px | Standard spacing |
| lg | 24px | Large spacing |
| xl | 32px | Extra large spacing |
| xxl | 48px | Section spacing |
| xxxl | 64px | Major section spacing |
| section | 80px | Page sections |

### Common Patterns
```dart
// Horizontal padding
AppSpacing.horizontal(value: AppSpacing.md)

// Vertical padding
AppSpacing.vertical(value: AppSpacing.lg)

// All around
AppSpacing.all(value: AppSpacing.md)

// Custom
AppSpacing.only(top: AppSpacing.lg, bottom: AppSpacing.md)
```

## Radius System

| Token | Value | Usage |
|-------|-------|-------|
| none | 0px | Sharp edges |
| xs | 4px | Small elements, checkboxes |
| sm | 8px | Chips, badges |
| md | 12px | Inputs, buttons |
| lg | 16px | Large buttons, FABs |
| xl | 24px | Cards, dialogs |
| xxl | 32px | Modals, bottom sheets |
| full | 9999px | Pills, avatars |

### Semantic Values
```dart
AppRadius.input    // 12px - Text inputs
AppRadius.button   // 16px - Buttons
AppRadius.card     // 24px - Cards
AppRadius.modal    // 32px - Modals
AppRadius.chip     // 8px  - Chips
AppRadius.badge    // full - Badges
AppRadius.avatar   // full - Avatars
```

## Elevation System

| Level | Value | Usage |
|-------|-------|-------|
| none | 0 | Flat elements |
| level1 | 1 | Cards, chips |
| level2 | 2 | Buttons, app bars |
| level3 | 3 | FABs, navigation |
| level4 | 4 | Dialogs, modals |
| level5 | 5 | Snackbars, tooltips |

### Shadow Formula
```dart
BoxShadow(
  color: Color(0x1A000000),
  blurRadius: elevation * 4,
  offset: Offset(0, elevation * 2),
  spreadRadius: elevation * -0.5,
)
```

## Animation System

### Durations
| Token | Value | Usage |
|-------|-------|-------|
| fast | 150ms | Micro-interactions, button press |
| normal | 300ms | Standard transitions, page transitions |
| slow | 500ms | Progress indicators, shimmer |
| verySlow | 800ms | Hero animations |

### Curves
| Token | Curve | Usage |
|-------|-------|-------|
| standard | `Curves.easeInOut` | Default transitions |
| decelerate | `Curves.easeOut` | Enter animations |
| accelerate | `Curves.easeIn` | Exit animations |
| elastic | `Curves.elasticOut` | Playful interactions |
| bounce | `Curves.bounceOut` | Success states |

## Component Guidelines

### Buttons
- **Primary**: Filled button with primary color
- **Secondary**: Outlined button with primary color
- **Tertiary**: Text button with primary color
- **Icon**: IconButton with rounded corners
- **Minimum height**: 54px
- **Padding**: 24px horizontal, 16px vertical

### Cards
- **Elevation**: Level 1
- **Border radius**: 24px
- **Border**: 1px outline with 50% opacity
- **Padding**: 16px
- **Margin**: 0 (handled by parent)

### Inputs
- **Fill color**: Surface container low
- **Border radius**: 12px
- **Border**: 1px outline
- **Focused border**: 2px primary
- **Padding**: 16px horizontal, 16px vertical
- **Minimum height**: 54px

### Chips
- **Background**: Surface container low
- **Selected**: Primary container
- **Border radius**: 8px
- **Border**: 1px outline with 50% opacity
- **Padding**: 12px horizontal, 6px vertical

### Navigation
- **Bottom navigation**: Fixed type, 80px height
- **Selected**: Primary color
- **Unselected**: On surface variant
- **Elevation**: Level 2

## Accessibility

### Contrast Ratios
- **Primary text on surface**: 16.1:1 (AAA)
- **Secondary text on surface**: 5.7:1 (AA)
- **Primary on primary container**: 4.6:1 (AA)
- **Error on surface**: 4.5:1 (AA)

### Touch Targets
- **Minimum size**: 48x48px
- **Spacing between targets**: 8px
- **Icon buttons**: 48x48px minimum

### Semantic Labels
- All icons must have semantic labels
- Form inputs must have associated labels
- Buttons must have descriptive text
- Images must have alt text

## Responsive Design

### Breakpoints
| Name | Width | Usage |
|------|-------|-------|
| Phone | < 600px | Single column, bottom navigation |
| Tablet | 600-840px | Two columns, optional side navigation |
| Desktop | > 840px | Three columns, side navigation |

### Adaptations
- **Phone**: Bottom navigation, single column layouts
- **Tablet**: Bottom or side navigation, two column layouts
- **Desktop**: Side navigation, three column layouts

## Best Practices

### Performance
- Use `const` constructors where possible
- Avoid rebuilding widgets unnecessarily
- Use `ListView.builder` for long lists
- Cache images and data
- Minimize animation complexity

### Code Organization
- Follow feature-first architecture
- Keep widgets small and focused
- Use providers for state management
- Separate business logic from UI
- Write tests for critical paths

### User Experience
- Provide feedback for all actions
- Use loading states for async operations
- Show error states with recovery options
- Use empty states with clear CTAs
- Implement pull-to-refresh where appropriate

## Migration Guide

### From Old System to New
1. Replace `ColorTokens` with `AppColors`
2. Replace `AppSpacing` constants with new values
3. Replace `AppRadius` constants with new values
4. Update text styles to use `AppTypography`
5. Update elevation to use `AppElevation`
6. Update animations to use `AppAnimations`

### Backward Compatibility
- Old tokens are still available via compatibility layer
- Gradually migrate to new system
- No breaking changes in current release

## Resources

### Figma Files
- Design system: [Link to Figma]
- Component library: [Link to Figma]
- Prototype: [Link to Figma]

### Code References
- Theme files: `lib/app/theme/`
- Color tokens: `lib/app/theme/app_colors.dart`
- Typography: `lib/app/theme/app_typography.dart`
- Spacing: `lib/app/theme/app_spacing.dart`
- Radius: `lib/app/theme/app_radius.dart`
- Elevation: `lib/app/theme/app_elevation.dart`
- Animations: `lib/app/theme/app_animations.dart`

## Version History

### v2.0.0 (Current)
- Complete Material 3 implementation
- New color system with semantic roles
- Updated typography scale
- New spacing system
- New radius system
- New elevation system
- New animation system
- Backward compatibility layer

### v1.0.0 (Previous)
- Initial design system
- Basic color tokens
- Simple spacing system
- Basic component styles
