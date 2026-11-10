import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/responsive.dart';

/// Convenient access to inherited display and localization properties.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  bool get isArabic =>
      (Get.locale ?? Localizations.localeOf(this)).languageCode == 'ar';
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  TextScaler get textScaler => MediaQuery.textScalerOf(this);
}
