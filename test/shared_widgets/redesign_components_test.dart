import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

Widget _host(
  Widget child, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
  bool reduced = true,
  double inset = 0,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reduced,
      viewInsets: EdgeInsets.only(bottom: inset),
    ),
    child: child!,
  ),
  home: Scaffold(body: SafeArea(child: child)),
);

class _Gallery extends StatelessWidget {
  const _Gallery({required this.arabic});
  final bool arabic;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionHeader(
              title: arabic ? 'مكونات واجهتك' : 'Your interface toolkit',
              subtitle: arabic
                  ? 'تصميم متناسق، واضح وسهل الاستخدام'
                  : 'Consistent, clear and ready to use',
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        name: arabic ? 'عمر' : 'Omer',
                        onCameraPressed: () {},
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Text(
                          arabic ? 'ملفك المهني' : 'Your professional profile',
                          style: AppTextStyles.resolve(
                            context,
                            AppTextStyles.h4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: arabic ? 'الاسم الكامل' : 'Full name',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: arabic ? 'البريد الإلكتروني' : 'Email address',
                    hint: 'you@example.com',
                    textDirection: TextDirection.ltr,
                    prefixIcon: const Icon(Icons.mail_outline),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppChip(
                        label: 'Flutter',
                        icon: Icons.code,
                        selected: true,
                        onSelected: (_) {},
                      ),
                      AppChip(
                        label: arabic ? 'العمل الجماعي' : 'Teamwork',
                        variant: AppChipVariant.outlined,
                        onDeleted: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: arabic ? 'حفظ ومتابعة' : 'Save and continue',
              icon: Icons.arrow_forward,
              fullWidth: true,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(
                  label: arabic ? 'معاينة' : 'Preview',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                AppButton(
                  label: arabic ? 'حذف' : 'Delete',
                  variant: AppButtonVariant.danger,
                  onPressed: () {},
                ),
                AppButton(
                  label: arabic ? 'إلغاء' : 'Cancel',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppEmptyState(
              title: arabic ? 'ابدأ رحلتك المهنية' : 'Start your next chapter',
              description: arabic
                  ? 'أضف سيرتك الأولى أو استورد ملفاً محفوظاً.'
                  : 'Add your first resume or import a saved file.',
              actionLabel: arabic ? 'إنشاء سيرة' : 'Create resume',
              onAction: () {},
            ),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: false),
              child: const TickerMode(
                enabled: false,
                child: AppLoading(message: 'PDF preview'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
  testWidgets(
    'focus nodes can be replaced without disposing external ownership',
    (tester) async {
      final first = FocusNode(), second = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await tester.pumpWidget(
        _host(AppTextField(label: 'Name', focusNode: first)),
      );
      first.requestFocus();
      await tester.pumpAndSettle();
      expect(first.hasFocus, isTrue);
      await tester.pumpWidget(
        _host(AppTextField(label: 'Name', focusNode: second)),
      );
      second.requestFocus();
      await tester.pumpAndSettle();
      expect(second.hasFocus, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      first.requestFocus();
      second.requestFocus();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('button variants keep activation, size and one semantic label', (
    tester,
  ) async {
    var taps = 0;
    final handle = tester.ensureSemantics();
    try {
      for (final variant in AppButtonVariant.values) {
        await tester.pumpWidget(
          _host(
            Center(
              child: AppButton(
                label: 'Action',
                variant: variant,
                size: AppButtonSize.sm,
                onPressed: () {
                  taps++;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Action'), findsOneWidget);
        expect(
          tester.getSize(find.byType(AppButton)).height,
          greaterThanOrEqualTo(48),
        );
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();
      }
      expect(taps, AppButtonVariant.values.length);
    } finally {
      handle.dispose();
    }
  });
  testWidgets(
    'press feedback contracts and returns after pointer cancellation',
    (tester) async {
      await tester.pumpWidget(
        _host(
          Center(
            child: AppButton(label: 'Action', onPressed: () {}),
          ),
          reduced: false,
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AppButton)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        .98,
      );
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    },
  );
  testWidgets('interactive cards respond to keyboard activation', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        Center(
          child: AppCard(
            onTap: () {
              taps++;
            },
            child: const Text('Open resume'),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
  testWidgets('chips dispatch selection and deletion separately', (
    tester,
  ) async {
    var selected = false, deleted = false;
    await tester.pumpWidget(
      _host(
        Center(
          child: AppChip(
            label: 'Dart',
            onSelected: (value) => selected = value,
            onDeleted: () => deleted = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Dart'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
    await tester.tap(find.byTooltip('delete'.tr));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });
  testWidgets(
    'avatar retains fallback after an invalid image and camera works',
    (tester) async {
      var camera = 0;
      await tester.pumpWidget(
        _host(
          Center(
            child: AppAvatar(
              name: 'عمر',
              image: MemoryImage(Uint8List.fromList([0, 1, 2])),
              onCameraPressed: () => camera++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ع'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('change_profile_image'.tr));
      await tester.pumpAndSettle();
      expect(camera, 1);
    },
  );
  testWidgets('snackbars present semantic feedback in the active theme', (
    tester,
  ) async {
    late BuildContext anchor;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            anchor = context;
            return const Text('Anchor');
          },
        ),
        dark: true,
      ),
    );
    final variants = <void Function(BuildContext, String)>[
      AppSnackBar.success,
      AppSnackBar.warning,
      AppSnackBar.error,
      AppSnackBar.info,
    ];
    for (var i = 0; i < variants.length; i++) {
      variants[i](anchor, 'Feedback $i');
      await tester.pumpAndSettle();
      expect(find.text('Feedback $i'), findsOneWidget);
      ScaffoldMessenger.of(anchor).removeCurrentSnackBar();
      await tester.pumpAndSettle();
    }
  });
  testWidgets(
    'bottom sheet scrolls to completion with RTL large text and keyboard',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      String? result;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await AppBottomSheet.show<String>(
                  context: context,
                  title: 'نموذج طويل لإضافة المعلومات',
                  builder: (sheetContext) => Column(
                    children: [
                      for (var i = 0; i < 10; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AppTextField(label: 'الحقل $i'),
                        ),
                      AppButton(
                        label: 'Done',
                        onPressed: () =>
                            Navigator.of(sheetContext).pop('saved'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('OPEN'),
            ),
          ),
          arabic: true,
          scale: 2,
          inset: 200,
        ),
      );
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final done = find.widgetWithText(ElevatedButton, 'Done');
      await tester.ensureVisible(done);
      await tester.pumpAndSettle();
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(result, 'saved');
    },
  );
  testWidgets(
    'shimmer animates, stops for reduced motion and disposes safely',
    (tester) async {
      await tester.pumpWidget(
        _host(const AppLoading(message: 'Loading'), reduced: false),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ShaderMask), findsOneWidget);
      await tester.pumpWidget(
        _host(const AppLoading(message: 'Loading'), reduced: true),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final dark in [false, true]) {
      for (final arabic in [false, true]) {
        testWidgets('shared components fit $width $dark $arabic at scale 2', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, width == 1024 ? 600 : 900);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          const boundary = ValueKey('shared-preview');
          Widget host(double scale) => _host(
            RepaintBoundary(
              key: boundary,
              child: Builder(
                builder: (context) => ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _Gallery(arabic: arabic),
                ),
              ),
            ),
            arabic: arabic,
            dark: dark,
            scale: scale,
          );
          await tester.pumpWidget(host(2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final scroll = find.byType(SingleChildScrollView).first;
          await tester.drag(scroll, const Offset(0, -2000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
              width == 390 &&
              dark == arabic) {
            tester.view.physicalSize = const Size(390, 1500);
            await tester.pumpWidget(host(1));
            await tester.pumpAndSettle();
            await tester.drag(scroll, const Offset(0, 3000));
            await tester.pumpAndSettle();
            await tester.runAsync(() async {
              final image = await tester
                  .renderObject<RenderRepaintBoundary>(find.byKey(boundary))
                  .toImage();
              try {
                final bytes = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                await Directory(
                  'deliveries/ui_redesign',
                ).create(recursive: true);
                await File(
                  'deliveries/ui_redesign/batch_02_${dark ? 'dark_ar' : 'light_en'}.png',
                ).writeAsBytes(bytes!.buffer.asUint8List());
              } finally {
                image.dispose();
              }
            });
          }
        });
      }
    }
  }
}
