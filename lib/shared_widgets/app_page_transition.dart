import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_routes.dart';

/// Route-specific presentation transitions installed without changing routing.
class AppPageTransition extends CustomTransition {
  static void install() => Get.customTransition = AppPageTransition();
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context)) {
      return HeroMode(enabled: false, child: child);
    }
    final name = ModalRoute.of(context)?.settings.name ?? Get.currentRoute;
    final progress = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    if (name == AppRoutes.resumeBuilder || name == AppRoutes.preview) {
      final begin = name == AppRoutes.preview
          ? const Offset(0, 1)
          : Offset(Directionality.of(context) == TextDirection.rtl ? -1 : 1, 0);
      return SlideTransition(
        key: const ValueKey('app-page-slide'),
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(progress),
        child: child,
      );
    }
    return FadeTransition(
      key: const ValueKey('app-page-fade'),
      opacity: progress,
      child: child,
    );
  }
}
