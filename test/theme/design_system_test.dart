import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

double _contrast(Color first, Color second) {
  final a = first.computeLuminance(), b = second.computeLuminance();
  return (math.max(a, b) + .05) / (math.min(a, b) + .05);
}

class _Specimen extends StatelessWidget {
  const _Specimen({required this.arabic});
  final bool arabic;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(arabic ? 'نظام التصميم' : 'Design system')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadii.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CV Builder Pro',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.lightSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        arabic
                            ? 'سيرتك، بأسلوب يليق بك'
                            : 'Build your next opportunity',
                        style: AppTextStyles.resolve(
                          context,
                          AppTextStyles.body,
                        ).copyWith(color: AppColors.lightSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  arabic ? 'ملفك المهني' : 'Your professional profile',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  arabic
                      ? 'أنشئ سيرة واضحة واحترافية تدعم العربية والإنجليزية.'
                      : 'Create a clear, professional resume in Arabic or English.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          arabic ? 'المعلومات الشخصية' : 'Personal information',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          key: const ValueKey('specimen-name'),
                          decoration: InputDecoration(
                            labelText: arabic ? 'الاسم الكامل' : 'Full name',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: arabic
                                ? 'البريد الإلكتروني'
                                : 'Email address',
                            hintText: 'you@example.com',
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            ChoiceChip(
                              label: Text(arabic ? 'المهارات' : 'Skills'),
                              selected: true,
                              onSelected: (_) {},
                            ),
                            ChoiceChip(
                              label: Text(arabic ? 'الخبرات' : 'Experience'),
                              selected: false,
                              onSelected: (_) {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(arabic ? 'حفظ ومتابعة' : 'Save and continue'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: Text(arabic ? 'معاينة' : 'Preview'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(arabic ? 'إلغاء' : 'Cancel'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        arabic
                            ? 'محفوظ وجاهز للخطوة التالية'
                            : 'Saved and ready for the next step',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const LinearProgressIndicator(value: .6),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await poppins.load();
    final cairo = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
    await cairo.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  tearDown(Get.reset);
  for (final brightness in Brightness.values) {
    test('normal text contrast is readable in $brightness', () {
      final theme = brightness == Brightness.dark
          ? AppTheme.dark
          : AppTheme.light;
      for (final pair in [
        [theme.colorScheme.onSurface, theme.colorScheme.surface],
        [theme.colorScheme.onSurfaceVariant, theme.colorScheme.surface],
        [theme.colorScheme.onPrimary, theme.colorScheme.primary],
        [theme.colorScheme.onSecondary, theme.colorScheme.secondary],
        [theme.colorScheme.onError, theme.colorScheme.error],
        [theme.colorScheme.error, theme.colorScheme.surface],
      ]) {
        expect(
          _contrast(pair[0], pair[1]),
          greaterThanOrEqualTo(4.5),
          reason: 'Foreground/background contrast in $brightness',
        );
      }
    });
  }
  test(
    'localized typography can be selected without changing shared styles',
    () {
      final english = AppTheme.forLocale(Brightness.light, const Locale('en'));
      final arabic = AppTheme.forLocale(Brightness.dark, const Locale('ar'));
      expect(english.textTheme.bodyMedium!.fontFamily, 'Poppins');
      expect(arabic.textTheme.bodyMedium!.fontFamily, 'Cairo');
      expect(AppTextStyles.body.fontFamily, 'Poppins');
      expect(
        AppTheme.light.textTheme.bodyMedium!.fontFamilyFallback,
        contains('Cairo'),
      );
    },
  );
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final dark in [false, true]) {
      for (final arabic in [false, true]) {
        testWidgets(
          'design system fits $width ${dark ? 'dark' : 'light'} ${arabic ? 'Arabic' : 'English'}',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, width == 1024 ? 600 : 1100);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetPhysicalSize);
            const boundaryKey = ValueKey('design-system-preview');
            Widget host(double scale) => GetMaterialApp(
              locale: Locale(arabic ? 'ar' : 'en'),
              translations: AppTranslations(),
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: RepaintBoundary(
                key: boundaryKey,
                child: _Specimen(arabic: arabic),
              ),
            );
            await tester.pumpWidget(host(2));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final buttons = find.byType(ElevatedButton);
            await tester.ensureVisible(buttons);
            await tester.pumpAndSettle();
            expect(
              tester.getSize(buttons).height,
              greaterThanOrEqualTo(AppSpacing.touchTarget),
            );
            expect(tester.takeException(), isNull);
            if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                width == 390 &&
                dark == arabic) {
              await tester.pumpWidget(host(1));
              await tester.pumpAndSettle();
              await tester.drag(
                find.byType(SingleChildScrollView),
                const Offset(0, 2000),
              );
              await tester.pumpAndSettle();
              await tester.runAsync(() async {
                final boundary = tester.renderObject<RenderRepaintBoundary>(
                  find.byKey(boundaryKey),
                );
                final image = await boundary.toImage();
                try {
                  final bytes = await image.toByteData(
                    format: ui.ImageByteFormat.png,
                  );
                  await Directory(
                    'deliveries/ui_redesign',
                  ).create(recursive: true);
                  await File(
                    'deliveries/ui_redesign/batch_01_${dark ? 'dark_ar' : 'light_en'}.png',
                  ).writeAsBytes(bytes!.buffer.asUint8List());
                } finally {
                  image.dispose();
                }
              });
            }
          },
        );
      }
    }
  }
}
