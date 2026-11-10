import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';

class _Repository implements ResumeRepository {
  bool fail = false;
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw StateError('disk full');
    saves++;
    return resume.copyWith(id: resume.id ?? 1, updatedAt: DateTime(2026, 1, 1));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Export extends PdfExportService {
  bool hold = false;
  bool fail = false;
  bool cancel = false;
  int saves = 0, prints = 0, shares = 0;
  final calls = <ResumeModel>[];
  final pending = <Completer<Uint8List>>[];
  @override
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    PdfExportQuality quality = PdfExportQuality.standard,
  }) async {
    calls.add(resume.copyWith());
    if (fail) throw const PdfExportException('pdf_generation_failed');
    if (hold) {
      final next = Completer<Uint8List>();
      pending.add(next);
      return next.future;
    }
    return Uint8List.fromList([1]);
  }

  @override
  Future<String?> savePdf(Uint8List bytes, {required String name}) async {
    saves++;
    return cancel ? null : 'cv.pdf';
  }

  @override
  Future<bool> printPdf(Uint8List bytes, {required String name}) async {
    prints++;
    return !cancel;
  }

  @override
  Future<ShareResult> sharePdf(
    Uint8List bytes, {
    required String name,
    required Rect origin,
  }) async {
    shares++;
    expect(origin.width, greaterThan(0));
    return ShareResult(
      '',
      cancel ? ShareResultStatus.dismissed : ShareResultStatus.success,
    );
  }
}

ResumeController _prepare(
  _Repository repository, {
  String template = 'modern',
}) {
  final resumes = Get.put(ResumeController(repository: repository));
  resumes.currentResume.value = ResumeModel(
    fullName: 'Draft',
    templateId: template,
    customization: {
      'fontFamily': 'Cairo',
      'fontSize': 11.0,
      'primaryColor': 0xff1565c0,
      'secondaryColor': 0xff546e7a,
      'customExtension': 'retained',
    },
  );
  return resumes;
}

