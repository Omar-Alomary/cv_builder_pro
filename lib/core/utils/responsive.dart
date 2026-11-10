import 'package:flutter/material.dart';

/// Width categories based on available logical pixels.
enum ScreenType { mobile, tablet, desktop }

/// Responsive values shared by application screens.
abstract final class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  static const double maxContentWidth = 1200;

  static ScreenType screenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      screenType(context) == ScreenType.mobile;
  static bool isTablet(BuildContext context) =>
      screenType(context) == ScreenType.tablet;
  static bool isDesktop(BuildContext context) =>
      screenType(context) == ScreenType.desktop;
  static bool isTabletOrLarger(BuildContext context) => !isMobile(context);

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) => switch (screenType(context)) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet ?? mobile,
    ScreenType.desktop => desktop ?? tablet ?? mobile,
  };

  static int columns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) =>
      value(context: context, mobile: mobile, tablet: tablet, desktop: desktop);

  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) =>
      value(context: context, mobile: mobile, tablet: tablet, desktop: desktop);

  static double padding(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) =>
      value(context: context, mobile: mobile, tablet: tablet, desktop: desktop);

  static EdgeInsets pagePadding(BuildContext context) =>
      EdgeInsets.all(padding(context, mobile: 16, tablet: 24, desktop: 32));

  static Widget maxWidth({required Widget child, double? width}) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width ?? maxContentWidth),
      child: child,
    ),
  );
}
