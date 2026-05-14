import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/radius.dart';
import '../../core/extensions/theme_extensions.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({this.height = 18, this.width, super.key});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.isDark
            ? ColorTokens.darkElevatedSurface
            : ColorTokens.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
  }
}
