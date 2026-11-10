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
  for (final width in [320.0, 800.0, 1920.0]) {
    for (final kind in ['education', 'experience', 'skills']) {
      testWidgets('$kind fits $width with Arabic large text', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final resumes = _prepare();
        resumes.currentResume.value!.education.add(
          Education(
            degree: 'بكالوريوس طويل في هندسة البرمجيات',
            institution: 'جامعة طويلة الاسم',
            year: '2024',
            description: 'وصف الشهادة',
          ),
        );
        resumes.currentResume.value!.experience.add(
          Experience(
            jobTitle: 'مهندس برمجيات ذو خبرة',
            company: 'شركة تقنية',
            startDate: '01/2024',
            isCurrent: true,
            description: 'تطوير تطبيقات وحلول برمجية.',
          ),
        );
        resumes.currentResume.value!.skills.add(
          Skill(name: 'مهارة طويلة في تطوير البرمجيات'),
        );
        await tester.pumpWidget(
          _host(
            switch (kind) {
              'education' => const EducationStep(),
              'experience' => const ExperienceStep(),
              _ => const SkillsStep(),
            },
            scale: 2,
            arabic: true,
          ),
        );
        await tester.pumpAndSettle();
        if (kind != 'skills') {
          await _tap(tester, 'add-$kind');
          await tester.ensureVisible(
            find.byKey(const ValueKey('save-resume-entry')),
          );
          await tester.pumpAndSettle();
          expect(
            tester
                .getSize(
                  find.byKey(const ValueKey('resume-form-dialog-surface')),
                )
                .width,
            lessThanOrEqualTo(
              width < 600
                  ? 500
                  : width < 1200
                  ? 600
                  : 650,
            ),
          );
        } else {
          await tester.ensureVisible(
            find.byKey(const ValueKey('delete-skill-0')),
          );
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('education add cancel edit and delete preserve descriptions', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const EducationStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-education');
    for (final entry in {
      'education-degree': 'BSc',
      'education-institution': 'University',
      'education-year': '٢٠٢٤',
      'education-grade': 'A',
      'education-description': 'Keep this description',
    }.entries) {
      await _type(tester, entry.key, entry.value);
    }
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.education.single.year, '2024');
    await _tap(tester, 'edit-education-0');
    await _type(tester, 'education-description', 'Cancelled edit');
    final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(
      resumes.currentResume.value!.education.single.description,
      'Keep this description',
    );
    await _tap(tester, 'edit-education-0');
    await _type(tester, 'education-degree', 'MSc');
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.education.single.degree, 'MSc');
    expect(
      resumes.currentResume.value!.education.single.description,
      'Keep this description',
    );
    await _tap(tester, 'delete-education-0');
    expect(resumes.currentResume.value!.education, isEmpty);
    expect(find.text('no_education_added'.tr), findsOneWidget);
  });
  testWidgets('education requires fields and a valid year', (tester) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const EducationStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-education');
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.education, isEmpty);
    await _type(tester, 'education-degree', 'BSc');
    await _type(tester, 'education-institution', 'University');
    await _type(tester, 'education-year', '20xx');
    await _tap(tester, 'save-resume-entry');
    expect(find.text('builder_invalid_year'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.education, isEmpty);
  });
  testWidgets('experience add current job edit and delete retain description', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const ExperienceStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-experience');
    for (final entry in {
      'experience-title': 'Developer',
      'experience-company': 'Company',
      'experience-start': '١/٢٠٢٤',
      'experience-end': '12/2024',
      'experience-description': 'Developed applications',
    }.entries) {
      await _type(tester, entry.key, entry.value);
    }
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.experience.single.startDate, '01/2024');
    await _tap(tester, 'edit-experience-0');
    await _tap(tester, 'experience-current');
    expect(_field('experience-end'), findsNothing);
    await _type(tester, 'experience-title', 'Lead');
    await _tap(tester, 'save-resume-entry');
    final saved = resumes.currentResume.value!.experience.single;
    expect(saved.isCurrent, true);
    expect(saved.endDate, isNull);
    expect(saved.description, 'Developed applications');
    await _tap(tester, 'delete-experience-0');
    expect(resumes.currentResume.value!.experience, isEmpty);
  });
  testWidgets('invalid date range and future dates do not commit', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const ExperienceStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-experience');
    for (final entry in {
      'experience-title': 'Developer',
      'experience-company': 'Company',
      'experience-start': '02/2024',
      'experience-end': '01/2024',
    }.entries) {
      await _type(tester, entry.key, entry.value);
    }
    await _tap(tester, 'save-resume-entry');
    expect(find.text('invalid_date_range'.tr), findsOneWidget);
    await _type(tester, 'experience-end', '01/2099');
    await _tap(tester, 'save-resume-entry');
    expect(find.text('builder_future_date'.tr), findsOneWidget);
    await _type(tester, 'experience-start', '13/2024');
    await _tap(tester, 'save-resume-entry');
    expect(find.text('invalid_date'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.experience, isEmpty);
  });
  testWidgets('skills add edit duplicate prevention cancel and delete', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const SkillsStep()));
    await tester.pumpAndSettle();
    await _type(tester, 'skill-name', ' Flutter ');
    await tester.drag(
      find.byKey(const ValueKey('skill-level')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'save-skill');
    expect(resumes.currentResume.value!.skills.single.name, 'Flutter');
    expect(resumes.currentResume.value!.skills.single.level, 5);
    await _type(tester, 'skill-name', 'FLUTTER');
    await _tap(tester, 'save-skill');
    expect(find.text('builder_skill_duplicate'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.skills, hasLength(1));
    await _tap(tester, 'edit-skill-0');
    await _type(tester, 'skill-name', 'Flutter Pro');
    await _tap(tester, 'save-skill');
    expect(resumes.currentResume.value!.skills.single.name, 'Flutter Pro');
    await _tap(tester, 'edit-skill-0');
    await _type(tester, 'skill-name', 'Cancelled');
    await _tap(tester, 'cancel-skill-edit');
    expect(resumes.currentResume.value!.skills.single.name, 'Flutter Pro');
    await _tap(tester, 'delete-skill-0');
    expect(resumes.currentResume.value!.skills, isEmpty);
  });
  testWidgets('editing a skill cannot overwrite a different selected resume', (
    tester,
  ) async {
    final resumes = _prepare();
    resumes.currentResume.value!.skills.add(Skill(name: 'Original'));
    await tester.pumpWidget(_host(const SkillsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'edit-skill-0');
    resumes.currentResume.value = ResumeModel(
      skills: [Skill(name: 'Other resume')],
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'save-skill');
    expect(find.text('builder_entry_changed'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.skills.single.name, 'Other resume');
  });
}
