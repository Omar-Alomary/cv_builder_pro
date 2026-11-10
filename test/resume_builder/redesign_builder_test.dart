import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

ResumeModel _seed() => ResumeModel(
  id: 1,
  fullName: 'Alex Morgan',
  email: 'alex@example.com',
  phone: '+15551234567',
  summary: 'Flutter developer building accessible mobile applications.',
  education: List.generate(
    2,
    (i) => Education(
      degree: 'Degree $i',
      institution: 'University',
      year: '2020',
      description: 'Computer science and software engineering.',
    ),
  ),
  experience: List.generate(
    2,
    (i) => Experience(
      jobTitle: 'Developer $i',
      company: 'Studio',
      startDate: '01/2021',
      isCurrent: true,
      description: 'Developed accessible mobile applications.',
    ),
  ),
  courses: List.generate(
    2,
    (i) => Course(name: 'Course $i', provider: 'Academy', year: '2022'),
  ),
  certificates: List.generate(
    2,
    (i) => Certificate(
      name: 'Certificate $i',
      organization: 'Academy',
      year: '2023',
    ),
  ),
  languages: List.generate(
    2,
    (i) => Language(name: 'Language $i', level: 'advanced'),
  ),
  projects: List.generate(
    2,
    (i) => Project(
      name: 'Project $i',
      description: 'Accessible application',
      startDate: '01/2024',
      isCurrent: true,
      technologies: ['Flutter', 'Dart'],
    ),
  ),
  achievements: List.generate(
    2,
    (i) => Achievement(
      name: 'Achievement $i',
      description: 'Delivered a successful product',
      date: '01/2025',
    ),
  ),
  skills: [
    Skill(name: 'Flutter', level: 5),
    Skill(name: 'Communication', level: 3),
  ],
  interests: ['Reading', 'Coding'],
);

class _Repository implements ResumeRepository {
  ResumeModel saved = _seed();
  @override
  List<ResumeModel> loadResumes() => [saved.copyWith()];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    saved = resume.copyWith(id: 1, updatedAt: DateTime.now());
    return saved.copyWith();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare(_Repository repository) {
  final controller = Get.put(ResumeController(repository: repository));
  Get.put(TemplateController());
  controller.currentResume.value = repository.saved.copyWith();
  return controller;
}

Widget _host(
  Widget child, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
  bool motion = false,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: !motion,
    ),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('builder-capture-boundary'),
    child: child,
  ),
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('builder-capture-boundary')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_07_$name.png',
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

