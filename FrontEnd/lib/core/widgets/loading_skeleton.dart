import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({this.height = 18, this.width, super.key});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark
        ? ColorTokens.darkElevatedSurface
        : ColorTokens.surfaceContainer;
    final highlightColor = context.isDark
        ? ColorTokens.darkBorder
        : ColorTokens.surfaceContainerHigh;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

class LoadingSkeletonCard extends StatelessWidget {
  const LoadingSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDark
          ? ColorTokens.darkElevatedSurface
          : ColorTokens.surfaceContainer,
      highlightColor: context.isDark
          ? ColorTokens.darkBorder
          : ColorTokens.surfaceContainerHigh,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
  }
}
