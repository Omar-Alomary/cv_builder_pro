import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'translations/en_us.dart';
import 'translations/ar_sa.dart';
import 'shared_widgets/app_error_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (_) => const AppErrorView();
  try {
    final repository = await StorageService.initialize();
    Get.put(repository, permanent: true);
    runApp(const CvBuilderApp());
  } catch (error, stackTrace) {
    debugPrint('Application initialization failed: $error\n$stackTrace');
    runApp(const _StartupErrorApp());
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    final arabic =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ar';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Text(
                    (arabic ? arSa : enUs)['startup_error']!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
