import 'package:get/get.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/app_snackbar.dart';
import '../data/repositories/resume_repository.dart';

/// Shares the persisted account photo across Home and Settings.
class ProfileController extends GetxController {
  ProfileController({ResumeRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<ResumeRepository>()
              ? Get.find<ResumeRepository>()
              : null);
  final ResumeRepository? _repository;
  String? imagePath;

  static ProfileController get instance => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController(), permanent: true);

  @override
  void onInit() {
    super.onInit();
    try {
      imagePath = _repository?.read<String>(StorageKeys.profileImage);
    } catch (_) {
      AppSnackbar.storageError();
    }
  }

  Future<void> setImage(String path) async {
    final repository = _repository;
    if (repository == null) throw StateError('Profile storage is unavailable');
    await repository.write(StorageKeys.profileImage, path);
    imagePath = path;
    update();
  }

  void resetImage() {
    imagePath = null;
    update();
  }
}
