library;

import 'package:flutter/material.dart';
import '../../core/premium_components.dart';
import 'app_animations.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Signature Visuals — PlatePilote brand identity layer.
///
/// Ce fichier est la couche "signature forte" du design system. Il cohabite
/// avec `app_colors.dart` (palette standard) et `premium_components.dart`
/// (glass system). Les couleurs ici sont arbitrées par Henry Brand Book
/// (Sprint 7.2d) et Jade UI Designer.
///
/// Pour appliquer une signature visuelle dans un screen :
///   - importer ce fichier
///   - utiliser `SignatureColors.*` pour les couleurs ponctuelles
///   - utiliser `SignatureGradients.*` pour les backgrounds premium
///   - utiliser `SignatureMotion.*` pour les durations/curves
///   - utiliser `SignatureHeroBackground`, `SignatureCard`, `SignatureBadge`
///     pour des composants prêts-à-l'emploi
///
/// Design rationale (Jade UI) :
/// Les meal-kits dominent le marché avec des palettes prévisibles
/// (orange HelloFresh #FF4F00, blue Blue Apron, red Yummly, purple Mealime,
/// green Too Good To Go). Pour être mémorable, PlatePilote propose un
/// sous-espace chromatique "corail-safran" (chaud, gourmand, distinctif)
/// qui n'appartient ni au vert traditionnel (legacy) ni aux saturations
/// criardes des concurrents. Les valeurs ci-dessous sont une **proposition
/// de départ** — Henry Brand Book doit trancher en Sprint 7.2d.
// TODO(brand): arbitrer les valeurs hex par Henry Brand Book (Sprint 7.2d).
// TODO(brand): valider accessibilité WCAG AA des paires texte/fond.

// =============================================================================
// 1. Memorable signature colors
// =============================================================================

/// Couleurs signature mémorisables PlatePilote.
///
/// Deux teintes primaires propres à PlatePilote :
/// - `primarySunset` (corail chaud) — couleur d'accent principale
/// - `primaryBakedApple` (rouge-pomme cuit) — emphase secondaire
///
/// Les legacy (green, warmAccent, cyan) restent disponibles pour rétro-compat.
abstract final class SignatureColors {
  // -- Primaires signature --
  /// Corail chaud (signature #1). N'existe pas dans le paysage meal-kit.
  static const Color primarySunset = Color(0xFFFF7A59);

  /// Rouge pomme-cuit (signature #2). Distinctif, gourmand.
  static const Color primaryBakedApple = Color(0xFFE84545);

  // -- Secondaires signature --
  /// Safran doré, accent tertiaire chaleureux.
  static const Color midnightSaffron = Color(0xFFFFB627);

  /// Navy profond pour contrastes hero.
  static const Color oceanDeep = Color(0xFF1F2937);

  /// Gris ardoise, dégradé navy.
  static const Color oceanSlate = Color(0xFF374151);

  /// Blanc papier (off-white chaud). Plus chaleureux que #FFFFFF.
  static const Color paperWhite = Color(0xFFFFFBF7);

  /// Vert frais, conservé pour accents gamification (catégorie produits frais).
  static const Color freshPantry = Color(0xFF10B981);

  /// Vert clair, dégradé de freshPantry.
  static const Color freshMint = Color(0xFF34D399);

  // -- Legacy aliases (rétro-compat design system existant) --
  /// Vert accent principal existant avant refonte signature.
  static const Color legacyPrimaryGreen = AppColors.primaryAccentGreen;

  /// Orange chaud existant avant refonte signature.
  static const Color legacyWarmAccent = AppColors.warmAccent;

  /// Cyan premium existant avant refonte signature.
  static const Color legacyPremiumCyan = AppColors.premiumCyanAccent;

  /// Helper : retourne la couleur primaire signature selon le contexte.
  static Color primary(BuildContext context) => primarySunset;

  /// Helper : retourne la couleur d'emphase secondaire.
  static Color emphasis(BuildContext context) => primaryBakedApple;
}

// =============================================================================
// 2. Signature gradient chart
// =============================================================================

/// Gradients signature prêts à l'emploi. Activent un sous-espace chromatique
/// mémorable (corail → safran) cohérent avec les couleurs signature.
abstract final class SignatureGradients {
  /// Gradient signature principal : corail → safran (meal-time warm).
  static const LinearGradient sunsetMeal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SignatureColors.primarySunset, SignatureColors.midnightSaffron],
  );

  /// Gradient sombre hero : navy profond → ardoise.
  static const LinearGradient midnightSaffron = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SignatureColors.oceanDeep, SignatureColors.oceanSlate],
  );

  /// Gradient frais (catégories produits frais, stat gamification).
  static const LinearGradient freshPantry = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SignatureColors.freshPantry, SignatureColors.freshMint],
  );

  /// Gradient de bord supérieur subtil, idéal pour SignatureCard.
  static const LinearGradient cardTopEdge = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      SignatureColors.primarySunset,
      SignatureColors.midnightSaffron,
    ],
    stops: [0.0, 1.0],
  );

  /// Gradient signature vertical pour hero overlays.
  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xCC000000)],
  );

  /// Helper : retourne un gradient signature en fonction d'une clé sémantique.
  static LinearGradient byKey(String key) {
    switch (key) {
      case 'sunset':
        return sunsetMeal;
      case 'midnight':
        return midnightSaffron;
      case 'fresh':
        return freshPantry;
      case 'card-edge':
        return cardTopEdge;
      default:
        return sunsetMeal;
    }
  }
}

