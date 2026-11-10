import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Consistent accessible feedback using the nearest scaffold messenger.
abstract final class AppSnackbar {
  static void storageError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.context;
      if (context == null || !context.mounted) return;
      error(context, 'storage_error'.tr);
    });
  }

  static void success(BuildContext context, String message) =>
      _show(context, message, Icons.check_circle_outline);
  static void error(BuildContext context, String message) =>
      _show(context, message, Icons.error_outline, error: true);
  static void warning(BuildContext context, String message) =>
      _show(context, message, Icons.warning_amber_outlined);
  static void info(BuildContext context, String message) =>
      _show(context, message, Icons.info_outline);

  static void _show(
    BuildContext context,
    String message,
    IconData icon, {
    bool error = false,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final scheme = Theme.of(context).colorScheme;
    final foreground = error
        ? scheme.onErrorContainer
        : scheme.onInverseSurface;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: error ? scheme.errorContainer : scheme.inverseSurface,
        duration: Duration(seconds: error ? 6 : 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Icon(icon, color: foreground)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
