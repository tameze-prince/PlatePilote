import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: ColorTokens.primaryGreen),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: context.text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: context.text.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
