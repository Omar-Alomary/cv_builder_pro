import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/language_controller.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';
import 'package:cv_builder_pro/data/repositories/resume_repository.dart';
import 'package:cv_builder_pro/features/splash/index.dart';
import 'package:cv_builder_pro/features/language/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final values = <String, dynamic>{};
  Completer<void>? gate;
  bool fail = false;
  int writes = 0;
  @override
  T? read<T>(String key) => values[key] as T?;
  @override
  Future<void> write(String key, Object? value) async {
    if (fail) throw const StorageException('write', 'simulated error');
    if (gate != null) await gate!.future;
    writes++;
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget displayHost(
  Widget child, {
  bool dark = false,
  double scale = 1,
  bool reducedMotion = false,
}) => MaterialApp(
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reducedMotion,
    ),
    child: child!,
  ),
  home: child,
);

Widget navigationHost(Widget child) => GetMaterialApp(
  translations: AppTranslations(),
  locale: const Locale('en', 'US'),
  theme: AppTheme.light,
  home: child,
  getPages: [
    GetPage(
      name: AppRoutes.home,
      page: () => const Scaffold(body: Text('home-marker')),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
      transition: Transition.noTransition,
    ),
  ],
);

void setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  late _Repository repository;
  late LanguageController language;
  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en', 'US');
    repository = _Repository();
    language = Get.put(LanguageController(repository: repository));
  });
  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'Splash fits mobile, landscape, tablet and desktop with large text',
    (tester) async {
      setSize(tester, const Size(320, 480));
      for (final size in [
        const Size(320, 480),
        const Size(480, 320),
        const Size(768, 1024),
        const Size(1920, 1080),
      ]) {
        tester.view.physicalSize = size;
        for (final dark in [false, true]) {
          await tester.pumpWidget(
            displayHost(const SplashScreen(), dark: dark, scale: 2),
          );
          await tester.pump(const Duration(seconds: 1));
          expect(find.byType(SafeArea), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    },
  );

  testWidgets(
    'Splash cancels navigation when disposed and respects reduced motion',
    (tester) async {
      await tester.pumpWidget(
        displayHost(const SplashScreen(), reducedMotion: true),
      );
      expect(find.byType(AnimatedTextKit), findsNothing);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        1,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('First launch routes from splash to language selection', (
    tester,
  ) async {
    await tester.pumpWidget(navigationHost(const SplashScreen()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    expect(Get.currentRoute, AppRoutes.languageSelection);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('A selected language routes from splash directly home', (
    tester,
  ) async {
    language.isLanguageSelected.value = true;
    await tester.pumpWidget(navigationHost(const SplashScreen()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('home-marker'), findsOneWidget);
    expect(Get.currentRoute, AppRoutes.home);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Language cards stack on mobile and form a row on larger screens',
    (tester) async {
      setSize(tester, const Size(320, 640));
      for (final size in [
        const Size(320, 640),
        const Size(600, 800),
        const Size(1200, 800),
        const Size(1920, 1080),
      ]) {
        tester.view.physicalSize = size;
        Get.locale = const Locale('ar', 'SA');
        await tester.pumpWidget(
          displayHost(
            const LanguageSelectionScreen(),
            dark: true,
            scale: 2,
            reducedMotion: true,
          ),
        );
        final row = size.width >= 600;
        expect(
          find.byKey(ValueKey(row ? 'language-row' : 'language-column')),
          findsOneWidget,
        );
        expect(
          Directionality.of(
            tester.element(
              find.byKey(ValueKey(row ? 'language-row' : 'language-column')),
            ),
          ),
          TextDirection.rtl,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('Arabic selection persists both settings and navigates home', (
    tester,
  ) async {
    setSize(tester, const Size(1000, 1000));
    await tester.pumpWidget(navigationHost(const LanguageSelectionScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('select-ar')));
    await tester.tap(find.byKey(const ValueKey('select-ar')));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(repository.values[StorageKeys.appLocale], 'ar');
    expect(repository.values[StorageKeys.languageSelected], true);
    expect(language.currentLanguage.value, 'ar');
    expect(language.isSelecting.value, false);
    expect(Get.locale?.languageCode, 'ar');
    expect(find.text('home-marker'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Pending language selection disables both cards and prevents duplicate writes',
    (tester) async {
      setSize(tester, const Size(1000, 1000));
      repository.gate = Completer<void>();
      await tester.pumpWidget(navigationHost(const LanguageSelectionScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('select-en')));
      await tester.pump();
      expect(language.isSelecting.value, true);
      final arabicButton = find.descendant(
        of: find.byKey(const ValueKey('select-ar')),
        matching: find.byType(ElevatedButton),
      );
      expect(tester.widget<ElevatedButton>(arabicButton).onPressed, isNull);
      await language.selectLanguage('ar');
      expect(repository.writes, 0);
      repository.gate!.complete();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(repository.writes, 2);
      expect(repository.values[StorageKeys.appLocale], 'en');
      expect(find.text('home-marker'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Failed selection stays on the language screen and permits retry',
    (tester) async {
      setSize(tester, const Size(1000, 1000));
      repository.fail = true;
      await tester.pumpWidget(navigationHost(const LanguageSelectionScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('select-en')));
      await tester.pump();
      await tester.pump();
      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
      expect(language.isLanguageSelected.value, false);
      expect(language.isSelecting.value, false);
      repository.fail = false;
      await tester.tap(find.byKey(const ValueKey('select-en')));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('home-marker'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
