import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/ats_checker/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/shared_widgets/app_error_view.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    saves++;
    return resume.copyWith(id: resume.id ?? 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(Widget home) => GetMaterialApp(
  locale: const Locale('ar'),
  translations: AppTranslations(),
  theme: AppTheme.dark,
  home: home,
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () => const ResumeBuilderScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const Scaffold(body: Text('recovered-home')),
    ),
  ],
);

void main() {
  late _Repository repository;
  late ResumeController resumes;
  void prepare() {
    repository = _Repository();
    resumes = Get.put(
      ResumeController(repository: repository),
      permanent: true,
    );
    Get.put(TemplateController(), permanent: true);
    Get.put(AtsController(resumeController: resumes), permanent: true);
  }

  tearDown(Get.reset);

  for (final saved in [false, true]) {
    testWidgets(
      'unnamed ${saved ? 'saved' : 'draft'} has no ATS score or apply action',
      (tester) async {
        prepare();
        resumes.currentResume.value = ResumeModel(
          id: saved ? 7 : null,
          fullName: '   ',
        );
        await tester.pumpWidget(_host(const ATSCheckerScreen()));
        await tester.pumpAndSettle();
        expect(find.text('no_resume_to_check'.tr), findsOneWidget);
        expect(Get.find<AtsController>().result.value, isNull);
        expect(find.byKey(const ValueKey('ats-use-template')), findsNothing);
        expect(await Get.find<AtsController>().useAtsTemplate(), false);
        expect(repository.saves, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'actual ATS edit route mounts real builder and survives returning',
    (tester) async {
      prepare();
      final source = ResumeModel(
        id: 7,
        fullName: 'أحمد',
        email: 'test@example.com',
      );
      resumes.currentResume.value = source;
      await tester.pumpWidget(_host(const ATSCheckerScreen()));
      await tester.pumpAndSettle();
      final edit = find.byKey(const ValueKey('ats-edit-issue-0'));
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(find.byType(ResumeBuilderScreen), findsOneWidget);
      expect(resumes.currentResume.value?.id, 7);
      expect(resumes.currentResume.value, isNot(same(source)));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('builder-save-close')));
      await tester.pumpAndSettle();
      // Save is queued; allow its completion and the resulting route transition.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.byType(ATSCheckerScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'null fix target opens a new editor with disabled empty actions',
    (tester) async {
      prepare();
      await tester.pumpWidget(_host(const ATSCheckerScreen()));
      await tester.pumpAndSettle();
      final navigation = Get.find<AtsController>().editResume();
      await tester.pumpAndSettle();
      expect(find.byType(ResumeBuilderScreen), findsOneWidget);
      for (final key in ['builder-preview', 'builder-save-close']) {
        expect(
          tester.widget<IconButton>(find.byKey(ValueKey(key))).onPressed,
          isNull,
        );
      }
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await navigation;
      expect(repository.saves, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('unnamed preview never generates a PDF', (tester) async {
    prepare();
    resumes.currentResume.value = ResumeModel();
    await tester.pumpWidget(_host(const PreviewScreen()));
    await tester.pumpAndSettle();
    expect(find.text('resume_is_empty'.tr), findsOneWidget);
    expect(find.byKey(const ValueKey('preview-check-ats')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('missing draft while editor is open shows safe empty state', (
    tester,
  ) async {
    prepare();
    await tester.pumpWidget(_host(const ResumeBuilderScreen()));
    await tester.pumpAndSettle();
    resumes.currentResume.value = null;
    await tester.pumpAndSettle();
    expect(find.text('resume_is_empty'.tr), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('global error view returns home in Arabic dark mode', (
    tester,
  ) async {
    prepare();
    await tester.pumpWidget(_host(const AppErrorView()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('return_home'.tr));
    await tester.pumpAndSettle();
    expect(find.text('recovered-home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
