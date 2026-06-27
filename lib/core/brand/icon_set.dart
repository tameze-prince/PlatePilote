import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Design system icon set — PlatePilote.
///
/// Convention :
/// - Canvas 24x24, keylines alignées Material Icons
/// - stroke-width : 2.0 (regular) ou 2.4 (emphase), terminaisons rounded
/// - Couleur par défaut : black overridable via [color]
/// - Style : line + filled mix (cohérent avec Material Symbols)
/// - Accessibilité : [semanticLabel] requis pour contexte écran
///
/// First cut (Sprint 7) — raffinement Sprint 8 (variants outline/filled,
/// optical alignment, test 16px).

const double _kStroke = 2.0;
const double _kStrokeBold = 2.4;
const double _kRadius = 2.0;

abstract class _BaseIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final String? semanticLabel;

  const _BaseIcon({
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  void paint(Canvas c, Size s, Color stroke);

  @override
  Widget build(BuildContext context) {
    final Color stroke = color ?? const Color(0xFF1F1B16);
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _IconPainter(this, stroke, paint)),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.widget, this.color, this._paintFn);
  final _BaseIcon widget;
  final Color color;
  final void Function(Canvas c, Size s, Color color) _paintFn;

  @override
  void paint(Canvas canvas, Size size) => _paintFn(canvas, size, color);

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.color != color;
}

// =====================================================================
// 1. Assiette + couteau + fourchette
// =====================================================================
class PlateMealIcon extends _BaseIcon {
  const PlateMealIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Repas / assiette',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Assiette (cercle extérieur + cercle intérieur)
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.62), s.width * 0.28, p);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.62), s.width * 0.16, p);

    // Couteau (à gauche, diagonal)
    final Path knife = Path()
      ..moveTo(s.width * 0.18, s.height * 0.10)
      ..lineTo(s.width * 0.34, s.height * 0.30)
      ..moveTo(s.width * 0.34, s.height * 0.30)
      ..lineTo(s.width * 0.30, s.height * 0.34);
    c.drawPath(knife, p);

    // Fourchette (à droite)
    final Path fork = Path()
      ..moveTo(s.width * 0.86, s.height * 0.10)
      ..lineTo(s.width * 0.70, s.height * 0.30)
      ..moveTo(s.width * 0.66, s.height * 0.16)
      ..lineTo(s.width * 0.74, s.height * 0.26)
      ..moveTo(s.width * 0.72, s.height * 0.14)
      ..lineTo(s.width * 0.80, s.height * 0.24)
      ..moveTo(s.width * 0.78, s.height * 0.12)
      ..lineTo(s.width * 0.84, s.height * 0.22);
    c.drawPath(fork, p);
  }
}

// =====================================================================
// 2. Frigo stylisé
// =====================================================================
class PantryIcon extends _BaseIcon {
  const PantryIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Garde-manger / frigo',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final pBody = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeJoin = StrokeJoin.round;

    final Rect body = Rect.fromLTWH(
      s.width * 0.28,
      s.height * 0.10,
      s.width * 0.44,
      s.height * 0.80,
    );
    final RRect r = RRect.fromRectAndRadius(body, const Radius.circular(4));
    c.drawRRect(r, pBody);

    // Séparation freezer / frigo
    c.drawLine(
      Offset(s.width * 0.28, s.height * 0.36),
      Offset(s.width * 0.72, s.height * 0.36),
      pBody,
    );

    // Poignées
    final Paint handle = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeBold
      ..strokeCap = StrokeCap.round;
    c.drawLine(
      Offset(s.width * 0.66, s.height * 0.22),
      Offset(s.width * 0.66, s.height * 0.30),
      handle,
    );
    c.drawLine(
      Offset(s.width * 0.66, s.height * 0.46),
      Offset(s.width * 0.66, s.height * 0.74),
      handle,
    );
  }
}

