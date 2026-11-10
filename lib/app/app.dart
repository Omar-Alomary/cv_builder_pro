import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../translations/app_translations.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../controllers/language_controller.dart';

/// Application root with routing, translations, and appearance themes.
class CvBuilderApp extends StatelessWidget {
  const CvBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>()
        : Get.put(LanguageController(), permanent: true);
    return Obx(
      () => GetMaterialApp(
        title: 'CV Maker Pro',
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        translations: AppTranslations(),
        locale: Locale(language.currentLanguage.value),
        fallbackLocale: const Locale('en', 'US'),
        builder: (context, child) => Directionality(
          textDirection: language.currentLanguage.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
