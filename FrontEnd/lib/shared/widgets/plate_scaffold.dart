import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/premium_components.dart';
import '../../core/extensions/theme_extensions.dart';

/// Scaffold réutilisable avec header, recherche et notifications.
class PlateScaffold extends StatelessWidget {
  const PlateScaffold({
    required this.title,
    required this.child,
    this.trailing,
    this.showBack = false,
    super.key,
  });

  /// Titre affiché dans l'en-tête.
  final String title;
  /// Contenu principal de la page.
  final Widget child;
  /// Widget optionnel à droite du titre.
  final Widget? trailing;
  /// Affiche le bouton retour.
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
                        tooltip: 'Retour',
                        semanticLabel: 'Retour à la page précédente',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      )
                    : null,
                actions: [
                  ?trailing,
                  IconButton(
                    tooltip: 'Search',
                    semanticLabel: 'Rechercher',
                    onPressed: () => context.push('/search'),
                    icon: Icon(Icons.search, color: context.colors.primary),
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    semanticLabel: 'Voir les notifications',
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
