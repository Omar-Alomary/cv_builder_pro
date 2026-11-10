import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';
import 'package:cv_builder_pro/core/services/settings_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/home/presentation/pages/home_screen.dart';
import 'package:cv_builder_pro/features/home/presentation/widgets/home_primary_action.dart';
import 'package:cv_builder_pro/features/settings/presentation/pages/settings_screen.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final values = <String, dynamic>{};
  bool fail = false;
  @override
  T? read<T>(String key) => values[key] as T?;
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  Future<void> write(String key, dynamic value) async {
    if (fail) throw StateError('disk full');
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service extends SettingsService {
  String? path;
  @override
  Future<String?> pickProfileImage() async => path;
}

void main() {
  tearDown(Get.reset);
  for (final ar in [false, true]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'three equal CTA actions at 320 ar=$ar dark=$dark scale=$scale',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = const Size(320, 900);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetPhysicalSize);
            final calls = <String>[];
            await tester.pumpWidget(
              GetMaterialApp(
                translations: AppTranslations(),
                locale: Locale(ar ? 'ar' : 'en'),
                theme: dark ? AppTheme.dark : AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: HomePrimaryAction(
                        onCreate: () async => calls.add('create'),
                        onImport: () async => calls.add('import'),
                        onAts: () async => calls.add('ats'),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final boxes = [
              for (final key in ['create-resume', 'import-resume', 'check-ats'])
                tester.getRect(find.byKey(ValueKey(key))),
            ];
            expect(boxes[0].top, boxes[1].top);
            expect(boxes[1].top, boxes[2].top);
            expect(boxes[0].width, closeTo(boxes[2].width, .1));
            expect(
              boxes.every(
                (r) => r.left >= 0 && r.right <= 320 && r.height >= 48,
              ),
              true,
            );
            for (final key in ['create-resume', 'import-resume', 'check-ats']) {
              await tester.tap(find.byKey(ValueKey(key)));
              await tester.pumpAndSettle();
            }
            expect(calls, ['create', 'import', 'ats']);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets(
    'settings photo persists and updates the existing home avatar immediately',
    (tester) async {
      final repository = _Repository();
      final service = _Service();
      final directory = await tester.runAsync(
        () => Directory.systemTemp.createTemp('cv_profile_test_'),
      );
      final photo = File('${directory!.path}/profile.png');
      await tester.runAsync(
        () => photo.writeAsBytes(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aWQAAAABJRU5ErkJggg==',
          ),
        ),
      );
      addTearDown(() => directory.delete(recursive: true));
      service.path = photo.path;
      Get.put<ResumeRepository>(repository, permanent: true);
      Get.put(ResumeController(repository: repository), permanent: true);
      Get.put(TemplateController(), permanent: true);
      Get.put(LanguageController(repository: repository), permanent: true);
      Get.put(ThemeController(repository: repository), permanent: true);
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          theme: AppTheme.light,
          home: const HomeScreen(),
          getPages: [
            GetPage(
              name: AppRoutes.settings,
              page: () => SettingsScreen(service: service),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final home = tester.state(find.byType(HomeScreen));
      await tester.tap(find.byKey(const ValueKey('home-profile-avatar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pick-profile-image')));
      await tester.pumpAndSettle();
      expect(repository.values[StorageKeys.profileImage], photo.path);
      expect(ProfileController.instance.imagePath, photo.path);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(HomeScreen)), same(home));
      final avatar = tester.widget<ProfileAvatar>(
        find.byKey(const ValueKey('home-profile-avatar')),
      );
      expect(avatar.imagePath, photo.path);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('home-profile-avatar')),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
      repository.fail = true;
      await expectLater(
        ProfileController.instance.setImage('new-path'),
        throwsStateError,
      );
      expect(ProfileController.instance.imagePath, photo.path);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'missing saved image uses the default icon without an image error',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              imagePath: 'missing-profile-image.png',
              label: 'Profile',
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
