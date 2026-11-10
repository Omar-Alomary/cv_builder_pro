# UI/UX — Batch 3: Splash + Language
طُبقت إعادة تصميم شاشة البداية واختيار اللغة باستخدام نظام التصميم الجديد، مع خلفية مشتركة لتفادي تكرار التدرجات والدوائر الزخرفية. بقيت المتحكمات والخدمات والمستودعات والمسارات والترجمات والاعتماديات دون تعديل.
Splash: خلفية Indigo→Violet في الوضع الفاتح ودرجات أغمق في الوضع الداكن، شعار بإضاءة وحلقات متحركة، جسيمات خفيفة، عنوان وشعار نصي متحرك وشريط تقدم. توقيت الانتقال السابق (3 ثوانٍ) ومسار الاختيار الأول أو الانتقال للرئيسية بقيا كما هما. شريط التقدم جزء من الحركة الزمنية ولا يمثل عملية I/O جديدة.
اختيار اللغة: خلفية مشتركة، شعار، بطاقتان بزوايا 24 وظلال وإطار وتفاعل hover/press، ورمزان طباعيان Aa/ع لتجنب الاعتماد على عرض أعلام Emoji. تستمر أزرار اختيار اللغة والمناطق القابلة للنقر باستدعاء LanguageController.selectLanguage نفسه. أثناء الحفظ تتعطل البطاقتان ويظهر الانتظار على الزر المختار. عند فشل الحفظ تبقى الشاشة وتسمح بإعادة المحاولة عبر السلوك القائم.
الاستجابة: البطاقتان في عمود على الجوال وصف على التابلت وسطح المكتب. SafeArea وتمرير كامل ومحتوى محدود العرض. التدرجات والمسافات اتجاهية لدعم RTL/LTR، والخطوط تستخدم AppTextStyles. تدعم الحركة إعداد تقليل الحركة، ويُلغى مؤقت البداية عند إزالة الشاشة.
التحقق: نجحت اختبارات البداية واللغة الثمانية السابقة، ومنها الحفظ ومنع التكرار وإعادة المحاولة وتحديد مسار البداية. أضيفت 43 حالة اختبار: 40 حالة للشاشتين عند عروض 320/390/600/1024/1920 مع الوضعين واللغتين وتكبير النص 200%، وحالتا hover مع/دون تقليل الحركة، وتغيير تفضيل الحركة أثناء شاشة البداية. ارتفاع 480 عند عرض 1024 يغطي الحالة الأفقية أيضاً.
راجعت صوراً فعلية لكل شاشة في Light/EN وDark/AR بخطوط التطبيق وأيقوناته. لم تُجر محاولة تشغيل على جهاز فعلي في هذه الدفعة. صور البداية تلتقط الحالة الثابتة مع تقليل الحركة، بينما اختبارات التنقل القديمة تتحقق من حركة البداية وتوقيتها.
## صور التصميم
[البداية — فاتح / إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_03_splash_light_en.png)
[البداية — داكن / عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_03_splash_dark_ar.png)
[اختيار اللغة — فاتح / إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_03_language_light_en.png)
[اختيار اللغة — داكن / عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_03_language_dark_ar.png)
## الملفات كاملة
1. lib/features/splash/presentation/pages/splash_screen.dart
2. lib/features/splash/presentation/widgets/particle_painter.dart
3. lib/features/language/presentation/pages/language_selection_screen.dart
4. lib/shared_widgets/app_onboarding_background.dart
5. lib/shared_widgets/index.dart
6. test/onboarding/redesign_onboarding_test.dart

