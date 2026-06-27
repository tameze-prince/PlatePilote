import 'package:flutter/material.dart';

/// Spoonie, la mascotte PlatePilote.
///
/// Personnage : cuillère souriante qui accompagne l'utilisateur
/// dans ses décisions culinaires. Positive, jamais culpabilisante.
/// Style design : minimal, geometrique, memorable.
/// Brand book : gradient signature [color] -> Color(0xFFFFB627).
class SpoonieMascot extends StatelessWidget {
  final double size;
  final Color? moodColor;
  final bool smile;
  final bool blink;

  const SpoonieMascot({
    super.key,
    this.size = 96,
    this.moodColor,
    this.smile = true,
    this.blink = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SpooniePainter(
          color: moodColor ?? const Color(0xFFFF7A59),
          smile: smile,
          blink: blink,
        ),
      ),
    );
  }
}

class _SpooniePainter extends CustomPainter {
  _SpooniePainter({
    required this.color,
    required this.smile,
    required this.blink,
  });

  final Color color;
  final bool smile;
  final bool blink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ----- Body (ovale : le creux de la cuillère) -----
    final Rect bodyRect = Rect.fromCenter(
      center: Offset(w * 0.42, h * 0.62),
      width: w * 0.62,
      height: h * 0.46,
    );

    final Paint body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, const Color(0xFFFFB627)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawOval(bodyRect, body);

    // ----- Manche incurvé -----
    final Path handle = Path()
      ..moveTo(w * 0.68, h * 0.40)
      ..quadraticBezierTo(w * 0.98, h * 0.22, w * 0.85, h * 0.04)
      ..lineTo(w * 0.66, h * 0.04)
      ..quadraticBezierTo(w * 0.78, h * 0.22, w * 0.52, h * 0.40)
      ..close();
    canvas.drawPath(handle, body);

    // Halo subtil / ombre douce sous la cuillère (optionnel, léger)
    final Paint shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.42, h * 0.86),
        width: w * 0.5,
        height: h * 0.06,
      ),
      shadow,
    );

    // ----- Œil -----
    final Offset eyeCenter = Offset(w * 0.38, h * 0.58);
    final double eyeR = w * 0.055;

    if (blink) {
      // Paupière fermée : petit arc
      final Paint lid = Paint()
        ..color = const Color(0xFF1F1B16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      final Path p = Path()
        ..moveTo(eyeCenter.dx - eyeR, eyeCenter.dy)
        ..quadraticBezierTo(
          eyeCenter.dx,
          eyeCenter.dy + eyeR * 0.6,
          eyeCenter.dx + eyeR,
          eyeCenter.dy,
        );
      canvas.drawPath(p, lid);
    } else {
      // Blanc
      canvas.drawCircle(eyeCenter, eyeR, Paint()..color = Colors.white);
      // Pupille
      canvas.drawCircle(
        Offset(eyeCenter.dx + eyeR * 0.15, eyeCenter.dy + eyeR * 0.1),
        eyeR * 0.5,
        Paint()..color = const Color(0xFF1F1B16),
      );
      // Catch-light (reflet)
      canvas.drawCircle(
        Offset(eyeCenter.dx + eyeR * 0.35, eyeCenter.dy - eyeR * 0.25),
        eyeR * 0.18,
        Paint()..color = Colors.white,
      );
    }

    // ----- Sourire -----
    if (smile && !blink) {
      final Paint mouth = Paint()
        ..color = const Color(0xFF1F1B16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Path p = Path()
        ..moveTo(w * 0.32, h * 0.68)
        ..quadraticBezierTo(w * 0.40, h * 0.74, w * 0.48, h * 0.68);
      canvas.drawPath(p, mouth);

      // Joues (cercles rosés optionnels)
      final Paint cheek = Paint()..color = const Color(0xFFFF9A7A).withValues(alpha: 0.55);
      canvas.drawCircle(Offset(w * 0.27, h * 0.67), w * 0.025, cheek);
      canvas.drawCircle(Offset(w * 0.51, h * 0.67), w * 0.018, cheek);
    }
  }

  @override
  bool shouldRepaint(covariant _SpooniePainter old) =>
      old.color != color || old.smile != smile || old.blink != blink;
}

/// Helper de prévisualisation pour QA / debug.
class SpoonieMascotPreview extends StatelessWidget {
  const SpoonieMascotPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: const [
        SpoonieMascot(size: 96, smile: true),
        SpoonieMascot(size: 96, smile: true, blink: true),
        SpoonieMascot(
          size: 96,
          moodColor: Color(0xFF6BCB77),
          smile: false,
        ),
        SpoonieMascot(size: 160),
      ],
    );
  }
}
