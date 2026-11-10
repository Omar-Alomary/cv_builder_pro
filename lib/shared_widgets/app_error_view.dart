import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_routes.dart';

/// Recoverable build-error screen that also works without inherited direction.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: Get.locale?.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr,
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('error_occurred'.tr, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => Get.offAllNamed<void>(AppRoutes.home),
                  label: Text('return_home'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
