import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/app.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/home/index.dart';
import 'package:cv_builder_pro/features/settings/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';

class _Repository implements ResumeRepository {
  final values = <String, dynamic>{
    StorageKeys.appLocale: 'en',
    StorageKeys.languageSelected: true,
  };
  @override
  T? read<T>(String key) => values[key] as T?;
  @override
  Future<void> write(String key, dynamic value) async {
    values[key] = value;
  }

  @override
  List<ResumeModel> loadResumes() => [
    ResumeModel(id: 1, fullName: 'Saved resume'),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(seconds: 1));
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  tearDown(Get.reset);
  testWidgets('cold start honors saved Arabic before opening home', (
    tester,
  ) async {
    final repository = _Repository()..values[StorageKeys.appLocale] = 'ar';
    Get.put<ResumeRepository>(repository, permanent: true);
    await tester.pumpWidget(const CvBuilderApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('أنشئ سيرة ذاتية جديدة'), findsOneWidget);
    expect(Get.locale!.languageCode, 'ar');
    expect(find.text('storage_error'.tr), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets(
    'settings updates existing home in both directions without restart',
    (tester) async {
      final repository = _Repository();
      Get.put<ResumeRepository>(repository, permanent: true);
      await tester.pumpWidget(const CvBuilderApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      final homeState = tester.state(find.byType(HomeScreen));
      for (final code in ['ar', 'en']) {
        await _tap(
          tester,
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byType(ProfileAvatar),
          ),
        );
        expect(find.byType(SettingsScreen), findsOneWidget);
        final current = Get.find<LanguageController>().currentLanguage.value;
        await _tap(
          tester,
          find.widgetWithText(
            AppButton,
            (current == 'ar' ? 'language_arabic' : 'language_english').tr,
          ),
        );
        await _tap(tester, find.byKey(ValueKey('settings-language-$code')));
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(SettingsScreen))),
          code == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        Get.back<void>();
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(HomeScreen)), same(homeState));
        expect(
          find.text(
            code == 'ar' ? 'أنشئ سيرة ذاتية جديدة' : 'Create New Resume',
          ),
          findsOneWidget,
        );
        expect(Get.locale!.languageCode, code);
        expect(
          Directionality.of(
            tester.element(find.byKey(const ValueKey('create-resume'))),
          ),
          code == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(repository.values[StorageKeys.appLocale], code);
        expect(
          Get.find<ResumeController>().resumes.single.fullName,
          'Saved resume',
        );
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
