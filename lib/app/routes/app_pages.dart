import 'package:get/get.dart';
import '../../features/resume_builder/presentation/pages/preview_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/language/presentation/pages/language_selection_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/templates/presentation/pages/templates_screen.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/import_resume/presentation/pages/import_resume_screen.dart';
import '../../features/ats_checker/presentation/pages/ats_checker_screen.dart';
import '../../features/resume_builder/presentation/pages/resume_builder_screen.dart';
import 'app_routes.dart';

/// Registers the independent feature screens.
abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.root, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.atsChecker, page: () => const ATSCheckerScreen()),
    GetPage(
      name: AppRoutes.importResume,
      page: () => const ImportResumeScreen(),
    ),
    GetPage(name: AppRoutes.templates, page: () => const TemplatesScreen()),
    GetPage(name: AppRoutes.favorites, page: () => const FavoritesScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () => const ResumeBuilderScreen(),
    ),
    GetPage(name: AppRoutes.preview, page: () => const PreviewScreen()),
  ];
}
