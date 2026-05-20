import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // Micro spacing
  static const xxxs = 2.0;
  static const xxs = 4.0;
  static const xs = 8.0;
  
  // Small spacing
  static const sm = 12.0;
  static const md = 16.0;
  
  // Medium spacing
  static const lg = 24.0;
  static const xl = 32.0;
  
  // Large spacing
  static const xxl = 48.0;
  static const xxxl = 64.0;
  
  // Section spacing
  static const section = 80.0;
  
  // Helper getters for common patterns
  static EdgeInsets horizontal({double value = md}) =>
      EdgeInsets.symmetric(horizontal: value);
  
  static EdgeInsets vertical({double value = md}) =>
      EdgeInsets.symmetric(vertical: value);
  
  static EdgeInsets all({double value = md}) =>
      EdgeInsets.all(value);
  
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
