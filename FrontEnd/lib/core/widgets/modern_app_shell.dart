import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_elevation.dart';

/// Shell d'application moderne avec navigation, barre et tiroir.
class ModernAppShell extends StatefulWidget {
  const ModernAppShell({
    required this.navigationShell,
    required this.appBar,
    required this.floatingActionButton,
    required this.drawer,
    super.key,
  });

  final Widget navigationShell;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;

  @override
  State<ModernAppShell> createState() => _ModernAppShellState();
}

class _ModernAppShellState extends State<ModernAppShell>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: widget.appBar,
      drawer: widget.drawer,
      body: FadeTransition(
        opacity: _animation,
        child: widget.navigationShell,
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        boxShadow: AppElevation.navigationBarShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                isDark: isDark,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                isSelected: true,
              ),
              _buildNavItem(
                context: context,
                isDark: isDark,
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month,
                label: 'Plan',
                isSelected: false,
              ),
              _buildNavItem(
                context: context,
                isDark: isDark,
                icon: Icons.shopping_cart_outlined,
                selectedIcon: Icons.shopping_cart,
                label: 'Grocery',
                isSelected: false,
              ),
              _buildNavItem(
                context: context,
                isDark: isDark,
                icon: Icons.kitchen_outlined,
                selectedIcon: Icons.kitchen,
                label: 'Pantry',
                isSelected: false,
              ),
              _buildNavItem(
                context: context,
                isDark: isDark,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Settings',
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected
        ? (isDark ? AppColors.primaryLight : AppColors.primary)
        : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant);
    
    return GestureDetector(
      onTap: () {
        // Navigation logic
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre d'application moderne avec recherche et notifications.
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ModernAppBar({
    this.title,
    this.leading,
    this.actions,
    this.showSearch = false,
    this.onSearchPressed,
    this.showNotifications = false,
    this.onNotificationsPressed,
    this.notificationCount,
    this.elevation,
    super.key,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showSearch;
  final VoidCallback? onSearchPressed;
  final bool showNotifications;
  final VoidCallback? onNotificationsPressed;
  final int? notificationCount;
  final double? elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: (isDark ? AppColors.darkSurface : AppColors.surface)
          .withValues(alpha: 0.95),
      foregroundColor: isDark
          ? AppColors.darkOnSurface
          : AppColors.onSurface,
      elevation: elevation ?? AppElevation.appBar,
      scrolledUnderElevation: AppElevation.appBar,
      centerTitle: false,
      leading: leading,
      title: title ?? Text(
        'PlatePilot',
        style: AppTypography.titleLarge.copyWith(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: onSearchPressed,
            tooltip: 'Rechercher',
            semanticsLabel: 'Rechercher',
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.onSurfaceVariant,
          ),
        if (showNotifications)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: onNotificationsPressed,
                tooltip: 'Notifications',
                semanticsLabel: 'Notifications',
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
              if (notificationCount != null && notificationCount! > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      notificationCount! > 9
                          ? '9+'
                          : notificationCount.toString(),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

/// Tiroir de navigation moderne avec profil et actions.
class ModernDrawer extends StatelessWidget {
  const ModernDrawer({
    required this.currentUser,
    required this.currentUserEmail,
    required this.onProfilePressed,
    required this.onSettingsPressed,
    required this.onHelpPressed,
    required this.onLogoutPressed,
    super.key,
  });

  final String currentUser;
  final String currentUserEmail;
  final VoidCallback onProfilePressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onHelpPressed;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark
                        ? AppColors.primaryContainer
                        : AppColors.primaryContainer,
                    child: Text(
                      currentUser.isNotEmpty
                          ? currentUser[0].toUpperCase()
                          : '?',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurface
                                : AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          currentUserEmail,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _buildDrawerItem(
                    context: context,
                    isDark: isDark,
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: onProfilePressed,
                  ),
                  _buildDrawerItem(
                    context: context,
                    isDark: isDark,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: onSettingsPressed,
                  ),
                  _buildDrawerItem(
                    context: context,
                    isDark: isDark,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: onHelpPressed,
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextButton.icon(
                onPressed: onLogoutPressed,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark
            ? AppColors.darkOnSurfaceVariant
            : AppColors.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark
              ? AppColors.darkOnSurface
              : AppColors.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
