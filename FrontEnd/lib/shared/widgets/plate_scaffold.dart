import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/premium_components.dart';
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
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FloatingHeader(
                title: title,
                leading: showBack
                    ? IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      )
                    : null,
                actions: [
                  ?trailing,
                  IconButton(
                    tooltip: 'Search',
                    onPressed: () => context.push('/search'),
                    icon: Icon(Icons.search, color: context.colors.primary),
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => context.push('/notifications'),
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }
}
