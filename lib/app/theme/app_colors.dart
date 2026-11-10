import 'package:flutter/material.dart';

/// Brand, surface and semantic colors shared by both appearance modes.
abstract final class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFF14B8A6);
  static const secondaryLight = Color(0xFF5EEAD4);
  static const secondaryDark = Color(0xFF0F766E);
  static const accentDark = Color(0xFFB45309);
  static const accent = Color(0xFFF59E0B);
  static const violet = Color(0xFF7C3AED);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  static const successForeground = Color(0xFF047857);
  static const warningForeground = Color(0xFF92400E);
  static const errorForeground = Color(0xFFB91C1C);
  static const infoForeground = Color(0xFF1D4ED8);
  static const errorLight = Color(0xFFFCA5A5);
  static const lightBackground = Color(0xFFF8FAFC);
  static const darkBackground = Color(0xFF0F172A);
  static const lightSurface = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF1E293B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const darkBorder = Color(0xFF475569);
  static const lightText = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const darkText = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const lightTint = Color(0xFFEEF2FF);
  static const darkTint = Color(0xFF312E81);
  static const darkErrorContainer = Color(0xFF7F1D1D);
  static const lightErrorContainer = Color(0xFFFEE2E2);
  static const shadow = Color(0x0F0F172A);
  static const shadowMedium = Color(0x1A0F172A);
  static const shadowLarge = Color(0x240F172A);
  static const darkShadow = Color(0x33000000);
  static const transparent = Color(0x00000000);
  static const primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [primary, violet],
  );
  static const successGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [successForeground, secondaryDark],
  );
  static const warmGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [warningForeground, accentDark],
  );
  static const coolGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [primary, secondary],
  );
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? darkBackground : lightBackground;
  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : lightSurface;
  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? darkBorder : lightBorder;
  static Color text(Brightness brightness) =>
      brightness == Brightness.dark ? darkText : lightText;
  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
}