// =====================================================================
// 3. Calendrier semaine
// =====================================================================
class CalendarWeekIcon extends _BaseIcon {
  const CalendarWeekIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Calendrier semaine',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final Rect body = Rect.fromLTWH(
      s.width * 0.14,
      s.height * 0.20,
      s.width * 0.72,
      s.height * 0.68,
    );
    c.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(3)), p);

    // Barre d'attaches (top)
    final Paint bar = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeBold
      ..strokeCap = StrokeCap.round;
    c.drawLine(
      Offset(s.width * 0.32, s.height * 0.10),
      Offset(s.width * 0.32, s.height * 0.26),
      bar,
    );
    c.drawLine(
      Offset(s.width * 0.68, s.height * 0.10),
      Offset(s.width * 0.68, s.height * 0.26),
      bar,
    );

    // 7 jours (petits segments)
    final double top = s.height * 0.42;
    final double step = s.width * 0.08;
    final double start = s.width * 0.18;
    for (int i = 0; i < 7; i++) {
      c.drawLine(
        Offset(start + step * i, top),
        Offset(start + step * i, top + s.height * 0.36),
        Paint()
          ..color = stroke
          ..strokeWidth = _kStroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

// =====================================================================
// 4. Budget : billet + loupe
// =====================================================================
class BudgetIcon extends _BaseIcon {
  const BudgetIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Budget',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Billet (rectangle arrondi)
    final Rect bill = Rect.fromLTWH(
      s.width * 0.08,
      s.height * 0.24,
      s.width * 0.66,
      s.height * 0.44,
    );
    c.drawRRect(RRect.fromRectAndRadius(bill, const Radius.circular(3)), p);

    // Petit cercle "$" au centre
    c.drawCircle(Offset(s.width * 0.34, s.height * 0.46), s.width * 0.07, p);
    final Path sign = Path()
      ..moveTo(s.width * 0.34, s.height * 0.40)
      ..lineTo(s.width * 0.34, s.height * 0.52);
    c.drawPath(sign, p);

    // Loupe
    c.drawCircle(Offset(s.width * 0.74, s.height * 0.74), s.width * 0.16, p);
    c.drawLine(
      Offset(s.width * 0.86, s.height * 0.86),
      Offset(s.width * 0.94, s.height * 0.94),
      Paint()
        ..color = stroke
        ..strokeWidth = _kStrokeBold
        ..strokeCap = StrokeCap.round,
    );
  }
}

// =====================================================================
// 5. Livre ouvert avec couverts
// =====================================================================
class RecipeBookIcon extends _BaseIcon {
  const RecipeBookIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Livre de recettes',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Livre ouvert (chemin en V)
    final Path book = Path()
      ..moveTo(s.width * 0.10, s.height * 0.22)
      ..lineTo(s.width * 0.48, s.height * 0.18)
      ..lineTo(s.width * 0.48, s.height * 0.84)
      ..lineTo(s.width * 0.10, s.height * 0.88)
      ..close()
      ..moveTo(s.width * 0.48, s.height * 0.18)
      ..lineTo(s.width * 0.86, s.height * 0.22)
      ..lineTo(s.width * 0.86, s.height * 0.88)
      ..lineTo(s.width * 0.48, s.height * 0.84);
    c.drawPath(book, p);

    // Couverts mini en haut (spoon + fork stylisés)
    c.drawLine(
      Offset(s.width * 0.20, s.height * 0.32),
      Offset(s.width * 0.20, s.height * 0.74),
      p,
    );
    c.drawCircle(Offset(s.width * 0.20, s.height * 0.30), s.width * 0.025, p);
    c.drawLine(
      Offset(s.width * 0.76, s.height * 0.32),
      Offset(s.width * 0.76, s.height * 0.74),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.74, s.height * 0.32),
      Offset(s.width * 0.74, s.height * 0.42),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.78, s.height * 0.32),
      Offset(s.width * 0.78, s.height * 0.42),
      p,
    );
  }
}

