import 'package:flutter/material.dart';

import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';

/// Shimmer-like skeleton loader that replaces the raw `shimmer` package
/// for new screens. Implementation is self-contained — no external
/// dependency.
class PpSkeleton extends StatefulWidget {
  const PpSkeleton({
    this.width,
    this.height = 16,
    this.radius = DsRadius.sm,
    super.key,
  });

  /// Width of the skeleton block. Defaults to filling available width.
  final double? width;

  /// Height of the skeleton block.
  final double height;

  /// Corner radius of the skeleton block.
  final double radius;

  @override
  State<PpSkeleton> createState() => _PpSkeletonState();
}

class _PpSkeletonState extends State<PpSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.02);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: base,
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2 * t, 0),
                end: Alignment(0.0 + 2 * t, 0),
                colors: [base, highlight, base],
                stops: const [0.35, 0.5, 0.65],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Convenience builder for a vertical list of skeletons — the most common
/// loading pattern in Pantry / Recipes / Grocery lists.
class PpSkeletonList extends StatelessWidget {
  const PpSkeletonList({
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = DsSpacing.md,
    this.padding,
    super.key,
  });

  /// Number of skeleton entries to render.
  final int itemCount;

  /// Builder for an individual skeleton row, receives the item index.
  final WidgetBuilder itemBuilder;

  /// Vertical gap between rows.
  final double spacing;

  /// Optional outer padding around the list.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            KeyedSubtree(
              key: ValueKey<int>(i),
              child: itemBuilder(context),
            ),
            if (i != itemCount - 1) SizedBox(height: spacing),
          ],
        ],
      ),
    );
  }
}