## lib/features/splash/presentation/pages/splash_screen.dart
```dart
import 'dart:async';
import 'dart:math' as math;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/language_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/app_onboarding_background.dart';
import '../widgets/particle_painter.dart';

/// Branded introduction preserving the existing three-second navigation flow.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale, _textFade;
  Timer? _navigationTimer;
  bool _animationStarted = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _logoScale = Tween<double>(begin: .75, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, .45, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.1, .4, curve: Curves.easeOut),
    );
    _navigationTimer = Timer(const Duration(seconds: 3), _navigate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_animationStarted) {
      _animationStarted = true;
      _controller.forward();
    }
  }

  void _navigate() {
    if (!mounted) return;
    final language = Get.find<LanguageController>();
    Get.offAllNamed<void>(
      language.isLanguageSelected.value
          ? AppRoutes.home
          : AppRoutes.languageSelection,
    );
  }

  Widget _logo(BuildContext context) {
    final size = Responsive.value<double>(
      context: context,
      mobile: AppSpacing.xxxl * 4,
      tablet: AppSpacing.xxxl * 5,
    );
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final factor in [1.0, .8])
              Transform.rotate(
                angle: _controller.value * math.pi * .12,
                child: Transform.scale(
                  scale: .9 + _controller.value * .1,
                  child: Container(
                    width: size * factor,
                    height: size * factor,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.lightSurface.withValues(alpha: .18),
                        width: AppSpacing.stroke,
                      ),
                    ),
                  ),
                ),
              ),
            Transform.scale(
              scale: _logoScale.value,
              child: Hero(
                tag: 'cv-onboarding-logo',
                child: Container(
                  width: size * .56,
                  height: size * .56,
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: AppRadii.dialog,
                    boxShadow: [
                      ...AppShadows.colored(AppColors.primaryLight),
                      BoxShadow(
                        color: AppColors.lightSurface.withValues(alpha: .2),
                        blurRadius: AppSpacing.xxxl,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: AppSpacing.xxxl,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final white = AppColors.lightSurface;
    final caption = AppTextStyles.resolve(
      context,
      AppTextStyles.bodySmall,
    ).copyWith(color: white.withValues(alpha: .9));
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        body: SizedBox.expand(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => AppOnboardingBackground(
              decoration: CustomPaint(
                painter: ParticlePainter(progress: _controller.value),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      Responsive.value<double>(
                        context: context,
                        mobile: AppSpacing.lg,
                        tablet: AppSpacing.xl,
                        desktop: AppSpacing.xxl,
                      ),
                    ),
                    child: Responsive.maxWidth(
                      width: Responsive.maxContentWidth * .6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _logo(context),
                          const SizedBox(height: AppSpacing.xl),
                          FadeTransition(
                            opacity: _textFade,
                            child: Semantics(
                              header: true,
                              child: Text(
                                'app_name'.tr,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.resolve(
                                  context,
                                  Responsive.isMobile(context)
                                      ? AppTextStyles.h1
                                      : AppTextStyles.display,
                                ).copyWith(color: white),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Semantics(
                            label: 'splash_tagline'.tr,
                            excludeSemantics: true,
                            child: reduced
                                ? Text(
                                    'splash_tagline'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.resolve(
                                      context,
                                      AppTextStyles.bodyLarge,
                                    ).copyWith(color: white),
                                  )
                                : AnimatedTextKit(
                                    key: ValueKey(Get.locale?.languageCode),
                                    totalRepeatCount: 1,
                                    animatedTexts: [
                                      FadeAnimatedText(
                                        'splash_tagline'.tr,
                                        textAlign: TextAlign.center,
                                        duration: const Duration(
                                          milliseconds: 2200,
                                        ),
                                        textStyle: AppTextStyles.resolve(
                                          context,
                                          AppTextStyles.bodyLarge,
                                        ).copyWith(color: white),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppSpacing.loadingMaxWidth,
                            ),
                            child: LinearProgressIndicator(
                              key: const ValueKey('splash-progress'),
                              value: _controller.value,
                              minHeight: AppSpacing.xs,
                              borderRadius: AppRadii.chip,
                              color: AppColors.secondaryLight,
                              backgroundColor: white.withValues(alpha: .18),
                              semanticsLabel: 'splash_preparing'.tr,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'splash_preparing'.tr,
                            textAlign: TextAlign.center,
                            style: caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

```

