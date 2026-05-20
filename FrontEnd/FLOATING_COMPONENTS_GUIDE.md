# Floating Components Guide

## Overview
This guide explains how to use the new floating, transparent/blur components in PlatePilot.

## Floating Navigation Bar

### Usage
```dart
FloatingNavigationBar(
  currentIndex: 0,
  onDestinationSelected: (index) {
    // Handle navigation
  },
  destinations: const [
    FloatingNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    // ... more destinations
  ],
)
```

### Features
- **Blur Effect**: Uses `BackdropFilter` with configurable `blurSigma`
- **Transparent Background**: Semi-transparent with theme-aware colors
- **Rounded Corners**: Uses `AppRadius.xxl` for modern look
- **Animated Selection**: Smooth transitions between selected states
- **Customizable**: Margin, colors, elevation, blur intensity

### Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `currentIndex` | `int` | Required | Currently selected index |
| `onDestinationSelected` | `ValueChanged<int>` | Required | Callback when destination tapped |
| `destinations` | `List<FloatingNavDestination>` | Required | Navigation destinations |
| `margin` | `EdgeInsetsGeometry?` | `EdgeInsets.only(left: 16, right: 16, bottom: 16)` | Margin around nav bar |
| `blurSigma` | `double` | `20.0` | Blur intensity |
| `backgroundColor` | `Color?` | Theme-aware | Background color |
| `borderColor` | `Color?` | Theme-aware | Border color |
| `elevation` | `double?` | `2.0` | Elevation shadow |

## Floating Search Bar

### Usage
```dart
FloatingSearchBar(
  hintText: 'Search recipes, ingredients...',
  onChanged: (value) {
    // Handle search
  },
  onSubmitted: (value) {
    // Handle submit
  },
  onTap: () {
    // Handle tap
  },
)
```

### Features
- **Blur Effect**: Uses `BackdropFilter` with configurable `blurSigma`
- **Transparent Background**: Semi-transparent with theme-aware colors
- **Pill Shape**: Full rounded corners for modern look
- **Clear Button**: Auto-shows when text is entered
- **Customizable**: Leading/trailing icons, colors, elevation

### Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController?` | `null` | Text controller |
| `hintText` | `String?` | `'Search...'` | Hint text |
| `onChanged` | `ValueChanged<String>?` | `null` | Called when text changes |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Called when submitted |
| `onTap` | `VoidCallback?` | `null` | Called when tapped |
| `margin` | `EdgeInsetsGeometry?` | `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` | Margin |
| `blurSigma` | `double` | `20.0` | Blur intensity |
| `backgroundColor` | `Color?` | Theme-aware | Background color |
| `borderColor` | `Color?` | Theme-aware | Border color |
| `elevation` | `double?` | `1.0` | Elevation shadow |
| `leading` | `Widget?` | Search icon | Leading widget |
| `trailing` | `Widget?` | Clear button | Trailing widget |

## Floating Button

### Usage
```dart
FloatingButton(
  onPressed: () {
    // Handle press
  },
  child: Icon(Icons.add),
)
```

### Features
- **Blur Effect**: Uses `BackdropFilter` with configurable `blurSigma`
- **Transparent Background**: Semi-transparent with theme-aware colors
- **Circular Shape**: Full rounded corners
- **Animated**: Press animation with scale effect
- **Customizable**: Size, colors, elevation, margin

### Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | Required | Button content |
| `onPressed` | `VoidCallback?` | Required | Callback when pressed |
| `margin` | `EdgeInsetsGeometry?` | `EdgeInsets.only(right: 16, bottom: 16)` | Margin |
| `blurSigma` | `double` | `20.0` | Blur intensity |
| `backgroundColor` | `Color?` | Theme-aware primary | Background color |
| `foregroundColor` | `Color?` | Theme-aware | Foreground color |
| `borderColor` | `Color?` | `null` | Border color |
| `elevation` | `double?` | `3.0` | Elevation shadow |
| `size` | `double` | `56.0` | Button size |

## Floating App Bar

### Usage
```dart
FloatingAppBar(
  title: Text('PlatePilot'),
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {},
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
    ),
  ],
)
```

### Features
- **Blur Effect**: Uses `BackdropFilter` with configurable `blurSigma`
- **Transparent Background**: Semi-transparent with theme-aware colors
- **Rounded Corners**: Modern rounded app bar
- **Safe Area**: Respects system UI
- **Customizable**: Colors, elevation, margin

### Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `Widget?` | `'PlatePilot'` | App bar title |
| `leading` | `Widget?` | `null` | Leading widget |
| `actions` | `List<Widget>?` | `null` | Action widgets |
| `blurSigma` | `double` | `20.0` | Blur intensity |
| `backgroundColor` | `Color?` | Theme-aware | Background color |
| `borderColor` | `Color?` | Theme-aware | Border color |
| `elevation` | `double?` | `2.0` | Elevation shadow |
| `margin` | `EdgeInsetsGeometry?` | `EdgeInsets.only(left: 16, right: 16, top: 12)` | Margin |

## Integration Example

### Home Screen with Floating Components
```dart
Scaffold(
  backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
  body: CustomScrollView(
    slivers: [
      // Floating App Bar
      SliverToBoxAdapter(
        child: FloatingAppBar(
          title: Text('PlatePilot'),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
      
      // Floating Search Bar
      SliverToBoxAdapter(
        child: FloatingSearchBar(
          hintText: 'Search recipes, ingredients...',
          onTap: () => context.push('/search'),
        ),
      ),
      
      // Content
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Your content here
            ],
          ),
        ),
      ),
    ],
  ),
  // Floating Navigation Bar
  extendBody: true,
  bottomNavigationBar: FloatingNavigationBar(
    currentIndex: 0,
    onDestinationSelected: (index) {
      // Handle navigation
    },
    destinations: const [
      FloatingNavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Home',
      ),
      // ... more destinations
    ],
  ),
  // Floating Action Button
  floatingActionButton: FloatingButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

## Best Practices

### 1. Use `extendBody: true`
When using floating navigation bar, set `extendBody: true` on Scaffold to allow content to extend behind the nav bar.

### 2. Add Bottom Padding
Add bottom padding to content to account for floating nav bar:
```dart
Padding(
  padding: EdgeInsets.only(bottom: 100),
  child: // Your content
)
```

### 3. Use Theme-Aware Colors
The floating components automatically adapt to light/dark mode, but you can customize colors if needed.

### 4. Adjust Blur Intensity
The default `blurSigma` is 20.0, but you can adjust it based on your design needs:
- Lower values (10-15): Subtle blur
- Default (20): Standard blur
- Higher values (25-30): Strong blur

### 5. Combine with Modern Components
Use floating components with modern cards, buttons, and animations for a cohesive design.

## Migration from Old Components

### Old Navigation Bar
```dart
bottomNavigationBar: NavigationBar(
  selectedIndex: currentIndex,
  onDestinationSelected: (index) {},
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
  ],
)
```

### New Floating Navigation Bar
```dart
extendBody: true,
bottomNavigationBar: FloatingNavigationBar(
  currentIndex: currentIndex,
  onDestinationSelected: (index) {},
  destinations: const [
    FloatingNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
  ],
)
```

### Old Search Bar
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Search...',
    prefixIcon: Icon(Icons.search),
  ),
)
```

### New Floating Search Bar
```dart
FloatingSearchBar(
  hintText: 'Search...',
  onChanged: (value) {},
)
```

## Performance Tips

1. **Use `const` constructors** where possible
2. **Avoid rebuilding** floating components unnecessarily
3. **Use `AnimatedBuilder`** for smooth animations
4. **Test on low-end devices** to ensure smooth performance
5. **Monitor frame rates** during development

## Troubleshooting

### Issue: Blur effect not showing
**Solution**: Ensure you're using `BackdropFilter` correctly and the parent widget has a background.

### Issue: Content hidden behind nav bar
**Solution**: Add bottom padding to content and set `extendBody: true` on Scaffold.

### Issue: Colors not adapting to theme
**Solution**: Use theme-aware colors or set `backgroundColor` explicitly.

### Issue: Performance issues
**Solution**: Reduce `blurSigma` value or use simpler components on low-end devices.

## Resources

- [Floating Components Source](lib/core/widgets/floating_components.dart)
- [Design System Guide](DESIGN_SYSTEM.md)
- [Migration Guide](MIGRATION_GUIDE.md)
- [Demo Screen](lib/features/design_system_demo/design_system_demo_screen.dart)
