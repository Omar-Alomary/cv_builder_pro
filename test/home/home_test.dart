import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/home/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final entries = List.generate(
    7,
    (index) => ResumeModel(
      id: index + 1,
      fullName: 'User ${index + 1}',
      createdAt: DateTime(2026, 1, index + 1),
      isFavorite: index < 3,
      skills: [
        Skill(name: 'Flutter'),
        Skill(name: 'Communication'),
        Skill(name: 'SQL'),
      ],
    ),
  );
  int loads = 0;
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() {
    loads++;
    return entries.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    saves++;
    final saved = resume.copyWith(
      id: resume.id ?? 99,
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
  Future<void> deleteResume(int id) async {
    entries.removeWhere((entry) => entry.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host({
  bool dark = false,
  double scale = 1,
  bool reducedMotion = true,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Get.locale ?? const Locale('en', 'US'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reducedMotion,
    ),
    child: child!,
  ),
  home: const HomeScreen(),
  getPages: [
    GetPage(
      name: AppRoutes.atsChecker,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('ats-marker')),
    ),
    GetPage(
      name: AppRoutes.importResume,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('import-marker')),
    ),
    GetPage(
      name: AppRoutes.resumeBuilder,
      transition: Transition.noTransition,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
    GetPage(
      name: AppRoutes.templates,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('templates-marker')),
    ),
    GetPage(
      name: AppRoutes.favorites,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('favorites-marker')),
    ),
    GetPage(
      name: AppRoutes.settings,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('settings-marker')),
    ),
  ],
);

void size(WidgetTester tester, double width, [double height = 900]) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    if (target.hitTestable().evaluate().isNotEmpty) return;
    final viewport = tester.getRect(find.byKey(const ValueKey('home-scroll')));
    final exists = target.evaluate().isNotEmpty;
    final above = exists && tester.getCenter(target).dy < viewport.top;
    await tester.dragFrom(
      Offset(viewport.left + 6, viewport.center.dy),
      Offset(0, above ? 300 : -300),
    );
    await tester.pumpAndSettle();
  }
  throw StateError('Unable to reveal $target');
}

