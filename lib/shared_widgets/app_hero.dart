import 'package:flutter/material.dart';

/// Shared-element motion respecting reduced motion and accessible navigation.
class AppHero extends StatelessWidget {
  const AppHero({super.key, required this.tag, required this.child});
  final Object tag;
  final Widget child;
  @override
  Widget build(BuildContext context) => HeroMode(
    enabled:
        !MediaQuery.disableAnimationsOf(context) &&
        !MediaQuery.accessibleNavigationOf(context),
    child: Hero(
      tag: tag,
      child: Material(type: MaterialType.transparency, child: child),
    ),
  );
}
