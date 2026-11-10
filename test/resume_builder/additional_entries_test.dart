import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare() {
  final resumes = Get.put(ResumeController(repository: _Repository()));
  resumes.currentResume.value = ResumeModel(fullName: 'Draft');
  return resumes;
}

Widget _host(Widget child, {double scale = 1, bool arabic = false}) =>
    GetMaterialApp(
      locale: Locale(arabic ? 'ar' : 'en'),
      translations: AppTranslations(),
      theme: arabic ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: child,
            ),
          ),
        ),
      ),
    );
Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);
Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String value) async {
  final target = _field(key);
  await tester.ensureVisible(target);
  await tester.enterText(target, value);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  for (final kind in ['course', 'certificate', 'language']) {
    testWidgets('$kind CRUD preserves optional fields and cancels edits', (
      tester,
    ) async {
      final resumes = _prepare();
      await tester.pumpWidget(
        _host(switch (kind) {
          'course' => const CoursesStep(),
          'certificate' => const CertificatesStep(),
          _ => const LanguagesStep(),
        }),
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'add-${kind}s');
      await _tap(tester, 'save-resume-entry');
      expect(find.byType(ResumeFormDialog), findsOneWidget);
      await _type(tester, '$kind-name', 'First');
      if (kind != 'language') {
        await _type(
          tester,
          kind == 'course' ? 'course-provider' : 'certificate-organization',
          'Provider',
        );
        await _type(tester, '$kind-year', '٢٠٢٤');
        await _type(
          tester,
          kind == 'course'
              ? 'course-certificateUrl'
              : 'certificate-credentialId',
          kind == 'course' ? 'https://example.com/cert' : 'ABC-123',
        );
      }
      await _tap(tester, 'save-resume-entry');
      expect(find.byType(ResumeFormDialog), findsNothing);
      final resume = resumes.currentResume.value!;
      if (kind == 'course') expect(resume.courses.single.year, '2024');
      if (kind == 'language') {
        resume.languages.single.level = 'CEFR C1';
        resumes.currentResume.refresh();
        await tester.pumpAndSettle();
      }
      await _tap(tester, 'edit-$kind-0');
      await _type(tester, '$kind-name', 'Changed');
      await _tap(tester, 'save-resume-entry');
      if (kind == 'course') {
        expect(resume.courses.single.name, 'Changed');
        expect(
          resume.courses.single.certificateUrl,
          'https://example.com/cert',
        );
      }
      if (kind == 'certificate') {
        expect(resume.certificates.single.name, 'Changed');
        expect(resume.certificates.single.credentialId, 'ABC-123');
      }
      if (kind == 'language') {
        expect(resume.languages.single.name, 'Changed');
        expect(resume.languages.single.level, 'CEFR C1');
      }
      await _tap(tester, 'edit-$kind-0');
      await _type(tester, '$kind-name', 'Discard');
      final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(find.text('Discard'), findsNothing);
      expect(find.text('Changed'), findsOneWidget);
      await _tap(tester, 'delete-$kind-0');
      expect(find.byType(ResumeEntryCard), findsNothing);
    });
  }
  testWidgets('course validates URL and year', (tester) async {
    _prepare();
    await tester.pumpWidget(_host(const CoursesStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-courses');
    await _type(tester, 'course-name', 'Flutter');
    await _type(tester, 'course-provider', 'School');
    await _type(tester, 'course-year', 'wrong');
    await _type(tester, 'course-certificateUrl', 'javascript:alert(1)');
    await _tap(tester, 'save-resume-entry');
    expect(find.byType(CourseDialog), findsOneWidget);
    await _type(tester, 'course-year', '2024');
    await _tap(tester, 'save-resume-entry');
    expect(find.byType(CourseDialog), findsOneWidget);
    await _type(tester, 'course-certificateUrl', 'https://example.com');
    await _tap(tester, 'save-resume-entry');
    expect(find.byType(CourseDialog), findsNothing);
  });
  for (final width in [320.0, 800.0, 1920.0]) {
    for (final kind in ['courses', 'certificates', 'languages']) {
      testWidgets('$kind Arabic scaled text at $width', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final r = _prepare().currentResume.value!;
        r.courses.add(
          Course(
            name: 'دورة طويلة في هندسة البرمجيات',
            provider: 'معهد التدريب والتطوير',
            year: '2024',
            certificateUrl: 'https://example.com/long/certificate',
          ),
        );
        r.certificates.add(
          Certificate(
            name: 'شهادة معتمدة في إدارة المشاريع',
            organization: 'منظمة الاختبارات والتطوير',
            year: '2024',
            credentialId: 'ABC-123',
          ),
        );
        r.languages.add(Language(name: 'اللغة العربية', level: 'CEFR C1'));
        await tester.pumpWidget(
          _host(
            switch (kind) {
              'courses' => const CoursesStep(),
              'certificates' => const CertificatesStep(),
              _ => const LanguagesStep(),
            },
            scale: 2,
            arabic: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _tap(tester, 'add-$kind');
        expect(tester.takeException(), isNull);
        final surface = find.byKey(
          const ValueKey('resume-form-dialog-surface'),
        );
        expect(
          tester.getSize(surface).width,
          lessThanOrEqualTo(
            width < 600
                ? 500
                : width < 1200
                ? 600
                : 650,
          ),
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('save-resume-entry')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
