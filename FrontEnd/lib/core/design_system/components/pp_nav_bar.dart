import 'package:flutter/material.dart';

import '../../premium_components.dart';

/// Description of a single item in [PpNavBar].
class PpNavBarItem {
  const PpNavBarItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.route,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
  final String? route;
  final String? tooltip;
}

/// Adaptive, floating pill bottom navigation bar.
///
/// Backed by the existing [FloatingBottomNavigation] premium primitive so we
/// keep a single source of truth for the glass + pill look-and-feel while
/// the design system evolves. Use this in new screens in place of
/// `FloatingBottomNavigation` directly.
class PpNavBar extends StatelessWidget {
  const PpNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<PpNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final destinations = items
        .map(
          (item) => FloatingBottomDestination(
            icon: item.icon,
            label: item.label,
            selectedIcon: item.selectedIcon,
          ),
        )
        .toList(growable: false);

    return Semantics(
      container: true,
      label: 'Bottom navigation',
      child: FloatingBottomNavigation(
        currentIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: destinations,
      ),
    );
  }
}
