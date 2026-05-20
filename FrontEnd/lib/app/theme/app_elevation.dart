import 'package:flutter/material.dart';

abstract final class AppElevation {
  // None
  static const none = 0.0;
  
  // Level 1 - Subtle lift (cards, chips)
  static const level1 = 1.0;
  
  // Level 2 - Light lift (buttons, FAB)
  static const level2 = 2.0;
  
  // Level 3 - Medium lift (app bars, navigation)
  static const level3 = 3.0;
  
  // Level 4 - High lift (dialogs, modals)
  static const level4 = 4.0;
  
  // Level 5 - Maximum lift (snackbars, tooltips)
  static const level5 = 5.0;
  
  // Semantic elevation values
  static const card = level1;
  static const button = level2;
  static const fab = level3;
  static const appBar = level2;
  static const dialog = level4;
  static const snackbar = level5;
  static const bottomSheet = level3;
  static const navigationBar = level2;
  
  // Shadow colors
  static const shadowColor = Color(0x1A000000);
  static const shadowColorLight = Color(0x0D000000);
  
  // Helper for creating box shadows
  static List<BoxShadow> shadow({
    double elevation = level1,
    Color color = shadowColor,
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: elevation * 4,
        offset: Offset(0, elevation * 2),
        spreadRadius: elevation * -0.5,
      ),
    ];
  }
  
  static List<BoxShadow> get cardShadow => shadow(elevation: card);
  static List<BoxShadow> get buttonShadow => shadow(elevation: button);
  static List<BoxShadow> get fabShadow => shadow(elevation: fab);
  static List<BoxShadow> get appBarShadow => shadow(elevation: appBar);
  static List<BoxShadow> get dialogShadow => shadow(elevation: dialog);
  static List<BoxShadow> get snackbarShadow => shadow(elevation: snackbar);
  static List<BoxShadow> get bottomSheetShadow => shadow(elevation: bottomSheet);
  static List<BoxShadow> get navigationBarShadow => shadow(elevation: navigationBar);
}
