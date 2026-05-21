import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/theme/app_animations.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_radius.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_typography.dart';

enum PremiumCardVariant { standard, elevated, glass, accent }

enum GlassButtonVariant { filled, outlined, ghost }

class PremiumTheme {
  const PremiumTheme._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? AppColors.darkBackground : AppColors.background;

  static Color surface(BuildContext context) =>
      isDark(context) ? AppColors.darkSurface : AppColors.surface;

  static Color elevatedSurface(BuildContext context) =>
      isDark(context) ? AppColors.darkElevatedSurface : AppColors.elevatedSurface;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AppColors.darkOnSurface : AppColors.onSurface;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;

  static Color textTertiary(BuildContext context) => isDark(context)
      ? AppColors.darkOnSurfaceTertiary
      : AppColors.onSurfaceTertiary;

  static Color border(BuildContext context) =>
      isDark(context) ? AppColors.darkOutline : AppColors.outline;

  static Color glass(BuildContext context, {bool elevated = false}) {
    if (isDark(context)) {
      return Colors.white.withOpacity(elevated ? 0.16 : 0.09);
    }
    return Colors.white.withOpacity(elevated ? 0.78 : 0.64);
  }

  static List<BoxShadow> softShadow(BuildContext context) {
    final dark = isDark(context);
    return [
      BoxShadow(
        color: Colors.black.withOpacity(dark ? 0.28 : 0.08),
        blurRadius: 30,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> floatingShadow(BuildContext context) {
    final dark = isDark(context);
    return [
      BoxShadow(
        color: Colors.black.withOpacity(dark ? 0.36 : 0.14),
        blurRadius: 40,
        offset: const Offset(0, 16),
      ),
      BoxShadow(
        color: AppColors.primaryAccentGreen.withOpacity(dark ? 0.12 : 0.08),
        blurRadius: 26,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> navbarShadow(BuildContext context) {
    final dark = isDark(context);
    return [
      BoxShadow(
        color: Colors.black.withOpacity(dark ? 0.35 : 0.14),
        blurRadius: 40,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(dark ? 0.18 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: AppColors.primaryAccentGreen.withOpacity(dark ? 0.15 : 0.08),
        blurRadius: 20,
        spreadRadius: -2,
      ),
    ];
  }

  static List<BoxShadow> glow(BuildContext context, {Color? color}) => [
        BoxShadow(
          color: (color ?? AppColors.primaryAccentGreen).withOpacity(
            isDark(context) ? 0.26 : 0.16,
          ),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ];

  static LinearGradient pageGradient(BuildContext context) {
    final dark = isDark(context);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dark
          ? const [
              AppColors.darkSecondaryBackground,
              AppColors.darkBackground,
              AppColors.darkBackground,
            ]
          : const [
              AppColors.background,
              AppColors.secondaryBackground,
              AppColors.background,
            ],
    );
  }
}

class PremiumBackground extends StatelessWidget {
  const PremiumBackground({
    required this.child,
    this.padding,
    this.safeArea = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final dark = PremiumTheme.isDark(context);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(gradient: PremiumTheme.pageGradient(context)),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _AmbientGlow(
              size: 260,
              color: dark
                  ? AppColors.premiumCyanAccent.withOpacity(0.12)
                  : AppColors.premiumCyanAccent.withOpacity(0.18),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -90,
            child: _AmbientGlow(
              size: 300,
              color: dark
                  ? AppColors.warmAccent.withOpacity(0.13)
                  : AppColors.primaryAccentGreen.withOpacity(0.12),
            ),
          ),
          child,
        ],
      ),
    );

    if (!safeArea) return content;
    return SafeArea(child: content);
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 46, sigmaY: 46),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.xl,
    this.blurSigma = 24,
    this.elevated = false,
    this.borderColor,
    this.backgroundColor,
    this.shadows,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final bool elevated;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ??
            (elevated
                ? PremiumTheme.floatingShadow(context)
                : PremiumTheme.softShadow(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  PremiumTheme.glass(context, elevated: elevated),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ??
                    (PremiumTheme.isDark(context)
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.82)),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    required this.child,
    this.variant = PremiumCardVariant.standard,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.borderRadius = AppRadius.xl,
    this.color,
    super.key,
  });

  final Widget child;
  final PremiumCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (variant == PremiumCardVariant.glass) {
      return GlassContainer(
        margin: margin,
        padding: padding,
        borderRadius: borderRadius,
        elevated: true,
        child: _Pressable(onTap: onTap, child: child),
      );
    }

    final dark = PremiumTheme.isDark(context);
    final surface = switch (variant) {
      PremiumCardVariant.standard => PremiumTheme.surface(context),
      PremiumCardVariant.elevated => PremiumTheme.elevatedSurface(context),
      PremiumCardVariant.accent => dark
          ? AppColors.primaryAccentGreen.withOpacity(0.14)
          : AppColors.primaryAccentGreen.withOpacity(0.09),
      PremiumCardVariant.glass => PremiumTheme.surface(context),
    };

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: variant == PremiumCardVariant.accent
            ? PremiumTheme.glow(context)
            : PremiumTheme.softShadow(context),
      ),
      child: Material(
        color: color ?? surface,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: variant == PremiumCardVariant.accent
                    ? AppColors.primaryAccentGreen.withOpacity(dark ? 0.22 : 0.18)
                    : PremiumTheme.border(context),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: AppAnimations.fast,
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.98 : 1,
        child: widget.child,
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = GlassButtonVariant.filled,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final filled = variant == GlassButtonVariant.filled;
    final outlined = variant == GlassButtonVariant.outlined;
    final foreground = filled
        ? (PremiumTheme.isDark(context) ? AppColors.darkBackground : Colors.white)
        : AppColors.primaryAccentGreen;
    final background = filled
        ? AppColors.primaryAccentGreen
        : PremiumTheme.glass(context, elevated: outlined);

    return SizedBox(
      width: expand ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: filled ? PremiumTheme.glow(context) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon ?? Icons.arrow_forward, size: 18),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: background,
                disabledBackgroundColor: background.withOpacity(0.45),
                foregroundColor: foreground,
                disabledForegroundColor: foreground.withOpacity(0.45),
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  side: BorderSide(
                    color: outlined
                        ? AppColors.primaryAccentGreen
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                textStyle: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassOutlinedButton extends StatelessWidget {
  const GlassOutlinedButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: GlassButtonVariant.outlined,
    );
  }
}

class GlassTextField extends StatelessWidget {
  const GlassTextField({
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    super.key,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.bodyLarge.copyWith(
            color: PremiumTheme.textPrimary(context),
          ),
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: PremiumTheme.glass(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: BorderSide(color: PremiumTheme.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: BorderSide(color: PremiumTheme.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: const BorderSide(
                color: AppColors.primaryAccentGreen,
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    required this.value,
    this.height = 8,
    super.key,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: PremiumTheme.isDark(context)
                ? Colors.white.withOpacity(0.12)
                : AppColors.outline,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 720),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * clamped,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.deepGreen,
                      AppColors.primaryAccentGreen,
                      AppColors.premiumCyanAccent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SelectableGlassCard extends StatelessWidget {
  const SelectableGlassCard({
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? (PremiumTheme.isDark(context) ? AppColors.darkBackground : Colors.white)
        : PremiumTheme.textPrimary(context);

    return AnimatedScale(
      duration: AppAnimations.fast,
      curve: Curves.easeOutCubic,
      scale: selected ? 1.02 : 1,
      child: GlassContainer(
        borderRadius: AppRadius.xl,
        backgroundColor: selected
            ? AppColors.primaryAccentGreen
            : PremiumTheme.glass(context, elevated: true),
        borderColor: selected
            ? AppColors.primaryAccentGreen
            : PremiumTheme.border(context),
        shadows:
            selected ? PremiumTheme.glow(context) : PremiumTheme.softShadow(context),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: padding,
            child: IconTheme(
              data: IconThemeData(color: foreground),
              child: DefaultTextStyle(
                style: AppTypography.bodyLarge.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlowBadge extends StatelessWidget {
  const GlowBadge({
    required this.label,
    this.icon,
    this.color = AppColors.primaryAccentGreen,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(PremiumTheme.isDark(context) ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.32)),
        boxShadow: PremiumTheme.glow(context, color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingHeader extends StatelessWidget {
  const FloatingHeader({
    required this.title,
    this.leading,
    this.actions = const [],
    this.subtitle,
    super.key,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppRadius.xxl,
      elevated: true,
      child: Row(
        children: [
          leading ??
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccentGreen,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: PremiumTheme.glow(context),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: PremiumTheme.isDark(context)
                      ? AppColors.darkBackground
                      : Colors.white,
                  size: 22,
                ),
              ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class GlassNavigationContainer extends StatelessWidget {
  const GlassNavigationContainer({
    required this.child,
    this.height = 74,
    super.key,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: PremiumTheme.navbarShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: PremiumTheme.isDark(context)
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.70),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: PremiumTheme.isDark(context)
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.85),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class FloatingBottomNavigation extends StatelessWidget {
  const FloatingBottomNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FloatingBottomDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: SizedBox(
            height: 80,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 74,
                  child: const GlassNavigationContainer(
                    height: 74,
                    child: SizedBox.expand(),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      for (final entry in destinations.indexed)
                        Expanded(
                          child: Center(
                            child: _FloatingNavItem(
                              destination: entry.$2,
                              selected: entry.$1 == currentIndex,
                              onTap: () =>
                                  onDestinationSelected(entry.$1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingBottomDestination {
  const FloatingBottomDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
}

class _FloatingNavItem extends StatefulWidget {
  const _FloatingNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final FloatingBottomDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selectedForeground =
        PremiumTheme.isDark(context) ? AppColors.darkBackground : Colors.white;
    final color = widget.selected
        ? selectedForeground
        : PremiumTheme.textSecondary(context).withOpacity(0.78);

    return Tooltip(
      message: widget.destination.label,
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.destination.label,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedSlide(
            duration: AppAnimations.normal,
            curve: Curves.easeOutCubic,
            offset: widget.selected ? const Offset(0, -0.10) : Offset.zero,
            child: AnimatedScale(
              duration: AppAnimations.normal,
              curve: Curves.easeOutCubic,
              scale: _pressed ? 0.92 : (widget.selected ? 1.0 : 1.0),
              child: AnimatedContainer(
                duration: AppAnimations.normal,
                curve: Curves.easeOutCubic,
                width: widget.selected ? 64 : 52,
                height: widget.selected ? 64 : 52,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? AppColors.primaryAccentGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: widget.selected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryAccentGreen
                                .withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.selected
                          ? widget.destination.selectedIcon ??
                              widget.destination.icon
                          : widget.destination.icon,
                      color: color,
                      size: widget.selected ? 24 : 22,
                    ),
                    if (widget.selected)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          widget.destination.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
