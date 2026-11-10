import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/templates/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(
  Widget child, {
  bool arabic = false,
  bool dark = false,
  bool reduced = false,
  bool accessible = false,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(disableAnimations: reduced, accessibleNavigation: accessible),
    child: child!,
  ),
  home: child,
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () => const ResumeBuilderScreen(),
    ),
    GetPage(
      name: AppRoutes.preview,
      page: () => const Scaffold(body: Text('preview-marker')),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const Scaffold(body: Text('splash-marker')),
    ),
  ],
);
void main() {
  tearDown(Get.reset);
  for (final arabic in [false, true]) {
    for (final dark in [false, true]) {
      for (final reduced in [false, true]) {
        testWidgets(
          'catalog hero and builder direction ar=$arabic dark=$dark reduced=$reduced',
          (tester) async {
            Get.put(ResumeController(repository: _Repository()));
            Get.put(TemplateController());
            await tester.pumpWidget(
              _host(
                const TemplatesScreen(),
                arabic: arabic,
                dark: dark,
                reduced: reduced,
              ),
            );
            await tester.pumpAndSettle();
            AppPageTransition.install();
            final select = find.byKey(const ValueKey('select-template-modern'));
            await tester.ensureVisible(select);
            await tester.pumpAndSettle();
            await tester.tap(select);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
            final transition = find.byKey(const ValueKey('app-page-slide'));
            if (reduced) {
              expect(transition, findsNothing);
            } else {
              expect(transition, findsOneWidget);
              final offset = tester
                  .widget<SlideTransition>(transition)
                  .position
                  .value;
              expect(offset.dx, arabic ? lessThan(0) : greaterThan(0));
              expect(offset.dy, 0);
            }
            await tester.pumpAndSettle();
            expect(find.byType(ResumeBuilderScreen), findsOneWidget);
            expect(tester.takeException(), isNull);
            expect(
              Get.find<ResumeController>().currentResume.value!.templateId,
              'modern',
            );
            await tester.tap(find.byType(BackButton));
            await tester.pumpAndSettle();
            expect(find.byType(TemplatesScreen), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  for (final destination in [AppRoutes.preview, AppRoutes.splash]) {
    testWidgets('$destination uses its intended transition', (tester) async {
      await tester.pumpWidget(_host(const Scaffold(body: Text('start'))));
      await tester.pumpAndSettle();
      AppPageTransition.install();
      Get.toNamed<void>(destination);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      if (destination == AppRoutes.preview) {
        final transition = tester.widget<SlideTransition>(
          find.byKey(const ValueKey('app-page-slide')),
        );
        expect(transition.position.value.dy, greaterThan(0));
        expect(transition.position.value.dx, 0);
      } else {
        expect(find.byKey(const ValueKey('app-page-fade')), findsOneWidget);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('accessible navigation suppresses route and avatar motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(body: AppAvatar(heroTag: 'profile')),
        accessible: true,
      ),
    );
    await tester.pumpAndSettle();
    AppPageTransition.install();
    expect(
      tester.widget<HeroMode>(find.byType(HeroMode).last).enabled,
      isFalse,
    );
    Get.toNamed<void>(AppRoutes.preview);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('app-page-slide')), findsNothing);
    await tester.pumpAndSettle();
  });
  for (final dark in [false, true]) {
    testWidgets('passive skill label remains readable dark=$dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const Scaffold(body: AppChip(label: 'Flutter')),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsOneWidget);
      expect(find.byType(InputChip), findsNothing);
      final chip = tester.widget<Chip>(find.byType(Chip));
      final label = chip.label as Text;
      final foreground = label.style!.color!.computeLuminance(),
          background = chip.backgroundColor!.computeLuminance();
      expect(
        (math.max(foreground, background) + .05) /
            (math.min(foreground, background) + .05),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
  testWidgets('avatar flight reaches matching destination and returns', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => AppAvatar(
              heroTag: 'profile',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: AppAvatar(heroTag: 'profile', size: 96),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(AppAvatar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    Get.back<void>();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