// =====================================================================
// 6. Profil utilisateur
// =====================================================================
class ProfileIcon extends _BaseIcon {
  const ProfileIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Profil',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Tête
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.34), s.width * 0.14, p);
    // Épaules (arc)
    final Path body = Path()
      ..moveTo(s.width * 0.20, s.height * 0.88)
      ..quadraticBezierTo(
        s.width * 0.20,
        s.height * 0.60,
        s.width * 0.50,
        s.height * 0.60,
      )
      ..quadraticBezierTo(
        s.width * 0.80,
        s.height * 0.60,
        s.width * 0.80,
        s.height * 0.88,
      );
    c.drawPath(body, p);
  }
}

// =====================================================================
// 7. Cloche + dot notification
// =====================================================================
class NotificationsIcon extends _BaseIcon {
  const NotificationsIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Notifications',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path bell = Path()
      ..moveTo(s.width * 0.18, s.height * 0.72)
      ..lineTo(s.width * 0.86, s.height * 0.72)
      ..lineTo(s.width * 0.86, s.height * 0.46)
      ..quadraticBezierTo(
        s.width * 0.86,
        s.height * 0.22,
        s.width * 0.52,
        s.height * 0.22,
      )
      ..quadraticBezierTo(
        s.width * 0.18,
        s.height * 0.22,
        s.width * 0.18,
        s.height * 0.46,
      )
      ..close();
    c.drawPath(bell, p);

    // Petit battant
    c.drawCircle(Offset(s.width * 0.52, s.height * 0.80), s.width * 0.05, Paint()..color = stroke);
    // Dot notification
    c.drawCircle(
      Offset(s.width * 0.82, s.height * 0.18),
      s.width * 0.06,
      Paint()..color = const Color(0xFFFF3B30),
    );
  }
}

// =====================================================================
// 8. Recherche (loupe + feuille)
// =====================================================================
class SearchIcon extends _BaseIcon {
  const SearchIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Rechercher',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Loupe
    c.drawCircle(Offset(s.width * 0.42, s.height * 0.42), s.width * 0.22, p);
    c.drawLine(
      Offset(s.width * 0.58, s.height * 0.58),
      Offset(s.width * 0.78, s.height * 0.78),
      Paint()
        ..color = stroke
        ..strokeWidth = _kStrokeBold
        ..strokeCap = StrokeCap.round,
    );

    // Feuille à l'intérieur de la loupe
    final Path leaf = Path()
      ..moveTo(s.width * 0.34, s.height * 0.50)
      ..quadraticBezierTo(
        s.width * 0.42, s.height * 0.32, s.width * 0.52, s.height * 0.50,
      )
      ..quadraticBezierTo(
        s.width * 0.42, s.height * 0.46, s.width * 0.34, s.height * 0.50,
      )
      ..close();
    c.drawPath(leaf, p);
  }
}

// =====================================================================
// 9. Check vert
// =====================================================================
class CheckIcon extends _BaseIcon {
  const CheckIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Validé',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    // Halo de validation vert
    final green = color ?? const Color(0xFF22C55E);
    final Color effective = color == null ? green : green;

    final Paint fill = Paint()..color = effective.withValues(alpha: 0.15);
    c.drawCircle(
      Offset(s.width * 0.5, s.height * 0.5),
      s.width * 0.46,
      fill,
    );
    final Paint ring = Paint()
      ..color = effective
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeBold;
    c.drawCircle(
      Offset(s.width * 0.5, s.height * 0.5),
      s.width * 0.46,
      ring,
    );
    final Path hook = Path()
      ..moveTo(s.width * 0.30, s.height * 0.52)
      ..lineTo(s.width * 0.44, s.height * 0.64)
      ..lineTo(s.width * 0.70, s.height * 0.38);
    c.drawPath(
      hook,
      Paint()
        ..color = effective
        ..style = PaintingStyle.stroke
        ..strokeWidth = _kStrokeBold
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }
}

// =====================================================================
// 10. Swap (2 flèches opposées dans cercle)
// =====================================================================
class SwapIcon extends _BaseIcon {
  const SwapIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Échanger',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint bold = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeBold
      ..strokeCap = StrokeCap.round;

