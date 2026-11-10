import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';
import 'package:cv_builder_pro/core/services/settings_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/settings/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final values = <String, dynamic>{};
  bool failClear = false;
  bool failWrite = false;
  bool cleared = false;
  @override
  T? read<T>(String key) => values[key] as T?;
  @override
  Future<void> write(String key, dynamic value) async {
    if (failWrite) throw Exception('write failure');
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  List<ResumeModel> loadResumes() => [ResumeModel(id: 1, fullName: 'Saved')];
  @override
  Future<void> clearAllData() async {
    if (failClear) throw Exception('clear failure');
    values.clear();
    cleared = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service extends SettingsService {
  int support = 0;
  int rate = 0;
  int shares = 0;
  int exits = 0;
  String? image;
  Rect? origin;
  bool fail = false;
  @override
  Future<String?> pickProfileImage() async => image;
  @override
  Future<void> contactSupport() async {
    if (fail) throw Exception('unavailable');
    support++;
  }

  @override
  Future<void> rateApp() async {
    rate++;
  }

  @override
  Future<void> shareApp(Rect origin, String text) async {
    shares++;
    this.origin = origin;
  }

  @override
  Future<void> exitApp() async {
    exits++;
  }
}

void _prepare(_Repository repository) {
  Get.put<ResumeRepository>(repository);
  Get.put(LanguageController(repository: repository));
  Get.put(ThemeController(repository: repository));
  Get.put(ResumeController(repository: repository));
}

Widget _host(_Service service, {double scale = 1, bool arabic = false}) =>
    GetMaterialApp(
      locale: Locale(arabic ? 'ar' : 'en'),
      translations: AppTranslations(),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: SettingsScreen(service: service),
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const Scaffold(body: Text('splash-marker')),
        ),
      ],
    );

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder action(String key) => find.widgetWithText(AppButton, key.tr).last;

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('settings fit width $width and large Arabic text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      _prepare(_Repository());
      await tester.pumpWidget(_host(_Service(), scale: 2, arabic: true));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('settings-exit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('theme persists and changes application appearance', (
    tester,
  ) async {
    final repository = _Repository();
    _prepare(repository);
    await tester.pumpWidget(_host(_Service()));
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const ValueKey('settings-theme-switch')));
    expect(repository.values[StorageKeys.isDarkMode], true);
    expect(Get.find<ThemeController>().isDarkMode.value, true);
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.dark,
    );
  });
  testWidgets('language dialog selects and persists Arabic', (tester) async {
    final repository = _Repository();
    _prepare(repository);
    await tester.pumpWidget(_host(_Service()));
    await tester.pumpAndSettle();
    await tap(tester, action('language_english'));
    await tap(tester, find.byKey(const ValueKey('settings-language-ar')));
    expect(repository.values[StorageKeys.appLocale], 'ar');
    expect(Get.locale!.languageCode, 'ar');
    expect(find.byType(LanguageDialog), findsNothing);
  });
  testWidgets('platform support rate and share actions are invoked', (
    tester,
  ) async {
    _prepare(_Repository());
    final service = _Service();
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await tap(tester, action('contact_us'));
    await tap(tester, action('rate_app'));
    await tap(tester, action('share_app'));
    expect([service.support, service.rate, service.shares], [1, 1, 1]);
    expect(service.origin!.width, greaterThan(0));
  });
  testWidgets('platform failure is reported', (tester) async {
    _prepare(_Repository());
    final service = _Service()..fail = true;
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await tap(tester, action('contact_us'));
    expect(find.text('action_failed'.tr), findsOneWidget);
  });
  testWidgets(
    'cancel clear keeps data and confirmed clear resets state and routes',
    (tester) async {
      final repository = _Repository();
      _prepare(repository);
      await tester.pumpWidget(_host(_Service()));
      await tester.pumpAndSettle();
      await tap(tester, action('clear_all_data'));
      await tap(tester, action('cancel'));
      expect(repository.cleared, false);
      await tap(tester, action('clear_all_data'));
      await tap(tester, find.byKey(const ValueKey('confirm-settings-action')));
      expect(repository.cleared, true);
      expect(Get.find<ResumeController>().resumes, isEmpty);
      expect(find.text('splash-marker'), findsOneWidget);
    },
  );
  testWidgets('clear failure keeps resumes and screen', (tester) async {
    final repository = _Repository()..failClear = true;
    _prepare(repository);
    await tester.pumpWidget(_host(_Service()));
    await tester.pumpAndSettle();
    await tap(tester, action('clear_all_data'));
    await tap(tester, find.byKey(const ValueKey('confirm-settings-action')));
    expect(Get.find<ResumeController>().resumes, hasLength(1));
    expect(find.text('clear_all_data_failed'.tr), findsOneWidget);
  });
  testWidgets(
    'cancel photo preserves preference and failed write is reported',
    (tester) async {
      final repository = _Repository();
      _prepare(repository);
      final service = _Service();
      await tester.pumpWidget(_host(service));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const ValueKey('pick-profile-image')));
      expect(repository.values.containsKey(StorageKeys.profileImage), false);
      service.image = '/missing/photo.jpg';
      repository.failWrite = true;
      await tap(tester, find.byKey(const ValueKey('pick-profile-image')));
      expect(repository.values.containsKey(StorageKeys.profileImage), false);
      expect(find.text('profile_image_failed'.tr), findsOneWidget);
    },
  );
  testWidgets('exit confirms and retains saved resumes', (tester) async {
    final repository = _Repository();
    repository.values[StorageKeys.profileImage] = '';
    _prepare(repository);
    final service = _Service();
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const ValueKey('settings-exit')));
    await tap(tester, action('cancel'));
    expect(service.exits, 0);
    await tap(tester, find.byKey(const ValueKey('settings-exit')));
    await tap(tester, find.byKey(const ValueKey('confirm-settings-action')));
    expect(service.exits, 1);
    expect(repository.values.containsKey(StorageKeys.profileImage), false);
    expect(Get.find<ResumeController>().resumes, hasLength(1));
  });
}