Widget _screen(_Export export) => PreviewScreen(
  exportService: export,
  previewBuilder: (bytes) => Center(child: Text('preview-${bytes.first}')),
);
Widget _host(
  _Export export, {
  bool arabic = false,
  double scale = 1,
  bool navigation = false,
  VoidCallback? applyAts,
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
  home: navigation
      ? Scaffold(
          body: TextButton(
            onPressed: () => Get.toNamed<void>(AppRoutes.preview),
            child: const Text('OPEN'),
          ),
        )
      : _screen(export),
  getPages: [
    GetPage(name: AppRoutes.preview, page: () => _screen(export)),
    GetPage(
      name: AppRoutes.atsChecker,
      page: () => Scaffold(
        body: TextButton(
          onPressed: () {
            applyAts?.call();
            Get.back<void>();
          },
          child: const Text('APPLY ATS'),
        ),
      ),
    ),
  ],
);
Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  testWidgets('appearance is isolated, reverts and saves all extensions', (
    tester,
  ) async {
    final repository = _Repository();
    final resumes = _prepare(repository);
    final original = resumes.currentResume.value!.copyWith();
    final export = _Export();
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    await _tap(tester, 'font-Sukar');
    expect(resumes.currentResume.value, original);
    final json = tester.widget<ResumeJsonExportButton>(
      find.byType(ResumeJsonExportButton),
    );
    expect(json.resume()!.customization!['fontFamily'], 'Sukar');
    await _tap(tester, 'reset-customization');
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('font-Cairo')))
          .selected,
      isTrue,
    );
    await _tap(tester, 'font-Poppins');
    await _tap(tester, 'save-customization');
    expect(repository.saves, 1);
    expect(resumes.isEditing.value, isTrue);
    expect(
      resumes.currentResume.value!.customization!['fontFamily'],
      'Poppins',
    );
    expect(
      resumes.currentResume.value!.customization!['customExtension'],
      'retained',
    );
  });
  testWidgets('failed save keeps current resume unchanged and allows retry', (
    tester,
  ) async {
    final repository = _Repository()..fail = true;
    final resumes = _prepare(repository);
    final original = resumes.currentResume.value!.copyWith();
    final export = _Export();
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    await _tap(tester, 'font-Sukar');
    await _tap(tester, 'save-customization');
    expect(resumes.currentResume.value, original);
    expect(find.text('pdf_customization_save_failed'.tr), findsOneWidget);
    repository.fail = false;
    await _tap(tester, 'save-customization');
    expect(resumes.currentResume.value!.customization!['fontFamily'], 'Sukar');
  });
  testWidgets('new generation wins when earlier request finishes later', (
    tester,
  ) async {
    _prepare(_Repository());
    final export = _Export()..hold = true;
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    expect(export.pending.length, 1);
    await _tap(tester, 'pdf-quality-high');
    expect(export.pending.length, 2);
    export.pending[1].complete(Uint8List.fromList([2]));
    await tester.pumpAndSettle();
    expect(find.text('preview-2'), findsOneWidget);
    export.pending[0].complete(Uint8List.fromList([1]));
    await tester.pumpAndSettle();
    expect(find.text('preview-2'), findsOneWidget);
    expect(find.text('preview-1'), findsNothing);
  });
  testWidgets('generation failure exposes retry', (tester) async {
    _prepare(_Repository());
    final export = _Export()..fail = true;
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    expect(find.text('pdf_generation_failed'.tr), findsWidgets);
    export.fail = false;
    await tester.tap(find.text('retry'.tr));
    await tester.pumpAndSettle();
    expect(find.text('preview-1'), findsOneWidget);
  });
  testWidgets(
    'save, print and share use current unsaved settings and handle cancellation',
    (tester) async {
      final resumes = _prepare(_Repository());
      final export = _Export()..cancel = true;
      await tester.pumpWidget(_host(export));
      await tester.pumpAndSettle();
      await _tap(tester, 'font-Poppins');
      await _tap(tester, 'preview-save-pdf');
      await _tap(tester, 'preview-print-pdf');
      await _tap(tester, 'preview-share-pdf');
      expect(export.saves, 1);
      expect(export.prints, 1);
      expect(export.shares, 1);
      expect(export.calls.last.customization!['fontFamily'], 'Poppins');
      expect(
        resumes.currentResume.value!.customization!['fontFamily'],
        'Cairo',
      );
      expect(find.text('pdf_saved'.tr), findsNothing);
      expect(find.text('pdf_print_submitted'.tr), findsNothing);
      expect(find.text('pdf_share_opened'.tr), findsNothing);
    },
  );
  testWidgets('ATS conversion reloads fixed template controls', (tester) async {
    final resumes = _prepare(_Repository());
    final export = _Export();
    await tester.pumpWidget(
      _host(
        export,
        applyAts: () => resumes.currentResume.value = resumes
            .currentResume
            .value!
            .copyWith(templateId: 'ats'),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'preview-check-ats');
    await tester.tap(find.text('APPLY ATS'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomizationPanel), findsNothing);
    expect(export.calls.last.templateId, 'ats');
    expect(find.text('pdf_ats_fixed_note'.tr), findsOneWidget);
  });
  testWidgets(
    'back supports cancel and explicit discard without changing resume',
    (tester) async {
      final resumes = _prepare(_Repository());
      final export = _Export();
      await tester.pumpWidget(_host(export, navigation: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
      await _tap(tester, 'font-Sukar');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('cancel'.tr));
      await tester.pumpAndSettle();
      expect(find.byType(PreviewScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await _tap(tester, 'preview-leave-discard');
      expect(find.text('OPEN'), findsOneWidget);
      expect(
        resumes.currentResume.value!.customization!['fontFamily'],
        'Cairo',
      );
    },
  );
  testWidgets('empty selection has a useful state', (tester) async {
    final resumes = _prepare(_Repository());
    resumes.currentResume.value = null;
    await tester.pumpWidget(_host(_Export()));
    await tester.pumpAndSettle();
    expect(find.text('export_no_resume'.tr), findsOneWidget);
  });
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('preview and customization fit Arabic text scale 2 at $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      _prepare(_Repository());
      await tester.pumpWidget(_host(_Export(), arabic: true, scale: 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (width == 320) {
        await _tap(tester, 'toggle-customization');
      } else {
        expect(
          find.byKey(const ValueKey('preview-side-by-side')),
          findsOneWidget,
        );
      }
      await _tap(tester, 'font-Sukar');
      expect(tester.takeException(), isNull);
      await _tap(tester, 'update-pdf-preview');
      expect(tester.takeException(), isNull);
    });
  }
  for (final arabic in [false, true]) {
    testWidgets(
      'mobile customization uses one scroll through reset ar=$arabic',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 700);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final resumes = _prepare(_Repository());
        await tester.pumpWidget(_host(_Export(), arabic: arabic, scale: 2));
        await tester.pumpAndSettle();
        await _tap(tester, 'toggle-customization');
        expect(
          find.byKey(const ValueKey('customization-scroll')),
          findsNothing,
        );
        await _tap(tester, 'font-Sukar');
        final reset = find.byKey(const ValueKey('reset-customization'));
        await tester.dragUntilVisible(
          reset,
          find.byKey(const ValueKey('preview-mobile-scroll')),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(reset).bottom, lessThanOrEqualTo(700));
        await tester.tap(reset);
        await tester.pumpAndSettle();
        expect(tester.widget<AppButton>(reset).onPressed, isNull);
        expect(
          resumes.currentResume.value?.customization?['fontFamily'],
          'Cairo',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
  testWidgets('custom color dialog remains reachable on small Arabic screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    _prepare(_Repository());
    await tester.pumpWidget(_host(_Export(), arabic: true, scale: 2));
    await tester.pumpAndSettle();
    await _tap(tester, 'toggle-customization');
    await _tap(tester, 'custom-color-primary');
    expect(tester.takeException(), isNull);
    final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.pumpAndSettle();
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
