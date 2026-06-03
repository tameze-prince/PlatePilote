import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../core/premium_components.dart';

/// Squelette d'affichage avec effet shimmer et verre.
class ShimmerGlassSkeleton extends StatefulWidget {
  const ShimmerGlassSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  /// Largeur du squelette.
  final double width;
  /// Hauteur du squelette.
  final double height;
  /// Rayon de bordure.
  final double? borderRadius;

  @override
  State<ShimmerGlassSkeleton> createState() => _ShimmerGlassSkeletonState();
}

class _ShimmerGlassSkeletonState extends State<ShimmerGlassSkeleton>
    with SingleTickerProviderStateMixin {
  /// Contrôleur d'animation du shimmer.
  late final AnimationController _controller;
  /// Animation du gradient.
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = PremiumTheme.isDark(context);
    final baseColor = isDark ? Colors.white : Colors.black;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value.clamp(0.0, 1.0);
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadius.lg),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor.withValues(alpha: 0.04),
                baseColor.withValues(alpha: 0.12),
                baseColor.withValues(alpha: 0.04),
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            blendMode: BlendMode.srcATop,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(widget.borderRadius ?? AppRadius.lg),
                color: baseColor.withValues(alpha: 0.05),
                border: Border.all(
                  color: baseColor.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
