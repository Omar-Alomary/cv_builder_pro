import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/import_resume/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final saved = <ResumeModel>[];
  bool fail = false;
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw Exception('disk failure');
    final value = resume.copyWith(id: saved.length + 1);
    saved.add(value);
    return value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service extends ResumeImportService {
  ResumeModel? result;
  String? selected;
  bool fail = false;
  @override
  Future<ResumeModel?> pickAndImport(String extension) async {
    selected = extension;
    if (fail) throw const ImportException('import_invalid_pdf');
    return result;
  }
}

Widget _host(
  _Service service, {
  double scale = 1,
  bool arabic = false,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: arabic ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: ImportResumeScreen(service: service),
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
  ],
);
Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('import fits width $width with Arabic large text and preview', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final service = _Service()..result = ResumeModel(fullName: 'عمر');
      Get.put(ResumeController(repository: _Repository()));
      await tester.pumpWidget(_host(service, scale: 2, arabic: true));
      await tester.pumpAndSettle();
      final button = find.text(
        'import_select_file'.trParams({'format': 'JSON'}),
      );
      await _tap(tester, button);
      await tester.ensureVisible(
        find.byKey(const ValueKey('save-imported-resume')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ImportPreviewWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('paste preview edit save imports new ID and opens builder', (
    tester,
  ) async {
    final repository = _Repository();
    Get.put(ResumeController(repository: repository));
    ResumeModel? draft;
    await tester.pumpWidget(
      _host(_Service(), capture: (value) => draft = value as ResumeModel),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(_field('paste-resume-json'));
    await tester.enterText(
      _field('paste-resume-json'),
      '{"fullName":"Alice","id":999,"profilePicture":"/foreign/file","isFavorite":true,"skills":[{"name":"Dart","level":3}]}',
    );
    await _tap(tester, find.byKey(const ValueKey('parse-pasted-json')));
    expect(repository.saved, isEmpty);
    await tester.enterText(
      _field('import-preview-json'),
      '{"fullName":"Edited","id":999,"profilePicture":"/foreign/file","isFavorite":true,"skills":[{"name":"Flutter","level":3}]}',
    );
    await _tap(tester, find.byKey(const ValueKey('save-imported-resume')));
    expect(repository.saved.single.fullName, 'Edited');
    expect(draft!.id, 1);
    expect(draft!.profilePicture, isNull);
    expect(draft!.isFavorite, false);
    expect(draft!.skills.single.name, 'Flutter');
  });
  testWidgets('picker cancel leaves preview empty and PDF error is reported', (
    tester,
  ) async {
    Get.put(ResumeController(repository: _Repository()));
    final service = _Service();
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await _tap(
      tester,
      find.text('import_select_file'.trParams({'format': 'TXT'})),
    );
    expect(service.selected, 'txt');
    expect(find.byType(ImportPreviewWidget), findsNothing);
    service.fail = true;
    await _tap(
      tester,
      find.text('import_select_file'.trParams({'format': 'PDF'})),
    );
    expect(find.text('import_invalid_pdf'.tr), findsOneWidget);
  });
  testWidgets('invalid JSON does not create preview', (tester) async {
    final repository = _Repository();
    Get.put(ResumeController(repository: repository));
    await tester.pumpWidget(_host(_Service()));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('parse-pasted-json')));
    expect(find.text('import_invalid_json'.tr), findsOneWidget);
    expect(repository.saved, isEmpty);
  });
  testWidgets('failed save keeps editable preview', (tester) async {
    final repository = _Repository()..fail = true;
    Get.put(ResumeController(repository: repository));
    final service = _Service()..result = ResumeModel(fullName: 'Alice');
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await _tap(
      tester,
      find.text('import_select_file'.trParams({'format': 'JSON'})),
    );
    await _tap(tester, find.byKey(const ValueKey('save-imported-resume')));
    expect(find.byType(ImportPreviewWidget), findsOneWidget);
    expect(repository.saved, isEmpty);
  });
}
