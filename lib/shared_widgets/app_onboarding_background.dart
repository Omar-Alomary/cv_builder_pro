import 'package:flutter/material.dart';
import '../app/theme/index.dart';

/// Direction-aware onboarding canvas with restrained orbs and a dark palette.
class AppOnboardingBackground extends StatelessWidget {
  const AppOnboardingBackground({
    super.key,
    required this.child,
    this.decoration,
  });
  final Widget child;
  final Widget? decoration;
  Widget _orb(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          AppColors.lightSurface.withValues(alpha: alpha),
          AppColors.transparent,
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  AppColors.darkBackground,
                  AppColors.darkTint,
                  AppColors.primaryDark,
                ],
              )
            : AppColors.primaryGradient,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diameter = (constraints.maxWidth * .7).clamp(
            AppSpacing.xxxl * 4,
            AppSpacing.xxxl * 10,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(
                child: Stack(
                  children: [
                    PositionedDirectional(
                      top: -AppSpacing.xxxl,
                      start: -AppSpacing.xxxl,
                      child: _orb(diameter, dark ? .08 : .15),
                    ),
                    PositionedDirectional(
                      bottom: -AppSpacing.xxxl,
                      end: -AppSpacing.xxxl,
                      child: _orb(diameter * 1.2, dark ? .06 : .12),
                    ),
                    PositionedDirectional(
                      top: constraints.maxHeight * .4,
                      end: AppSpacing.xl,
                      child: _orb(AppSpacing.xxxl * 2, .08),
                    ),
                  ],
                ),
              ),
              if (decoration != null) ExcludeSemantics(child: decoration!),
              child,
            ],
          );
        },
      ),
    );
  }
}
