import 'package:get/get.dart';
import '../../controllers/index.dart';

/// Registers the separated controllers for the application lifetime.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LanguageController(), permanent: true);
    Get.put(ThemeController(), permanent: true);
    Get.put(ResumeController(), permanent: true);
    Get.put(TemplateController(), permanent: true);
    Get.put(AtsController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}
