import 'dart:async';
import 'package:get/get.dart';
import '../core/utils/app_snackbar.dart';
import '../data/models/resume_model.dart';
import '../data/repositories/resume_repository.dart';

/// Coordinates editing and serializes saves, favorites, deletion and clearing.
class ResumeController extends GetxController {
  final ResumeRepository _repository;
  final RxList<ResumeModel> resumes = <ResumeModel>[].obs;
  final Rx<ResumeModel?> currentResume = Rx<ResumeModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<DateTime?> lastSavedAt = Rx<DateTime?>(null);
  final RxBool lastSaveWasAutomatic = false.obs;
  Timer? _autoSaveTimer;
  Future<void> _pending = Future<void>.value();
  bool _clearing = false;

  ResumeController({ResumeRepository? repository})
    : _repository = repository ?? Get.find<ResumeRepository>();

  @override
  void onInit() {
    super.onInit();
    loadResumes();
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  void loadResumes() {
    try {
      resumes.assignAll(_repository.loadResumes());
    } catch (_) {
      AppSnackbar.storageError();
    }
  }

  Future<bool> saveResume(ResumeModel resume, {bool automatic = false}) {
    if (_clearing) return Future.value(false);
    return _enqueue(() => _saveResume(resume, automatic: automatic));
  }

  Future<bool> _saveResume(ResumeModel resume, {bool automatic = false}) async {
    isSaving.value = true;
    try {
      final saved = await _repository.saveResume(resume);
      resume.id = saved.id;
      resume.updatedAt = saved.updatedAt;
      final index = resumes.indexWhere((entry) => entry.id == saved.id);
      if (index < 0) {
        resumes.add(saved);
      } else {
        resumes[index] = saved;
      }
      lastSavedAt.value = saved.updatedAt;
      lastSaveWasAutomatic.value = automatic;
      return true;
    } catch (_) {
      AppSnackbar.storageError();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteResume(int id) {
    if (_clearing) return Future.value();
    if (currentResume.value?.id == id) stopAutoSave();
    return _enqueue(() async {
      try {
        await _repository.deleteResume(id);
        resumes.removeWhere((entry) => entry.id == id);
        if (currentResume.value?.id == id) {
          currentResume.value = null;
          isEditing.value = false;
          lastSavedAt.value = null;
        }
        final context = Get.context;
        if (context != null && context.mounted) {
          AppSnackbar.success(context, 'resume_deleted'.tr);
        }
      } catch (_) {
        AppSnackbar.storageError();
      }
    });
  }

  Future<void> toggleFavorite(int id) {
    if (_clearing) return Future.value();
    return _enqueue(() async {
      final index = resumes.indexWhere((entry) => entry.id == id);
      if (index < 0) return;
      final changed = resumes[index].copyWith(
        isFavorite: !resumes[index].isFavorite,
      );
      if (await _saveResume(changed)) {
        final current = currentResume.value;
        if (current != null && current.id == id) {
          current.isFavorite = changed.isFavorite;
          currentResume.refresh();
        }
      }
    });
  }

  void startAutoSave() {
    stopAutoSave();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final resume = currentResume.value;
      if (!_clearing &&
          !isSaving.value &&
          resume != null &&
          resume.fullName.trim().isNotEmpty) {
        unawaited(saveResume(resume, automatic: true));
      }
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  Future<void> clearAllData() async {
    if (_clearing) return;
    _clearing = true;
    stopAutoSave();
    try {
      await _enqueue(() async {
        await _repository.clearAllData();
        resumes.clear();
        currentResume.value = null;
        isEditing.value = false;
        lastSavedAt.value = null;
        lastSaveWasAutomatic.value = false;
      });
    } finally {
      _clearing = false;
    }
  }

  List<ResumeModel> getRecentResumes({int limit = 5}) {
    final sorted = List<ResumeModel>.from(resumes)
      ..sort(
        (a, b) =>
            (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt),
      );
    return sorted.take(limit < 0 ? 0 : limit).toList();
  }

  List<ResumeModel> getFavoriteResumes() =>
      resumes.where((resume) => resume.isFavorite).toList();

  @override
  void onClose() {
    stopAutoSave();
    super.onClose();
  }
}
