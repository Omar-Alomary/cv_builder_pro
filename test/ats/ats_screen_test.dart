import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/ats_checker/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final entries = [
    ResumeModel(id: 1, fullName: 'Alice'),
    ResumeModel(id: 2, fullName: 'عمر'),
  ];
  bool fail = false;
  ResumeModel? saved;
  @override
  List<ResumeModel> loadResumes() =>
      entries.map((resume) => resume.copyWith()).toList();
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw Exception('disk failure');
    saved = resume.copyWith(id: resume.id ?? 3);
    return saved!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host({
  bool arabic = false,
  double scale = 1,
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
  home: const ATSCheckerScreen(),
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () {
        capture?.call(Get.arguments);
        return Scaffold(
          body: TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('return-from-builder'),
          ),
        );
      },
    ),
  ],
);
ResumeController _prepare(_Repository repository, {bool select = true}) {
  final resumes = Get.put(ResumeController(repository: repository));
  if (select) resumes.currentResume.value = resumes.resumes.first.copyWith();
  Get.put(AtsController(resumeController: resumes));
  return resumes;
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 600.0, 1200.0, 1920.0]) {
    testWidgets('ATS layout fits $width with large Arabic text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 600 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      _prepare(_Repository());
      await tester.pumpWidget(_host(arabic: true, scale: 2));
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          ValueKey(width < 600 ? 'ats-mobile-layout' : 'ats-wide-layout'),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('ats-use-template')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('no selection supports choosing an independent saved resume', (
    tester,
  ) async {
    final repository = _Repository();
    final resumes = _prepare(repository, select: false);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    expect(find.text('no_resume_to_check'.tr), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('ats-choose-resume')));
    await _tap(tester, find.byKey(const ValueKey('ats-select-2')));
    expect(resumes.currentResume.value!.id, 2);
    expect(find.byType(AtsScoreGauge), findsOneWidget);
    resumes.currentResume.value!.fullName = 'Changed';
    expect(repository.entries[1].fullName, 'عمر');
  });
  testWidgets('recheck uses edits made to current draft', (tester) async {
    final resumes = _prepare(_Repository());
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    final before = Get.find<AtsController>().result.value!.overallScore;
    resumes.currentResume.value!.email = 'alice@example.com';
    await _tap(tester, find.byKey(const ValueKey('ats-recheck')));
    expect(Get.find<AtsController>().result.value!.overallScore, before + 5);
  });
  testWidgets('applying ATS persists settings and reanalyzes formatting', (
    tester,
  ) async {
    final repository = _Repository();
    final resumes = _prepare(repository);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('ats-use-template')));
    expect(repository.saved!.templateId, 'ats');
    expect(resumes.currentResume.value!.customization!['fontSize'], 11);
    expect(
      Get.find<AtsController>().result.value!.sectionScores['formatting'],
      10,
    );
  });
  testWidgets('save failure preserves template and reports error', (
    tester,
  ) async {
    final repository = _Repository()..fail = true;
    final resumes = _prepare(repository);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('ats-use-template')));
    expect(resumes.currentResume.value!.templateId, 'modern');
    expect(find.text('ats_save_failed'.tr), findsOneWidget);
  });
  testWidgets('issue edit passes a copy and rechecks after return', (
    tester,
  ) async {
    final resumes = _prepare(_Repository());
    ResumeModel? draft;
    await tester.pumpWidget(
      _host(capture: (value) => draft = value as ResumeModel),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('ats-edit-issue-0')));
    expect(draft!.id, 1);
    expect(identical(draft, resumes.currentResume.value), false);
    draft!.email = 'alice@example.com';
    resumes.currentResume.value = draft;
    await tester.tap(find.text('return-from-builder'));
    await tester.pumpAndSettle();
    expect(Get.find<AtsController>().result.value, isNotNull);
  });
  testWidgets('issues sort critical before warning and info', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: AtsIssuesList(
              issues: [
                AtsIssue(
                  severity: 'info',
                  category: 'skills',
                  description: 'Info finding',
                  suggestion: 'Improve',
                ),
                AtsIssue(
                  severity: 'critical',
                  category: 'contact',
                  description: 'Critical finding',
                  suggestion: 'Fix',
                ),
                AtsIssue(
                  severity: 'warning',
                  category: 'summary',
                  description: 'Warning finding',
                  suggestion: 'Review',
                ),
              ],
              onEdit: () async {},
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('Critical finding')).dy,
      lessThan(tester.getTopLeft(find.text('Warning finding')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Warning finding')).dy,
      lessThan(tester.getTopLeft(find.text('Info finding')).dy),
    );
  });
  testWidgets('score has a spoken numeric equivalent', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          translations: AppTranslations(),
          home: const Scaffold(
            body: SizedBox(width: 300, child: AtsScoreGauge(score: 85)),
          ),
        ),
      );
      expect(find.bySemanticsLabel('85 out of 100'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
