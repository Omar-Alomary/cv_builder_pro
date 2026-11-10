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
  testWidgets('project validates range, edits all fields and cancels safely', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const ProjectsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-projects');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects, isEmpty);
    await _type(tester, 'project-title', 'App');
    await _type(tester, 'project-start', '٠٢/٢٠٢٤');
    await _type(tester, 'project-end', '01/2024');
    await _type(tester, 'project-description', 'Built app');
    await _type(tester, 'project-technologies', 'Dart\nFlutter, Web');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects, isEmpty);
    await _type(tester, 'project-end', '03/2024');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects.single.startDate, '02/2024');
    expect(r.projects.single.technologies, ['Dart', 'Flutter, Web']);
    await _tap(tester, 'edit-project-0');
    await _type(tester, 'project-title', 'Discard');
    final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(r.projects.single.name, 'App');
    await _tap(tester, 'edit-project-0');
    await _tap(tester, 'project-current');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects.single.isCurrent, isTrue);
    expect(r.projects.single.endDate, isNull);
    expect(r.projects.single.technologies, ['Dart', 'Flutter, Web']);
    await _tap(tester, 'delete-project-0');
    expect(r.projects, isEmpty);
  });
  testWidgets('achievement preserves custom category and organization', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const AchievementsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-achievements');
    await _type(tester, 'achievement-name', 'Award');
    await _type(tester, 'achievement-description', 'Won award');
    await _type(tester, 'achievement-date', '٠١/٢٠٢٤');
    await _type(tester, 'achievement-category', 'Custom imported');
    await _type(tester, 'achievement-organization', 'University');
    await _tap(tester, 'save-resume-entry');
    expect(r.achievements.single.date, '01/2024');
    await _tap(tester, 'edit-achievement-0');
    await _type(tester, 'achievement-name', 'Updated');
    await _tap(tester, 'save-resume-entry');
    expect(r.achievements.single.category, 'Custom imported');
    expect(r.achievements.single.organization, 'University');
    expect(r.achievements.single.name, 'Updated');
    await _tap(tester, 'delete-achievement-0');
    expect(r.achievements, isEmpty);
  });
  testWidgets('interests add, deduplicate, edit, cancel, toggle and remove', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const InterestsStep()));
    await tester.pumpAndSettle();
    await _type(tester, 'interest-name', 'Reading');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Reading']);
    await _type(tester, 'interest-name', ' reading ');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Reading']);
    await _tap(tester, 'edit-interest-0');
    await _type(tester, 'interest-name', 'Custom hobby');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'edit-interest-0');
    await _type(tester, 'interest-name', 'Discard');
    await _tap(tester, 'cancel-interest');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'interest-suggestion-Reading');
    expect(r.interests, ['Custom hobby', 'Reading']);
    await _tap(tester, 'interest-suggestion-Reading');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'delete-interest-0');
    expect(r.interests, isEmpty);
  });
  for (final width in [320.0, 800.0, 1920.0]) {
    for (final kind in ['projects', 'achievements', 'interests']) {
      testWidgets('$kind Arabic scaled text at $width', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final r = _prepare().currentResume.value!;
        r.projects.add(
          Project(
            name: 'مشروع طويل في تطوير التطبيقات',
            description: 'تطوير حلول تقنية متقدمة ومتنوعة',
            startDate: '01/2024',
            isCurrent: true,
            technologies: ['Flutter', 'Dart'],
          ),
        );
        r.achievements.add(
          Achievement(
            name: 'إنجاز طويل في تطوير البرمجيات',
            description: 'وصف تفصيلي للإنجاز',
            date: '01/2024',
            category: 'تصنيف مخصص',
          ),
        );
        r.interests = ['اهتمام مخصص طويل في تطوير البرمجيات'];
        await tester.pumpWidget(
          _host(
            switch (kind) {
              'projects' => const ProjectsStep(),
              'achievements' => const AchievementsStep(),
              _ => const InterestsStep(),
            },
            scale: 2,
            arabic: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (kind != 'interests') {
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
        } else {
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('edit-interest-0')),
            300,
            scrollable: find.byType(Scrollable).first,
          );
          await _tap(tester, 'edit-interest-0');
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
