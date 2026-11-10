# UI/UX — Batch 6: Settings
اكتملت إعادة تصميم الإعدادات ضمن طبقة العرض فقط. بقيت خدمات المنصة والمستودع والمتحكمات والترجمات والمسارات والاعتماديات دون تعديل.
رأس الملف الشخصي: تدرج Indigo/Violet مع درجات مناسبة للوضع الداكن، صورة AppAvatar دائرية مع بديل عند غياب الصورة أو تعذر قراءتها، وأيقونة كاميرا وزر تغيير الصورة. يتشارك الزر والكاميرا حارس انتظار واحداً يمنع فتح اختيار الصورة مرتين. عند الإلغاء أو الفشل يستمر السلوك القائم دون تغيير التفضيل المحفوظ.
الأقسام: المظهر والدعم وحول التطبيق والبيانات. تظهر في عمود على الجوال وعمودين على التابلت وسطح المكتب، ضمن حد العرض العام. بطاقات AppCard بأيقونات في حاويات ملونة، ونصوص مرنة وأزرار واضحة؛ ينتقل مفتاح الثيم إلى سطر مستقل عندما لا تكفي المساحة. حسّن لون مقبض المفتاح وضوح حالتي التشغيل والإيقاف. تتميز بطاقة حذف جميع البيانات وإجراء تأكيدها باللون الأحمر؛ يبقى زر الخروج منفصلاً وموضحاً بنافذة التأكيد القائمة.
نافذة اللغة: عنوان وأيقونة ترجمة، اللغة الحالية بزر متدرج وعلامة تحقق، واللغة الأخرى وزر الإلغاء بإطار. بقيت آلية الإرجاع والحفظ الحالية كما هي. تشمل الواجهة SafeArea وتمريراً ودعم RTL/LTR والوضعين وتكبير النص، وتستخدم رموز نظام التصميم.
لا تغير في إجراءات حفظ اللغة والثيم، اختيار الصورة وحفظ مسارها، التواصل والتقييم والمشاركة وأصل نافذة المشاركة، تأكيد الحذف وإعادة تهيئة التطبيق، والخروج مع الاحتفاظ بالسير المحفوظة. لم تُضف حالة تحميل وهمية؛ تعرض الإجراءات غير المتزامنة الانتظار عبر AppButton، وتبقى رسائل فشل المنصة والتخزين فعالة.
التحقق: flutter analyze دون ملاحظات، ونجحت اختبارات المشروع الـ443. أضيفت 21 حالة اختبار: 20 حالة للإعدادات وفتح وإلغاء نافذة اللغة عند عروض 320/390/600/1024/1920 مع العربية والإنجليزية والوضعين وتكبير النص 200%، وحالة منع تكرار اختيار الصورة بين الكاميرا والزر. يتضمن عرض 1024 ارتفاعاً أفقياً 480. بقيت اختبارات الإعدادات السابقة الـ11 دون تعديل. بعد تحسين تباين مقبض المفتاح أُعيد التحليل واختبارات الإعدادات الـ32 وتحديث صور المعاينة. لم يُكرر التشغيل على جهاز فعلي؛ استُخدمت بدائل اختبار لخدمات المنصة.
## المعاينات
[Settings — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_06_settings_light_en_390.png)
[Settings — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_06_settings_light_en_1920.png)
[Settings — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_06_settings_dark_ar_390.png)
[Settings — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_06_settings_dark_ar_1920.png)
## الملفات كاملة
1. lib/features/settings/presentation/pages/settings_screen.dart
2. lib/features/settings/presentation/widgets/settings_card.dart
3. lib/features/settings/presentation/widgets/profile_header.dart
4. lib/features/settings/presentation/widgets/language_dialog.dart
5. test/settings/redesign_settings_test.dart

## lib/features/settings/presentation/pages/settings_screen.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/index.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/repositories/resume_repository.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/language_dialog.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_card.dart';

