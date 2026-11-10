import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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

Widget _host(
  _Service service, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('settings-preview'),
    child: SettingsScreen(service: service),
  ),
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('settings-preview')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_06_$name.png',
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
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });
  tearDown(Get.reset);
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final arabic in [false, true]) {
      for (final dark in [false, true]) {
        testWidgets(
          'settings and language dialog $width ar=$arabic dark=$dark scale2',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, width == 1024 ? 480 : 1200);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final repository = _Repository();
            repository.values[StorageKeys.appLocale] = arabic ? 'ar' : 'en';
            repository.values[StorageKeys.isDarkMode] = dark;
            Get.locale = Locale(arabic ? 'ar' : 'en');
            _prepare(repository);
            final service = _Service();
            await tester.pumpWidget(
              _host(service, arabic: arabic, dark: dark, scale: 2),
            );
            await tester.pumpAndSettle();
            await tester.ensureVisible(
              find.byKey(const ValueKey('settings-exit')),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final languageAction = find.widgetWithText(
              AppButton,
              (arabic ? 'language_arabic' : 'language_english').tr,
            );
            await tester.ensureVisible(languageAction);
            await tester.pumpAndSettle();
            await tester.tap(languageAction);
            await tester.pumpAndSettle();
            final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
            await tester.ensureVisible(cancel);
            await tester.pumpAndSettle();
            await tester.tap(cancel);
            await tester.pumpAndSettle();
            expect(
              repository.values[StorageKeys.appLocale],
              arabic ? 'ar' : 'en',
            );
            expect(tester.takeException(), isNull);
            if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                (width == 390 || width == 1920) &&
                arabic == dark) {
              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                _host(service, arabic: arabic, dark: dark),
              );
              await tester.pumpAndSettle();
              await _capture(
                tester,
                'settings_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
              );
            }
          },
        );
      }
    }
  }
  testWidgets('camera and profile button share a single pending picker', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<void>();
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: ProfileHeader(
            onPick: () {
              calls++;
              return pending.future;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('change_profile_image'.tr));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('pick-profile-image')));
    await tester.pump();
    expect(calls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
