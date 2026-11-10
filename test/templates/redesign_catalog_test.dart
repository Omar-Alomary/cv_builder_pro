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
import 'package:cv_builder_pro/features/templates/index.dart';
import 'package:cv_builder_pro/features/favorites/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  bool fail = false;
  final entries = [
    ResumeModel(
      id: 1,
      fullName: 'Alex Morgan',
      email: 'alex@example.com',
      isFavorite: true,
      skills: [
        Skill(name: 'Flutter'),
        Skill(name: 'Communication'),
      ],
    ),
  ];
  @override
  List<ResumeModel> loadResumes() => entries.map((e) => e.copyWith()).toList();
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw StateError('storage failure');
    entries[0] = resume.copyWith();
    return resume.copyWith();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(
  bool favorites, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('catalog-preview'),
    child: favorites ? const FavoritesScreen() : const TemplatesScreen(),
  ),
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('catalog-preview')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_05_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

void main() {
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
  for (final favorites in [false, true]) {
    for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
      for (final arabic in [false, true]) {
        for (final dark in [false, true]) {
          testWidgets(
            '${favorites ? 'favorites' : 'templates'} $width ar=$arabic dark=$dark large text',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(
                width,
                width == 1024 ? 480 : 1000,
              );
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              Get.put(TemplateController());
              Get.put(ResumeController(repository: _Repository()));
              await tester.pumpWidget(
                _host(favorites, arabic: arabic, dark: dark, scale: 2),
              );
              await tester.pumpAndSettle();
              await tester.drag(
                find.byKey(
                  ValueKey(favorites ? 'favorites-scroll' : 'templates-scroll'),
                ),
                const Offset(0, -400),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                  (width == 390 || width == 1920) &&
                  arabic == dark) {
                await tester.pumpWidget(const SizedBox());
                await tester.pumpWidget(
                  _host(favorites, arabic: arabic, dark: dark),
                );
                await tester.pumpAndSettle();
                await _capture(
                  tester,
                  '${favorites ? 'favorites' : 'templates'}_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
                );
              }
            },
          );
        }
      }
    }
  }
  for (final arabic in [false, true]) {
    for (final outcome in ['cancel', 'confirm', 'failure']) {
      testWidgets(
        'swipe favorite $outcome ar=$arabic preserves persisted state',
        (tester) async {
          final repository = _Repository()..fail = outcome == 'failure';
          final controller = Get.put(ResumeController(repository: repository));
          await tester.pumpWidget(_host(true, arabic: arabic));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('swipe-favorite-1')),
            Offset(arabic ? 700 : -700, 0),
          );
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.byType(Dialog), findsOneWidget);
          await tester.tap(
            outcome == 'cancel'
                ? find.text('cancel'.tr)
                : find.byKey(const ValueKey('confirm-remove-favorite')),
          );
          await tester.pumpAndSettle();
          expect(controller.resumes, hasLength(1));
          expect(
            controller.getFavoriteResumes(),
            hasLength(outcome == 'confirm' ? 0 : 1),
          );
          expect(repository.entries.first.isFavorite, outcome != 'confirm');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
