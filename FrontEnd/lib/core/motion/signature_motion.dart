library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_signature_visuals.dart';

// =============================================================================
// PlatePilot — Signature Motion
// =============================================================================
// Ce fichier constitue la couche "motion signature"PlatePilot: 6 sections.
// Il complète `SignatureMotion` (app_signature_visuals.dart:162) avec des
// widgets prêts-à-l'emploi (stagger, page transitions, haptics, liste,
// hero insight). Référence : Brand Book v1 §4.5 (Motion philosophy)
// + brief iris-motion Sprint 7.
//
// Authors: Iris Ng (design) + Dave (impl Flutter) — Sprint 7.2d
// =============================================================================

// =============================================================================
// 1. Motion Principles — Documentation inline
// =============================================================================

/// Quatre principes de motion PlatePilot.
///
/// 1. **Subhero** — Entrée bouncy (`SignatureMotion.heroEase`) sur les moments
///    signature (onboarding, plan generation, success). Durée 720 ms.
/// 2. **Settle** — Decay court (`Curves.easeOutCubic`) 320 ms qui suit toute
///    bouncy entry pour stabiliser l'écran.
/// 3. **Fast** — Tout le reste utilise `pageEntry` 480 ms expo-out, nerveux
///    sans overshoot.
/// 4. **Page entry** — Cubic(0.16, 1, 0.3, 1) — utilisé pour les transitions
///    inter-écrans et parallaxe contenu.
///
/// Trois anti-principes :
/// - Anti A : pas de bounce résiduel sans settle.
/// - Anti B : pas de duration > 720 ms hors onboarding.
/// - Anti C : pas de parallaxe / scale sans courbe (toujours via `pageEntry`).

// =============================================================================
// 2. SignatureStagger — Opacity + translate cumulé
// =============================================================================

/// Widget qui anime séquentiellement des enfants (children) avec stagger :
/// fade-in + slide-up cumulé. Le délais de chaque enfant =
/// `delay * staggerStep * index`.
///
/// Use case : révéler une liste de cards / sections dans un écran
/// d'onboarding ou un screen post-plan sans surcharger l'animation système.
class SignatureStagger extends StatefulWidget {
  const SignatureStagger({
    required this.children,
    this.delay = Duration.zero,
    this.staggerStep = const Duration(milliseconds: 55),
    this.duration = const Duration(milliseconds: 320),
    this.curve = Curves.easeOutCubic,
    this.translateY = 16,
    super.key,
  });

  final List<Widget> children;
  final Duration delay;
  final Duration staggerStep;
  final Duration duration;
  final Curve curve;
  final double translateY;

  @override
  State<SignatureStagger> createState() => _SignatureStaggerState();
}

class _SignatureStaggerState extends State<SignatureStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration + widget.staggerStep * widget.children.length,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future<void>.delayed(widget.delay);
      if (!mounted) return;
      await _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final effectiveCurve = reduced ? Curves.linear : widget.curve;
    final children = widget.children;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(children.length, (i) {
        final intervalStart = i / children.length;
        final intervalEnd = (i + 1) / children.length;
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(intervalStart, intervalEnd, curve: effectiveCurve),
        );
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: reduced ? 1.0 : animation.value,
              child: Transform.translate(
                offset: Offset(
                  0,
                  reduced ? 0 : widget.translateY * (1 - animation.value),
                ),
                child: child,
              ),
            );
          },
          child: children[i],
        );
      }),
    );
  }
}

// =============================================================================
// 3. SignaturePageTransitions — captionUp + parallaxSlide
// =============================================================================

/// Transitions signature inter-pages PlatePilote.
///
/// Deux transitions natives :
/// - `captionUp` : la nouvelle page monte avec une courbe expo-out, associée
///   à un léger parallaxe vertical du contenu.
/// - `parallaxSlide` : la nouvelle page glisse latéralement avec un parallaxe
///   horizontal du background (effet depth léger).
abstract final class SignaturePageTransitions {
  const SignaturePageTransitions._();

  /// Builds the **captionUp** transition — new page slides up with content parallax.
  static Widget captionUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final curved = CurvedAnimation(
      parent: animation,
      curve: reduced ? Curves.linear : SignatureMotion.pageEntry,
      reverseCurve: reduced ? Curves.linear : Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(
        opacity: curved,
        child: child,
      ),
    );
  }

  /// Builds the **parallaxSlide** transition — horizontal slide + bg parallax.
  static Widget parallaxSlide(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final curved = CurvedAnimation(
      parent: animation,
      curve: reduced ? Curves.linear : SignatureMotion.pageEntry,
    );
    final reverse = CurvedAnimation(
      parent: secondaryAnimation,
      curve: reduced ? Curves.linear : Curves.easeOutCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.18, 0),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(
        opacity: curved,
        child: AnimatedBuilder(
          animation: reverse,
          builder: (context, c) {
            return Transform.translate(
              offset: Offset(-0.08 * reverse.value, 0),
              child: c,
            );
          },
          child: child,
        ),
      ),
    );
  }
}

