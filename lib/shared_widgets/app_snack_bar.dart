import 'package:flutter/material.dart';
import '../app/theme/index.dart';

/// Floating semantic feedback without changing the service-layer snackbar API.
abstract final class AppSnackBar {
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success, Icons.check_circle_outline);
  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error, Icons.error_outline);
  static void warning(BuildContext context, String message) =>
      _show(context, message, AppColors.warning, Icons.warning_amber_rounded);
  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.info, Icons.info_outline);
  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.dark
        ? color
        : color == AppColors.success
        ? AppColors.successForeground
        : color == AppColors.warning
        ? AppColors.warningForeground
        : color == AppColors.info
        ? AppColors.infoForeground
        : AppColors.errorForeground;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
          side: BorderSide(color: color.withValues(alpha: .5)),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppSpacing.none,
        duration: const Duration(seconds: 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: AppRadii.field,
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.xl),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.resolve(
                  context,
                  AppTextStyles.bodySmall,
                ).copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
