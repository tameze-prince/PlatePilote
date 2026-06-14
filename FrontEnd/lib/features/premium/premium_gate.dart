import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../premium/subscription_provider.dart';

/// Widget qui gate l'accès à une feature Premium.
///
/// - [child] est affiché si l'utilisateur est Premium.
/// - Si non-Premium et [showUpgrade]=true → affiche un banner cliquable de CTA.
/// - Si non-Premium et [showUpgrade]=false → cache le contenu (`SizedBox.shrink`).
///
/// Au lieu de cacher brutalement une feature, on la prévisualise avec un
/// overlay de cadenas + bouton "Débloquer". L'utilisateur gratuit voit
/// l'EXISTENCE de la feature (puissant pour upsell).
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.child,
    this.showUpgrade = true,
    this.blurBackground = true,
    this.message,
  });

  /// Contenu gated.
  final Widget child;

  /// Afficher le bloc de CTA ou simplement cacher.
  final bool showUpgrade;

  /// Flouter le contenu non-Premium pour teaser visuellement.
  final bool blurBackground;

  /// Message personnalisé affiché sur le banner (ex: "Analyses avancées").
  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFFFFB300); // or premium

    // Premium user : render direct
    if (sub.isPremium) {
      return child;
    }

    // Free user : teaser + CTA
    return Stack(
      children: [
        // Contenu bluré en arrière-plan (teaser)
        if (blurBackground)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.18,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0, //
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
                  child: child,
                ),
              ),
            ),
          ),

        // CTA banner
        if (showUpgrade)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Material(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                elevation: 6,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => context.push('/premium-upgrade'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.08),
                          accent.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: accent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message ?? 'Fonctionnalité Premium',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Débloquez cette section avec PlatePilote Premium.\n7 jours gratuits, sans engagement.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => context.push('/premium-upgrade'),
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Voir les offres'),
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
