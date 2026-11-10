import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cv_builder_pro/main.dart' as application;
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'device_full_verification.dart' show verificationResume;

/// Isolated device-only repository; never modifies the user's saved resumes.
class CrashVerificationRepository implements ResumeRepository {
  final entries = <ResumeModel>[];
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() => entries.map((e) => e.copyWith()).toList();
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    saves++;
    final saved = resume.copyWith(
      id: resume.id ?? 900000 + saves,
      updatedAt: DateTime.now(),
    );
    entries.removeWhere((e) => e.id == saved.id);
    entries.add(saved.copyWith());
    return saved;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _repository = CrashVerificationRepository();
final _errors = <String>[];
File? _audit;
void _record() {
  unawaited(
    _audit?.writeAsString(
      jsonEncode({
        'errors': _errors,
        'saveCalls': _repository.saves,
        'entries': _repository.entries.map((e) => e.toJson()).toList(),
        'current': Get.find<ResumeController>().currentResume.value?.toJson(),
        'route': Get.currentRoute,
      }),
    ),
  );
}

/// Native launcher opening unchanged production screens with controlled states.
class CrashVerificationLauncher extends StatelessWidget {
  const CrashVerificationLauncher({super.key});
  Future<void> _open(
    String route,
    ResumeModel? resume, {
    bool emptyLibrary = false,
  }) async {
    final controller = Get.find<ResumeController>();
    controller.stopAutoSave();
    if (emptyLibrary) {
      _repository.entries.clear();
      controller.resumes.clear();
    }
    controller.currentResume.value = resume;
    await Get.toNamed<void>(
      route,
      arguments: route == AppRoutes.resumeBuilder ? resume : null,
    );
    _record();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Crash verification')),
    body: ListView(
      children: [
        for (final label in [
          'ATS null',
          'ATS empty',
          'ATS saved empty',
          'ATS full',
          'Preview null',
          'Preview empty',
          'Builder new',
          'Builder saved',
          'Import',
          'English dark',
          'Arabic light',
          'Global error',
        ])
          ListTile(
            title: Text(label),
            onTap: () async {
              final sample = verificationResume('modern').copyWith(id: 900001);
              switch (label) {
                case 'ATS null':
                  await _open(AppRoutes.atsChecker, null, emptyLibrary: true);
                case 'ATS empty':
                  await _open(AppRoutes.atsChecker, ResumeModel());
                case 'ATS saved empty':
                  final blank = ResumeModel(id: 900002);
                  _repository.entries.add(blank);
                  Get.find<ResumeController>().loadResumes();
                  await _open(AppRoutes.atsChecker, blank);
                case 'ATS full':
                  await _open(AppRoutes.atsChecker, sample);
                case 'Preview null':
                  await _open(AppRoutes.preview, null);
                case 'Preview empty':
                  await _open(AppRoutes.preview, ResumeModel());
                case 'Builder new':
                  await _open(AppRoutes.resumeBuilder, null);
                case 'Builder saved':
                  await _open(AppRoutes.resumeBuilder, sample);
                case 'Import':
                  await _open(AppRoutes.importResume, null);
                case 'English dark':
                  await Get.find<LanguageController>().changeLanguage('en');
                  Get.changeThemeMode(ThemeMode.dark);
                case 'Arabic light':
                  await Get.find<LanguageController>().changeLanguage('ar');
                  Get.changeThemeMode(ThemeMode.light);
                case 'Global error':
                  await Get.to<void>(
                    () => Scaffold(
                      body: Builder(
                        builder: (_) =>
                            throw StateError('QA intentional build error'),
                      ),
                    ),
                  );
              }
            },
          ),
      ],
    ),
  );
}

Future<void> main() async {
  await application.main();
  Timer(const Duration(seconds: 5), () async {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      _errors.add(
        '${Get.currentRoute}: ${details.exceptionAsString()}\n${details.stack}',
      );
      previous?.call(details);
      _record();
    };
    Get.find<ResumeController>().stopAutoSave();
    await Get.delete<AtsController>(force: true);
    await Get.delete<ResumeController>(force: true);
    final controller = Get.put(
      ResumeController(repository: _repository),
      permanent: true,
    );
    Get.put(AtsController(resumeController: controller), permanent: true);
    _audit = File(
      '${(await getTemporaryDirectory()).path}/crash_verification.json',
    );
    Timer.periodic(const Duration(seconds: 2), (_) => _record());
    Get.offAll<void>(() => const CrashVerificationLauncher());
  });
}
