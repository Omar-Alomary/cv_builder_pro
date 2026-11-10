# Part 2 — الدفعة العاشرة: شاشة البداية واختيار اللغة

الملفات كاملة دون اختصار. تم الحفاظ على التدرج اللوني والحلقات والشعار والجزيئات في شاشة البداية، مع تحسين التجاوب وإلغاء مؤقت التنقل عند إغلاقها. تستمر المقدمة ثلاث ثوانٍ، وتنتقل إلى اختيار اللغة أو الرئيسية وفق الحالة المحفوظة.

بطاقتا اللغة عموديتان على الجوال وجانباً إلى جنب من عرض 600 بكسل، مع دعم العربية والثيم الداكن وتكبير النص وتقليل الحركة. يمنع المتحكم تكرار الاختيار أثناء الحفظ. أُزيلت نسختا الشاشتين والرسام من lib/legacy_app.dart، وربطت المسارات بالملفات الجديدة. لا توجد اعتمادية جديدة.

التحقق: اجتازت الملفات المفصولة الفحص دون ملاحظات، ونجحت اختبارات المشروع الـ72، منها ثمانية اختبارات لهذه الدفعة. أصبحت قواميس الترجمة تحتوي على 332 مفتاحاً لكل لغة.

## lib/features/splash/presentation/pages/splash_screen.dart

