import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';

class PlateScaffold extends StatelessWidget {
  const PlateScaffold({
    required this.title,
    required this.child,
    this.trailing,
    this.showBack = false,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: showBack
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: ColorTokens.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(title),
          ],
        ),
        actions: [
          ?trailing,
          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(Icons.search, color: context.colors.primary),
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: Icon(
              Icons.notifications_outlined,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: child,
          ),
        ),
      ),
    );
  }
}
