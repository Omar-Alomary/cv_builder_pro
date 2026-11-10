import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/language_controller.dart';
import 'package:cv_builder_pro/data/repositories/resume_repository.dart';
import 'package:cv_builder_pro/features/language/index.dart';
import 'package:cv_builder_pro/features/splash/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  T? read<T>(String key) => null;
  @override
  Future<void> write(String key, Object? value) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _prepare(bool arabic) {
  Get.testMode = true;
  Get.locale = Locale(arabic ? 'ar' : 'en');
  Get.put(LanguageController(repository: _Repository()));
}

Widget _host(
  Widget child, {
  bool dark = false,
  bool arabic = false,
  double scale = 1,
  bool reduced = true,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reduced,
    ),
    child: child!,
  ),
  home: child,
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('onboarding-preview')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('deliveries/ui_redesign').create(recursive: true);
      await File(
        'deliveries/ui_redesign/batch_03_$name.png',
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
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });
  tearDown(Get.reset);
  for (final splash in [true, false]) {
    for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
      for (final dark in [false, true]) {
        for (final arabic in [false, true]) {
          testWidgets(
            '${splash ? 'splash' : 'language'} fits $width $dark $arabic at text scale 2',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(width, width == 1024 ? 480 : 900);
              addTearDown(tester.view.resetDevicePixelRatio);
              addTearDown(tester.view.resetPhysicalSize);
              _prepare(arabic);
              Widget host(double scale) => _host(
                RepaintBoundary(
                  key: const ValueKey('onboarding-preview'),
                  child: splash
                      ? const SplashScreen()
                      : const LanguageSelectionScreen(),
                ),
                dark: dark,
                arabic: arabic,
                scale: scale,
              );
              await tester.pumpWidget(host(2));
              await tester.pump();
              expect(tester.takeException(), isNull);
              expect(
                Directionality.of(tester.element(find.byType(SafeArea))),
                arabic ? TextDirection.rtl : TextDirection.ltr,
              );
              if (!splash) {
                expect(
                  find.byKey(
                    ValueKey(width >= 600 ? 'language-row' : 'language-column'),
                  ),
                  findsOneWidget,
                );
                await tester.ensureVisible(
                  find.byKey(const ValueKey('select-ar')),
                );
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
              if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                  width == 390 &&
                  dark == arabic) {
                tester.view.physicalSize = Size(390, splash ? 900 : 1400);
                await tester.pumpWidget(host(1));
                await tester.pump();
                if (!splash) {
                  await tester.drag(
                    find.byType(SingleChildScrollView),
                    const Offset(0, 3000),
                  );
                  await tester.pumpAndSettle();
                }
                await _capture(
                  tester,
                  '${splash ? 'splash' : 'language'}_${dark ? 'dark_ar' : 'light_en'}',
                );
              }
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump(const Duration(seconds: 4));
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
  for (final reduced in [false, true]) {
    testWidgets(
      'language choices keep stable hit targets on hover, reduced motion $reduced',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1024, 1000);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        _prepare(false);
        await tester.pumpWidget(
          _host(const LanguageSelectionScreen(), reduced: reduced),
        );
        await tester.pumpAndSettle();
        final card = find.byKey(const ValueKey('language-card-en'));
        final bounds = tester.getRect(card);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(0, 0));
        await mouse.moveTo(tester.getCenter(card));
        await tester.pumpAndSettle();
        expect(tester.getRect(card), bounds);
        expect(
          tester
              .widget<ElevatedButton>(
                find.descendant(
                  of: card,
                  matching: find.byType(ElevatedButton),
                ),
              )
              .onPressed,
          isNotNull,
        );
        await mouse.removePointer();
        await tester.pumpAndSettle();
        expect(tester.getRect(card), bounds);
      },
    );
  }
  testWidgets('splash remains finite when motion preference changes', (
    tester,
  ) async {
    _prepare(false);
    await tester.pumpWidget(_host(const SplashScreen(), reduced: false));
    await tester.pump(const Duration(milliseconds: 800));
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('splash-progress')),
          )
          .value,
      lessThan(1),
    );
    await tester.pumpWidget(_host(const SplashScreen(), reduced: true));
    await tester.pump();
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('splash-progress')),
          )
          .value,
      1,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
}