// =============================================================================
// 3. Signature motion tokens
// =============================================================================

/// Tokens motion signature. Encapsulent durées + courbes pour les animations
/// "hero", "settle", "page entry" et "haptic". Réutilisent [AppAnimations]
/// quand possible pour rester alignés avec le system.
abstract final class SignatureMotion {
  SignatureMotion._();

  /// Entrée bouncy (signature hero, celebration).
  static const Curve heroEase = Cubic(0.34, 1.56, 0.64, 1);
  static const Duration heroDuration = Duration(milliseconds: 720);

  /// Decay settle — stabilisation après entrée.
  static const Curve settle = Curves.easeOutCubic;
  static const Duration settleDuration = Duration(milliseconds: 320);

  /// Entrée de page — expo-out (sans overshoot).
  static const Curve pageEntry = Cubic(0.16, 1, 0.3, 1);
  static const Duration pageDuration = Duration(milliseconds: 480);

  /// Feedback haptique visuel — cycles sympathiques.
  static const Curve haptic = Curves.easeInOutCubic;
  static const Duration hapticDuration = Duration(milliseconds: 140);

  /// Pulse ambient — très subtil (hero backgrounds).
  static const Curve ambientPulse = Curves.easeInOut;
  static const Duration ambientPulseDuration = Duration(milliseconds: 2400);

  /// Helpers reduced-motion seamless : retourne la courbe linéaire si réduit.
  static Curve effectiveCurve({bool reduced = false}) =>
      reduced ? Curves.linear : pageEntry;

  /// Durée effective selon prefers-reduced-motion.
  static Duration effectiveDuration({bool reduced = false}) =>
      AppAnimations.effective(pageDuration, reduced: reduced);
}

// =============================================================================
// 4. Composite signature components
// =============================================================================

/// Widget hero background signature : gradient + overlay icon subtil +
/// pulse ambient. Ref. Linear / Notion / Vercel hero aesthetics.
class SignatureHeroBackground extends StatefulWidget {
  const SignatureHeroBackground({
    required this.child,
    this.gradient = SignatureGradients.sunsetMeal,
    this.icon = Icons.local_dining_outlined,
    this.height = 280,
    this.intensity = 0.18,
    this.enablePulse = true,
    super.key,
  });

  final Widget child;
  final LinearGradient gradient;
  final IconData icon;
  final double height;
  final double intensity;
  final bool enablePulse;

  @override
  State<SignatureHeroBackground> createState() =>
      _SignatureHeroBackgroundState();
}

class _SignatureHeroBackgroundState extends State<SignatureHeroBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SignatureMotion.ambientPulseDuration,
    );
    if (widget.enablePulse) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = PremiumTheme.isDark(context);
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient
          DecoratedBox(
            decoration: BoxDecoration(gradient: widget.gradient),
          ),
          // Discret icon overlay (blurred)
          if (widget.enablePulse)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return Center(
                  child: Opacity(
                    opacity: widget.intensity * (0.85 + 0.15 * t),
                    child: Icon(
                      widget.icon,
                      size: widget.height * 0.9,
                      color: dark ? Colors.black : Colors.white,
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Opacity(
                opacity: widget.intensity,
                child: Icon(
                  widget.icon,
                  size: widget.height * 0.9,
                  color: dark ? Colors.black : Colors.white,
                ),
              ),
            ),
          // Bottom overlay for legibility
          DecoratedBox(
            decoration: BoxDecoration(gradient: SignatureGradients.heroOverlay),
          ),
          // Content
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

// =============================================================================
// 5. SignatureCard et SignatureBadge
// =============================================================================

/// Carte signature : hérite de `PremiumCard` (design system glass) avec
/// gradient signature sur le bord supérieur + lueur ambiance.
class SignatureCard extends StatelessWidget {
  const SignatureCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.gradient = SignatureGradients.sunsetMeal,
    this.borderRadius = AppRadius.xl,
    this.glowIntensity = 0.16,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final double borderRadius;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: SignatureColors.primarySunset.withValues(
              alpha: glowIntensity,
            ),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            PremiumCard(
              padding: const EdgeInsets.only(top: 4),
              borderRadius: borderRadius,
              variant: PremiumCardVariant.glass,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Padding(padding: padding, child: child),
              ),
            ),
            // Gradient top edge
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: gradient),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Variante de `SignatureCard`.
enum SignatureShape { pill, circle }

/// Badge signature compact : gradient + texte (BETA, achievements, counts).
class SignatureBadge extends StatelessWidget {
  const SignatureBadge({
    required this.label,
    this.icon,
    this.gradient = SignatureGradients.sunsetMeal,
    this.shape = SignatureShape.pill,
    this.size = 36,
    super.key,
  });

  final String label;
  final IconData? icon;
  final LinearGradient gradient;
  final SignatureShape shape;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = shape == SignatureShape.pill
        ? BorderRadius.circular(AppRadius.full)
        : BorderRadius.circular(size);
    final isIconOnly = label.isEmpty && icon != null;
    final paddingH = isIconOnly ? (size * 0.25) : AppSpacing.md;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: SignatureColors.primarySunset.withValues(alpha: 0.22),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: size * 0.42, color: Colors.white),
            if (label.isNotEmpty) const SizedBox(width: 6),
          ],
          if (label.isNotEmpty)
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
        ],
      ),
    );
  }
}