```dart
import 'dart:async';
import 'dart:math' as math;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/language_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/particle_painter.dart';

/// Animated introduction retaining the original gradient, logo and rings.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _textFade;
  Timer? _navigationTimer;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.elasticOut),
      ),
    );
    _ringScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
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

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _orb(double diameter, double alpha) => Container(
    width: diameter,
    height: diameter,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          Colors.white.withValues(alpha: alpha),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _logo() => ExcludeSemantics(
    child: SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final factor in [1.0, 0.85])
            Transform.scale(
              scale: _ringScale.value * factor,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
              ),
            ),
          Transform.rotate(
            angle: -0.25 * (1 - _controller.value),
            child: Transform.scale(
              scale: _logoScale.value,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF1F5F9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.25),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description,
                  size: 65,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: SweepGradient(
                startAngle: 0,
                endAngle: math.pi * 2,
                colors: [
                  dark
                      ? const Color(0xFF0F172A)
                      : Theme.of(context).colorScheme.primary,
                  const Color(0xFF6A1B9A),
                  const Color(0xFF1A237E),
                  dark
                      ? const Color(0xFF0F172A)
                      : Theme.of(context).colorScheme.primary,
                ],
                stops: const [0, 0.3, 0.7, 1],
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(
                    child: CustomPaint(
                      painter: ParticlePainter(progress: _controller.value),
                    ),
                  ),
                  Positioned(top: -50, left: -50, child: _orb(180, 0.15)),
                  Positioned(bottom: -60, right: -50, child: _orb(220, 0.12)),
                  Positioned(top: 100, right: 40, child: _orb(80, 0.1)),
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: Responsive.pagePadding(context),
                        child: Responsive.maxWidth(
                          width: 700,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _logo(),
                              const SizedBox(height: 24),
                              Opacity(
                                opacity: _textFade.value,
                                child: Semantics(
                                  header: true,
                                  child: Text(
                                    'app_name'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.fontSize(
                                        context,
                                        mobile: 30,
                                        tablet: 36,
                                        desktop: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 60,
                                height: 3,
                                color: Colors.white70,
                              ),
                              const SizedBox(height: 20),
                              Semantics(
                                label: 'splash_tagline'.tr,
                                excludeSemantics: true,
                                child: reducedMotion
                                    ? Text(
                                        'splash_tagline'.tr,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
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
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 48),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                child: LinearProgressIndicator(
                                  value: _controller.value,
                                  color: Colors.white,
                                  backgroundColor: Colors.white24,
                                  semanticsLabel: 'splash_preparing'.tr,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'splash_preparing'.tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## lib/features/splash/presentation/widgets/particle_painter.dart

```dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Deterministic decorative particles used by the introductory screen.
class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  const ParticlePainter({required this.progress, this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()..color = color.withValues(alpha: 0.4);
    for (var index = 0; index < 50; index++) {
      final position = Offset(
        size.width * random.nextDouble(),
        size.height * random.nextDouble(),
      );
      final radius = 2 * random.nextDouble() * progress.clamp(0.0, 1.0);
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
import '../../../../controllers/language_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/app_button.dart';

/// Responsive first-run language selection with persistent choices.
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
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _animation, curve: Curves.easeIn);
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

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Widget _card(String code) {
    final controller = Get.find<LanguageController>();
    final english = code == 'en';
    final theme = Theme.of(context);
    return Obx(() {
      final busy = controller.isSelecting.value;
      Future<void> select() => controller.selectLanguage(code);
      return Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: busy ? null : select,
          canRequestFocus: false,
          excludeFromSemantics: true,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Text(
                      english ? '🇺🇸' : '🇸🇦',
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    (english ? 'language_english' : 'language_arabic').tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (english ? 'country_us' : 'country_sa').tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  (english ? 'switch_to_english' : 'switch_to_arabic').tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                AppButton(
                  key: ValueKey('select-$code'),
                  label: (english ? 'select_english' : 'select_arabic').tr,
                  onPressed: busy ? null : select,
                  fullWidth: true,
                ),
              ],
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0F172A)
                    : Theme.of(context).colorScheme.primary,
                const Color(0xFF1A237E),
                const Color(0xFF0D47A1),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -70,
                left: -70,
                child: ExcludeSemantics(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white10,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -90,
                right: -60,
                child: ExcludeSemantics(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white10,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: Responsive.pagePadding(context),
                    child: Responsive.maxWidth(
                      width: 900,
                      child: FadeTransition(
                        opacity: _fade,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ExcludeSemantics(
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.translate,
                                  size: 48,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Semantics(
                              header: true,
                              child: Text(
                                'language_selection_title'.tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'language_selection_subtitle'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (Responsive.isTabletOrLarger(context))
                              Row(
                                key: const ValueKey('language-row'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _card('en')),
                                  const SizedBox(width: 20),
                                  Expanded(child: _card('ar')),
                                ],
                              )
                            else
                              Column(
                                key: const ValueKey('language-column'),
                                children: [
                                  _card('en'),
                                  const SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    ),
  );
}
```

## lib/features/splash/index.dart

```dart
export 'presentation/pages/splash_screen.dart';
export 'presentation/widgets/particle_painter.dart';
```

## lib/features/language/index.dart

```dart
export 'presentation/pages/language_selection_screen.dart';
```

## lib/features/index.dart

```dart
export 'splash/index.dart';
export 'language/index.dart';
```

## lib/app/routes/app_pages.dart

```dart
import 'package:get/get.dart';
import '../../legacy_app.dart' as legacy;
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/language/presentation/pages/language_selection_screen.dart';
import 'app_routes.dart';

/// Registers existing screens during the staged migration.
abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.root, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const legacy.HomeScreen()),
    GetPage(
      name: AppRoutes.templates,
      page: () => const legacy.TemplatesScreen(),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const legacy.FavoritesScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const legacy.SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () => const legacy.ResumeBuilderScreen(),
    ),
    GetPage(name: AppRoutes.preview, page: () => const legacy.PreviewScreen()),
  ];
}
```

## lib/controllers/language_controller.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/index.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/app_snackbar.dart';

/// Manages the persisted application language.
class LanguageController extends GetxController {
  final ResumeRepository _repository;
  final RxBool isLanguageSelected = false.obs;
  final RxString currentLanguage = 'en'.obs;
  final RxBool isSelecting = false.obs;

  LanguageController({ResumeRepository? repository})
    : _repository = repository ?? Get.find<ResumeRepository>();

  @override
  void onInit() {
    super.onInit();
    checkLanguageSelection();
  }

  Future<void> checkLanguageSelection() async {
    try {
      isLanguageSelected.value =
          _repository.read<bool>(StorageKeys.languageSelected) ?? false;
      final locale = _repository.read<String>(StorageKeys.appLocale) ?? 'en';
      currentLanguage.value = locale;
      if (isLanguageSelected.value && Get.locale?.languageCode != locale) {
        Get.locale = Locale(locale);
        Get.appUpdate();
      }
    } catch (error) {
      AppSnackbar.storageError();
    }
  }

  Future<void> selectLanguage(String languageCode) async {
    if (isSelecting.value) return;
    isSelecting.value = true;
    try {
      await _repository.write(StorageKeys.appLocale, languageCode);
      await _repository.write(StorageKeys.languageSelected, true);
      currentLanguage.value = languageCode;
      if (Get.locale?.languageCode != languageCode) {
        // A new route is opened below; update the application locale without
        // a hot-reassemble of the departing selection screen.
        Get.locale = Locale(languageCode);
        Get.appUpdate();
      }
      isLanguageSelected.value = true;
      Get.offAllNamed('/home');
    } catch (error) {
      AppSnackbar.storageError();
    } finally {
      isSelecting.value = false;
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      await _repository.write(StorageKeys.appLocale, languageCode);
      currentLanguage.value = languageCode;
      if (Get.locale?.languageCode != languageCode) {
        await Get.updateLocale(Locale(languageCode));
      }
    } catch (error) {
      AppSnackbar.storageError();
    }
  }
}
```

## lib/core/extensions/context_extensions.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/responsive.dart';

/// Convenient access to inherited display and localization properties.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  bool get isArabic =>
      (Get.locale ?? Localizations.localeOf(this)).languageCode == 'ar';
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  TextScaler get textScaler => MediaQuery.textScalerOf(this);
}
```

## lib/translations/en_us.dart

```dart
/// English interface messages.
const Map<String, String> enUs = {
  'home': 'Home',
  'templates': 'Templates',
  'favorites': 'Favorites',
  'settings': 'Settings',
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'next': 'Next',
  'previous': 'Previous',
  'finish': 'Finish',
  'preview': 'Preview',
  'view_all': 'View All',
  'success': 'Success',
  'resume_saved': 'Resume saved successfully',
  'resume_deleted': 'Resume deleted successfully',
  'no_resumes_found': 'No resumes found',
  'no_favorites': 'No favorites yet',
  'browse_templates': 'Browse Templates',
  'create_new': 'Create New',
  'recent_activity': 'Recent Activity',
  'featured_templates': 'Featured Templates',
  'use_template': 'Use Template',
  'personal_info': 'Personal Information',
  'education': 'Education',
  'experience': 'Experience',
  'skills': 'Skills',
  'full_name': 'Full Name',
  'email': 'Email',
  'phone': 'Phone',
  'address': 'Address',
  'summary': 'Professional Summary',
  'degree': 'Degree',
  'institution': 'Institution',
  'graduation_year': 'Graduation Year',
  'grade': 'Grade',
  'add_education': 'Add Education',
  'edit_education': 'Edit Education',
  'no_education_added': 'No education added',
  'degree_required': 'Degree is required',
  'institution_required': 'Institution is required',
  'year_required': 'Graduation year is required',
  'job_title': 'Job Title',
  'company': 'Company',
  'start_date': 'Start Date',
  'end_date': 'End Date',
  'current_job': 'Current Job',
  'description': 'Description',
  'add_experience': 'Add Experience',
  'edit_experience': 'Edit Experience',
  'no_experience_added': 'No experience added',
  'job_title_required': 'Job title is required',
  'company_required': 'Company is required',
  'start_date_required': 'Start date is required',
  'skill_name': 'Skill Name',
  'skill_level': 'Skill Level',
  'add_skill': 'Add Skill',
  'no_skills_added': 'No skills added',
  'language': 'Language',
  'change_app_language': 'Change app language',
  'dark_mode': 'Dark Mode',
  'switch_theme': 'Switch between light and dark theme',
  'contact_us': 'Contact Us',
  'share_app': 'Share App',
  'email_required': 'Email is required',
  'invalid_email': 'Please enter a valid email',
  'phone_required': 'Phone number is required',
  'invalid_phone': 'Please enter a valid phone number',
  'is_required': 'is required',
  'create_resume': 'Create Resume',
  'edit_resume': 'Edit Resume',
  'customize_resume': 'Customize Resume',
  'apply_changes': 'Apply Changes',
  'customization_saved': 'Customization saved successfully',
  'failed_to_generate_preview': 'Failed to generate preview',
  'failed_to_export': 'Failed to export PDF',
  'choose_color': 'Choose Color',
  'preview_updated': 'Preview updated successfully',
  'update_preview': 'Update Preview',
  'courses': 'Courses',
  'certificates': 'Certificates',
  'languages': 'Languages',
  'add_course': 'Add Course',
  'add_certificate': 'Add Certificate',
  'add_language': 'Add Language',
  'course_name': 'Course Name',
  'certificate_name': 'Certificate Name',
  'language_name': 'Language Name',
  'provider': 'Provider',
  'organization': 'Organization',
  'proficiency_level': 'Proficiency Level',
  'no_courses_added': 'No courses added',
  'no_certificates_added': 'No certificates added',
  'no_languages_added': 'No languages added',
  'course_name_required': 'Course name is required',
  'provider_required': 'Provider is required',
  'certificate_name_required': 'Certificate name is required',
  'organization_required': 'Organization is required',
  'language_name_required': 'Language name is required',
  'additional_info': 'Additional Info',
  'projects': 'Projects',
  'achievements': 'Achievements',
  'interests': 'Interests',
  'project_name': 'Project Name',
  'achievement': 'Achievement',
  'no_projects_added': 'No projects added',
  'no_achievements_added': 'No achievements added',
  'no_additional_sections': 'No additional sections available',
  'your_selected_interests': 'Your Selected Interests:',
  'select_interests': 'Select Your Interests',
  'linkedin': 'LinkedIn',
  'github': 'GitHub',
  'website': 'Website',
  'portfolio': 'Portfolio',
  'profile_image_updated': 'Profile image updated successfully',
  'clear_cache': 'Clear Cache',
  'clear_cache_description': 'Remove temporary files and free up space',
  'clear_cache_confirmation': 'Are you sure you want to clear cache?',
  'cache_cleared': 'Cache cleared successfully',
  'cache_clear_failed': 'Failed to clear cache',
  'data': 'Data',
  'about': 'About',
  'app_version': 'App Version',
  'version_1_0_0': 'Version 1.0.0',
  'exit_app': 'Exit App',
  'exit_confirmation': 'Are you sure you want to exit?',
  'exit': 'Exit',
  'yes': 'Yes',
  'no': 'No',
  'logged_out': 'Logged out',
  'come_back_soon': 'We hope to see you again soon!',
  'logout_confirmation': 'Are you sure you want to logout?',
  'professional_resume_builder': 'Professional Resume Builder',
  'appearance': 'Appearance',
  'data_management': 'Data Management',
  'support': 'Support',
  'get_help_support': 'Get help and support',
  'rate_app': 'Rate App',
  'rate_us_on_store': 'Rate us on the store',
  'share_with_friends': 'Share with friends',
  'cannot_open_email': 'Cannot open email client',
  'select_language': 'Select Language',
  'add_project': 'Add Project',
  'edit_project': 'Edit Project',
  'current_project': 'Current Project',
  'technologies_used': 'Technologies Used',
  'add_technology': 'Add Technology',
  'project_name_required': 'Project name is required',
  'description_required': 'Description is required',
  'achievement_name': 'Achievement Name',
  'achievement_name_required': 'Achievement name is required',
  'category': 'Category',
  'date_required': 'Date is required',
  'add_achievement': 'Add Achievement',
  'edit_achievement': 'Edit Achievement',
  'cache_cleared_completely': 'Cache cleared completely',
  'clear_all_data': 'Clear All Data',
  'clear_all_data_confirmation':
      'This will delete ALL your resumes and settings. This action cannot be undone. Are you sure?',
  'clear_all': 'Clear All',
  'all_data_cleared': 'All data cleared successfully',
  'clear_all_data_failed': 'Failed to clear all data',
  'close': 'Close',
  'date': 'Date',
  'year': 'Year',
  'error': 'Error',
  'retry': 'Retry',
  'featured': 'Featured',
  'logout': 'Log out',
  'my_skills': 'My skills',
  'resumes': 'Resumes',
  'edit_certificate': 'Edit certificate',
  'edit_course': 'Edit course',
  'edit_language': 'Edit language',
  'app_name': 'CV Builder Pro',
  'search_templates': 'Search templates',
  'search': 'Search',
  'no_search_results': 'No matching results',
  'search_hint': 'Search by name or description',
  'total_resumes': 'Total resumes',
  'favorite_resumes': 'Favorite resumes',
  'available_templates': 'Available templates',
  'saving': 'Saving…',
  'auto_saved': 'Saved automatically',
  'last_saved': 'Last saved: @time',
  'save_failed': 'Could not save your changes. Try again.',
  'loading': 'Loading…',
  'please_wait': 'Please wait',
  'storage_error':
      'Storage operation failed. Check device storage and try again.',
  'startup_error':
      'Local storage could not be opened. Close and reopen the app. If the problem persists, check storage space and app permissions.',
  'field_required': '@field is required',
  'invalid_url': 'Enter a full http(s) URL',
  'invalid_date': 'Use a valid MM/YYYY date',
  'invalid_date_range': 'The end date must not precede the start date',
  'choose_image': 'Choose image',
  'remove_image': 'Remove image',
  'delete_resume_confirmation': 'Delete this resume?',
  'select_resume': 'Select a resume',
  'import_resume': 'Import resume',
  'export_json': 'Export JSON',
  'export_pdf': 'Export PDF',
  'share_json': 'Share JSON',
  'share_pdf': 'Share PDF',
  'print_pdf': 'Print PDF',
  'import_json': 'Import JSON',
  'import_pdf': 'Import PDF',
  'import_txt': 'Import TXT',
  'recommended': 'Recommended',
  'choose_file': 'Choose file',
  'paste_json': 'Paste JSON',
  'paste_json_hint': 'Paste the complete resume JSON here',
  'json_import_description':
      'Restores all fields from a compatible resume JSON file.',
  'pdf_import_description':
      'Attempts to extract text from supported text-based PDF files. Scanned PDFs require OCR.',
  'txt_import_description':
      'Extracts recognizable contact details and text for review.',
  'import_preview': 'Review imported data',
  'import_loading': 'Reading resume…',
  'import_success': 'Resume imported successfully',
  'import_failed': 'Could not import this file. Check its format and contents.',
  'import_cancelled': 'No file selected',
  'unsupported_file': 'This file type is not supported',
  'file_too_large': 'The file exceeds the 10 MB import limit',
  'invalid_json': 'The JSON structure or field types are invalid',
  'pdf_import_unsupported':
      'Text could not be extracted from this PDF. Try JSON or TXT.',
  'review_before_save':
      'Review and correct the imported information before saving.',
  'save_and_edit': 'Save and edit',
  'export_success': 'Export completed',
  'export_failed': 'Could not export the resume',
  'export_cancelled': 'Export cancelled',
  'export_quality': 'Export quality',
  'quality_standard': 'Standard',
  'quality_high': 'High',
  'customization': 'Customization',
  'font_family': 'Font',
  'font_size': 'Font size',
  'primary_color': 'Primary color',
  'secondary_color': 'Secondary color',
  'ats_checker': 'ATS checker',
  'ats_score': 'ATS score',
  'ats_score_out_of': '@score out of 100',
  'ats_recheck': 'Check again',
  'ats_use_template': 'Use ATS template',
  'ats_edit_resume': 'Go to edit',
  'ats_issues': 'Issues',
  'ats_suggestions': 'Suggestions',
  'ats_missing_keywords': 'Missing keywords',
  'ats_no_issues': 'No issues found by these checks',
  'ats_no_resume': 'Select or create a resume to start the check',
  'ats_checking': 'Analyzing resume…',
  'ats_guidance':
      'This is a rule-based guide, not a guarantee of acceptance by recruiting systems.',
  'ats_formatting_note':
      'Formatting checks use the configured template, not a parsed exported PDF.',
  'ats_template_applied': 'ATS template saved',
  'ats_section_contact': 'Contact',
  'ats_section_summary': 'Summary',
  'ats_section_experience': 'Experience',
  'ats_section_education': 'Education',
  'ats_section_skills': 'Skills',
  'ats_section_keywords': 'Keywords',
  'ats_section_formatting': 'Formatting',
  'ats_severity_critical': 'Critical',
  'ats_severity_warning': 'Warning',
  'ats_severity_info': 'Information',
  'ats_keyword_teamwork': 'teamwork',
  'ats_keyword_leadership': 'leadership',
  'ats_keyword_communication': 'communication',
  'ats_keyword_problem_solving': 'problem-solving',
  'time_just_now': 'Just now',
  'time_ago': '@count @unit ago',
  'time_in': 'In @count @unit',
  'time_minute': 'minute',
  'time_minutes': 'minutes',
  'time_hour': 'hour',
  'time_hours': 'hours',
  'time_day': 'day',
  'time_days': 'days',
  'ats_issue_name': 'The resume has no name.',
  'ats_fix_name': 'Add your full name.',
  'ats_issue_email': 'Email is missing or invalid.',
  'ats_fix_email': 'Add a valid email address.',
  'ats_issue_phone': 'Phone is missing or invalid.',
  'ats_fix_phone': 'Add a valid phone number.',
  'ats_issue_linkedin': 'A valid LinkedIn URL is missing.',
  'ats_fix_linkedin': 'Add your full LinkedIn profile URL.',
  'ats_issue_website': 'A website or portfolio URL is missing.',
  'ats_fix_website': 'Add a relevant website or portfolio URL.',
  'ats_issue_summary_missing': 'Professional summary is missing.',
  'ats_fix_summary_missing': 'Write a concise professional summary.',
  'ats_issue_summary_length': 'Summary length is outside 50–300 characters.',
  'ats_fix_summary_length': 'Keep the summary between 50 and 300 characters.',
  'ats_issue_summary_keywords': 'The summary lacks recognized job keywords.',
  'ats_fix_summary_keywords': 'Include relevant skills in the summary.',
  'ats_issue_experience_missing':
      'No complete work experience entry was found.',
  'ats_fix_experience_missing':
      'Add relevant work, internship or volunteer experience.',
  'ats_issue_experience_actions':
      'Experience descriptions lack recognized action verbs.',
  'ats_fix_experience_actions':
      'Describe achievements with verbs such as developed or led.',
  'ats_issue_experience_dates':
      'Experience dates are missing, invalid or in the future.',
  'ats_fix_experience_dates':
      'Use MM/YYYY dates and mark ongoing positions as current.',
  'ats_issue_education_missing':
      'Education is missing a degree or institution.',
  'ats_fix_education_missing': 'Add your degree and institution.',
  'ats_issue_education_year': 'A valid graduation year is missing.',
  'ats_fix_education_year':
      'Add a four-digit graduation or expected graduation year.',
  'ats_issue_skills_minimum': 'Fewer than five distinct skills were found.',
  'ats_fix_skills_minimum': 'Add at least five relevant distinct skills.',
  'ats_issue_skills_count': 'Fewer than ten distinct skills were found.',
  'ats_fix_skills_count':
      'Add more relevant skills where supported by your experience.',
  'ats_issue_skills_diversity':
      'A mix of recognized technical and interpersonal skills was not found.',
  'ats_fix_skills_diversity':
      'Include both technical and interpersonal skills you actually use.',
  'ats_issue_keywords_missing':
      'Common transferable skill keywords were not found.',
  'ats_fix_keywords_missing':
      'Mention relevant teamwork, leadership, communication or problem-solving experience.',
  'ats_issue_placeholders': 'Placeholder text requiring review was found.',
  'ats_fix_placeholders':
      'Replace placeholder text with your own verified information.',
  'ats_issue_photo': 'The configured output includes a photo.',
  'ats_fix_photo': 'Use the ATS template to omit the photo from the output.',
  'ats_issue_font': 'The selected font is not in the simple-font list.',
  'ats_fix_font': 'Choose Cairo or Poppins, or use the ATS template.',
  'ats_issue_columns':
      'A single-column layout is not confirmed for this configuration.',
  'ats_fix_columns': 'Use the single-column ATS template.',
  'ats_select_resume': 'Select or create a resume before analyzing.',
  'ats_analysis_failed':
      'The resume could not be analyzed. Check its data and try again.',
  'ats_save_failed': 'The ATS template could not be saved.',
  'ats_apply_failed': 'The ATS template could not be applied.',
  'action_failed': 'The action could not be completed. Try again.',
  'splash_tagline': 'Create your professional resume',
  'splash_preparing': 'Getting ready…',
  'language_selection_title': 'Choose your language',
  'language_selection_subtitle':
      'Select your preferred language. You can change it later in settings.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'United States',
  'country_sa': 'Saudi Arabia',
  'select_english': 'Select English',
  'select_arabic': 'Select Arabic',
  'switch_to_english': 'Use the app in English',
  'switch_to_arabic': 'Use the app in Arabic',
};
```

## lib/translations/ar_sa.dart

```dart
/// Arabic interface messages.
const Map<String, String> arSa = {
  'home': 'الرئيسية',
  'templates': 'القوالب',
  'favorites': 'المفضلة',
  'settings': 'الإعدادات',
  'save': 'حفظ',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'edit': 'تعديل',
  'next': 'التالي',
  'previous': 'السابق',
  'finish': 'إنهاء',
  'preview': 'معاينة',
  'view_all': 'عرض الكل',
  'success': 'نجاح',
  'resume_saved': 'تم حفظ السيرة الذاتية بنجاح',
  'resume_deleted': 'تم حذف السيرة الذاتية بنجاح',
  'no_resumes_found': 'لا توجد سير ذاتية',
  'no_favorites': 'لا توجد مفضلات بعد',
  'browse_templates': 'تصفح جميع القوالب',
  'create_new': 'إنشاء سيرة جديدة',
  'recent_activity': 'النشاطات الأخيرة',
  'featured_templates': 'قوالب مميزة',
  'use_template': 'استخدم القالب',
  'personal_info': 'المعلومات الشخصية',
  'education': 'التعليم',
  'experience': 'الخبرات',
  'skills': 'المهارات',
  'full_name': 'الاسم الكامل',
  'email': 'البريد الإلكتروني',
  'phone': 'رقم الهاتف',
  'address': 'العنوان',
  'summary': 'الملخص المهني',
  'degree': 'الشهادة',
  'institution': 'المؤسسة التعليمية',
  'graduation_year': 'سنة التخرج',
  'grade': 'التقدير',
  'add_education': 'إضافة تعليم',
  'edit_education': 'تعديل التعليم',
  'no_education_added': 'لم تتم إضافة تعليم',
  'degree_required': 'الشهادة مطلوبة',
  'institution_required': 'المؤسسة التعليمية مطلوبة',
  'year_required': 'سنة التخرج مطلوبة',
  'job_title': 'المسمى الوظيفي',
  'company': 'الشركة',
  'start_date': 'تاريخ البدء',
  'end_date': 'تاريخ الانتهاء',
  'current_job': 'وظيفة حالية',
  'description': 'الوصف',
  'add_experience': 'إضافة خبرة',
  'edit_experience': 'تعديل الخبرة',
  'no_experience_added': 'لم تتم إضافة خبرات',
  'job_title_required': 'المسمى الوظيفي مطلوب',
  'company_required': 'الشركة مطلوبة',
  'start_date_required': 'تاريخ البدء مطلوب',
  'skill_name': 'اسم المهارة',
  'skill_level': 'المستوى',
  'add_skill': 'إضافة مهارة',
  'no_skills_added': 'لم تتم إضافة مهارات',
  'language': 'اللغة',
  'change_app_language': 'تغيير لغة التطبيق',
  'dark_mode': 'الوضع الليلي',
  'switch_theme': 'التبديل بين الوضع الليلي والنهاري',
  'contact_us': 'اتصل بنا',
  'share_app': 'مشاركة التطبيق',
  'email_required': 'البريد الإلكتروني مطلوب',
  'invalid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
  'phone_required': 'رقم الهاتف مطلوب',
  'invalid_phone': 'الرجاء إدخال رقم هاتف صحيح',
  'is_required': 'مطلوب',
  'create_resume': 'إنشاء سيرة ذاتية',
  'edit_resume': 'تعديل السيرة الذاتية',
  'customize_resume': 'تخصيص السيرة الذاتية',
  'apply_changes': 'تطبيق التغييرات',
  'customization_saved': 'تم حفظ التخصيص بنجاح',
  'failed_to_generate_preview': 'فشل في إنشاء المعاينة',
  'failed_to_export': 'فشل في تصدير PDF',
  'choose_color': 'اختر اللون',
  'preview_updated': 'تم تحديث المعاينة بنجاح',
  'update_preview': 'تحديث المعاينة',
  'courses': 'الدورات التدريبية',
  'certificates': 'الشهادات',
  'languages': 'اللغات',
  'add_course': 'إضافة دورة',
  'add_certificate': 'إضافة شهادة',
  'add_language': 'إضافة لغة',
  'course_name': 'اسم الدورة',
  'certificate_name': 'اسم الشهادة',
  'language_name': 'اسم اللغة',
  'provider': 'مقدم الدورة',
  'organization': 'الجهة المانحة',
  'proficiency_level': 'مستوى الإتقان',
  'no_courses_added': 'لم تتم إضافة دورات',
  'no_certificates_added': 'لم تتم إضافة شهادات',
  'no_languages_added': 'لم تتم إضافة لغات',
  'course_name_required': 'اسم الدورة مطلوب',
  'provider_required': 'مقدم الدورة مطلوب',
  'certificate_name_required': 'اسم الشهادة مطلوب',
  'organization_required': 'الجهة المانحة مطلوبة',
  'language_name_required': 'اسم اللغة مطلوب',
  'additional_info': 'معلومات إضافية',
  'projects': 'المشاريع',
  'achievements': 'الإنجازات',
  'interests': 'الاهتمامات',
  'project_name': 'اسم المشروع',
  'achievement': 'الإنجاز',
  'no_projects_added': 'لم تتم إضافة مشاريع',
  'no_achievements_added': 'لم تتم إضافة إنجازات',
  'no_additional_sections': 'لا توجد أقسام إضافية',
  'your_selected_interests': 'اهتماماتك المختارة:',
  'select_interests': 'اختر اهتماماتك',
  'linkedin': 'لينكد إن',
  'github': 'جيت هاب',
  'website': 'الموقع الإلكتروني',
  'portfolio': 'ملف الأعمال',
  'profile_image_updated': 'تم تحديث صورة الملف الشخصي بنجاح',
  'clear_cache': 'مسح الكاش',
  'clear_cache_description': 'إزالة الملفات المؤقتة وتحرير المساحة',
  'clear_cache_confirmation': 'هل أنت متأكد من مسح الكاش؟',
  'cache_cleared': 'تم مسح الكاش بنجاح',
  'cache_clear_failed': 'فشل في مسح الكاش',
  'data': 'البيانات',
  'about': 'حول التطبيق',
  'app_version': 'إصدار التطبيق',
  'version_1_0_0': 'الإصدار 1.0.0',
  'exit_app': 'الخروج من التطبيق',
  'exit_confirmation': 'هل أنت متأكد من الخروج من التطبيق؟',
  'exit': 'خروج',
  'yes': 'نعم',
  'no': 'لا',
  'logged_out': 'تم تسجيل الخروج',
  'come_back_soon': 'نتمنى رؤيتك مرة أخرى قريباً!',
  'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
  'professional_resume_builder': 'منشئ السير الذاتية الاحترافي',
  'appearance': 'المظهر',
  'data_management': 'إدارة البيانات',
  'support': 'الدعم',
  'get_help_support': 'احصل على المساعدة والدعم',
  'rate_app': 'تقييم التطبيق',
  'rate_us_on_store': 'قيمنا في المتجر',
  'share_with_friends': 'شارك مع الأصدقاء',
  'cannot_open_email': 'لا يمكن فتح بريد إلكتروني',
  'select_language': 'اختر لغتك المفضلة',
  'add_project': 'إضافة مشروع',
  'edit_project': 'تعديل مشروع',
  'current_project': 'مشروع حالي',
  'technologies_used': 'التقنيات المستخدمة',
  'add_technology': 'إضافة تقنية',
  'project_name_required': 'اسم المشروع مطلوب',
  'description_required': 'الوصف مطلوب',
  'achievement_name': 'اسم الإنجاز',
  'achievement_name_required': 'اسم الإنجاز مطلوب',
  'category': 'التصنيف',
  'date_required': 'التاريخ مطلوب',
  'add_achievement': 'إضافة إنجاز',
  'edit_achievement': 'تعديل إنجاز',
  'cache_cleared_completely': 'تم مسح الكاش بالكامل',
  'clear_all_data': 'مسح جميع البيانات',
  'clear_all_data_confirmation':
      'سيؤدي هذا إلى حذف جميع سيرك الذاتية وإعداداتك. هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟',
  'clear_all': 'مسح الكل',
  'all_data_cleared': 'تم مسح جميع البيانات بنجاح',
  'clear_all_data_failed': 'فشل في مسح جميع البيانات',
  'close': 'إغلاق',
  'date': 'التاريخ',
  'year': 'السنة',
  'error': 'خطأ',
  'retry': 'إعادة المحاولة',
  'featured': 'مميز',
  'logout': 'تسجيل الخروج',
  'my_skills': 'مهاراتي',
  'resumes': 'السير الذاتية',
  'edit_certificate': 'تعديل الشهادة',
  'edit_course': 'تعديل الدورة',
  'edit_language': 'تعديل اللغة',
  'app_name': 'CV Builder Pro',
  'search_templates': 'البحث في القوالب',
  'search': 'بحث',
  'no_search_results': 'لا توجد نتائج مطابقة',
  'search_hint': 'ابحث بالاسم أو الوصف',
  'total_resumes': 'إجمالي السير',
  'favorite_resumes': 'السير المفضلة',
  'available_templates': 'القوالب المتاحة',
  'saving': 'جارٍ الحفظ…',
  'auto_saved': 'تم الحفظ تلقائياً',
  'last_saved': 'آخر حفظ: @time',
  'save_failed': 'تعذر حفظ التغييرات. أعد المحاولة.',
  'loading': 'جارٍ التحميل…',
  'please_wait': 'يرجى الانتظار',
  'storage_error': 'تعذرت عملية التخزين. تحقق من مساحة الجهاز وأعد المحاولة.',
  'startup_error':
      'تعذر فتح التخزين المحلي. أغلق التطبيق ثم أعد تشغيله. إذا استمرت المشكلة، تحقق من مساحة التخزين وصلاحيات التطبيق.',
  'field_required': '@field مطلوب',
  'invalid_url': 'أدخل رابطاً كاملاً يبدأ بـ http أو https',
  'invalid_date': 'استخدم تاريخاً صالحاً بصيغة MM/YYYY',
  'invalid_date_range': 'يجب ألا يسبق تاريخ الانتهاء تاريخ البدء',
  'choose_image': 'اختيار صورة',
  'remove_image': 'إزالة الصورة',
  'delete_resume_confirmation': 'هل تريد حذف هذه السيرة؟',
  'select_resume': 'اختر سيرة ذاتية',
  'import_resume': 'استيراد سيرة',
  'export_json': 'تصدير JSON',
  'export_pdf': 'تصدير PDF',
  'share_json': 'مشاركة JSON',
  'share_pdf': 'مشاركة PDF',
  'print_pdf': 'طباعة PDF',
  'import_json': 'استيراد JSON',
  'import_pdf': 'استيراد PDF',
  'import_txt': 'استيراد TXT',
  'recommended': 'موصى به',
  'choose_file': 'اختيار ملف',
  'paste_json': 'لصق JSON',
  'paste_json_hint': 'الصق بيانات السيرة بصيغة JSON هنا',
  'json_import_description': 'يستعيد جميع الحقول من ملف JSON متوافق للسيرة.',
  'pdf_import_description':
      'يحاول استخراج النص من ملفات PDF النصية المدعومة. الملفات الممسوحة ضوئياً تحتاج إلى OCR.',
  'txt_import_description':
      'يستخرج بيانات الاتصال والنصوص التي يمكن التعرف عليها لمراجعتها.',
  'import_preview': 'مراجعة البيانات المستوردة',
  'import_loading': 'جارٍ قراءة السيرة…',
  'import_success': 'تم استيراد السيرة بنجاح',
  'import_failed': 'تعذر استيراد الملف. تحقق من صيغته ومحتواه.',
  'import_cancelled': 'لم يتم اختيار ملف',
  'unsupported_file': 'نوع الملف غير مدعوم',
  'file_too_large': 'يتجاوز الملف حد الاستيراد البالغ 10 ميجابايت',
  'invalid_json': 'بنية JSON أو أنواع الحقول غير صالحة',
  'pdf_import_unsupported':
      'تعذر استخراج النص من ملف PDF هذا. جرّب JSON أو TXT.',
  'review_before_save': 'راجع المعلومات المستوردة وصححها قبل الحفظ.',
  'save_and_edit': 'حفظ وتعديل',
  'export_success': 'اكتمل التصدير',
  'export_failed': 'تعذر تصدير السيرة',
  'export_cancelled': 'تم إلغاء التصدير',
  'export_quality': 'جودة التصدير',
  'quality_standard': 'قياسية',
  'quality_high': 'عالية',
  'customization': 'التخصيص',
  'font_family': 'الخط',
  'font_size': 'حجم الخط',
  'primary_color': 'اللون الرئيسي',
  'secondary_color': 'اللون الثانوي',
  'ats_checker': 'فحص ATS',
  'ats_score': 'نتيجة ATS',
  'ats_score_out_of': '@score من 100',
  'ats_recheck': 'إعادة الفحص',
  'ats_use_template': 'استخدام قالب ATS',
  'ats_edit_resume': 'انتقل للتعديل',
  'ats_issues': 'الملاحظات',
  'ats_suggestions': 'الاقتراحات',
  'ats_missing_keywords': 'الكلمات المفتاحية المفقودة',
  'ats_no_issues': 'لم تُكتشف ملاحظات وفق هذه القواعد',
  'ats_no_resume': 'اختر سيرة أو أنشئ سيرة لبدء الفحص',
  'ats_checking': 'جارٍ تحليل السيرة…',
  'ats_guidance':
      'هذا تقييم إرشادي قائم على قواعد، ولا يضمن القبول لدى أنظمة التوظيف.',
  'ats_formatting_note':
      'يعتمد فحص التنسيق على إعداد القالب، وليس على تحليل ملف PDF مصدّر.',
  'ats_template_applied': 'تم حفظ قالب ATS',
  'ats_section_contact': 'بيانات الاتصال',
  'ats_section_summary': 'الملخص المهني',
  'ats_section_experience': 'الخبرة',
  'ats_section_education': 'التعليم',
  'ats_section_skills': 'المهارات',
  'ats_section_keywords': 'الكلمات المفتاحية',
  'ats_section_formatting': 'التنسيق',
  'ats_severity_critical': 'حرجة',
  'ats_severity_warning': 'تنبيه',
  'ats_severity_info': 'معلومة',
  'ats_keyword_teamwork': 'العمل الجماعي',
  'ats_keyword_leadership': 'القيادة',
  'ats_keyword_communication': 'التواصل',
  'ats_keyword_problem_solving': 'حل المشكلات',
  'time_just_now': 'الآن',
  'time_ago': 'منذ @count @unit',
  'time_in': 'خلال @count @unit',
  'time_minute': 'دقيقة',
  'time_minutes': 'دقيقة',
  'time_hour': 'ساعة',
  'time_hours': 'ساعة',
  'time_day': 'يوم',
  'time_days': 'يوم',
  'ats_issue_name': 'السيرة لا تحتوي على اسم.',
  'ats_fix_name': 'أضف اسمك الكامل.',
  'ats_issue_email': 'البريد الإلكتروني مفقود أو غير صالح.',
  'ats_fix_email': 'أضف بريداً إلكترونياً صالحاً.',
  'ats_issue_phone': 'رقم الهاتف مفقود أو غير صالح.',
  'ats_fix_phone': 'أضف رقم هاتف صالحاً.',
  'ats_issue_linkedin': 'رابط LinkedIn صالح مفقود.',
  'ats_fix_linkedin': 'أضف رابط ملفك الكامل في LinkedIn.',
  'ats_issue_website': 'رابط الموقع أو معرض الأعمال مفقود.',
  'ats_fix_website': 'أضف رابط موقع أو معرض أعمال مناسب.',
  'ats_issue_summary_missing': 'الملخص المهني مفقود.',
  'ats_fix_summary_missing': 'اكتب ملخصاً مهنياً موجزاً.',
  'ats_issue_summary_length': 'طول الملخص خارج نطاق 50–300 حرف.',
  'ats_fix_summary_length': 'اجعل الملخص بين 50 و300 حرف.',
  'ats_issue_summary_keywords': 'الملخص يفتقر إلى كلمات وظيفية معروفة.',
  'ats_fix_summary_keywords': 'اذكر المهارات المرتبطة بالوظيفة في الملخص.',
  'ats_issue_experience_missing': 'لا توجد خبرة بمسمى وظيفي وشركة.',
  'ats_fix_experience_missing': 'أضف خبرة عمل أو تدريب أو تطوع مناسبة.',
  'ats_issue_experience_actions': 'أوصاف الخبرة تفتقر إلى أفعال إنجاز معروفة.',
  'ats_fix_experience_actions': 'صف إنجازاتك بأفعال مثل طورت أو قدت.',
  'ats_issue_experience_dates':
      'تواريخ الخبرة مفقودة أو غير مرتبة أو مستقبلية.',
  'ats_fix_experience_dates': 'استخدم MM/YYYY وحدد الوظائف المستمرة كعمل حالي.',
  'ats_issue_education_missing': 'التعليم يفتقر إلى المؤهل أو المؤسسة.',
  'ats_fix_education_missing': 'أضف المؤهل والمؤسسة التعليمية.',
  'ats_issue_education_year': 'سنة تخرج صالحة مفقودة.',
  'ats_fix_education_year': 'أضف سنة التخرج أو التخرج المتوقع بأربعة أرقام.',
  'ats_issue_skills_minimum': 'عدد المهارات المختلفة أقل من خمس.',
  'ats_fix_skills_minimum': 'أضف خمس مهارات مختلفة مرتبطة بالوظيفة على الأقل.',
  'ats_issue_skills_count': 'عدد المهارات المختلفة أقل من عشر.',
  'ats_fix_skills_count': 'أضف مهارات مناسبة إضافية تدعمها خبرتك.',
  'ats_issue_skills_diversity':
      'لم يظهر مزيج من المهارات التقنية والشخصية المعروفة.',
  'ats_fix_skills_diversity': 'اذكر مهارات تقنية وشخصية تستخدمها فعلياً.',
  'ats_issue_keywords_missing': 'لم تظهر كلمات المهارات العامة المعروفة.',
  'ats_fix_keywords_missing':
      'اذكر خبرة مناسبة في العمل الجماعي أو القيادة أو التواصل أو حل المشكلات.',
  'ats_issue_placeholders': 'ظهر نص تجريبي يحتاج إلى مراجعة.',
  'ats_fix_placeholders': 'استبدل النصوص التجريبية بمعلوماتك الصحيحة.',
  'ats_issue_photo': 'الإخراج المحدد يتضمن صورة.',
  'ats_fix_photo': 'استخدم قالب ATS لاستبعاد الصورة من الإخراج.',
  'ats_issue_font': 'الخط المحدد خارج قائمة الخطوط البسيطة.',
  'ats_fix_font': 'اختر Cairo أو Poppins أو استخدم قالب ATS.',
  'ats_issue_columns': 'لم يُعتمد تخطيط بعمود واحد لهذا الإعداد.',
  'ats_fix_columns': 'استخدم قالب ATS ذي العمود الواحد.',
  'ats_select_resume': 'اختر سيرة أو أنشئ سيرة قبل الفحص.',
  'ats_analysis_failed': 'تعذر تحليل السيرة. راجع بياناتها وأعد المحاولة.',
  'ats_save_failed': 'تعذر حفظ قالب ATS.',
  'ats_apply_failed': 'تعذر تطبيق قالب ATS.',
  'action_failed': 'تعذر إكمال العملية. أعد المحاولة.',
  'splash_tagline': 'أنشئ سيرتك الذاتية الاحترافية',
  'splash_preparing': 'جارٍ التجهيز…',
  'language_selection_title': 'اختر لغتك',
  'language_selection_subtitle':
      'اختر اللغة التي تفضلها. يمكنك تغييرها لاحقاً من الإعدادات.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'الولايات المتحدة',
  'country_sa': 'السعودية',
  'select_english': 'اختيار الإنجليزية',
  'select_arabic': 'اختيار العربية',
  'switch_to_english': 'استخدم التطبيق باللغة الإنجليزية',
  'switch_to_arabic': 'استخدم التطبيق باللغة العربية',
};
```

## test/onboarding/onboarding_test.dart

```dart
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/language_controller.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';
import 'package:cv_builder_pro/data/repositories/resume_repository.dart';
import 'package:cv_builder_pro/features/splash/index.dart';
import 'package:cv_builder_pro/features/language/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final values = <String, dynamic>{};
  Completer<void>? gate;
  bool fail = false;
  int writes = 0;
  @override
  T? read<T>(String key) => values[key] as T?;
  @override
  Future<void> write(String key, Object? value) async {
    if (fail) throw const StorageException('write', 'simulated error');
    if (gate != null) await gate!.future;
    writes++;
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget displayHost(
  Widget child, {
  bool dark = false,
  double scale = 1,
  bool reducedMotion = false,
}) => MaterialApp(
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reducedMotion,
    ),
    child: child!,
  ),
  home: child,
);

Widget navigationHost(Widget child) => GetMaterialApp(
  translations: AppTranslations(),
  locale: const Locale('en', 'US'),
  theme: AppTheme.light,
  home: child,
  getPages: [
    GetPage(
      name: AppRoutes.home,
      page: () => const Scaffold(body: Text('home-marker')),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
      transition: Transition.noTransition,
    ),
  ],
);

void setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  late _Repository repository;
  late LanguageController language;
  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en', 'US');
    repository = _Repository();
    language = Get.put(LanguageController(repository: repository));
  });
  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'Splash fits mobile, landscape, tablet and desktop with large text',
    (tester) async {
      setSize(tester, const Size(320, 480));
      for (final size in [
        const Size(320, 480),
        const Size(480, 320),
        const Size(768, 1024),
        const Size(1920, 1080),
      ]) {
        tester.view.physicalSize = size;
        for (final dark in [false, true]) {
          await tester.pumpWidget(
            displayHost(const SplashScreen(), dark: dark, scale: 2),
          );
          await tester.pump(const Duration(seconds: 1));
          expect(find.byType(SafeArea), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    },
  );

  testWidgets(
    'Splash cancels navigation when disposed and respects reduced motion',
    (tester) async {
      await tester.pumpWidget(
        displayHost(const SplashScreen(), reducedMotion: true),
      );
      expect(find.byType(AnimatedTextKit), findsNothing);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        1,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('First launch routes from splash to language selection', (
    tester,
  ) async {
    await tester.pumpWidget(navigationHost(const SplashScreen()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    expect(Get.currentRoute, AppRoutes.languageSelection);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('A selected language routes from splash directly home', (
    tester,
  ) async {
    language.isLanguageSelected.value = true;
    await tester.pumpWidget(navigationHost(const SplashScreen()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('home-marker'), findsOneWidget);
    expect(Get.currentRoute, AppRoutes.home);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Language cards stack on mobile and form a row on larger screens',
    (tester) async {
      setSize(tester, const Size(320, 640));
      for (final size in [
        const Size(320, 640),
        const Size(600, 800),
        const Size(1200, 800),
        const Size(1920, 1080),
      ]) {
        tester.view.physicalSize = size;
        Get.locale = const Locale('ar', 'SA');
        await tester.pumpWidget(
          displayHost(
            const LanguageSelectionScreen(),
            dark: true,
            scale: 2,
            reducedMotion: true,
          ),
        );
        final row = size.width >= 600;
        expect(
          find.byKey(ValueKey(row ? 'language-row' : 'language-column')),
          findsOneWidget,
        );
        expect(
          Directionality.of(
            tester.element(
              find.byKey(ValueKey(row ? 'language-row' : 'language-column')),
            ),
          ),
          TextDirection.rtl,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('Arabic selection persists both settings and navigates home', (
    tester,
  ) async {
    setSize(tester, const Size(1000, 1000));
    await tester.pumpWidget(navigationHost(const LanguageSelectionScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('select-ar')));
    await tester.tap(find.byKey(const ValueKey('select-ar')));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(repository.values[StorageKeys.appLocale], 'ar');
    expect(repository.values[StorageKeys.languageSelected], true);
    expect(language.currentLanguage.value, 'ar');
    expect(language.isSelecting.value, false);
    expect(Get.locale?.languageCode, 'ar');
    expect(find.text('home-marker'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Pending language selection disables both cards and prevents duplicate writes',
    (tester) async {
      setSize(tester, const Size(1000, 1000));
      repository.gate = Completer<void>();
      await tester.pumpWidget(navigationHost(const LanguageSelectionScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('select-en')));
      await tester.pump();
      expect(language.isSelecting.value, true);
      final arabicButton = find.descendant(
        of: find.byKey(const ValueKey('select-ar')),
        matching: find.byType(ElevatedButton),
      );
      expect(tester.widget<ElevatedButton>(arabicButton).onPressed, isNull);
      await language.selectLanguage('ar');
      expect(repository.writes, 0);
      repository.gate!.complete();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(repository.writes, 2);
      expect(repository.values[StorageKeys.appLocale], 'en');
      expect(find.text('home-marker'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Failed selection stays on the language screen and permits retry',
    (tester) async {
      setSize(tester, const Size(1000, 1000));
      repository.fail = true;
      await tester.pumpWidget(navigationHost(const LanguageSelectionScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('select-en')));
      await tester.pump();
      await tester.pump();
      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
      expect(language.isLanguageSelected.value, false);
      expect(language.isSelecting.value, false);
      repository.fail = false;
      await tester.tap(find.byKey(const ValueKey('select-en')));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('home-marker'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
```