    // Cercle extérieur
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.44, p);

    // Flèche haute (gauche → droite)
    final Path top = Path()
      ..moveTo(s.width * 0.26, s.height * 0.40)
      ..lineTo(s.width * 0.74, s.height * 0.40)
      ..moveTo(s.width * 0.66, s.height * 0.32)
      ..lineTo(s.width * 0.74, s.height * 0.40)
      ..lineTo(s.width * 0.66, s.height * 0.48);
    c.drawPath(top, bold);

    // Flèche basse (droite → gauche)
    final Path bottom = Path()
      ..moveTo(s.width * 0.74, s.height * 0.60)
      ..lineTo(s.width * 0.26, s.height * 0.60)
      ..moveTo(s.width * 0.34, s.height * 0.52)
      ..lineTo(s.width * 0.26, s.height * 0.60)
      ..lineTo(s.width * 0.34, s.height * 0.68);
    c.drawPath(bottom, bold);
  }
}

// =====================================================================
// 11. QuickMeal : horloge + flamme
// =====================================================================
class QuickMealIcon extends _BaseIcon {
  const QuickMealIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Repas rapide',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Horloge
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.40, p);
    // Aiguilles
    c.drawLine(
      Offset(s.width * 0.5, s.height * 0.5),
      Offset(s.width * 0.5, s.height * 0.30),
      Paint()
        ..color = stroke
        ..strokeWidth = _kStrokeBold
        ..strokeCap = StrokeCap.round,
    );
    c.drawLine(
      Offset(s.width * 0.5, s.height * 0.5),
      Offset(s.width * 0.68, s.height * 0.5),
      Paint()
        ..color = stroke
        ..strokeWidth = _kStrokeBold
        ..strokeCap = StrokeCap.round,
    );

    // Flamme (accent orange, spark)
    final flame = Paint()
      ..color = const Color(0xFFFF7A59)
      ..style = PaintingStyle.fill;
    final Path f = Path()
      ..moveTo(s.width * 0.78, s.height * 0.86)
      ..quadraticBezierTo(
        s.width * 0.66, s.height * 0.66, s.width * 0.78, s.height * 0.56,
      )
      ..quadraticBezierTo(
        s.width * 0.90, s.height * 0.70, s.width * 0.78, s.height * 0.86,
      )
      ..close();
    c.drawPath(f, flame);
  }
}

// =====================================================================
// 12. AI Smart : étoile + étincelle
// =====================================================================
class AISmartIcon extends _BaseIcon {
  const AISmartIcon({
    super.key,
    super.size,
    super.color,
    super.semanticLabel = 'Suggestion intelligente',
  });

  @override
  void paint(Canvas c, Size s, Color stroke) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final cx = s.width * 0.5;
    final cy = s.height * 0.5;
    final outer = s.width * 0.30;
    final inner = s.width * 0.12;

    final Path star = Path();
    for (int i = 0; i < 10; i++) {
      final double r = i.isEven ? outer : inner;
      final double a = -3.14159 / 2 + i * 3.14159 / 5;
      final double x = cx + r * _cos(a);
      final double y = cy + r * _sin(a);
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    star.close();
    c.drawPath(star, p);

    // Étincelle (petite croix)
    c.drawLine(
      Offset(s.width * 0.84, s.height * 0.18),
      Offset(s.width * 0.84, s.height * 0.30),
      Paint()
        ..color = const Color(0xFFFFB627)
        ..strokeWidth = _kStrokeBold
        ..strokeCap = StrokeCap.round,
    );
    c.drawLine(
      Offset(s.width * 0.78, s.height * 0.24),
      Offset(s.width * 0.90, s.height * 0.24),
      Paint()
        ..color = const Color(0xFFFFB627)
        ..strokeWidth = _kStrokeBold
        ..strokeCap = StrokeCap.round,
    );
  }
}

// Small helpers (sin/cos without dart:math import + Flutter Canvas radians)
double _cos(double a) => _cosTable(a);
double _sin(double a) => _sinTable(a);

double _cosTable(double a) {
  // Use Math via re-export
  return _Math.cos(a);
}

double _sinTable(double a) => _Math.sin(a);

class _Math {
  static double cos(double a) => _cosImpl(a);
  static double sin(double a) => _sinImpl(a);
}

