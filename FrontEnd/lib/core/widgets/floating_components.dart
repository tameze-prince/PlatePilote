import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_elevation.dart';
import '../premium_components.dart';

/// Barre de navigation flottante avec effet de flou.
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

  /// Index de la destination sélectionnée.
  final int currentIndex;

  /// Callback lors de la sélection d'une destination.
  final ValueChanged<int> onDestinationSelected;

  /// Liste des destinations de navigation.
  final List<FloatingNavDestination> destinations;

  /// Marge extérieure du conteneur.
  final EdgeInsetsGeometry? margin;

  /// Intensité du flou.
  final double blurSigma;

  /// Couleur de fond personnalisée.
  final Color? backgroundColor;

  /// Couleur de bordure personnalisée.
  final Color? borderColor;

  /// Élévation optionnelle.
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return FloatingBottomNavigation(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final destination in destinations)
          FloatingBottomDestination(
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
            label: destination.label,
          ),
      ],
    );
  }

  // ignore: unused_element
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
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.1))
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

/// Élément de destination pour la barre de navigation flottante.
class FloatingNavDestination {
  const FloatingNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  /// Icône par défaut.
  final IconData icon;

  /// Libellé de la destination.
  final String label;

  /// Icône alternative lorsque sélectionné.
  final IconData? selectedIcon;

  /// Badge optionnel (ex: compteur de notifications).
  final Widget? badge;
}

/// Barre de recherche flottante avec effet de flou.
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

  /// Contrôleur de texte optionnel.
  final TextEditingController? controller;

  /// Texte indicatif.
  final String? hintText;

  /// Callback à chaque changement de texte.
  final ValueChanged<String>? onChanged;

  /// Callback à la soumission du texte.
  final ValueChanged<String>? onSubmitted;

  /// Callback au tap sur le champ.
  final VoidCallback? onTap;

  /// Marge extérieure.
  final EdgeInsetsGeometry? margin;

  /// Intensité du flou.
  final double blurSigma;

  /// Couleur de fond personnalisée.
  final Color? backgroundColor;

  /// Couleur de bordure personnalisée.
  final Color? borderColor;

  /// Élévation optionnelle.
  final double? elevation;

  /// Widget précédant le champ de recherche.
  final Widget? leading;

  /// Widget suivant le champ de recherche.
  final Widget? trailing;

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  late TextEditingController _controller;
  // ignore: unused_field
  final bool _isFocused = false;

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
                  .withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: widget.borderColor ??
                    (isDark
                        ? AppColors.darkOutline.withValues(alpha: 0.3)
                        : AppColors.outline.withValues(alpha: 0.3)),
                width: 1,
              ),
              boxShadow: widget.elevation != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                      ? AppColors.darkOnSurfaceVariant.withValues(alpha: 0.6)
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
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

/// Bouton d'action flottant avec effet de flou.
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

  /// Contenu du bouton.
  final Widget child;

  /// Callback au tap.
  final VoidCallback? onPressed;

  /// Marge extérieure.
  final EdgeInsetsGeometry? margin;

  /// Intensité du flou.
  final double blurSigma;

  /// Couleur de fond personnalisée.
  final Color? backgroundColor;

  /// Couleur du texte/icône.
  final Color? foregroundColor;

  /// Couleur de bordure personnalisée.
  final Color? borderColor;

  /// Élévation optionnelle.
  final double? elevation;

  /// Taille du bouton (largeur et hauteur).
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
                .withValues(alpha: 0.9),
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

/// Barre d'application flottante avec effet de flou.
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

  /// Titre affiché dans la barre.
  final Widget? title;

  /// Widget précédant le titre.
  final Widget? leading;

  /// Liste d'actions (icônes) affichées à droite.
  final List<Widget>? actions;

  /// Intensité du flou.
  final double blurSigma;

  /// Couleur de fond personnalisée.
  final Color? backgroundColor;

  /// Couleur de bordure personnalisée.
  final Color? borderColor;

  /// Élévation optionnelle.
  final double? elevation;

  /// Marge extérieure.
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
                  .withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? AppColors.darkOutline.withValues(alpha: 0.3)
                        : AppColors.outline.withValues(alpha: 0.3)),
                width: 1,
              ),
              boxShadow: elevation != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                    ?leading,
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
