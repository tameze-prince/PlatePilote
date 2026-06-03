import 'package:flutter/material.dart';

/// Définition des espacements de l'application.
abstract final class AppSpacing {
  // Micro spacing
  /// 2px.
  static const xxxs = 2.0;
  /// 4px.
  static const xxs = 4.0;
  /// 8px.
  static const xs = 8.0;

  // Small spacing
  /// 12px.
  static const sm = 12.0;
  /// 16px.
  static const md = 16.0;

  // Medium spacing
  /// 24px.
  static const lg = 24.0;
  /// 32px.
  static const xl = 32.0;

  // Large spacing
  /// 48px.
  static const xxl = 48.0;
  /// 64px.
  static const xxxl = 64.0;

  // Section spacing
  /// 80px.
  static const section = 80.0;

  /// [EdgeInsets] symétriques horizontaux.
  static EdgeInsets horizontal({double value = md}) =>
      EdgeInsets.symmetric(horizontal: value);

  /// [EdgeInsets] symétriques verticaux.
  static EdgeInsets vertical({double value = md}) =>
      EdgeInsets.symmetric(vertical: value);

  /// [EdgeInsets] uniformes.
  static EdgeInsets all({double value = md}) =>
      EdgeInsets.all(value);

  /// [EdgeInsets] personnalisés.
  static EdgeInsets only({
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) => EdgeInsets.only(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
  );
}