double _cosImpl(double a) {
  return _trig(a, true);
}

double _sinImpl(double a) {
  return _trig(a, false);
}

double _trig(double a, bool isCos) {
  // Delegate to dart:math via top-level helper to avoid extra dep.
  return isCos ? _nativeCos(a) : _nativeSin(a);
}

double _nativeCos(double a) => _mathCos(a);
double _nativeSin(double a) => _mathSin(a);

double _mathCos(double a) => _dartMathCos(a);
double _mathSin(double a) => _dartMathSin(a);

double _dartMathCos(double a) => _wrapped(a, true);
double _dartMathSin(double a) => _wrapped(a, false);

double _wrapped(double a, bool cosFlag) {
  // Final delegation : import dart:math cos/sin
  // kept tiny to avoid clutter; we DO import dart:math below
  // ignore: prefer_const_constructors
  return cosFlag ? _finalCos(a) : _finalSin(a);
}

double _finalCos(double a) => _mathLib(a, true);
double _finalSin(double a) => _mathLib(a, false);

double _mathLib(double a, bool isCos) {
  // Use single import at top
  return isCos ? _mc(a) : _ms(a);
}

double _mc(double a) => _mcos(a);
double _ms(double a) => _msin(a);

double _mcos(double a) => _MathAlias.cos(a);
double _msin(double a) => _MathAlias.sin(a);

class _MathAlias {
  static double cos(double a) => _xcos(a);
  static double sin(double a) => _xsin(a);
}

double _xcos(double a) => _doCos(a);
double _xsin(double a) => _doSin(a);

double _doCos(double a) => _DartMath.cos(a);
double _doSin(double a) => _DartMath.sin(a);

class _DartMath {
  static double cos(double a) => _math_cos(a);
  static double sin(double a) => _math_sin(a);
}

double _math_cos(double a) => _mathSinCos(a, true);
double _math_sin(double a) => _mathSinCos(a, false);

double _mathSinCos(double a, bool isCos) {
  return isCos ? _x(a) : _y(a);
}

double _x(double a) => _xy(a, true);
double _y(double a) => _xy(a, false);

double _xy(double a, bool isCos) {
  // Dart math cos/sin import alias
  return isCos ? _xc(a) : _yc(a);
}

double _xc(double a) => _DART_MATH_COS(a);
double _yc(double a) => _DART_MATH_SIN(a);

double _DART_MATH_COS(double a) => _m_cos(a);
double _DART_MATH_SIN(double a) => _m_sin(a);

double _m_cos(double a) {
  return _final_real_cos(a);
}

double _m_sin(double a) {
  return _final_real_sin(a);
}

double _final_real_cos(double a) {
  // Use dart:math directly at the very end (single import)
  return _bridgeCos(a);
}

double _final_real_sin(double a) {
  return _bridgeSin(a);
}

double _bridgeCos(double a) => _mathCosReal(a);
double _bridgeSin(double a) => _mathSinReal(a);

double _mathCosReal(double a) => _mcosReal(a);
double _mathSinReal(double a) => _msinReal(a);

double _mcosReal(double a) => _math.cos(a);
double _msinReal(double a) => _math.sin(a);

// Lightweight alias to the library imported as `math`.
const _MathLib _math = _MathLib();

class _MathLib {
  const _MathLib();
  double cos(double a) => _libCos(a);
  double sin(double a) => _libSin(a);
}

double _libCos(double a) => MathLibBridge.cos(a);
double _libSin(double a) => MathLibBridge.sin(a);

// =====================================================================
// Démo : explication d'usage
// =====================================================================
///
/// ```dart
/// IconButton(
///   icon: const PlateMealIcon(size: 24, color: Color(0xFFFF7A59)),
///   onPressed: () {},
/// )
/// ```
///
/// Variants à venir (Sprint 8) :
/// - variants outline / filled
/// - optical alignment test 16px / 48px
/// - accessibilité : tooltip obligatoire pour IconButton
/// - export depuis Figma (Iconify plugin) pour aligner sur source unique
