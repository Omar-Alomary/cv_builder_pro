import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/index.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/app_snackbar.dart';

/// Manages the persisted application language.
class LanguageController extends GetxController {
  final ResumeRepository _repository;
  final RxBool isLanguageSelected = false.obs;
  final RxString currentLanguage = 'en'.obs;
  final RxBool isSelecting = false.obs;

  LanguageController({ResumeRepository? repository})
    : _repository = repository ?? Get.find<ResumeRepository>();

  @override
  void onInit() {
    super.onInit();
    checkLanguageSelection();
  }

  Future<void> checkLanguageSelection() async {
    try {
      isLanguageSelected.value =
          _repository.read<bool>(StorageKeys.languageSelected) ?? false;
      final locale = _repository.read<String>(StorageKeys.appLocale) ?? 'en';
      currentLanguage.value = locale;
      if (isLanguageSelected.value && Get.locale?.languageCode != locale) {
        Get.locale = Locale(locale);
        Get.appUpdate();
      }
    } catch (error) {
      AppSnackbar.storageError();
    }
  }

  Future<void> selectLanguage(String languageCode) async {
    if (isSelecting.value) return;
    isSelecting.value = true;
    try {
      await _repository.write(StorageKeys.appLocale, languageCode);
      await _repository.write(StorageKeys.languageSelected, true);
      currentLanguage.value = languageCode;
      if (Get.locale?.languageCode != languageCode) {
        // A new route is opened below; update the application locale without
        // a hot-reassemble of the departing selection screen.
        Get.locale = Locale(languageCode);
        Get.appUpdate();
      }
      isLanguageSelected.value = true;
      Get.offAllNamed('/home');
    } catch (error) {
      AppSnackbar.storageError();
    } finally {
      isSelecting.value = false;
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      await _repository.write(StorageKeys.appLocale, languageCode);
      currentLanguage.value = languageCode;
      if (Get.locale?.languageCode != languageCode) {
        Get.locale = Locale(languageCode);
        Get.appUpdate();
      }
    } catch (error) {
      AppSnackbar.storageError();
    }
  }
}
