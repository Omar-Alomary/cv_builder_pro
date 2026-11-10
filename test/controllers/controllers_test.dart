import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';
import 'package:cv_builder_pro/data/index.dart';

class _Repository implements ResumeRepository {
  final values = <String, dynamic>{};
  final saved = <ResumeModel>[];
  bool fail = false;
  int nextId = 1;

  void _check() {
    if (fail) {
      throw const StorageException('test operation', 'simulated failure');
    }
  }

  @override
  T? read<T>(String key) {
    _check();
    return values[key] as T?;
  }

  @override
  Future<void> write(String key, Object? value) async {
    _check();
    values[key] = value;
  }

  @override
  List<ResumeModel> loadResumes() {
    _check();
    return saved.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    _check();
    final result = resume.copyWith(
      id: resume.id ?? nextId++,
      updatedAt: DateTime.now(),
    );
    final index = saved.indexWhere((entry) => entry.id == result.id);
    if (index < 0) {
      saved.add(result);
    } else {
      saved[index] = result;
    }
    return result.copyWith();
  }

  @override
  Future<void> deleteResume(int id) async {
    _check();
    saved.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<void> clearAllData() async {
    _check();
    saved.clear();
    values.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
  });
  tearDown(() async {
    Get.reset();
  });

  test(
    'Queued saves of the same draft create one resume and isolate edits',
    () async {
      final repository = _Repository();
      final controller = ResumeController(repository: repository);
      addTearDown(controller.onClose);
      final draft = ResumeModel(fullName: 'Original');
      final results = await Future.wait([
        controller.saveResume(draft),
        controller.saveResume(draft),
      ]);
      expect(results, [true, true]);
      expect(repository.saved, hasLength(1));
      expect(controller.resumes, hasLength(1));
      expect(draft.id, 1);
      draft.fullName = 'Unsaved edit';
      expect(controller.resumes.single.fullName, 'Original');
      expect(controller.isSaving.value, false);
      expect(controller.lastSavedAt.value, isNotNull);
    },
  );

  test('Rapid favorite toggles serialize without losing a toggle', () async {
    final controller = ResumeController(repository: _Repository());
    addTearDown(controller.onClose);
    final draft = ResumeModel(fullName: 'Favorite');
    controller.currentResume.value = draft;
    await controller.saveResume(draft);
    await Future.wait([
      controller.toggleFavorite(draft.id!),
      controller.toggleFavorite(draft.id!),
    ]);
    expect(controller.getFavoriteResumes(), isEmpty);
    expect(draft.isFavorite, false);
    await controller.toggleFavorite(draft.id!);
    expect(controller.getFavoriteResumes(), hasLength(1));
    expect(draft.isFavorite, true);
  });

  test('Delete follows pending saves and clears the active resume', () async {
    final repository = _Repository();
    final controller = ResumeController(repository: repository);
    addTearDown(controller.onClose);
    final draft = ResumeModel(fullName: 'Delete');
    controller.currentResume.value = draft;
    await controller.saveResume(draft);
    final save = controller.saveResume(draft);
    final deletion = controller.deleteResume(draft.id!);
    await save;
    await deletion;
    expect(repository.saved, isEmpty);
    expect(controller.currentResume.value, isNull);
  });

  test(
    'Clearing waits for pending saves and blocks new saves during clear',
    () async {
      final repository = _Repository();
      final controller = ResumeController(repository: repository);
      addTearDown(controller.onClose);
      final draft = ResumeModel(fullName: 'Clear');
      controller.currentResume.value = draft;
      final save = controller.saveResume(draft);
      final clear = controller.clearAllData();
      expect(await controller.saveResume(draft), false);
      await save;
      await clear;
      expect(repository.saved, isEmpty);
      expect(controller.resumes, isEmpty);
      expect(controller.currentResume.value, isNull);
      expect(controller.lastSavedAt.value, isNull);
    },
  );

  test(
    'Failed save returns failure and does not mark the draft as saved',
    () async {
      final repository = _Repository()..fail = true;
      final controller = ResumeController(repository: repository);
      addTearDown(controller.onClose);
      final draft = ResumeModel(fullName: 'Failure');
      expect(await controller.saveResume(draft), false);
      expect(draft.id, isNull);
      expect(controller.resumes, isEmpty);
      expect(controller.lastSavedAt.value, isNull);
      expect(controller.isSaving.value, false);
      repository.fail = false;
      expect(await controller.saveResume(draft), true);
    },
  );

  testWidgets('Autosave records success and stops when requested', (
    tester,
  ) async {
    final repository = _Repository();
    final controller = ResumeController(repository: repository);
    addTearDown(controller.onClose);
    controller.currentResume.value = ResumeModel(fullName: 'Auto');
    controller.startAutoSave();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(repository.saved, hasLength(1));
    expect(controller.lastSaveWasAutomatic.value, true);
    controller.stopAutoSave();
    controller.currentResume.value!.fullName = 'Unsaved';
    await tester.pump(const Duration(seconds: 10));
    expect(repository.saved.single.fullName, 'Auto');
  });

  testWidgets('Language and appearance restore, change and persist', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      ),
    );
    final repository = _Repository();
    repository.values.addAll({
      StorageKeys.appLocale: 'ar',
      StorageKeys.languageSelected: true,
      StorageKeys.isDarkMode: true,
    });
    final language = LanguageController(repository: repository);
    final theme = ThemeController(repository: repository);
    final restoreLanguage = language.checkLanguageSelection();
    await tester.pump();
    await restoreLanguage;
    theme.loadTheme();
    await tester.pump();
    expect(language.currentLanguage.value, 'ar');
    expect(Get.locale?.languageCode, 'ar');
    expect(theme.isDarkMode.value, true);
    final changeLanguage = language.changeLanguage('en');
    await tester.pump();
    await changeLanguage;
    await theme.toggleTheme();
    await tester.pumpAndSettle();
    expect(repository.values[StorageKeys.appLocale], 'en');
    expect(repository.values[StorageKeys.isDarkMode], false);
    await Future.wait([theme.toggleTheme(), theme.toggleTheme()]);
    expect(theme.isDarkMode.value, false);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Template lookup and bilingual search retain all five templates', () {
    final controller = TemplateController();
    controller.loadTemplates();
    expect(controller.templates, hasLength(10));
    expect(controller.searchTemplates('تقني').map((t) => t.id), [
      'technical',
      'technical_en',
    ]);
    expect(controller.searchTemplates(' ATS ').map((t) => t.id), [
      'ats',
      'ats_en',
    ]);
    expect(controller.searchTemplates(''), hasLength(10));
    expect(controller.getTemplateById('unknown'), isNull);
    final ats = controller.getFieldsForTemplate('ats');
    expect(ats.showProfilePicture, false);
    expect(ats.showProjects && ats.showCertificates && ats.showLanguages, true);
    expect(TemplateFields.fromJson(ats.toJson()), ats);
  });
}
