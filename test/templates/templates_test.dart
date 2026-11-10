import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/template_controller.dart';
import 'package:cv_builder_pro/features/templates/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

Widget host({
  double scale = 1,
  bool arabic = false,
  bool dark = false,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: const TemplatesScreen(),
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
  ],
);

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 600.0, 1200.0, 1920.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('catalog fits width $width scale $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        Get.put(TemplateController());
        await tester.pumpWidget(
          host(scale: scale, arabic: scale == 2, dark: scale == 2),
        );
        await tester.pumpAndSettle();
        if (find.byKey(const ValueKey('template-grid')).evaluate().isEmpty) {
          await tester.drag(
            find.byKey(const ValueKey('templates-scroll')),
            const Offset(0, -450),
          );
          await tester.pumpAndSettle();
        }
        final grid = tester.widget<SliverGrid>(
          find.byKey(const ValueKey('template-grid')),
        );
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(
          delegate.crossAxisCount,
          width < 600
              ? 1
              : width < 1200
              ? 2
              : 3,
        );
        expect(
          delegate.childAspectRatio,
          width < 600
              ? .65
              : width < 1200
              ? .75
              : .85,
        );
        await tester.drag(
          find.byKey(const ValueKey('templates-scroll')),
          const Offset(0, -550),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'search crosses languages and intersects category, reset restores catalog',
    (tester) async {
      Get.put(TemplateController());
      await tester.pumpWidget(host(arabic: true));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Modern');
      await tester.pumpAndSettle();
      expect(find.byType(TemplateGridCard), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('category-classic')));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateGridCard), findsNothing);
      await tester.ensureVisible(find.text('reset_template_filters'.tr));
      await tester.pumpAndSettle();
      await tester.tap(find.text('reset_template_filters'.tr));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        isEmpty,
      );
      expect(find.byType(TemplateGridCard), findsWidgets);
    },
  );
  testWidgets('language tabs show five per language and ten together', (
    tester,
  ) async {
    Get.put(TemplateController());
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    int count() =>
        (tester
                    .widget<SliverGrid>(
                      find.byKey(const ValueKey('template-grid')),
                    )
                    .delegate
                as SliverChildBuilderDelegate)
            .estimatedChildCount!;
    expect(count(), 5);
    await tester.tap(find.byKey(const ValueKey('language-en')));
    await tester.pumpAndSettle();
    expect(count(), 5);
    expect(
      tester
          .widget<TemplateGridCard>(find.byType(TemplateGridCard).first)
          .template
          .id,
      'modern_en',
    );
    await tester.tap(find.byKey(const ValueKey('language-all')));
    await tester.pumpAndSettle();
    expect(count(), 10);
    expect(tester.takeException(), isNull);
  });
  testWidgets('English selection passes its distinct id to builder', (
    tester,
  ) async {
    Get.put(TemplateController());
    Object? argument;
    await tester.pumpWidget(
      host(arabic: true, capture: (value) => argument = value),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-en')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('select-template-modern_en')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('select-template-modern_en')));
    await tester.pumpAndSettle();
    expect(argument, 'modern_en');
  });
  testWidgets('select sends template id to builder', (tester) async {
    Get.put(TemplateController());
    Object? argument;
    await tester.pumpWidget(host(capture: (value) => argument = value));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('select-template-modern')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('select-template-modern')));
    await tester.pumpAndSettle();
    expect(argument, 'modern');
    expect(find.text('builder-marker'), findsOneWidget);
  });
  testWidgets(
    'clearing query retains category and empty catalog is supported',
    (tester) async {
      final controller = Get.put(TemplateController());
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('category-ats')));
      await tester.enterText(find.byType(TextFormField), 'nonexistent');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('clear-template-search')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TemplateGridCard>(find.byType(TemplateGridCard))
            .template
            .id,
        'ats',
      );
      controller.templates.clear();
      await tester.pumpAndSettle();
      expect(find.byType(TemplateGridCard), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
