import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cv_builder_pro/app/app.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/shared_widgets/app_error_view.dart';
import 'device_full_verification.dart' show verificationResume;

final _errors = <Map<String, String>>[];
late Directory _directory;
late ResumeRepository _repository;
late ResumeRepository _original;
bool _commandBusy = false;
bool _archiveBusy = false;
String _lastCommand = '';
String _ack = '';
String _lastPreview = '';

Future<void> _audit() async {
  if (!Get.isRegistered<ResumeController>()) return;
  try {
    final c = Get.find<ResumeController>();
    await File('${_directory.path}/audit.json').writeAsString(
      jsonEncode({
        'ack': _ack,
        'route': Get.currentRoute,
        'errors': _errors,
        'resumes': _repository.loadResumes().map((e) => e.toJson()).toList(),
        'current': c.currentResume.value?.toJson(),
        'locale': Get.locale?.languageCode,
        'profile': _repository.read<String>(StorageKeys.profileImage),
        'dark': Get.find<ThemeController>().isDarkMode.value,
        'metrics': {
          'physicalWidth':
              ui.PlatformDispatcher.instance.views.first.physicalSize.width,
          'physicalHeight':
              ui.PlatformDispatcher.instance.views.first.physicalSize.height,
          'dpr': ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
          'keyboardBottom':
              ui.PlatformDispatcher.instance.views.first.viewInsets.bottom,
        },
      }),
    );
  } catch (_) {
    /* Audit files must not interfere with production UI. */
  }
}

Future<void> _command() async {
  if (_commandBusy || !Get.isRegistered<ResumeController>()) return;
  final file = File('${_directory.path}/command.json');
  if (!await file.exists()) return;
  _commandBusy = true;
  try {
    final raw = await file.readAsString();
    if (raw == _lastCommand) return;
    final command = jsonDecode(raw) as Map<String, dynamic>;
    _lastCommand = raw;
    await File('${_directory.path}/processed.json').writeAsString(raw);
    final c = Get.find<ResumeController>();
    final action = command['action'];
    if (action == 'verify-original') {
      final before = await File(
        '${_directory.path}/original_snapshot.json',
      ).readAsString();
      final after = jsonEncode(
        _original.loadResumes().map((e) => e.toJson()).toList(),
      );
      await File('${_directory.path}/original_preserved.json').writeAsString(
        jsonEncode({
          'unchanged': before == after,
          'count': _original.loadResumes().length,
        }),
      );
    } else {
      c.stopAutoSave();
      Get.offAllNamed<void>(AppRoutes.home);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (action == 'fixture') {
        final id = command['template'] as String? ?? 'modern';
        await Get.find<LanguageController>().changeLanguage(
          command['locale'] as String? ?? (id.endsWith('_en') ? 'en' : 'ar'),
        );
        var model = verificationResume(
          id,
        ).copyWith(fullName: command['name'] as String? ?? 'أحمد محمد العُمري');
        if (command['save'] == true) await c.saveResume(model);
        c.currentResume.value = model;
        unawaited(
          Get.toNamed<void>(
            command['preview'] == true
                ? AppRoutes.preview
                : AppRoutes.resumeBuilder,
            arguments: model,
          ),
        );
      } else if (action == 'null' ||
          action == 'empty' ||
          action == 'saved-empty') {
        ResumeModel? model;
        if (action != 'null') model = ResumeModel();
        if (action == 'saved-empty' && model != null) await c.saveResume(model);
        c.currentResume.value = model;
        unawaited(
          Get.toNamed<void>(
            command['route'] as String? ?? AppRoutes.atsChecker,
          ),
        );
      } else {
        unawaited(
          Get.toNamed<void>(command['route'] as String? ?? AppRoutes.home),
        );
      }
    }
    _ack = command['id'] as String;
    await _audit();
  } catch (error, stack) {
    _errors.add({
      'route': Get.currentRoute,
      'error': 'QA command: $error',
      'stack': '$stack',
    });
  } finally {
    _commandBusy = false;
  }
}

Future<void> _archive() async {
  if (_archiveBusy || Get.currentRoute != AppRoutes.preview) return;
  final current = Get.find<ResumeController>().currentResume.value;
  if (current == null || current.fullName.trim().isEmpty) return;
  final fingerprint = jsonEncode(current.toJson());
  if (fingerprint == _lastPreview) return;
  _archiveBusy = true;
  try {
    final model = current.copyWith();
    final bytes = await PdfExportService().generate(
      model,
      locale: Get.locale?.languageCode ?? 'en',
    );
    final name = '${model.templateId}_${Get.locale?.languageCode ?? 'en'}';
    await File('${_directory.path}/$name.pdf').writeAsBytes(bytes);
    await File(
      '${_directory.path}/$name.json',
    ).writeAsString(jsonEncode(model.toJson()));
    _lastPreview = fingerprint;
  } catch (error, stack) {
    _errors.add({
      'route': Get.currentRoute,
      'error': 'Archive: $error',
      'stack': '$stack',
    });
  } finally {
    _archiveBusy = false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _directory = Directory(
    '${(await getTemporaryDirectory()).path}/comprehensive_qa',
  );
  await _directory.create(recursive: true);
  final processed = File('${_directory.path}/processed.json');
  if (await processed.exists()) _lastCommand = await processed.readAsString();
  _original = await ResumeRepository.initialize();
  final originalFile = File('${_directory.path}/original_snapshot.json');
  if (!await originalFile.exists()) {
    await originalFile.writeAsString(
      jsonEncode(_original.loadResumes().map((e) => e.toJson()).toList()),
    );
  }
  _repository = await ResumeRepository.initialize(
    container: 'cv_builder_comprehensive_qa_20261030',
  );
  Get.put<ResumeRepository>(_repository, permanent: true);
  ErrorWidget.builder = (_) => const AppErrorView();
  final prior = FlutterError.onError;
  FlutterError.onError = (details) {
    _errors.add({
      'route': Get.currentRoute,
      'error': details.exceptionAsString(),
      'stack': '${details.stack}',
    });
    prior?.call(details);
    unawaited(_audit());
  };
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    _errors.add({
      'route': Get.currentRoute,
      'error': '$error',
      'stack': '$stack',
    });
    unawaited(_audit());
    return false;
  };
  runApp(const CvBuilderApp());
  Timer.periodic(
    const Duration(milliseconds: 350),
    (_) => unawaited(_command()),
  );
  Timer.periodic(const Duration(seconds: 1), (_) {
    unawaited(_audit());
    unawaited(_archive());
  });
}