/// Settings with persisted preferences and guarded platform operations.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.service});
  final SettingsService? service;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _service = widget.service ?? SettingsService();
  final _repository = Get.find<ResumeRepository>();
  String? _imagePath;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    try {
      _imagePath = _repository.read<String>(StorageKeys.profileImage);
    } catch (_) {
      AppSnackbar.storageError();
    }
  }

  Future<void> _pickImage() async {
    try {
      final path = await _service.pickProfileImage();
      if (path == null || !mounted) return;
      await _repository.write(StorageKeys.profileImage, path);
      if (!mounted) return;
      setState(() => _imagePath = path);
      AppSnackbar.success(context, 'profile_image_updated'.tr);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'profile_image_failed'.tr);
    }
  }

  Future<void> _language() async {
    final controller = Get.find<LanguageController>();
    final code = await showDialog<String>(
      context: context,
      builder: (_) =>
          LanguageDialog(selectedLanguage: controller.currentLanguage.value),
    );
    if (code != null && mounted) await controller.changeLanguage(code);
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.value<double>(
                context: context,
                mobile: 500,
                tablet: 600,
                desktop: 650,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Text(message),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'cancel'.tr,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      AppButton(
                        key: const ValueKey('confirm-settings-action'),
                        label: action,
                        variant: AppButtonVariant.danger,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ) ??
      false;

  Future<void> _clear() async {
    if (_busy) return;
    _busy = true;
    try {
      if (!await _confirm(
            'clear_all_data'.tr,
            'clear_all_data_confirmation'.tr,
            'clear_all'.tr,
          ) ||
          !mounted) {
        return;
      }
      await Get.find<ResumeController>().clearAllData();
      final language = Get.find<LanguageController>();
      language.isLanguageSelected.value = false;
      language.currentLanguage.value = 'en';
      Get.find<ThemeController>().isDarkMode.value = false;
      Get.changeThemeMode(ThemeMode.light);
      Get.locale = const Locale('en', 'US');
      Get.appUpdate();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      if (!mounted) return;
      Get.offAllNamed<void>(AppRoutes.splash);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'clear_all_data_failed'.tr);
    } finally {
      _busy = false;
    }
  }

  Future<void> _exit() async {
    if (_busy) return;
    _busy = true;
    try {
      if (!await _confirm(
            'exit_app'.tr,
            'settings_exit_confirmation'.tr,
            'exit'.tr,
          ) ||
          !mounted) {
        return;
      }
      Get.find<ResumeController>().stopAutoSave();
      await _repository.remove(StorageKeys.currentCv);
      await _repository.remove(StorageKeys.profileImage);
      if (mounted) setState(() => _imagePath = null);
      await _service.exitApp();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
    } finally {
      _busy = false;
    }
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeader(title: title),
      const SizedBox(height: AppSpacing.lg),
      ...children,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.textScalerOf(context).scale(AppSpacing.lg) / AppSpacing.lg;
    final theme = Get.find<ThemeController>();
    final language = Get.find<LanguageController>();
    final sections = [
      _section('appearance'.tr, [
        Obx(
          () => SettingsCard(
            icon: Icons.dark_mode_outlined,
            title: 'dark_mode'.tr,
            subtitle: 'switch_theme'.tr,
            trailing: Switch(
              key: const ValueKey('settings-theme-switch'),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                final scheme = Theme.of(context).colorScheme;
                return states.contains(WidgetState.selected)
                    ? scheme.onPrimary
                    : scheme.onSurfaceVariant;
              }),
              value: theme.isDarkMode.value,
              onChanged: _busy
                  ? null
                  : (_) async {
                      await theme.toggleTheme();
                    },
            ),
          ),
        ),
        Obx(
          () => SettingsCard(
            icon: Icons.language,
            title: 'language'.tr,
            subtitle: 'change_app_language'.tr,
            actionLabel:
                (language.currentLanguage.value == 'ar'
                        ? 'language_arabic'
                        : 'language_english')
                    .tr,
            onAction: _language,
          ),
        ),
      ]),
      _section('support'.tr, [
        SettingsCard(
          icon: Icons.contact_support_outlined,
          title: 'contact_us'.tr,
          subtitle: 'get_help_support'.tr,
          onAction: _service.contactSupport,
        ),
        SettingsCard(
          icon: Icons.star_outline,
          title: 'rate_app'.tr,
          subtitle: 'rate_us_on_store'.tr,
          onAction: _service.rateApp,
        ),
        Builder(
          builder: (context) => SettingsCard(
            icon: Icons.share_outlined,
            title: 'share_app'.tr,
            subtitle: 'share_with_friends'.tr,
            onAction: () async {
              final box = context.findRenderObject() as RenderBox;
              await _service.shareApp(
                box.localToGlobal(Offset.zero) & box.size,
                'share_app_message'.tr,
              );
            },
          ),
        ),
      ]),
      _section('about'.tr, [
        SettingsCard(
          icon: Icons.info_outline,
          title: 'app_version'.tr,
          subtitle: 'version_1_0_0'.tr,
        ),
      ]),
      _section('data'.tr, [
        SettingsCard(
          key: const ValueKey('settings-clear'),
          icon: Icons.delete_forever_outlined,
          title: 'data_management'.tr,
          subtitle: 'settings_data_description'.tr,
          actionLabel: 'clear_all_data'.tr,
          isDestructive: true,
          onAction: _clear,
        ),
        AppButton(
          key: const ValueKey('settings-exit'),
          label: 'exit_app'.tr,
          icon: Icons.exit_to_app,
          fullWidth: true,
          variant: AppButtonVariant.secondary,
          onPressed: _exit,
        ),
      ]),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        toolbarHeight:
            AppSpacing.touchTarget +
            AppSpacing.sm +
            math.max(0, scale - 1) * AppSpacing.xxl,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('settings-scroll'),
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(imagePath: _imagePath, onPick: _pickImage),
                const SizedBox(height: AppSpacing.xxl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = Responsive.isTabletOrLarger(context)
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - AppSpacing.xl * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: AppSpacing.xl,
                      runSpacing: AppSpacing.xl,
                      children: sections
                          .map(
                            (section) => SizedBox(width: width, child: section),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/features/settings/presentation/widgets/settings_card.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Adaptive settings tile with a tinted icon, async action and danger treatment.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.isDestructive = false,
  });
  final IconData icon;
  final String title, subtitle;
  final String? actionLabel;
  final FutureOr<void> Function()? onAction;
  final Widget? trailing;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = isDestructive ? scheme.error : scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final inline =
                constraints.maxWidth >= AppSpacing.xxxl * 9 &&
                MediaQuery.textScalerOf(context).scale(AppSpacing.lg) <=
                    AppSpacing.xl;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDestructive
                              ? scheme.errorContainer
                              : scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Icon(
                          icon,
                          color: foreground,
                          size: AppSpacing.xl,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                                AppTextStyles.resolve(
                                  context,
                                  AppTextStyles.h4,
                                ).copyWith(
                                  color: isDestructive
                                      ? scheme.error
                                      : scheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle,
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.bodySmall,
                            ).copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (inline && trailing != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      trailing!,
                    ],
                  ],
                ),
                if (!inline && trailing != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: trailing!,
                  ),
                ],
                if (onAction != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: actionLabel ?? title,
                    onPressed: onAction,
                    fullWidth: true,
                    variant: isDestructive
                        ? AppButtonVariant.danger
                        : AppButtonVariant.secondary,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

```

## lib/features/settings/presentation/widgets/profile_header.dart
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared_widgets/index.dart';

/// Gradient profile header with a guarded photo picker and camera badge.
class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key, this.imagePath, required this.onPick});
  final String? imagePath;
  final Future<void> Function() onPick;
  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _picking = false;
  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      await widget.onPick();
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'profile_image_failed'.tr);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: Theme.of(context).brightness == Brightness.dark
          ? const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                AppColors.darkTint,
                AppColors.primaryDark,
                AppColors.violet,
              ],
            )
          : AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(AppRadii.xxl),
      boxShadow: AppShadows.colored(AppColors.primary),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avatar = AppAvatar(
            size: AppSpacing.avatar + AppSpacing.xl,
            image: widget.imagePath?.isNotEmpty == true
                ? FileImage(File(widget.imagePath!))
                : null,
            onCameraPressed: _picking ? null : _pick,
            semanticsLabel: 'change_profile_image'.tr,
          );
          final content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: AppTextStyles.resolve(
                  context,
                  AppTextStyles.h2,
                ).copyWith(color: AppColors.lightSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'professional_resume_builder'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.resolve(
                  context,
                  AppTextStyles.bodySmall,
                ).copyWith(color: AppColors.lightSurface),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                key: const ValueKey('pick-profile-image'),
                label: 'change_profile_image'.tr,
                icon: Icons.camera_alt_outlined,
                isLoading: _picking,
                onPressed: _pick,
                gradient: AppColors.successGradient,
              ),
            ],
          );
          if (constraints.maxWidth >= AppSpacing.xxxl * 12 &&
              MediaQuery.textScalerOf(context).scale(AppSpacing.lg) <=
                  AppSpacing.xl) {
            return Row(
              children: [
                avatar,
                const SizedBox(width: AppSpacing.xxl),
                Expanded(child: content),
              ],
            );
          }
          return Column(
            children: [
              avatar,
              const SizedBox(height: AppSpacing.lg),
              content,
            ],
          );
        },
      ),
    ),
  );
}

```

## lib/features/settings/presentation/widgets/language_dialog.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Returns a selected language so the caller can persist it after closing.
class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key, required this.selectedLanguage});
  final String selectedLanguage;
  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Responsive.value<double>(
          context: context,
          mobile: 500,
          tablet: 600,
          desktop: 650,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.translate,
              color: Theme.of(context).colorScheme.primary,
              size: AppSpacing.xxl,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSectionHeader(title: 'select_language'.tr),
            const SizedBox(height: AppSpacing.xl),
            for (final code in ['en', 'ar'])
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppButton(
                  key: ValueKey('settings-language-$code'),
                  label: (code == 'ar' ? 'language_arabic' : 'language_english')
                      .tr,
                  icon: selectedLanguage == code
                      ? Icons.check_circle
                      : Icons.language,
                  fullWidth: true,
                  variant: selectedLanguage == code
                      ? AppButtonVariant.primary
                      : AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(code),
                ),
              ),
            AppButton(
              label: 'cancel'.tr,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}

```

## test/settings/redesign_settings_test.dart
```dart
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

```

