import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/import_resume/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service extends ResumeImportService {
  Completer<ResumeModel?>? pending;
  int calls = 0;
  @override
  Future<ResumeModel?> pickAndImport(String extension) async {
    calls++;
    return pending?.future ??
        ResumeModel(
          fullName: 'Alex Morgan',
          email: 'alex@example.com',
          skills: [Skill(name: 'Flutter', level: 4)],
        );
  }
}

Widget _host(
  Widget child, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
  bool keyboard = false,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => RepaintBoundary(
    key: const ValueKey('import-dialog-capture'),
    child: MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: true,
        viewInsets: EdgeInsets.only(bottom: keyboard ? 280 : 0),
      ),
      child: child!,
    ),
  ),
  home: child,
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('import-dialog-capture')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_09_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget _dialogs() => Scaffold(
  appBar: AppBar(title: Text('education'.tr)),
  body: Builder(
    builder: (context) => TextButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => const EducationDialog(),
      ),
      child: Text('add_education'.tr),
    ),
  ),
);
void main() {
  setUpAll(() async {
    for (final entry in {
      'Poppins': 'assets/fonts/Poppins-Regular.ttf',
      'Cairo': 'assets/fonts/Cairo-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });
  tearDown(Get.reset);
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final arabic in [false, true]) {
      for (final dark in [false, true]) {
        testWidgets('import preview $width ar=$arabic dark=$dark scale2', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, width == 1024 ? 480 : 1200);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          Get.put(ResumeController(repository: _Repository()));
          final service = _Service();
          await tester.pumpWidget(
            _host(
              ImportResumeScreen(service: service),
              arabic: arabic,
              dark: dark,
              scale: 2,
            ),
          );
          await tester.pumpAndSettle();
          final json = tester.widget<ImportOptionCard>(
            find.byKey(const ValueKey('import-option-json')),
          );
          final pdf = tester.widget<ImportOptionCard>(
            find.byKey(const ValueKey('import-option-pdf')),
          );
          expect(json.recommended, isTrue);
          expect(pdf.warning, isTrue);
          await _tap(
            tester,
            find.text('import_select_file'.trParams({'format': 'JSON'})),
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('save-imported-resume')),
          );
          await tester.pumpAndSettle();
          expect(find.byType(ImportPreviewWidget), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
              (width == 390 || width == 1920) &&
              arabic == dark) {
            await tester.pumpWidget(const SizedBox());
            await tester.pumpWidget(
              _host(
                ImportResumeScreen(service: service),
                arabic: arabic,
                dark: dark,
              ),
            );
            await tester.pumpAndSettle();
            await _capture(
              tester,
              'import_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
            );
            await _tap(
              tester,
              find.text('import_select_file'.trParams({'format': 'JSON'})),
            );
            await _capture(
              tester,
              'import_preview_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
            );
          }
        });
        testWidgets(
          'all entry dialogs $width ar=$arabic dark=$dark scale2 with keyboard',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, width == 1024 ? 480 : 1200);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final dialogs = <Widget>[
              const EducationDialog(),
              const ExperienceDialog(),
              const CourseDialog(),
              const CertificateDialog(),
              const ResumeLanguageDialog(),
              const ProjectDialog(),
              const AchievementDialog(),
            ];
            for (final dialog in dialogs) {
              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                _host(
                  Scaffold(
                    body: Builder(
                      builder: (context) => TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => dialog,
                        ),
                        child: const Text('open-dialog'),
                      ),
                    ),
                  ),
                  arabic: arabic,
                  dark: dark,
                  scale: 2,
                  keyboard: true,
                ),
              );
              await tester.tap(find.text('open-dialog'));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tester.ensureVisible(
                find.byKey(const ValueKey('save-resume-entry')),
              );
              await tester.pumpAndSettle();
              final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
              await _tap(tester, cancel);
              expect(find.byType(ResumeFormDialog), findsNothing);
              expect(tester.takeException(), isNull);
            }
            if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                (width == 390 || width == 1920) &&
                arabic == dark) {
              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                _host(_dialogs(), arabic: arabic, dark: dark),
              );
              await tester.tap(find.text('add_education'.tr));
              await tester.pumpAndSettle();
              await _capture(
                tester,
                'education_dialog_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
              );
            }
          },
        );
      }
    }
  }
  testWidgets(
    'pending file picker shows loading and blocks duplicate selection',
    (tester) async {
      Get.put(ResumeController(repository: _Repository()));
      final service = _Service()..pending = Completer<ResumeModel?>();
      await tester.pumpWidget(_host(ImportResumeScreen(service: service)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('import_select_file'.trParams({'format': 'JSON'})),
      );
      await tester.pump();
      expect(find.byType(ImportLoadingWidget), findsOneWidget);
      for (final card in tester.widgetList<ImportOptionCard>(
        find.byType(ImportOptionCard),
      )) {
        expect(card.onSelect, isNull);
      }
      expect(service.calls, 1);
      service.pending!.complete(null);
      await tester.pumpAndSettle();
      expect(find.byType(ImportLoadingWidget), findsNothing);
      expect(find.byType(ImportPreviewWidget), findsNothing);
    },
  );
}
