import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Type scale with Poppins for Latin text and Cairo for Arabic glyphs.
abstract final class AppTextStyles {
  static const fontFamily = 'Poppins';
  static const arabicFontFamily = 'Cairo';
  static const fontFallback = [arabicFontFamily];
  static const display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const h3 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static const h4 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static String familyFor(Locale locale) =>
      locale.languageCode == 'ar' ? arabicFontFamily : fontFamily;
  static TextStyle resolve(BuildContext context, TextStyle style) {
    // The app supplies its Arabic direction even when Material falls back to en.
    final locale = Directionality.of(context) == TextDirection.rtl
        ? const Locale('ar')
        : Localizations.localeOf(context);
    return style.copyWith(
      fontFamily: familyFor(locale),
      fontFamilyFallback: const [fontFamily, arabicFontFamily],
    );
  }

  static TextTheme textTheme(Brightness brightness, {Locale? locale}) {
    final theme = TextTheme(
      displayLarge: display,
      displayMedium: h1,
      displaySmall: h2,
      headlineLarge: h1,
      headlineMedium: h2,
      headlineSmall: h3,
      titleLarge: h4,
      titleMedium: body.copyWith(fontWeight: FontWeight.w600),
      titleSmall: label,
      bodyLarge: bodyLarge,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: button,
      labelMedium: label,
      labelSmall: caption,
    );
    return theme.apply(
      fontFamily: locale == null ? fontFamily : familyFor(locale),
      fontFamilyFallback: const [fontFamily, arabicFontFamily],
      bodyColor: AppColors.text(brightness),
      displayColor: AppColors.text(brightness),
    );
  }
}
