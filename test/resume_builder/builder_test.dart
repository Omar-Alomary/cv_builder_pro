import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final entries = [
    ResumeModel(
      id: 1,
      fullName: 'Alice',
      email: 'alice@example.com',
      phone: '+15551234567',
      github: 'https://github.com/alice',
    ),
  ];
  bool fail = false;
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() =>
      entries.map((resume) => resume.copyWith()).toList();
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw Exception('disk failure');
    saves++;
    final saved = resume.copyWith(
      id: resume.id ?? 2,
      updatedAt: DateTime.now(),
    );
    final index = entries.indexWhere((entry) => entry.id == saved.id);
    if (index < 0) {
      entries.add(saved);
    } else {
      entries[index] = saved;
    }
    return saved.copyWith();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare(_Repository repository) {
  final resumes = Get.put(ResumeController(repository: repository));
  Get.put(TemplateController());
  return resumes;
}

Widget _host(Object? argument, {double scale = 1, bool arabic = false}) =>
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
        body: TextButton(
          onPressed: () =>
              Get.toNamed<void>(AppRoutes.resumeBuilder, arguments: argument),
          child: const Text('open-builder'),
        ),
      ),
      getPages: [
        GetPage(
          name: AppRoutes.resumeBuilder,
          page: () => const ResumeBuilderScreen(),
        ),
        GetPage(
          name: AppRoutes.preview,
          page: () => Scaffold(
            body: Column(
              children: [
                const Text('preview-marker'),
                TextButton(
                  onPressed: () {
                    final resumes = Get.find<ResumeController>();
                    resumes.currentResume.value = resumes.currentResume.value!
                        .copyWith(
                          email: 'updated@example.com',
                          templateId: 'ats',
                        );
                    Get.back<void>();
                  },
                  child: const Text('return-preview'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open-builder'));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Finder _field(String name) => find.descendant(
  of: find.byKey(ValueKey('personal-$name')),
  matching: find.byType(TextFormField),
);
Future<void> _edit(WidgetTester tester, String field, String value) async {
  await tester.ensureVisible(_field(field));
  await tester.enterText(_field(field), value);
  await tester.pumpAndSettle();
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  for (final arabic in [false, true]) {
    testWidgets(
      'compact toolbar keeps full title and all actions visible ar=$arabic',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final repository = _Repository();
        _prepare(repository);
        await tester.pumpWidget(
          _host(repository.entries.first, arabic: arabic),
        );
        await _open(tester);
        final title = find.byKey(const ValueKey('builder-title'));
        expect(
          tester.renderObject<RenderParagraph>(title).didExceedMaxLines,
          false,
        );
        final actions = [
          for (final key in [
            'builder-change-template',
            'builder-export-json',
            'builder-preview',
            'builder-save-close',
          ])
            tester.getRect(find.byKey(ValueKey(key))),
        ];
        expect(actions.map((rect) => rect.top).toSet(), hasLength(1));
        expect(
          actions.every((rect) => rect.left >= 0 && rect.right <= 320),
          true,
        );
        expect(tester.getRect(title).bottom <= actions.first.top, true);
        expect(tester.takeException(), isNull);
        await _close(tester);
      },
    );
  }
  for (final width in [320.0, 600.0, 1200.0, 1920.0]) {
    testWidgets('editor fits $width and large Arabic text', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 600 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _Repository();
      _prepare(repository);
      await tester.pumpWidget(
        _host(repository.entries.first, scale: 2, arabic: true),
      );
      await _open(tester);
      await tester.ensureVisible(_field('email'));
      await tester.pumpAndSettle();
      final nameRect = tester.getRect(_field('fullName'));
      final emailRect = tester.getRect(_field('email'));
      if (width >= 600) {
        expect(nameRect.top, emailRect.top);
      } else {
        expect(nameRect.top, lessThan(emailRect.top));
      }
      expect(
        tester.getSize(find.byType(PersonalInfoStep)).width,
        lessThanOrEqualTo(900),
      );
      expect(tester.takeException(), isNull);
      await _close(tester);
    });
  }
  testWidgets('editing clones data and back saves the latest changes', (
    tester,
  ) async {
    final repository = _Repository();
    final resumes = _prepare(repository);
    final original = repository.entries.first;
    await tester.pumpWidget(_host(original));
    await _open(tester);
    await _edit(tester, 'fullName', 'Edited');
    expect(original.fullName, 'Alice');
    expect(resumes.resumes.first.fullName, 'Alice');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(repository.entries.first.fullName, 'Edited');
    expect(find.text('open-builder'), findsOneWidget);
    await _close(tester);
  });
  testWidgets('untouched new draft does not create an empty resume on back', (
    tester,
  ) async {
    final repository = _Repository();
    _prepare(repository);
    await tester.pumpWidget(_host('technical'));
    await _open(tester);
    expect(
      Get.find<ResumeController>().currentResume.value!.templateId,
      'technical',
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(repository.saves, 0);
    await _close(tester);
  });
  testWidgets('personal validation prevents navigation until corrected', (
    tester,
  ) async {
    _prepare(_Repository());
    await tester.pumpWidget(_host('ats'));
    await _open(tester);
    await _tap(tester, find.byKey(const ValueKey('builder-next')));
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('builder-step-0')))
          .selected,
      true,
    );
    await _edit(tester, 'fullName', 'User');
    await _edit(tester, 'email', 'bad');
    await _edit(tester, 'phone', '+15551234567');
    await _tap(tester, find.byKey(const ValueKey('builder-next')));
    expect(find.text('invalid_email'.tr), findsOneWidget);
    await _edit(tester, 'email', 'user@example.com');
    await _tap(tester, find.byKey(const ValueKey('builder-next')));
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('builder-step-1')))
          .selected,
      true,
    );
    await _close(tester);
  });
  testWidgets(
    'autosave status reflects successful persistence and later edits',
    (tester) async {
      final repository = _Repository();
      _prepare(repository);
      await tester.pumpWidget(_host(repository.entries.first));
      await _open(tester);
      await _edit(tester, 'fullName', 'Automatic');
      expect(find.text('builder_unsaved'.tr), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(repository.entries.first.fullName, 'Automatic');
      expect(find.text('auto_saved'.tr), findsOneWidget);
      await _edit(tester, 'fullName', 'Pending');
      expect(find.text('builder_unsaved'.tr), findsOneWidget);
      await _close(tester);
    },
  );
  testWidgets('save failure keeps editor and unsaved draft', (tester) async {
    final repository = _Repository()..fail = true;
    _prepare(repository);
    await tester.pumpWidget(_host(repository.entries.first));
    await _open(tester);
    await _edit(tester, 'fullName', 'Pending');
    await tester.tap(find.byKey(const ValueKey('builder-save-close')));
    await tester.pumpAndSettle();
    expect(find.byType(ResumeBuilderScreen), findsOneWidget);
    expect(repository.entries.first.fullName, 'Alice');
    expect(find.text('storage_error'.tr), findsOneWidget);
    await _close(tester);
  });
  testWidgets(
    'additional sections navigate forward and back then finish in preview',
    (tester) async {
      final repository = _Repository();
      _prepare(repository);
      await tester.pumpWidget(_host(repository.entries.first));
      await _open(tester);
      await _tap(tester, find.byKey(const ValueKey('builder-step-4')));
      await _tap(tester, find.byKey(const ValueKey('builder-next')));
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('additional-certificates')),
            )
            .selected,
        true,
      );
      await _tap(tester, find.byKey(const ValueKey('builder-previous')));
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('additional-courses')),
            )
            .selected,
        true,
      );
      await _tap(tester, find.byKey(const ValueKey('additional-interests')));
      await _tap(tester, find.byKey(const ValueKey('builder-next')));
      expect(find.text('preview-marker'), findsOneWidget);
      expect(repository.saves, greaterThan(0));
      await _close(tester);
    },
  );
  testWidgets(
    'returning from preview synchronizes changed fields and template visibility',
    (tester) async {
      final repository = _Repository();
      _prepare(repository);
      await tester.pumpWidget(_host(repository.entries.first));
      await _open(tester);
      await tester.tap(find.byKey(const ValueKey('builder-preview')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('return-preview'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(_field('email')).controller!.text,
        'updated@example.com',
      );
      expect(find.byKey(const ValueKey('personal-pick-image')), findsNothing);
      await _close(tester);
    },
  );
  testWidgets('template hides fields without deleting their stored values', (
    tester,
  ) async {
    final repository = _Repository();
    final resumes = _prepare(repository);
    await tester.pumpWidget(
      _host(repository.entries.first.copyWith(templateId: 'classic')),
    );
    await _open(tester);
    expect(_field('github'), findsNothing);
    expect(resumes.currentResume.value!.github, 'https://github.com/alice');
    await _edit(tester, 'fullName', 'Changed');
    expect(resumes.currentResume.value!.github, 'https://github.com/alice');
    await _close(tester);
  });

  testWidgets('optional URLs validate when supplied and may be cleared', (
    tester,
  ) async {
    final repository = _Repository();
    _prepare(repository);
    await tester.pumpWidget(_host(repository.entries.first));
    await _open(tester);
    await _edit(tester, 'linkedin', 'invalid-link');
    await _tap(tester, find.byKey(const ValueKey('builder-next')));
    expect(find.text('invalid_url'.tr), findsOneWidget);
    await _edit(tester, 'linkedin', '');
    await _tap(tester, find.byKey(const ValueKey('builder-next')));
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('builder-step-1')))
          .selected,
      true,
    );
    await _close(tester);
  });
}
