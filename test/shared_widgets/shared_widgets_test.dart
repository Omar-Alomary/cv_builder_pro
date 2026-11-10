import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

Widget host(
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1,
  bool reducedMotion = false,
}) => MaterialApp(
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reducedMotion,
    ),
    child: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: child!,
    ),
  ),
  home: Scaffold(body: SafeArea(child: child)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en', 'US');
  });
  tearDown(() {
    Get.clearTranslations();
    Get.locale = null;
  });

  testWidgets('Text fields preserve controllers, validation and formatters', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      host(
        Form(
          key: form,
          child: AppTextField(
            label: 'Phone',
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) => value == '123' ? null : 'Invalid phone',
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), false);
    await tester.pump();
    expect(find.text('Invalid phone'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'abc123');
    expect(controller.text, '123');
    expect(form.currentState!.validate(), true);
    await tester.pump();
    expect(find.text('Invalid phone'), findsNothing);
  });

  testWidgets(
    'Text fields support initial values, disabled state and LTR entry inside RTL',
    (tester) async {
      await tester.pumpWidget(
        host(
          const AppTextField(
            label: 'البريد',
            initialValue: 'user@example.com',
            enabled: false,
            textDirection: TextDirection.ltr,
          ),
          rtl: true,
        ),
      );
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, false);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).textDirection,
        TextDirection.ltr,
      );
    },
  );

  testWidgets(
    'Buttons block duplicate presses while asynchronous work is pending',
    (tester) async {
      final completed = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        host(
          AppButton(
            label: 'Save',
            onPressed: () {
              calls++;
              return completed.future;
            },
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completed.complete();
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets(
    'Button errors show translated feedback and allow another attempt',
    (tester) async {
      await tester.pumpWidget(
        host(
          AppButton(
            label: 'Save',
            onPressed: () {
              throw StateError('Simulated failure');
            },
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text(enUs['action_failed']!), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Buttons can finish after their widget has been removed', (
    tester,
  ) async {
    final completed = Completer<void>();
    await tester.pumpWidget(
      host(AppButton(label: 'Save', onPressed: () => completed.future)),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpWidget(const SizedBox.shrink());
    completed.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Disabled buttons expose one accessible label', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        host(
          const AppButton(
            label: 'Save',
            semanticsLabel: 'Save resume',
            onPressed: null,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Save resume'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
    'Empty states and section headers wrap at 320 px with large RTL text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 360);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var actions = 0;
      await tester.pumpWidget(
        host(
          AppEmptyState(
            title: 'لا توجد سير ذاتية محفوظة حتى الآن',
            description: 'ابدأ بإنشاء سيرة ذاتية أو استيراد بياناتك.',
            actionLabel: 'إنشاء سيرة ذاتية جديدة',
            onAction: () {
              actions++;
            },
          ),
          dark: true,
          rtl: true,
          scale: 2,
        ),
      );
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(actions, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            child: AppSectionHeader(
              title: 'الخبرات العملية والإنجازات المهنية',
              subtitle: 'أضف الخبرات المرتبطة بالوظيفة المطلوبة',
              actionLabel: 'إضافة خبرة جديدة',
              onAction: () {
                actions++;
              },
            ),
          ),
          rtl: true,
          scale: 2,
        ),
      );
      await tester.ensureVisible(find.byType(TextButton));
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(actions, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Full-width buttons adapt to large text in narrow landscape layouts',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 320);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Save all changes to this resume',
                fullWidth: true,
                icon: Icons.save_outlined,
                onPressed: () {},
              ),
            ),
          ),
          dark: true,
          scale: 3,
        ),
      );
      expect(tester.getSize(find.byType(ElevatedButton)).width, 448);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ResponsiveBuilder uses local constraints and documented fallback layouts',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1920, 1080);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final entry in <double, String>{
        320: 'mobile',
        599: 'mobile',
        600: 'tablet',
        1199: 'tablet',
        1200: 'desktop',
        1920: 'desktop',
      }.entries) {
        await tester.pumpWidget(
          host(
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: entry.key,
                child: ResponsiveBuilder(
                  mobile: (_) => const Text('mobile'),
                  tablet: (_) => const Text('tablet'),
                  desktop: (_) => const Text('desktop'),
                ),
              ),
            ),
          ),
        );
        expect(find.text(entry.value), findsOneWidget);
      }
      await tester.pumpWidget(
        host(
          ResponsiveBuilder(
            mobile: (_) => const Text('mobile'),
            tablet: (_) => const Text('fallback'),
          ),
        ),
      );
      expect(find.text('fallback'), findsOneWidget);
    },
  );

  testWidgets(
    'Loading states respect reduced motion and expose progress to accessibility',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          host(
            const AppLoading(message: 'Reading resume'),
            reducedMotion: true,
          ),
        );
        expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
        expect(find.byType(LottieBuilder), findsNothing);
        await tester.pumpWidget(
          host(const AppLoading(message: 'Reading resume', progress: 0.4)),
        );
        expect(
          tester
              .widget<CircularProgressIndicator>(
                find.byType(CircularProgressIndicator),
              )
              .value,
          0.4,
        );
        final semantics = tester.getSemantics(
          find.bySemanticsLabel('Reading resume'),
        );
        expect(semantics.getSemanticsData().value, '40%');
      } finally {
        handle.dispose();
      }
    },
  );

  test('The bundled Lottie loading animation parses successfully', () async {
    final composition = await AssetLottie(
      'assets/animations/loading.json',
    ).load();
    expect(composition.duration, const Duration(seconds: 2));
    expect(composition.layers, isNotEmpty);
  });
}
