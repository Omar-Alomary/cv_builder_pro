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
import '../../../../shared_widgets/app_page_transition.dart';
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
    AppPageTransition.install();
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
                  child: ClipRRect(
                    borderRadius: AppRadii.dialog,
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.cover,
                    ),
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
