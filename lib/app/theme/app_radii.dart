import 'package:flutter/material.dart';

/// Reusable corner radii for fields, cards, dialogs and pill controls.
abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 999;
  static const field = BorderRadius.all(Radius.circular(sm));
  static const card = BorderRadius.all(Radius.circular(lg));
  static const dialog = BorderRadius.all(Radius.circular(xl));
  static const chip = BorderRadius.all(Radius.circular(pill));
}
