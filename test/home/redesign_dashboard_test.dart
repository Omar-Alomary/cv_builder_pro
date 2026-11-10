import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/home/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  _Repository(bool arabic)
    : entries = List.generate(
        3,
        (index) => ResumeModel(
          id: index + 1,
          fullName: arabic
              ? 'سيرة تجريبية ${index + 1}'
              : 'Demo Resume ${index + 1}',
          createdAt: DateTime(2026, 1, index + 1),
          isFavorite: index == 0,
          skills: [
            Skill(name: 'Flutter'),
            Skill(name: 'Dart'),
            Skill(name: 'Communication'),
          ],
          templateId: 'modern',
        ),
      );
  final List<ResumeModel> entries;
  @override
  List<ResumeModel> loadResumes() =>
      entries.map((entry) => entry.copyWith()).toList();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _prepare(bool arabic) {
  Get.testMode = true;
  Get.locale = Locale(arabic ? 'ar' : 'en');
  Get.put(ResumeController(repository: _Repository(arabic)));
  Get.put(TemplateController());
}

Widget _host({bool arabic = false, bool dark = false, double scale = 1}) =>
    GetMaterialApp(
      locale: Locale(arabic ? 'ar' : 'en'),
      translations: AppTranslations(),
      theme: dark ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: const RepaintBoundary(
        key: ValueKey('dashboard-preview'),
        child: HomeScreen(),
      ),
      getPages: [
        GetPage(
          name: AppRoutes.resumeBuilder,
          transition: Transition.noTransition,
          page: () => const Scaffold(body: Text('builder-marker')),
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
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 90; i++) {
    if (finder.hitTestable().evaluate().isNotEmpty) return;
    final viewport = tester.getRect(find.byKey(const ValueKey('home-scroll')));
    final above =
        finder.evaluate().isNotEmpty &&
        tester.getCenter(finder).dy < viewport.top;
    await tester.dragFrom(
      Offset(viewport.left + AppSpacing.sm, viewport.center.dy),
      Offset(0, above ? 250 : -250),
    );
    await tester.pumpAndSettle();
  }
  throw StateError('Unable to reveal $finder');
}

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('dashboard-preview')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('deliveries/ui_redesign').create(recursive: true);
      await File(
        'deliveries/ui_redesign/batch_04_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'Poppins': 'assets/fonts/Poppins-Regular.ttf',
      'Cairo': 'assets/fonts/Cairo-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final font = FontLoader(entry.key)..addFont(rootBundle.load(entry.value));
      await font.load();
    }
  });
  tearDown(Get.reset);
  test('quick-action gradients keep white labels readable', () {
    for (final gradient in [
      AppColors.primaryGradient,
      AppColors.successGradient,
      AppColors.warmGradient,
    ]) {
      for (final color in gradient.colors) {
        final a = AppColors.lightSurface.computeLuminance(),
            b = color.computeLuminance();
        expect(
          (math.max(a, b) + .05) / (math.min(a, b) + .05),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });
  testWidgets('rail destinations open the existing routes', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    _prepare(false);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    for (final entry in {
      'templates': 'templates-marker',
      'favorites': 'favorites-marker',
      'settings': 'settings-marker',
    }.entries) {
      final rail = find.byType(NavigationRail);
      expect(rail, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final tooltip = find.descendant(
        of: rail,
        matching: find.byTooltip(entry.key.tr),
      );
      await tester.tap(tooltip);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      Get.back<void>();
      await tester.pumpAndSettle();
    }
  });
  testWidgets(
    'primary create action opens builder without mutating saved resumes',
    (tester) async {
      _prepare(false);
      final resumes = Get.find<ResumeController>();
      final original = resumes.resumes.map((r) => r.copyWith()).toList();
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('create-resume')));
      await tester.pumpAndSettle();
      expect(find.text('builder-marker'), findsOneWidget);
      expect(resumes.resumes, original);
    },
  );
  testWidgets('header avatar opens settings', (tester) async {
    _prepare(false);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    final avatar = find.descendant(
      of: find.byType(AppBar),
      matching: find.bySemanticsLabel('settings'.tr),
    );
    await tester.tap(avatar);
    await tester.pumpAndSettle();
    expect(find.text('settings-marker'), findsOneWidget);
  });
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final dark in [false, true]) {
      for (final arabic in [false, true]) {
        testWidgets('dashboard fits $width $dark $arabic at scale 2', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, width == 1024 ? 480 : 900);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          _prepare(arabic);
          await tester.pumpWidget(_host(arabic: arabic, dark: dark, scale: 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            find.byType(width < 600 ? NavigationBar : NavigationRail),
            findsOneWidget,
          );
          await _reveal(tester, find.byKey(const ValueKey('check-ats')));
          expect(tester.takeException(), isNull);
          await _reveal(tester, find.byKey(const ValueKey('recent-list')));
          await tester.ensureVisible(find.byKey(const ValueKey('recent-list')));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('delete-resume-3')),
            200,
            scrollable: find
                .descendant(
                  of: find.byKey(const ValueKey('recent-list')),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.pumpAndSettle();
          await _reveal(tester, find.byKey(const ValueKey('delete-resume-3')));
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
              ((width == 390 && dark == arabic) ||
                  (width == 1920 && !dark && !arabic))) {
            tester.view.physicalSize = Size(width, width == 390 ? 1800 : 1500);
            await tester.pumpWidget(_host(arabic: arabic, dark: dark));
            await tester.pumpAndSettle();
            await tester.drag(
              find.byKey(const ValueKey('home-scroll')),
              const Offset(0, 20000),
            );
            await tester.pumpAndSettle();
            await _capture(
              tester,
              width == 1920
                  ? 'desktop_light_en'
                  : dark
                  ? 'home_dark_ar'
                  : 'home_light_en',
            );
          }
        });
      }
    }
  }
}
