import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/data/models/template_model.dart';
import 'package:cv_builder_pro/features/templates/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
  });
  tearDown(Get.reset);
  for (final id in ['modern', 'classic', 'business', 'technical', 'ats']) {
    testWidgets('$id preview can be inspected, cancelled and selected', (
      tester,
    ) async {
      var selected = 0;
      final template = TemplateModel(
        id: id,
        name: id,
        nameAr: id,
        description: 'Document layout',
        descriptionAr: 'تخطيط السيرة',
        type: id,
        language: 'en',
      );
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 440,
                child: TemplateGridCard(
                  template: template,
                  onSelect: () async {
                    selected++;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final preview = find.byKey(ValueKey('preview-template-$id'));
      await tester.tap(preview);
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(TemplateMiniPreview), findsNWidgets(2));
      expect(selected, 0);
      await tester.tap(find.byTooltip('close'.tr));
      await tester.pumpAndSettle();
      expect(selected, 0);
      await tester.tap(preview);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.byType(AppButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(find.byType(AppBottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('five document layouts render together', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 420);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: const ValueKey('mini-layouts'),
          child: Scaffold(
            backgroundColor: const Color(0xffedf1f5),
            body: Row(
              children: [
                for (final id in [
                  'modern',
                  'classic',
                  'business',
                  'technical',
                  'ats',
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Expanded(child: TemplateMiniPreview(templateId: id)),
                          const SizedBox(height: 16),
                          Text(
                            id,
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('WRITE_FOCUSED_PREVIEWS')) {
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('mini-layouts')),
        );
        final image = await boundary.toImage();
        try {
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'deliveries/ui_redesign/focused_template_layouts.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
        } finally {
          image.dispose();
        }
      });
    }
  });
}