Widget _section(String name) => switch (name) {
  'education' => const EducationStep(),
  'experience' => const ExperienceStep(),
  'courses' => const CoursesStep(),
  'certificates' => const CertificatesStep(),
  'languages' => const LanguagesStep(),
  'projects' => const ProjectsStep(),
  _ => const AchievementsStep(),
};
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
  testWidgets('next stays visible on a small screen with keyboard open', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    _prepare(_Repository());
    await tester.pumpWidget(_host(const ResumeBuilderScreen()));
    await tester.pumpAndSettle();
    final next = find.byKey(const ValueKey('builder-next'));
    expect(next.hitTestable(), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();
    expect(next.hitTestable(), findsOneWidget);
    expect(tester.getRect(next).bottom, lessThanOrEqualTo(380));
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final arabic in [false, true]) {
      for (final dark in [false, true]) {
        testWidgets('all builder stages $width ar=$arabic dark=$dark scale2', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, width == 1024 ? 480 : 1200);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          _prepare(_Repository());
          // Exercise all optional sections using the ATS field configuration.

          await tester.pumpWidget(
            _host(
              const ResumeBuilderScreen(),
              arabic: arabic,
              dark: dark,
              scale: 2,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Get.find<ResumeController>().currentResume.value = _seed().copyWith(
            templateId: 'ats',
          );
          await tester.pumpAndSettle();
          // Keep validation tied to actual form edits as in the existing tests.
          for (final entry in {
            'fullName': 'Alex Morgan',
            'email': 'alex@example.com',
            'phone': '+15551234567',
          }.entries) {
            final field = find.descendant(
              of: find.byKey(ValueKey('personal-${entry.key}')),
              matching: find.byType(TextFormField),
            );
            await tester.ensureVisible(field);
            await tester.enterText(field, entry.value);
            await tester.pumpAndSettle();
          }
          for (var step = 1; step < 5; step++) {
            await _tap(tester, find.byKey(ValueKey('builder-step-$step')));
            expect(tester.takeException(), isNull);
            if (step == 4) {
              for (final name in [
                'courses',
                'certificates',
                'languages',
                'projects',
                'achievements',
                'interests',
              ]) {
                await _tap(tester, find.byKey(ValueKey('additional-$name')));
                expect(tester.takeException(), isNull);
              }
            }
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        });
      }
    }
  }
  for (final section in [
    'education',
    'experience',
    'courses',
    'certificates',
    'languages',
    'projects',
    'achievements',
  ]) {
    testWidgets('$section reorder survives saving and preserves source copy', (
      tester,
    ) async {
      final repository = _Repository();
      final controller = _prepare(repository);
      await tester.pumpWidget(_host(Scaffold(body: _section(section))));
      await tester.pumpAndSettle();
      final before = controller.currentResume.value!.toJson()[section] as List;
      final first = before.first;
      tester
          .widget<ReorderableListView>(find.byType(ReorderableListView))
          .onReorder(0, 2);
      await tester.pumpAndSettle();
      expect(
        (controller.currentResume.value!.toJson()[section] as List).last,
        first,
      );
      expect((repository.saved.toJson()[section] as List).first, first);
      await controller.saveResume(controller.currentResume.value!);
      expect((repository.saved.toJson()[section] as List).last, first);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('education accepts an actual long-press reorder gesture', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _prepare(_Repository());
    final first = controller.currentResume.value!.education.first;
    await tester.pumpWidget(_host(const Scaffold(body: EducationStep())));
    await tester.pumpAndSettle();
    final cards = find.byType(ResumeEntryCard);
    final point = tester.getCenter(
      find.byType(ReorderableDragStartListener).first,
    );
    final destination =
        tester.getBottomRight(cards.last) - const Offset(100, 10);
    final gesture = await tester.startGesture(point);
    await tester.pump(const Duration(milliseconds: 700));
    for (var segment = 1; segment <= 30; segment++) {
      await gesture.moveTo(Offset.lerp(point, destination, segment / 30)!);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.currentResume.value!.education.last, same(first));
  });
  testWidgets('step animations retain personal form edits', (tester) async {
    _prepare(_Repository());
    await tester.pumpWidget(_host(const ResumeBuilderScreen(), motion: true));
    await tester.pumpAndSettle();
    for (final entry in {
      'fullName': 'Alex Morgan',
      'email': 'alex@example.com',
      'phone': '+15551234567',
    }.entries) {
      final field = find.descendant(
        of: find.byKey(ValueKey('personal-${entry.key}')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
      await tester.pumpAndSettle();
    }
    await _tap(tester, find.byKey(const ValueKey('builder-step-1')));
    await _tap(tester, find.byKey(const ValueKey('builder-step-0')));
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('personal-fullName')),
              matching: find.byType(TextFormField),
            ),
          )
          .controller!
          .text,
      'Alex Morgan',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  if (const bool.fromEnvironment('WRITE_UI_PREVIEWS')) {
    for (final dark in [false, true]) {
      for (final width in [390.0, 1920.0]) {
        testWidgets('capture builder and skills $width dark=$dark', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final controller = _prepare(_Repository());
          await tester.pumpWidget(
            _host(const ResumeBuilderScreen(), arabic: dark, dark: dark),
          );
          await tester.pumpAndSettle();
          await _capture(
            tester,
            'personal_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
          );
          controller.currentResume.value = _seed();
          await tester.pumpAndSettle();
          await _tap(tester, find.byKey(const ValueKey('builder-step-3')));
          await _capture(
            tester,
            'skills_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        });
      }
    }
  }
}
