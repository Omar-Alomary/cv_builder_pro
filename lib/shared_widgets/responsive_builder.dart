import 'package:flutter/material.dart';
import '../core/utils/responsive.dart';

/// Selects a layout from the actual width available to this widget.
class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final WidgetBuilder builder;
      if (width < Responsive.mobileBreakpoint) {
        builder = mobile;
      } else if (width < Responsive.tabletBreakpoint) {
        builder = tablet ?? mobile;
      } else {
        builder = desktop ?? tablet ?? mobile;
      }
      return builder(context);
    },
  );
}
