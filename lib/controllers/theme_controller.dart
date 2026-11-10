import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/index.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/app_snackbar.dart';

/// Manages the persisted appearance preference.
class ThemeController extends GetxController {
  final ResumeRepository _repository;
  final RxBool isDarkMode = false.obs;
  Future<void> _pending = Future<void>.value();

  ThemeController({ResumeRepository? repository})
    : _repository = repository ?? Get.find<ResumeRepository>();

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  void loadTheme() {
    try {
      isDarkMode.value =
          _repository.read<bool>(StorageKeys.isDarkMode) ?? false;
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (error) {
      AppSnackbar.storageError();
    }
  }

  Future<void> toggleTheme() {
    final result = _pending.then((_) => _toggleTheme());
    _pending = result;
    return result;
  }

  Future<void> _toggleTheme() async {
    try {
      final dark = !isDarkMode.value;
      await _repository.write(StorageKeys.isDarkMode, dark);
      isDarkMode.value = dark;
      Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
    } catch (error) {
      AppSnackbar.storageError();
    }
  }
}
