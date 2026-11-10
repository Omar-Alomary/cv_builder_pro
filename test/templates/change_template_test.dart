import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/shared_widgets/resume_template_picker.dart';
import 'package:cv_builder_pro/translations/app_translations.dart';

class _Repository implements ResumeRepository {
  bool fail = false;
  int writes = 0;
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw StateError('unavailable');
    writes++;
    return resume.copyWith(
      id: resume.id ?? 90,
      updatedAt: DateTime(2026, 10, 29),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);
  for (final scenario in ['save', 'failure', 'cancel', 'same']) {
    testWidgets('template picker $scenario retains every resume field', (
      tester,
    ) async {
      final repository = _Repository()..fail = scenario == 'failure';
      final controller = Get.put(ResumeController(repository: repository));
      Get.put(TemplateController());
      final original = ResumeModel(
        id: 7,
        templateId: 'modern',
        fullName: 'أحمد',
        email: 'ahmed@example.com',
        skills: [Skill(name: 'Dart')],
        customization: {'fontFamily': 'Sukar'},
        isFavorite: true,
      );
      controller.currentResume.value = original;
      final before = original.copyWith();
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => ResumeTemplatePicker.show(context, original),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(
        (tester
                    .widget<GridView>(
                      find.byKey(const ValueKey('change-template-grid')),
                    )
                    .childrenDelegate
                as SliverChildBuilderDelegate)
            .estimatedChildCount,
        10,
      );
      if (scenario == 'cancel') {
        Navigator.of(
          tester.element(find.byKey(const ValueKey('change-template-grid'))),
        ).pop();
      } else {
        await tester.tap(
          find.byKey(
            ValueKey(
              'change-template-${scenario == 'same' ? 'modern' : 'classic'}',
            ),
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(original, before);
      if (scenario == 'save') {
        expect(repository.writes, 1);
        expect(controller.currentResume.value!.templateId, 'classic');
        expect(controller.currentResume.value!.skills, before.skills);
        expect(
          controller.currentResume.value!.customization,
          before.customization,
        );
        expect(controller.currentResume.value!.isFavorite, true);
      } else {
        expect(repository.writes, 0);
        expect(controller.currentResume.value, before);
      }
    });
  }
  testWidgets('template picker fits 320 RTL dark large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _Repository();
    Get.put(ResumeController(repository: repository));
    Get.put(TemplateController());
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('ar'),
        translations: AppTranslations(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => ResumeTemplatePicker.show(
                context,
                ResumeModel(templateId: 'ats_en'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(
      tester.element(find.byKey(const ValueKey('change-template-grid'))),
    ).pop();
    await tester.pumpAndSettle();
  });
}
