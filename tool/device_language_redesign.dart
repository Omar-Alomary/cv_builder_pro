import 'dart:async';
import 'package:get/get.dart';
import 'package:cv_builder_pro/main.dart' as application;
import 'package:cv_builder_pro/app/routes/app_routes.dart';

/// Opens the real language screen for device review without changing settings.
Future<void> main() async {
  await application.main();
  Timer(const Duration(seconds: 5), () {
    Get.offAllNamed<void>(AppRoutes.languageSelection);
  });
}

