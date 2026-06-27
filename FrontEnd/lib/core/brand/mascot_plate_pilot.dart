library;

import 'package:flutter/material.dart';

import '../../app/theme/app_signature_visuals.dart';

// =============================================================================
// PlatePilot — Mascot Spoonie
// =============================================================================
// Une mascotte cuillère stylisée (Friendly, jamais infantilisante) qui
// incarne le "sous-chef de poche" du Brand Book v1 §1.
//
// Auteur : Kévin Larsson (illustration) + Dave Tech (impl Flutter CustomPainter).
// Sprint : 7.2d — finalisation brand / motion / mascot.
// =============================================================================

/// Widget Stateless exposant Spoonie, la mascotte signature PlatePilot.
///
/// Props par défaut conformes au Brand Book :
/// - `size = 96` — taille d'usage standard (empty states, onboarding).
/// - `moodColor` — optionnel, colore l'oeil OU le sourire.
/// - `smile = true` — affiche le sourire arc.
class SpoonieMascot extends StatelessWidget {
  const SpoonieMascot({
    this.size = 96,
    this.moodColor,
    this.smile = true,
    super.key,
  });

  final double size;
  final Color? moodColor;
  final bool smile;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SpooniePainter(
          moodColor: moodColor,
          smile: smile,
        ),
      ),
    );
  }
}

/// CustomPainter qui dessine Spoonie :
/// - corps ovale gradient coral → safran (utilise `SignatureGradients.sunsetMeal`).
/// - manche courbé en arrière-plan.
/// - 1 gros oeil rond blanc + pupille noir centrée.
/// - petit sourire arc (si `smile == true`).
class _SpooniePainter extends CustomPainter {
  _SpooniePainter({
    required this.moodColor,
    required this.smile,
  });

  final Color? moodColor;
  final bool smile;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Centre logique de la cuillère (bulle ovale)
    final bowlCenter = Offset(w * 0.55, h * 0.55);
    final bowlRadiusX = w * 0.32;
    final bowlRadiusY = h * 0.36;

    // 1) Bol ovale avec gradient sunsetMeal
    final bowlRect = Rect.fromCenter(
      center: bowlCenter,
      width: bowlRadiusX * 2,
      height: bowlRadiusY * 2,
    );
    final bowlPaint = Paint()
      ..shader = SignatureGradients.sunsetMeal.createShader(bowlRect)
      ..style = PaintingStyle.fill;
    canvas.drawOval(bowlRect, bowlPaint);

    // Fine highlight blanc subtil (reflet supérieur)
    final highlightPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.fill;
    final highlightPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(bowlCenter.dx - bowlRadiusX * 0.55,
              bowlCenter.dy - bowlRadiusY * 0.55),
          width: bowlRadiusX * 0.55,
          height: bowlRadiusY * 0.30,
        ),
      );
    canvas.drawPath(highlightPath, highlightPaint);

    // 2) Manche (handle) courbé — part du bord gauche du bol et remonte
    final handlePaint = Paint()
      ..color = SignatureColors.primarySunset
      ..strokeWidth = w * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final handlePath = Path()
      ..moveTo(
        bowlCenter.dx - bowlRadiusX * 0.90,
        bowlCenter.dy + bowlRadiusY * 0.20,
      )
      ..cubicTo(
        bowlCenter.dx - bowlRadiusX * 1.30,
        bowlCenter.dy - bowlRadiusY * 0.40,
        bowlCenter.dx - bowlRadiusX * 0.60,
        bowlCenter.dy - bowlRadiusY * 1.10,
        bowlCenter.dx - bowlRadiusX * 0.10,
        bowlCenter.dy - bowlRadiusY * 1.30,
      );
    canvas.drawPath(handlePath, handlePaint);

    // Bout arrondi en haut du manche
    final handleTipPaint = Paint()
      ..color = SignatureColors.primarySunset
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        bowlCenter.dx - bowlRadiusX * 0.10,
        bowlCenter.dy - bowlRadiusY * 1.30,
      ),
      w * 0.05,
      handleTipPaint,
    );

    // 3) Oeil — gros rond blanc centré légèrement en haut du bol
    final eyeCenter = Offset(
      bowlCenter.dx + bowlRadiusX * 0.10,
      bowlCenter.dy - bowlRadiusY * 0.30,
    );
    final eyeRadius = bowlRadiusX * 0.34;

    final eyeWhitePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(eyeCenter, eyeRadius, eyeWhitePaint);

    // Pupille noire centrée (légèrement décalée suivant le moodColor éventuel)
    final pupilOffsetX = moodColor == null
        ? 0.0
        : (moodColor == SignatureColors.primaryBakedApple ? -1.5 : 1.5);
    final pupilCenter = Offset(
      eyeCenter.dx + pupilOffsetX,
      eyeCenter.dy,
    );
    final pupilPaint = Paint()..color = const Color(0xFF1F2937);
    canvas.drawCircle(pupilCenter, eyeRadius * 0.45, pupilPaint);

    // Petit reflet blanc dans la pupille (vivacité)
    final sparklePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(
      Offset(
        pupilCenter.dx + eyeRadius * 0.18,
        pupilCenter.dy - eyeRadius * 0.18,
      ),
      eyeRadius * 0.12,
      sparklePaint,
    );

    // 4) Sourire — arc sous l'oeil si `smile == true`
    if (smile) {
      final smileColor = moodColor ?? SignatureColors.midnightSaffron;
      final smilePaint = Paint()
        ..color = smileColor
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final smileRect = Rect.fromCenter(
        center: Offset(
          bowlCenter.dx + bowlRadiusX * 0.05,
          bowlCenter.dy + bowlRadiusY * 0.35,
        ),
        width: bowlRadiusX * 0.85,
        height: bowlRadiusY * 0.55,
      );
      canvas.drawArc(
        smileRect,
        0.25,
        2.6,
        false,
        smilePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpooniePainter old) =>
      old.moodColor != moodColor || old.smile != smile;
}