## lib/features/splash/presentation/widgets/particle_painter.dart
```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Deterministic low-contrast particles for the finite splash animation.
class ParticlePainter extends CustomPainter {
  const ParticlePainter({
    required this.progress,
    this.color = AppColors.lightSurface,
  });
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()..color = color.withValues(alpha: .22);
    for (var index = 0; index < 32; index++) {
      final position = Offset(
        size.width * random.nextDouble(),
        size.height * random.nextDouble(),
      );
      final radius =
          AppSpacing.focusStroke *
          random.nextDouble() *
          progress.clamp(0.0, 1.0);
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

```

## lib/features/language/presentation/pages/language_selection_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/language_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/app_button.dart';
import '../../../../shared_widgets/app_onboarding_background.dart';

/// Responsive language choices retaining controller persistence and routing.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});
  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _animationStarted = false;
  final _hovered = <String>{};
  String? _pressedCode, _activeCode;
  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _animation, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, .04),
      end: Offset.zero,
    ).animate(_fade);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 1;
    } else if (!_animationStarted) {
      _animationStarted = true;
      _animation.forward();
    }
  }

  Widget _card(String code) {
    final controller = Get.find<LanguageController>();
    final english = code == 'en';
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final busy = controller.isSelecting.value;
      Future<void> select() async {
        if (controller.isSelecting.value) return;
        setState(() => _activeCode = code);
        try {
          await controller.selectLanguage(code);
        } finally {
          if (mounted) setState(() => _activeCode = null);
        }
      }

      final reduced = MediaQuery.disableAnimationsOf(context);
      final hovered = _hovered.contains(code);
      return MouseRegion(
        cursor: busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered.add(code)),
        onExit: (_) => setState(() => _hovered.remove(code)),
        child: AnimatedScale(
          key: ValueKey('language-card-$code'),
          scale: reduced || busy
              ? 1
              : _pressedCode == code
              ? 0.98
              : hovered
              ? 1.02
              : 1,
          duration: reduced ? Duration.zero : AppTheme.motionDuration,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadii.dialog,
              boxShadow: hovered && !busy
                  ? AppShadows.colored(scheme.primary)
                  : AppShadows.forBrightness(Theme.of(context).brightness),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.dialog,
                side: BorderSide(
                  color: hovered
                      ? scheme.primary
                      : scheme.outline.withValues(alpha: .65),
                ),
              ),
              child: InkWell(
                onTap: busy ? null : select,
                canRequestFocus: false,
                excludeFromSemantics: true,
                onHighlightChanged: (value) =>
                    setState(() => _pressedCode = value ? code : null),
                borderRadius: AppRadii.dialog,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: AppSpacing.avatar,
                          height: AppSpacing.avatar,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: AppRadii.dialog,
                          ),
                          child: Center(
                            child: Text(
                              english ? 'Aa' : 'ع',
                              textScaler: TextScaler.noScaling,
                              style:
                                  (english
                                          ? AppTextStyles.h1
                                          : AppTextStyles.h1.copyWith(
                                              fontFamily: AppTextStyles
                                                  .arabicFontFamily,
                                            ))
                                      .copyWith(color: scheme.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Semantics(
                        header: true,
                        child: Text(
                          (english ? 'language_english' : 'language_arabic').tr,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.resolve(
                            context,
                            AppTextStyles.h3,
                          ).copyWith(color: scheme.onSurface),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        (english ? 'country_us' : 'country_sa').tr,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.resolve(
                          context,
                          AppTextStyles.bodySmall,
                        ).copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        (english ? 'switch_to_english' : 'switch_to_arabic').tr,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.resolve(
                          context,
                          AppTextStyles.bodySmall,
                        ).copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        key: ValueKey('select-$code'),
                        label:
                            (english ? 'select_english' : 'select_arabic').tr,
                        isLoading: busy && _activeCode == code,
                        fullWidth: true,
                        onPressed: busy ? null : select,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: Get.locale?.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr,
    child: Scaffold(
      body: SizedBox.expand(
        child: AppOnboardingBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  Responsive.value<double>(
                    context: context,
                    mobile: AppSpacing.lg,
                    tablet: AppSpacing.xl,
                    desktop: AppSpacing.xxl,
                  ),
                ),
                child: Responsive.maxWidth(
                  width: Responsive.maxContentWidth * .75,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExcludeSemantics(
                            child: Hero(
                              tag: 'cv-onboarding-logo',
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                decoration: BoxDecoration(
                                  color: AppColors.lightSurface,
                                  borderRadius: AppRadii.dialog,
                                  boxShadow: AppShadows.colored(
                                    AppColors.primaryLight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.translate,
                                  size: AppSpacing.xxxl,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Semantics(
                            header: true,
                            child: Text(
                              'language_selection_title'.tr,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.resolve(
                                context,
                                Responsive.isMobile(context)
                                    ? AppTextStyles.h2
                                    : AppTextStyles.h1,
                              ).copyWith(color: AppColors.lightSurface),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'language_selection_subtitle'.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.body,
                            ).copyWith(color: AppColors.lightSurface),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          if (Responsive.isTabletOrLarger(context))
                            Row(
                              key: const ValueKey('language-row'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _card('en')),
                                const SizedBox(width: AppSpacing.xl),
                                Expanded(child: _card('ar')),
                              ],
                            )
                          else
                            Column(
                              key: const ValueKey('language-column'),
                              children: [
                                _card('en'),
                                const SizedBox(height: AppSpacing.xl),
                                _card('ar'),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }
}

```

## lib/shared_widgets/app_onboarding_background.dart
```dart
import 'package:flutter/material.dart';
import '../app/theme/index.dart';

/// Direction-aware onboarding canvas with restrained orbs and a dark palette.
class AppOnboardingBackground extends StatelessWidget {
  const AppOnboardingBackground({
    super.key,
    required this.child,
    this.decoration,
  });
  final Widget child;
  final Widget? decoration;
  Widget _orb(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          AppColors.lightSurface.withValues(alpha: alpha),
          AppColors.transparent,
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  AppColors.darkBackground,
                  AppColors.darkTint,
                  AppColors.primaryDark,
                ],
              )
            : AppColors.primaryGradient,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diameter = (constraints.maxWidth * .7).clamp(
            AppSpacing.xxxl * 4,
            AppSpacing.xxxl * 10,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(
                child: Stack(
                  children: [
                    PositionedDirectional(
                      top: -AppSpacing.xxxl,
                      start: -AppSpacing.xxxl,
                      child: _orb(diameter, dark ? .08 : .15),
                    ),
                    PositionedDirectional(
                      bottom: -AppSpacing.xxxl,
                      end: -AppSpacing.xxxl,
                      child: _orb(diameter * 1.2, dark ? .06 : .12),
                    ),
                    PositionedDirectional(
                      top: constraints.maxHeight * .4,
                      end: AppSpacing.xl,
                      child: _orb(AppSpacing.xxxl * 2, .08),
                    ),
                  ],
                ),
              ),
              if (decoration != null) ExcludeSemantics(child: decoration!),
              child,
            ],
          );
        },
      ),
    );
  }
}

```

## lib/shared_widgets/index.dart
```dart
export 'app_text_field.dart';
export 'app_button.dart';
export 'app_empty_state.dart';
export 'app_section_header.dart';
export 'app_loading.dart';
export 'responsive_builder.dart';
export 'app_card.dart';
export 'app_chip.dart';
export 'app_avatar.dart';
export 'app_snack_bar.dart';
export 'app_bottom_sheet.dart';
export 'app_onboarding_background.dart';

```

## test/onboarding/redesign_onboarding_test.dart
```dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/language_controller.dart';
import 'package:cv_builder_pro/data/repositories/resume_repository.dart';
import 'package:cv_builder_pro/features/language/index.dart';
import 'package:cv_builder_pro/features/splash/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  T? read<T>(String key) => null;
  @override
  Future<void> write(String key, Object? value) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _prepare(bool arabic) {
  Get.testMode = true;
  Get.locale = Locale(arabic ? 'ar' : 'en');
  Get.put(LanguageController(repository: _Repository()));
}

Widget _host(
  Widget child, {
  bool dark = false,
  bool arabic = false,
  double scale = 1,
  bool reduced = true,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reduced,
    ),
    child: child!,
  ),
  home: child,
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('onboarding-preview')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('deliveries/ui_redesign').create(recursive: true);
      await File(
        'deliveries/ui_redesign/batch_03_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
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
  for (final splash in [true, false]) {
    for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
      for (final dark in [false, true]) {
        for (final arabic in [false, true]) {
          testWidgets(
            '${splash ? 'splash' : 'language'} fits $width $dark $arabic at text scale 2',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(width, width == 1024 ? 480 : 900);
              addTearDown(tester.view.resetDevicePixelRatio);
              addTearDown(tester.view.resetPhysicalSize);
              _prepare(arabic);
              Widget host(double scale) => _host(
                RepaintBoundary(
                  key: const ValueKey('onboarding-preview'),
                  child: splash
                      ? const SplashScreen()
                      : const LanguageSelectionScreen(),
                ),
                dark: dark,
                arabic: arabic,
                scale: scale,
              );
              await tester.pumpWidget(host(2));
              await tester.pump();
              expect(tester.takeException(), isNull);
              expect(
                Directionality.of(tester.element(find.byType(SafeArea))),
                arabic ? TextDirection.rtl : TextDirection.ltr,
              );
              if (!splash) {
                expect(
                  find.byKey(
                    ValueKey(width >= 600 ? 'language-row' : 'language-column'),
                  ),
                  findsOneWidget,
                );
                await tester.ensureVisible(
                  find.byKey(const ValueKey('select-ar')),
                );
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
              if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                  width == 390 &&
                  dark == arabic) {
                tester.view.physicalSize = Size(390, splash ? 900 : 1400);
                await tester.pumpWidget(host(1));
                await tester.pump();
                if (!splash) {
                  await tester.drag(
                    find.byType(SingleChildScrollView),
                    const Offset(0, 3000),
                  );
                  await tester.pumpAndSettle();
                }
                await _capture(
                  tester,
                  '${splash ? 'splash' : 'language'}_${dark ? 'dark_ar' : 'light_en'}',
                );
              }
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump(const Duration(seconds: 4));
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
  for (final reduced in [false, true]) {
    testWidgets('language hover respects reduced motion $reduced', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1024, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      _prepare(false);
      await tester.pumpWidget(
        _host(const LanguageSelectionScreen(), reduced: reduced),
      );
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('language-card-en'));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(0, 0));
      await mouse.moveTo(tester.getCenter(card));
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(card).scale, reduced ? 1 : 1.02);
      await mouse.removePointer();
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(card).scale, 1);
    });
  }
  testWidgets('splash remains finite when motion preference changes', (
    tester,
  ) async {
    _prepare(false);
    await tester.pumpWidget(_host(const SplashScreen(), reduced: false));
    await tester.pump(const Duration(milliseconds: 800));
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('splash-progress')),
          )
          .value,
      lessThan(1),
    );
    await tester.pumpWidget(_host(const SplashScreen(), reduced: true));
    await tester.pump();
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('splash-progress')),
          )
          .value,
      1,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
}

```


التحقق النهائي: flutter analyze دون ملاحظات، ونجحت جميع اختبارات المشروع وعددها 352 (309 سابقة + 43 جديدة).
