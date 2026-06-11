import 'package:flutter/material.dart';

import '../../app/theme/app_animations.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Bouton animé avec effet de pression (scale à 0.95 au tap).
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (isDark ? AppColors.primaryLight : AppColors.primary),
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.button,
            ),
            boxShadow: widget.elevation != null
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: widget.elevation! * 2,
                      offset: Offset(0, widget.elevation!),
                    ),
                  ]
                : null,
          ),
          child: DefaultTextStyle(
            style: AppTypography.labelLarge.copyWith(
              color: widget.foregroundColor ??
                  (isDark ? AppColors.darkBackground : Colors.white),
              fontWeight: FontWeight.w600,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Carte animée avec effet de survol (scale à 1.02 au tap).
class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 1.0,
      end: (widget.elevation ?? 1.0) + 2.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    (isDark ? AppColors.darkSurface : AppColors.surface),
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? AppRadius.card,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: _elevationAnimation.value * 4,
                    offset: Offset(0, _elevationAnimation.value * 2),
                    spreadRadius: _elevationAnimation.value * -0.5,
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Élément de liste animé avec effet d'apparition par glissement.
class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    required this.child,
    this.delay = 0,
    this.direction = AxisDirection.down,
    super.key,
  });

  final Widget child;
  final int delay;
  final AxisDirection direction;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.listItem,
      vsync: this,
    );
    
    final offset = switch (widget.direction) {
      AxisDirection.up => const Offset(0, 0.2),
      AxisDirection.down => const Offset(0, -0.2),
      AxisDirection.left => const Offset(0.2, 0),
      AxisDirection.right => const Offset(-0.2, 0),
    };
    
    _slideAnimation = Tween<Offset>(
      begin: offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Indicateur de progression animé.
class AnimatedProgressIndicator extends StatefulWidget {
  const AnimatedProgressIndicator({
    required this.value,
    this.backgroundColor,
    this.valueColor,
    this.minHeight,
    this.borderRadius,
    super.key,
  });

  final double value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double? minHeight;
  final double? borderRadius;

  @override
  State<AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState
    extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.progress,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value.clamp(0.0, 1.0),
        end: widget.value.clamp(0.0, 1.0),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? AppRadius.xs,
      ),
      child: LinearProgressIndicator(
        value: _animation.value,
        backgroundColor: widget.backgroundColor ??
            (isDark
                ? AppColors.darkSurfaceContainerHigh
                : AppColors.surfaceContainerHigh),
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.valueColor ??
              (isDark ? AppColors.primaryLight : AppColors.primary),
        ),
        minHeight: widget.minHeight ?? 8,
      ),
    );
  }
}

/// Compteur animé avec transition fluide entre les valeurs.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    required this.value,
    this.style,
    this.duration,
    super.key,
  });

  final double value;
  final TextStyle? style;
  final Duration? duration;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.normal,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _formatValue(_animation.value),
          style: widget.style,
        );
      },
    );
  }

  String _formatValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

/// Bouton d'icône animé avec effets de pression et rotation.
class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
    this.padding,
    this.semanticsLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final String? semanticsLabel;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Semantics(
        label: widget.semanticsLabel ?? 'Bouton',
        button: true,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onPressed?.call();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                widget.icon,
                color: widget.color ??
                    (isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant),
                size: widget.size ?? 24,
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