// =============================================================================
// 4. SignatureHaptics — PlatePilotHapticKind enum + fire()
// =============================================================================

/// Enum des types de retour haptique PlatePilot.
///
/// Aligné sur les moments signature reconnus dans le Brand Book §4.5.
enum PlatePilotHapticKind {
  /// Tap léger sur CTA standard (button press).
  tapLight,

  /// Tap appuyé sur CTA hero (onboarding, "Generate plan").
  tapMedium,

  /// Confirmation de plan généré ou liste de courses prête.
  success,

  /// Subtile signal d'attention (nouveau plan prêt, alerter doucement).
  attention,

  /// Sélection d'un repas dans une liste de propositions.
  selection,

  /// Annulation ou back-step (rare,érogeable).
  cancel,
}

/// Helper global pour déclencher un feedback haptique depuis n'importe quel
/// point du code UI PlatePilot.
abstract final class SignatureHaptics {
  const SignatureHaptics._();

  /// Émet un feedback haptique selon le `kind`. Résilient : ignore les
  /// plateformes sans support haptique (sans throw).
  static Future<void> fire(PlatePilotHapticKind kind) async {
    switch (kind) {
      case PlatePilotHapticKind.tapLight:
        return HapticFeedback.selectionClick();
      case PlatePilotHapticKind.tapMedium:
        return HapticFeedback.lightImpact();
      case PlatePilotHapticKind.success:
        return HapticFeedback.mediumImpact();
      case PlatePilotHapticKind.attention:
        return HapticFeedback.heavyImpact();
      case PlatePilotHapticKind.selection:
        return HapticFeedback.selectionClick();
      case PlatePilotHapticKind.cancel:
        return HapticFeedback.vibrate();
    }
  }
}

// =============================================================================
// 5. ListEntryBuilder — Helpers pour listes stagger
// =============================================================================

/// Builders prêt-à-l'emploi pour les entrées de listes stagger
/// (ex: liste de cards recettes dans le screen plan).
abstract final class ListEntryBuilder {
  const ListEntryBuilder._();

  /// Construit un widget animé pour un index donné dans une liste.
  ///
  /// Utilise implicitement `SignatureMotion.settle` et respecte
  /// `prefers-reduced-motion` du `MediaQuery`.
  static Widget build({
    required int index,
    required Widget child,
    Duration step = const Duration(milliseconds: 45),
    Duration perItem = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _ListEntryWrapper(
      index: index,
      step: step,
      perItem: perItem,
      curve: curve,
      child: child,
    );
  }
}

class _ListEntryWrapper extends StatefulWidget {
  const _ListEntryWrapper({
    required this.index,
    required this.step,
    required this.perItem,
    required this.curve,
    required this.child,
  });

  final int index;
  final Duration step;
  final Duration perItem;
  final Curve curve;
  final Widget child;

  @override
  State<_ListEntryWrapper> createState() => _ListEntryWrapperState();
}

class _ListEntryWrapperState extends State<_ListEntryWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.perItem,
    );
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future<void>.delayed(widget.step * widget.index);
      if (!mounted) return;
      await _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = reduced ? 1.0 : _animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, reduced ? 0 : 12 * (1 - t)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// =============================================================================
// 6. WelcomeHeroInsight — Custom paint draw-in
// =============================================================================

/// Petit widget hero de l'écran onboarding welcome : cercle gradient
/// avec un arc (insight = proposition) qui se dessine en 1.6 s.
///
/// Utilise un `CustomPainter` pour le tracé (animation draw-in via
/// réinvalidation continue).
class WelcomeHeroInsight extends StatefulWidget {
  const WelcomeHeroInsight({
    this.size = 160,
    this.label,
    this.gradient,
    super.key,
  });

  final double size;
  final String? label;
  final LinearGradient? gradient;

  @override
  State<WelcomeHeroInsight> createState() => _WelcomeHeroInsightState();
}

class _WelcomeHeroInsightState extends State<WelcomeHeroInsight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size.square(widget.size),
                painter: _WelcomeHeroPainter(
                  progress: reduced ? 1.0 : _controller.value,
                  gradient: widget.gradient ??
                      SignatureGradients.sunsetMeal,
                ),
              );
            },
          ),
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.label!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Draw-in painter : trace un cercle de fond + un arc qui se dessine en
/// `progress * 2π`.
class _WelcomeHeroPainter extends CustomPainter {
  _WelcomeHeroPainter({
    required this.progress,
    required this.gradient,
  });

  final double progress;
  final LinearGradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Background circle painted with gradient
    final bgPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw-in arc — orbital sweep
    final arcPaint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final arcRadius = radius * 0.78;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);
    canvas.drawArc(
      rect,
      -1.5708, // -π/2
      6.28318 * progress.clamp(0.0, 1.0),
      false,
      arcPaint,
    );

    // Center dot
    final dotPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(center, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _WelcomeHeroPainter old) =>
      old.progress != progress || old.gradient != gradient;
}
