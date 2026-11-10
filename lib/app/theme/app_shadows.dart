import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Elevation recipes for surfaces and restrained brand-colored emphasis.
abstract final class AppShadows {
  static const soft = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: AppSpacing.lg,
      offset: Offset(0, AppSpacing.xs),
    ),
  ];
  static const medium = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: AppSpacing.xl,
      offset: Offset(0, AppSpacing.sm),
    ),
  ];
  static const large = [
    BoxShadow(
      color: AppColors.shadowLarge,
      blurRadius: AppSpacing.xxxl,
      offset: Offset(0, AppSpacing.lg),
    ),
  ];
  static const dark = [
    BoxShadow(
      color: AppColors.darkShadow,
      blurRadius: AppSpacing.xl,
      offset: Offset(0, AppSpacing.sm),
    ),
  ];
  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: .18),
      blurRadius: AppSpacing.xl,
      offset: const Offset(0, AppSpacing.sm),
    ),
  ];
  static List<BoxShadow> forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : soft;
}