void main() {
  late _Repository repository;
  late ResumeController resumes;
  late TemplateController templates;
  void prepare() {
    resumes = Get.put(ResumeController(repository: repository));
    templates = Get.put(TemplateController());
  }

  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en', 'US');
    repository = _Repository();
  });
  tearDown(() {
    Get.reset();
  });

  testWidgets('Import action opens the import screen', (tester) async {
    prepare();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('import-resume'));
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('import-marker'), findsOneWidget);
  });

  testWidgets('ATS action opens the checker', (tester) async {
    prepare();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('check-ats'));
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('ats-marker'), findsOneWidget);
  });

  testWidgets(
    'Statistics reflect all seven resumes, ten templates and three favorites',
    (tester) async {
      prepare();
      await tester.pumpWidget(host());
      for (final value in ['7', '10', '3']) {
        expect(
          find.descendant(
            of: find.byType(StatsCards),
            matching: find.text(value),
          ),
          findsOneWidget,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Home responds at mobile, tablet, desktop and large Arabic text sizes',
    (tester) async {
      prepare();
      size(tester, 320);
      for (final entry in <double, double>{
        320: 2,
        600: 2,
        1200: 2,
        1920: 1,
      }.entries) {
        tester.view.physicalSize = Size(entry.key, 900);
        Get.locale = const Locale('ar', 'SA');
        await tester.pumpWidget(host(dark: true, scale: entry.value));
        await tester.pump();
        final expected = 'recent-list';
        await reveal(tester, find.byKey(ValueKey(expected)));
        expect(find.byKey(ValueKey(expected)), findsOneWidget);
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        Get.reset();
        Get.testMode = true;
        resumes = Get.put(ResumeController(repository: repository));
        templates = Get.put(TemplateController());
      }
    },
  );

  testWidgets(
    'Carousel fractions are 0.85, 0.5 and 0.35 and manual controls work',
    (tester) async {
      prepare();
      size(tester, 390);
      for (final entry in <double, double>{
        390: 0.85,
        800: 0.5,
        1440: 0.35,
      }.entries) {
        tester.view.physicalSize = Size(entry.key, 1000);
        await tester.pumpWidget(host());
        await reveal(tester, find.byType(carousel.CarouselSlider));
        final widget = tester.widget<carousel.CarouselSlider>(
          find.byType(carousel.CarouselSlider),
        );
        expect(widget.options.viewportFraction, entry.value);
        expect(widget.options.autoPlay, false);
        await reveal(tester, find.byTooltip('Next'));
        await tester.tap(find.byTooltip('Next'));
        await tester.pumpAndSettle();
        expect(find.text('2 of 10'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        Get.reset();
        Get.testMode = true;
        resumes = Get.put(ResumeController(repository: repository));
        templates = Get.put(TemplateController());
      }
    },
  );

  testWidgets(
    'View all displays older resumes instead of navigating to favorites',
    (tester) async {
      prepare();
      size(tester, 390);
      await tester.pumpWidget(host());
      expect(find.byKey(const ValueKey('recent-1')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('stat-0')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('recent-1')),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('recent-list')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('recent-1')), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Create and use-template actions open the builder with the correct arguments',
    (tester) async {
      prepare();
      size(tester, 800, 1200);
      Object? argument;
      await tester.pumpWidget(
        host(
          capture: (value) {
            argument = value;
          },
        ),
      );
      await reveal(tester, find.byKey(const ValueKey('create-resume')));
      await tester.tap(find.byKey(const ValueKey('create-resume')));
      await tester.pumpAndSettle();
      expect(find.text('builder-marker'), findsOneWidget);
      expect(argument, isNull);
      Get.back<void>();
      await tester.pumpAndSettle();
      final use = find.byKey(const ValueKey('use-template-modern')).first;
      await reveal(tester, use);
      await tester.tap(use);
      await tester.pumpAndSettle();
      expect(argument, 'modern');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Favorite and edit actions update live counts and pass an independent resume',
    (tester) async {
      prepare();
      size(tester, 800, 1200);
      Object? argument;
      await tester.pumpWidget(
        host(
          capture: (value) {
            argument = value;
          },
        ),
      );
      final card = find.byKey(const ValueKey('recent-7'));
      await reveal(tester, card);
      final favorite = find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('favorite-resume-7')),
      );
      await reveal(tester, favorite);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.widget<RecentActivityCard>(card).resume.id, 7);
      expect(tester.widget<IconButton>(favorite).onPressed, isNotNull);
      await tester.tap(favorite);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        repository.saves,
        1,
        reason:
            'Favorite should save without navigating; route: ${Get.currentRoute}',
      );
      expect(resumes.getFavoriteResumes(), hasLength(4));
      final edit = find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('edit-resume-7')),
      );
      await reveal(tester, edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(argument, isA<ResumeModel>());
      final edited = argument as ResumeModel;
      expect(edited.id, 7);
      edited.fullName = 'Unsaved change';
      expect(
        resumes.resumes.firstWhere((resume) => resume.id == 7).fullName,
        'User 7',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Delete requires confirmation before removing a resume', (
    tester,
  ) async {
    prepare();
    size(tester, 800, 1200);
    await tester.pumpWidget(host());
    final card = find.byKey(const ValueKey('recent-7'));
    await reveal(tester, card);
    await reveal(
      tester,
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.pumpAndSettle();
    expect(resumes.resumes, hasLength(7));
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('Cancel')),
    );
    await tester.pumpAndSettle();
    expect(resumes.resumes, hasLength(7));
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(of: find.byType(Dialog), matching: find.text('Delete'))
          .last,
    );
    await tester.pump();
    expect(resumes.resumes, hasLength(6));
    expect(repository.entries.any((resume) => resume.id == 7), false);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Bottom navigation opens the selected destination', (
    tester,
  ) async {
    prepare();
    size(tester, 390);
    await tester.pumpWidget(host());
    final destination = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.favorite_outline),
    );
    await tester.tap(destination);
    await tester.pumpAndSettle();
    expect(find.text('favorites-marker'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Empty data and invalid template colors render without crashes', (
    tester,
  ) async {
    prepare();
    size(tester, 320);
    resumes.resumes.clear();
    templates.templates.assignAll([
      const TemplateModel(
        id: 'custom',
        name: 'Custom',
        nameAr: 'مخصص',
        description: 'Description',
        descriptionAr: 'وصف',
        type: 'classic',
        language: 'en',
        previewColor: 'invalid',
        isFeatured: true,
      ),
    ]);
    await tester.pumpWidget(host(scale: 3));
    await reveal(tester, find.text('No resumes yet'));
    expect(find.text('No resumes yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
    templates.templates.clear();
    await tester.pump();
    expect(find.text('No templates are available'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
