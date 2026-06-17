import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';

/// Squelette de chargement animé (shimmer) pour un élément.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({this.height = 18, this.width, super.key});

  /// Hauteur du squelette.
  final double height;

  /// Largeur du squelette (null = toute la largeur disponible).
  final double? width;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark
        ? AppColors.darkElevatedSurface
        : AppColors.surfaceContainer;
    final highlightColor = context.isDark
        ? AppColors.darkOutline
        : AppColors.surfaceContainerHigh;

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

/// Squelette de chargement pour une carte entière (shimmer).
class LoadingSkeletonCard extends StatelessWidget {
  const LoadingSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDark
          ? AppColors.darkElevatedSurface
          : AppColors.surfaceContainer,
      highlightColor: context.isDark
          ? AppColors.darkOutline
          : AppColors.surfaceContainerHigh,
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
