import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/features/ats_checker/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

final _pdfImages = <String, ui.Image>{};

ResumeModel _sample(bool arabic) => ResumeModel(
  id: 1,
  fullName: arabic ? 'عمر أحمد' : 'Alex Morgan',
  email: 'alex@example.com',
  phone: '+15551234567',
  address: arabic ? 'الرياض، السعودية' : 'Riyadh, Saudi Arabia',
  summary: arabic
      ? 'مطور تطبيقات متخصص في بناء تطبيقات سهلة الاستخدام وتحسين الأداء والعمل الجماعي.'
      : 'Flutter developer building accessible applications. Developed reliable products through teamwork and communication.',
  education: [
    Education(
      degree: arabic ? 'بكالوريوس علوم الحاسب' : 'BSc Computer Science',
      institution: 'University',
      year: '2020',
    ),
  ],
  experience: [
    Experience(
      jobTitle: arabic ? 'مطور تطبيقات' : 'Mobile Developer',
      company: 'Product Studio',
      startDate: '01/2021',
      isCurrent: true,
      description:
          'Developed reliable Flutter applications. Increased delivery speed by 30%.',
    ),
  ],
  skills: [
    Skill(name: 'Flutter', level: 5),
    Skill(name: 'Dart', level: 4),
    Skill(name: 'Communication', level: 4),
    Skill(name: 'Teamwork', level: 5),
    Skill(name: 'Problem-solving', level: 4),
  ],
  languages: [
    Language(name: 'English', level: 'advanced'),
    Language(name: 'العربية', level: 'native'),
  ],
  projects: [
    Project(
      name: 'CV Builder Pro',
      description: 'Accessible resume builder',
      startDate: '01/2024',
      isCurrent: true,
      technologies: ['Flutter', 'Dart'],
    ),
  ],
  linkedin: 'https://linkedin.com/in/alex',
  github: 'https://github.com/alex',
  website: 'https://example.com',
  portfolio: 'https://example.com/work',
);

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Export extends PdfExportService {
  Completer<Uint8List>? pending;
  @override
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    PdfExportQuality quality = PdfExportQuality.standard,
  }) async => pending?.future ?? Uint8List.fromList([1]);
}

void _prepare(bool arabic) {
  final resumes = Get.put(ResumeController(repository: _Repository()));
  resumes.currentResume.value = _sample(arabic);
  Get.put(AtsController(resumeController: resumes));
}

Widget _host(
  bool ats, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
  _Export? export,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('workspace-capture'),
    child: ats
        ? const ATSCheckerScreen()
        : PreviewScreen(
            exportService: export ?? _Export(),
            previewBuilder: (_) =>
                const bool.fromEnvironment('WRITE_UI_PREVIEWS')
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: RawImage(
                      image: _pdfImages[arabic ? 'ar' : 'en'],
                      fit: BoxFit.contain,
                    ),
                  )
                : const Center(child: Icon(Icons.description_outlined)),
          ),
  ),
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('workspace-capture')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_08_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
  setUpAll(() async {
    if (!const bool.fromEnvironment('WRITE_UI_PREVIEWS')) return;
    for (final locale in ['ar', 'en']) {
      final codec = await ui.instantiateImageCodec(
        await File('tmp/ui_redesign/batch_08_pdf_$locale.png').readAsBytes(),
      );
      _pdfImages[locale] = (await codec.getNextFrame()).image;
      codec.dispose();
    }
  });
  tearDownAll(() {
    for (final image in _pdfImages.values) {
      image.dispose();
    }
  });
  tearDown(Get.reset);
  if (const bool.fromEnvironment('GENERATE_PDF_FIXTURES')) {
    test('write actual PDF fixtures', () async {
      for (final arabic in [false, true]) {
        final bytes = await PdfService().generate(
          _sample(arabic),
          locale: arabic ? 'ar' : 'en',
        );
        await File(
          'tmp/ui_redesign/batch_08_pdf_${arabic ? 'ar' : 'en'}.pdf',
        ).writeAsBytes(bytes);
      }
    });
  }
  for (final ats in [false, true]) {
    for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
      for (final arabic in [false, true]) {
        for (final dark in [false, true]) {
          testWidgets(
            '${ats ? 'ATS' : 'preview'} $width ar=$arabic dark=$dark scale2',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(
                width,
                width == 1024 ? 480 : 1200,
              );
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              _prepare(arabic);
              await tester.pumpWidget(
                _host(ats, arabic: arabic, dark: dark, scale: 2),
              );
              await tester.pumpAndSettle();
              if (ats) {
                expect(find.byType(LinearProgressIndicator), findsNWidgets(7));
                await tester.ensureVisible(
                  find.byKey(const ValueKey('ats-use-template')),
                );
                await tester.pumpAndSettle();
              } else {
                if (width < 600) await _tap(tester, 'toggle-customization');
                await _tap(tester, 'font-Poppins');
                await _tap(tester, 'update-pdf-preview');
              }
              expect(tester.takeException(), isNull);
              if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                  (width == 390 || width == 1920) &&
                  arabic == dark) {
                await tester.pumpWidget(const SizedBox());
                await tester.pumpWidget(_host(ats, arabic: arabic, dark: dark));
                await tester.pumpAndSettle();
                await _capture(
                  tester,
                  '${ats ? 'ats' : 'preview'}_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
                );
              }
            },
          );
        }
      }
    }
  }
  for (final score in [-10, 0, 50, 100, 150]) {
    testWidgets(
      'gauge $score keeps numeric semantics and fits narrow large text',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            GetMaterialApp(
              locale: const Locale('en'),
              translations: AppTranslations(),
              theme: AppTheme.dark,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: Scaffold(
                body: SizedBox(width: 160, child: AtsScoreGauge(score: score)),
              ),
            ),
          );
          expect(
            find.bySemanticsLabel('${score.clamp(0, 100)} out of 100'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
  testWidgets('PDF loading respects reduced motion and resolves to preview', (
    tester,
  ) async {
    _prepare(false);
    final export = _Export()..pending = Completer<Uint8List>();
    await tester.pumpWidget(_host(false, export: export));
    await tester.pump();
    expect(find.byType(AppLoading), findsOneWidget);
    export.pending!.complete(Uint8List.fromList([1]));
    await tester.pumpAndSettle();
    expect(find.byType(AppLoading), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
