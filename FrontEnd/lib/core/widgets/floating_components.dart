import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_elevation.dart';

/// Floating navigation bar with blur effect
class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    this.destinations = const [],
    this.margin,
    this.blurSigma = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FloatingNavDestination> destinations;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: margin ??
          const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: (backgroundColor ??
                      (isDark
                          ? AppColors.darkSurface
                          : AppColors.surface))
                  .withOpacity(0.85),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? AppColors.darkOutline.withOpacity(0.3)
                        : AppColors.outline.withOpacity(0.3)),
                width: 1,
              ),
              boxShadow: elevation != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: elevation! * 4,
                        offset: Offset(0, elevation! * 2),
                        spreadRadius: elevation! * -0.5,
                      ),
                    ]
                  : AppElevation.navigationBarShadow,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    destinations.length,
                    (index) => _buildDestination(
                      context: context,
                      isDark: isDark,
                      destination: destinations[index],
                      isSelected: index == currentIndex,
                      onTap: () => onDestinationSelected(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestination({
    required BuildContext context,
    required bool isDark,
    required FloatingNavDestination destination,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected
        ? (isDark ? AppColors.primaryLight : AppColors.primary)
        : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant);
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected
                      ? destination.selectedIcon ?? destination.icon
                      : destination.icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Destination item for floating navigation bar
class FloatingNavDestination {
  const FloatingNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
  final Widget? badge;
}

/// Floating search bar with blur effect
class FloatingSearchBar extends StatefulWidget {
  const FloatingSearchBar({
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.margin,
    this.blurSigma = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.leading,
    this.trailing,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final Widget? leading;
  final Widget? trailing;

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: widget.margin ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: (widget.backgroundColor ??
                      (isDark
                          ? AppColors.darkSurface
                          : AppColors.surface))
                  .withOpacity(0.85),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: widget.borderColor ??
                    (isDark
                        ? AppColors.darkOutline.withOpacity(0.3)
                        : AppColors.outline.withOpacity(0.3)),
                width: 1,
              ),
              boxShadow: widget.elevation != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: widget.elevation! * 4,
                        offset: Offset(0, widget.elevation! * 2),
                        spreadRadius: widget.elevation! * -0.5,
                      ),
                    ]
                  : AppElevation.cardShadow,
            ),
            child: TextField(
              controller: _controller,
              onTap: widget.onTap,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant.withOpacity(0.6)
                      : AppColors.onSurfaceVariant.withOpacity(0.6),
                ),
                prefixIcon: widget.leading ??
                    Icon(
                      Icons.search_outlined,
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                suffixIcon: widget.trailing ??
                    (_controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: isDark
                                  ? AppColors.darkOnSurfaceVariant
                                  : AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => _controller.clear(),
                          )
                        : null),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating action button with blur effect
class FloatingButton extends StatelessWidget {
  const FloatingButton({
    required this.child,
    required this.onPressed,
    this.margin,
    this.blurSigma = 20.0,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.size = 56.0,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? elevation;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: margin ??
          const EdgeInsets.only(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Material(
            color: (backgroundColor ??
                    (isDark ? AppColors.primaryLight : AppColors.primary))
                .withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppRadius.full),
            elevation: elevation ?? AppElevation.fab,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: SizedBox(
                width: size,
                height: size,
                child: IconTheme(
                  data: IconThemeData(
                    color: foregroundColor ??
                        (isDark ? AppColors.darkBackground : Colors.white),
                    size: size * 0.45,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating app bar with blur effect
class FloatingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FloatingAppBar({
    this.title,
    this.leading,
    this.actions,
    this.blurSigma = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.margin,
    super.key,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final EdgeInsetsGeometry? margin;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: margin ??
          const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.sm,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: (backgroundColor ??
                      (isDark
                          ? AppColors.darkSurface
                          : AppColors.surface))
                  .withOpacity(0.85),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? AppColors.darkOutline.withOpacity(0.3)
                        : AppColors.outline.withOpacity(0.3)),
                width: 1,
              ),
              boxShadow: elevation != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: elevation! * 4,
                        offset: Offset(0, elevation! * 2),
                        spreadRadius: elevation! * -0.5,
                      ),
                    ]
                  : AppElevation.appBarShadow,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    if (leading != null) leading!,
                    Expanded(
                      child: title ??
                          Text(
                            'PlatePilot',
                            style: AppTypography.titleLarge.copyWith(
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
