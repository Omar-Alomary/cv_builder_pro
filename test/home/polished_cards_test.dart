import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/features/home/presentation/widgets/home_cta_card.dart';
import 'package:cv_builder_pro/features/settings/presentation/widgets/settings_profile_header.dart';
import 'package:cv_builder_pro/shared_widgets/app_section_header.dart';
import 'package:cv_builder_pro/translations/index.dart';

Widget _host(Widget child, bool arabic) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: AppTheme.light,
  home: Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

void main() {
  tearDown(Get.reset);
  for (final ar in [false, true]) {
    testWidgets(
      'CTA uses localized fonts, pressed opacity and light haptics ar=$ar',
      (tester) async {
        final haptics = <MethodCall>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            haptics.add(call);
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        var calls = 0;
        await tester.pumpWidget(
          _host(
            HomeCtaCard(
              onCreate: () async {
                calls++;
              },
              onImport: () async {},
              onAts: () async {},
            ),
            ar,
          ),
        );
        await tester.pumpAndSettle();
        for (final key in ['create-resume', 'import-resume', 'check-ats']) {
          final button = tester.widget<ButtonStyleButton>(
            find.byKey(ValueKey(key)),
          );
          final style = button.style!.textStyle!.resolve({})!;
          expect(style.fontFamily, ar ? 'Cairo' : 'Poppins');
          expect(style.fontWeight, FontWeight.w600);
          expect(button.style!.minimumSize!.resolve({})!.height, 44);
        }
        final create = find.byKey(const ValueKey('create-resume'));
        final gesture = await tester.startGesture(tester.getCenter(create));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final opacity = tester.widget<AnimatedOpacity>(
          find
              .ancestor(of: create, matching: find.byType(AnimatedOpacity))
              .first,
        );
        expect(opacity.opacity, .76);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(
          haptics.where(
            (e) =>
                e.method == 'HapticFeedback.vibrate' &&
                e.arguments == 'HapticFeedbackType.lightImpact',
          ),
          hasLength(1),
        );
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'profile title and outlined action use localized fonts ar=$ar',
      (tester) async {
        var picks = 0;
        await tester.pumpWidget(
          _host(
            SettingsProfileHeader(
              onPick: () async {
                picks++;
              },
            ),
            ar,
          ),
        );
        await tester.pumpAndSettle();
        final action = tester.widget<OutlinedButton>(
          find.byKey(const ValueKey('pick-profile-image')),
        );
        expect(
          action.style!.textStyle!.resolve({})!.fontFamily,
          ar ? 'Cairo' : 'Poppins',
        );
        final title = tester.widget<Text>(find.text('CV Maker Pro'));
        expect(title.style!.fontFamily, ar ? 'Cairo' : 'Poppins');
        expect(title.style!.fontSize, 18);
        expect(title.style!.fontWeight, FontWeight.w700);
        await tester.tap(find.byKey(const ValueKey('pick-profile-image')));
        await tester.pumpAndSettle();
        expect(picks, 1);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('view all remains next to section title at 320 ar=$ar', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var calls = 0;
      await tester.pumpWidget(
        _host(
          AppSectionHeader(
            title: ar ? 'السير الذاتية الأخيرة' : 'Recent Resumes',
            inlineAction: true,
            actionLabel: ar ? 'عرض الكل' : 'View all',
            onAction: () {
              calls++;
            },
          ),
          ar,
        ),
      );
      await tester.pumpAndSettle();
      final title = tester.getRect(
        find.text(ar ? 'السير الذاتية الأخيرة' : 'Recent Resumes'),
      );
      final action = tester.getRect(find.byType(TextButton));
      expect(title.bottom > action.top && action.bottom > title.top, true);
      expect(
        ar ? action.right <= title.left : title.right <= action.left,
        true,
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('unavailable haptics do not block navigation action', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          throw PlatformException(code: 'unavailable');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    var calls = 0;
    await tester.pumpWidget(
      _host(
        HomeCtaCard(
          onCreate: () async {
            calls++;
          },
          onImport: () async {},
          onAts: () async {},
        ),
        true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-resume')));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
}
