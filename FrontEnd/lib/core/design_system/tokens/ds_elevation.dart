import '../../../app/theme/app_elevation.dart';

/// Elevation tokens re-exposed with DS naming.
abstract final class DsElevation {
  DsElevation._();

  static const double none = AppElevation.none;
  static const double level1 = AppElevation.level1;
  static const double level2 = AppElevation.level2;
  static const double level3 = AppElevation.level3;
  static const double level4 = AppElevation.level4;
  static const double level5 = AppElevation.level5;

  static const double card = AppElevation.card;
  static const double button = AppElevation.button;
  static const double fab = AppElevation.fab;
  static const double appBar = AppElevation.appBar;
  static const double dialog = AppElevation.dialog;
  static const double snackbar = AppElevation.snackbar;
  static const double bottomSheet = AppElevation.bottomSheet;
  static const double navigationBar = AppElevation.navigationBar;
}
