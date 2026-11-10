# UI/UX — Batch 4: Home Dashboard
اكتملت إعادة تصميم الرئيسية: رأس بتدرج وصورة رمزية تفتح الإعدادات، إحصاءات عائمة، اختصارات إنشاء واستيراد وفحص ATS، بطاقات قوالب متدرجة، بطاقات السير الأخيرة، وزر إنشاء عائم. أصبح التنقل NavigationBar على الجوال وNavigationRail على التابلت وسطح المكتب.
حُفظت إجراءات الإنشاء والتعديل والحذف والتأكيد والمفضلة وعرض الكل والتحديث والتنقل. لم تتغير المتحكمات أو الخدمات أو المستودعات أو النماذج أو المسارات، ولم تضف اعتماديات. أضيف خيارا gradient وiconOnTop إلى AppButton، وعُمقت نهايتا التدرجين الأخضر والكهرماني لتحسين تباين النص الأبيض مع إبقاء ألوان الهوية الأساسية.
تدعم الواجهة الوضعين واللغتين وتكبير النص وتقليل الحركة. تظهر الاختصارات في صف أو عمود حسب المساحة وحجم النص، وتتحول السير الأخيرة إلى شبكة على الشاشات الأوسع. توجد أسماء دلالية وأدوات تلميح للأزرار المهمة.
التحقق: flutter analyze دون ملاحظات، وجميع اختبارات المشروع الـ376 ناجحة. تشمل 24 اختباراً جديداً: تباين تدرجات الاختصارات، تنقل الشريط الجانبي، زر الإنشاء والصورة الرمزية، و20 حالة للتجاوب عند عروض 320/390/600/1024/1920 مع العربية والإنجليزية والوضعين وتكبير النص 200%. يتضمن عرض 1024 ارتفاعاً أفقياً 480. نجحت اختبارات الرئيسية السابقة الـ11؛ عُدل عرض اختبار التنقل السفلي إلى 390 لأن عرض 800 يستخدم الآن الشريط الجانبي.
رُوجعت صور فعلية من اختبارات Flutter بخطوط التطبيق. لم يُكرر التشغيل على جهاز فعلي في هذه الدفعة؛ نجاح الاختبارات لا يمثل تحققاً من جميع عمليات المنصة على جهاز.
## المعاينات
[الجوال — فاتح / إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_04_home_light_en.png)
[الجوال — داكن / عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_04_home_dark_ar.png)
[سطح المكتب](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_04_desktop_light_en.png)
## الملفات كاملة
1. lib/app/theme/app_colors.dart
2. lib/shared_widgets/app_button.dart
3. lib/features/home/index.dart
4. lib/features/home/presentation/pages/home_screen.dart
5. lib/features/home/presentation/widgets/home_header.dart
6. lib/features/home/presentation/widgets/stats_cards.dart
7. lib/features/home/presentation/widgets/home_quick_actions.dart
8. lib/features/home/presentation/widgets/template_carousel.dart
9. lib/features/home/presentation/widgets/recent_activity_card.dart
10. lib/features/home/presentation/widgets/marquee_header.dart
11. test/home/home_test.dart
12. test/home/redesign_dashboard_test.dart

## lib/app/theme/app_colors.dart
```dart
import 'package:flutter/material.dart';

/// Brand, surface and semantic colors shared by both appearance modes.
abstract final class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFF14B8A6);
  static const secondaryLight = Color(0xFF5EEAD4);
  static const secondaryDark = Color(0xFF0F766E);
  static const accentDark = Color(0xFFB45309);
  static const accent = Color(0xFFF59E0B);
  static const violet = Color(0xFF7C3AED);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  static const successForeground = Color(0xFF047857);
  static const warningForeground = Color(0xFF92400E);
  static const errorForeground = Color(0xFFB91C1C);
  static const infoForeground = Color(0xFF1D4ED8);
  static const errorLight = Color(0xFFFCA5A5);
  static const lightBackground = Color(0xFFF8FAFC);
  static const darkBackground = Color(0xFF0F172A);
  static const lightSurface = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF1E293B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const darkBorder = Color(0xFF475569);
  static const lightText = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const darkText = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const lightTint = Color(0xFFEEF2FF);
  static const darkTint = Color(0xFF312E81);
  static const darkErrorContainer = Color(0xFF7F1D1D);
  static const lightErrorContainer = Color(0xFFFEE2E2);
  static const shadow = Color(0x0F0F172A);
  static const shadowMedium = Color(0x1A0F172A);
  static const shadowLarge = Color(0x240F172A);
  static const darkShadow = Color(0x33000000);
  static const transparent = Color(0x00000000);
  static const primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [primary, violet],
  );
  static const successGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [successForeground, secondaryDark],
  );
  static const warmGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [warningForeground, accentDark],
  );
  static const coolGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [primary, secondary],
  );
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? darkBackground : lightBackground;
  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : lightSurface;
  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? darkBorder : lightBorder;
  static Color text(Brightness brightness) =>
      brightness == Brightness.dark ? darkText : lightText;
  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
}

```

## lib/shared_widgets/app_button.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';
import 'app_snack_bar.dart';

/// Button styles, retaining the original filled/outlined/text names as aliases.
enum AppButtonVariant {
  filled,
  outlined,
  text,
  primary,
  secondary,
  danger,
  ghost,
}

/// Button padding and minimum heights; every size retains a 48px touch target.
enum AppButtonSize { sm, md, lg }

/// Accessible gradient action with asynchronous guards and reduced-motion support.
class AppButton extends StatefulWidget {
  final String label;
  final FutureOr<void> Function()? onPressed;
  final void Function(Object, StackTrace)? onError;
  final IconData? icon;
  final bool isLoading, fullWidth;
  final String? semanticsLabel;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Gradient? gradient;
  final bool iconOnTop;
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onError,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.semanticsLabel,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.md,
    this.gradient,
    this.iconOnTop = false,
  });
  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _busy = false, _pressed = false;
  Future<void> _press() async {
    if (_busy || widget.isLoading || widget.onPressed == null) return;
    setState(() {
      _busy = true;
      _pressed = false;
    });
    try {
      await widget.onPressed!();
    } catch (error, stackTrace) {
      if (widget.onError != null) {
        widget.onError!(error, stackTrace);
      } else if (mounted) {
        AppSnackBar.error(context, 'action_failed'.tr);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = _busy || widget.isLoading;
    final disabled = loading || widget.onPressed == null;
    final primary =
        widget.variant == AppButtonVariant.filled ||
        widget.variant == AppButtonVariant.primary;
    final danger = widget.variant == AppButtonVariant.danger;
    final outline =
        widget.variant == AppButtonVariant.outlined ||
        widget.variant == AppButtonVariant.secondary;
    final foreground = disabled
        ? scheme.onSurfaceVariant
        : primary || danger
        ? AppColors.lightSurface
        : scheme.primary;
    final horizontal = switch (widget.size) {
      AppButtonSize.sm => AppSpacing.md,
      AppButtonSize.md => AppSpacing.lg,
      AppButtonSize.lg => AppSpacing.xl,
    };
    final vertical = widget.size == AppButtonSize.sm
        ? AppSpacing.sm
        : AppSpacing.md;
    final leading = loading
        ? SizedBox.square(
            dimension: AppSpacing.icon,
            child: MediaQuery.disableAnimationsOf(context)
                ? Icon(
                    Icons.hourglass_empty,
                    size: AppSpacing.icon,
                    color: foreground,
                  )
                : CircularProgressIndicator(
                    strokeWidth: AppSpacing.focusStroke,
                    color: foreground,
                  ),
          )
        : widget.icon == null
        ? null
        : Icon(widget.icon, size: AppSpacing.icon);
    final content = widget.iconOnTop
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.resolve(
                  context,
                  AppTextStyles.button,
                ).copyWith(color: foreground),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) ...[
                SizedBox.square(
                  dimension: AppSpacing.icon,
                  child: MediaQuery.disableAnimationsOf(context)
                      ? Icon(
                          Icons.hourglass_empty,
                          size: AppSpacing.icon,
                          color: foreground,
                        )
                      : CircularProgressIndicator(
                          strokeWidth: AppSpacing.focusStroke,
                          color: foreground,
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, size: AppSpacing.icon),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.button,
                  ).copyWith(color: foreground),
                ),
              ),
            ],
          );
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(
          AppSpacing.touchTarget,
          AppSpacing.touchTarget +
              (widget.size == AppButtonSize.lg
                  ? AppSpacing.sm
                  : AppSpacing.none),
        ),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadii.field),
      ),
      foregroundColor: WidgetStatePropertyAll(foreground),
    );
    final Widget button;
    if (primary || danger) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadii.field,
          gradient: primary && !disabled
              ? widget.gradient ?? AppColors.primaryGradient
              : null,
          color: disabled
              ? scheme.surfaceContainerHighest
              : danger
              ? AppColors.errorForeground
              : null,
        ),
        child: ElevatedButton(
          onPressed: disabled ? null : _press,
          style: style.copyWith(
            backgroundColor: const WidgetStatePropertyAll(
              AppColors.transparent,
            ),
            shadowColor: const WidgetStatePropertyAll(AppColors.transparent),
            surfaceTintColor: const WidgetStatePropertyAll(
              AppColors.transparent,
            ),
            elevation: const WidgetStatePropertyAll(AppSpacing.none),
          ),
          child: content,
        ),
      );
    } else if (outline) {
      button = OutlinedButton(
        onPressed: disabled ? null : _press,
        style: style,
        child: content,
      );
    } else {
      button = TextButton(
        onPressed: disabled ? null : _press,
        style: style,
        child: content,
      );
    }
    final label = widget.semanticsLabel ?? widget.label;
    return Semantics(
      button: true,
      enabled: !disabled,
      liveRegion: loading,
      label: loading ? '$label, ${'loading'.tr}' : label,
      onTap: disabled ? null : _press,
      excludeSemantics: true,
      child: Listener(
        onPointerDown: disabled ? null : (_) => setState(() => _pressed = true),
        onPointerUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        onPointerCancel: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: AnimatedScale(
          scale: _pressed && !disabled ? 0.98 : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppTheme.motionDuration,
          child: SizedBox(
            width: widget.fullWidth ? double.infinity : null,
            child: button,
          ),
        ),
      ),
    );
  }
}

```

## lib/features/home/index.dart
```dart
export 'presentation/pages/home_screen.dart';
export 'presentation/widgets/home_header.dart';
export 'presentation/widgets/stats_cards.dart';
export 'presentation/widgets/marquee_header.dart';
export 'presentation/widgets/template_carousel.dart';
export 'presentation/widgets/recent_activity_card.dart';
export 'presentation/widgets/home_quick_actions.dart';

```

## lib/features/home/presentation/pages/home_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/home_header.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/stats_cards.dart';
import '../widgets/marquee_header.dart';
import '../widgets/template_carousel.dart';
import '../widgets/recent_activity_card.dart';

/// Responsive dashboard for templates, saved resumes and navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _recentKey = GlobalKey();
  bool _showAll = false;
  bool _exitDialogOpen = false;
  bool _creating = false;

  void _viewAll() {
    setState(() => _showAll = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _recentKey.currentContext == null) return;
      Scrollable.ensureVisible(
        _recentKey.currentContext!,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
      );
    });
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Dialog(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(message),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'cancel'.tr,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                      ),
                      AppButton(
                        label: action,
                        variant: AppButtonVariant.danger,
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
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

  Future<void> _delete(ResumeModel resume) async {
    if (resume.id == null) return;
    final confirmed = await _confirm(
      'delete'.tr,
      'delete_resume_confirmation'.tr,
      'delete'.tr,
    );
    if (confirmed && mounted) {
      await Get.find<ResumeController>().deleteResume(resume.id!);
    }
  }

  Future<void> _requestExit() async {
    if (_exitDialogOpen) return;
    _exitDialogOpen = true;
    try {
      final confirmed = await _confirm(
        'exit_app'.tr,
        'exit_confirmation'.tr,
        'exit'.tr,
      );
      if (confirmed && mounted) await SystemNavigator.pop();
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'action_failed'.tr);
    } finally {
      _exitDialogOpen = false;
    }
  }

  Widget _recent() {
    final controller = Get.find<ResumeController>();
    return Obx(() {
      final items = controller.getRecentResumes(
        limit: _showAll ? controller.resumes.length : 5,
      );
      if (items.isEmpty) {
        return AppEmptyState(
          title: 'no_resumes_found'.tr,
          description: 'home_empty_description'.tr,
          actionLabel: 'create_new'.tr,
          onAction: () async {
            await Get.toNamed<void>(AppRoutes.resumeBuilder);
          },
        );
      }
      Widget card(int index) => RecentActivityCard(
        key: ValueKey('recent-${items[index].id}'),
        resume: items[index],
        onEdit: () {
          Get.toNamed<void>(
            AppRoutes.resumeBuilder,
            arguments: items[index].copyWith(),
          );
        },
        onDelete: () => _delete(items[index]),
        onFavorite: () async {
          final id = items[index].id;
          if (id != null) await controller.toggleFavorite(id);
        },
      );
      if (Responsive.isMobile(context)) {
        return ListView.separated(
          key: const ValueKey('recent-list'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, index) => card(index),
        );
      }
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      return GridView.builder(
        key: const ValueKey('recent-grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isDesktop(context) ? 3 : 2,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          mainAxisExtent:
              AppSpacing.xxxl * 7 +
              (scale > 1 ? scale - 1 : 0) * AppSpacing.xxxl * 8,
        ),
        itemBuilder: (_, index) => card(index),
      );
    });
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      await Get.toNamed<void>(AppRoutes.resumeBuilder);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _destination(int index) {
    if (index == 0) return;
    Get.toNamed<void>(
      [
        AppRoutes.home,
        AppRoutes.templates,
        AppRoutes.favorites,
        AppRoutes.settings,
      ][index],
    );
  }

  Widget _content(ResumeController resumes) => RefreshIndicator(
    onRefresh: () async {
      resumes.loadResumes();
    },
    child: CustomScrollView(
      key: const ValueKey('home-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: HomeHeader(statistics: StatsCards(onViewResumes: _viewAll)),
        ),
        SliverToBoxAdapter(
          child: Responsive.maxWidth(
            child: Padding(
              padding: EdgeInsets.all(
                Responsive.value<double>(
                  context: context,
                  mobile: AppSpacing.lg,
                  tablet: AppSpacing.xl,
                  desktop: AppSpacing.xxl,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeQuickActions(onCreate: _create),
                  const SizedBox(height: AppSpacing.xxl),
                  AppSectionHeader(
                    title: 'featured_templates'.tr,
                    subtitle: 'home_templates_description'.tr,
                    actionLabel: 'view_all'.tr,
                    onAction: () async {
                      await Get.toNamed<void>(AppRoutes.templates);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const TemplateCarousel(),
                  const SizedBox(height: AppSpacing.xxl),
                  AppSectionHeader(
                    key: _recentKey,
                    title: (_showAll ? 'resumes' : 'recent_activity').tr,
                    subtitle: 'home_recent_description'.tr,
                    actionLabel: (_showAll ? 'show_recent' : 'view_all').tr,
                    onAction: () {
                      if (_showAll) {
                        setState(() => _showAll = false);
                      } else {
                        _viewAll();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _recent(),
                  const SizedBox(height: AppSpacing.xl),
                  const MarqueeHeader(),
                  const SizedBox(height: AppSpacing.xxxl * 2),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _rail(double scale) {
    final extended = Responsive.isDesktop(context) && scale < 1.5;
    final labels = ['home'.tr, 'templates'.tr, 'favorites'.tr, 'settings'.tr];
    final icons = [
      Icons.home_outlined,
      Icons.grid_view_outlined,
      Icons.favorite_outline,
      Icons.settings_outlined,
    ];
    return NavigationRail(
      key: const ValueKey('home-navigation-rail'),
      selectedIndex: 0,
      extended: extended,
      labelType: NavigationRailLabelType.none,
      minWidth: AppSpacing.xxxl + AppSpacing.xxl,
      minExtendedWidth: AppSpacing.xxxl * 4,
      onDestinationSelected: _destination,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Icon(
          Icons.description_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      destinations: [
        for (var index = 0; index < labels.length; index++)
          NavigationRailDestination(
            icon: Tooltip(message: labels[index], child: Icon(icons[index])),
            label: Text(labels[index]),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumes = Get.find<ResumeController>();
    final scale =
        MediaQuery.textScalerOf(
          context,
        ).scale(AppTextStyles.bodySmall.fontSize!) /
        AppTextStyles.bodySmall.fontSize!;
    final mobile = Responsive.isMobile(context);
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _requestExit();
        },
        child: Scaffold(
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!mobile) ...[
                  _rail(scale),
                  const VerticalDivider(width: AppSpacing.stroke),
                ],
                Expanded(child: _content(resumes)),
              ],
            ),
          ),
          floatingActionButton: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: AppShadows.colored(AppColors.primary),
            ),
            child: FloatingActionButton(
              key: const ValueKey('home-create-fab'),
              heroTag: 'home-create-fab',
              tooltip: 'create_new'.tr,
              onPressed: _creating ? null : _create,
              backgroundColor: AppColors.transparent,
              foregroundColor: AppColors.lightSurface,
              elevation: AppSpacing.none,
              highlightElevation: AppSpacing.none,
              hoverElevation: AppSpacing.none,
              focusElevation: AppSpacing.none,
              disabledElevation: AppSpacing.none,
              child: const Icon(Icons.add),
            ),
          ),
          bottomNavigationBar: mobile
              ? NavigationBar(
                  key: const ValueKey('home-navigation-bar'),
                  height:
                      AppSpacing.touchTarget +
                      AppSpacing.xxl +
                      (scale > 1 ? scale - 1 : 0) * AppSpacing.xl,
                  selectedIndex: 0,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  onDestinationSelected: _destination,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: 'home'.tr,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.grid_view_outlined),
                      label: 'templates'.tr,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.favorite_outline),
                      label: 'favorites'.tr,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      label: 'settings'.tr,
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}

```

## lib/features/home/presentation/widgets/home_header.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/index.dart';

/// Welcome banner with statistics overlapping its lower edge inside hit bounds.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.statistics});
  final Widget statistics;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.value<double>(
      context: context,
      mobile: AppSpacing.lg,
      tablet: AppSpacing.xl,
      desktop: AppSpacing.xxl,
    );
    return Stack(
      children: [
        Positioned.fill(
          bottom: AppSpacing.xxxl,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.xxl),
              ),
              gradient: dark
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
            ),
          ),
        ),
        Responsive.maxWidth(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              padding,
              AppSpacing.xl,
              padding,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'app_name'.tr,
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.caption,
                            ).copyWith(color: AppColors.lightSurface),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Semantics(
                            header: true,
                            child: Text(
                              'home_welcome'.tr,
                              style: AppTextStyles.resolve(
                                context,
                                Responsive.isMobile(context)
                                    ? AppTextStyles.h2
                                    : AppTextStyles.h1,
                              ).copyWith(color: AppColors.lightSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppAvatar(
                      size: AppSpacing.touchTarget + AppSpacing.sm,
                      semanticsLabel: 'settings'.tr,
                      onTap: () => Get.toNamed<void>(AppRoutes.settings),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'splash_tagline'.tr,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.bodySmall,
                  ).copyWith(color: AppColors.lightSurface),
                ),
                const SizedBox(height: AppSpacing.xl),
                statistics,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

```

## lib/features/home/presentation/widgets/stats_cards.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../controllers/template_controller.dart';
import '../../../../shared_widgets/index.dart';

/// Live all-resume statistics in accessible equal-height surface cards.
class StatsCards extends StatelessWidget {
  const StatsCards({super.key, required this.onViewResumes});
  final VoidCallback onViewResumes;
  @override
  Widget build(BuildContext context) {
    final resumes = Get.find<ResumeController>();
    final templates = Get.find<TemplateController>();
    return Obx(() {
      final values = [
        (
          Icons.description_outlined,
          'total_resumes'.tr,
          resumes.resumes.length,
          onViewResumes,
        ),
        (
          Icons.grid_view_outlined,
          'available_templates'.tr,
          templates.templates.length,
          () {
            Get.toNamed<void>(AppRoutes.templates);
          },
        ),
        (
          Icons.favorite_outline,
          'favorite_resumes'.tr,
          resumes.getFavoriteResumes().length,
          () {
            Get.toNamed<void>(AppRoutes.favorites);
          },
        ),
      ];
      final scheme = Theme.of(context).colorScheme;
      final colors = [
        scheme.primary,
        Theme.of(context).brightness == Brightness.dark
            ? AppColors.secondaryLight
            : AppColors.successForeground,
        scheme.error,
      ];
      return LayoutBuilder(
        builder: (context, constraints) {
          final scale =
              MediaQuery.textScalerOf(
                context,
              ).scale(AppTextStyles.caption.fontSize!) /
              AppTextStyles.caption.fontSize!;
          final columns = constraints.maxWidth < 360 && scale > 1.5
              ? 1
              : constraints.maxWidth < 560 && scale > 1.2
              ? 2
              : 3;
          Widget card(int index) => Semantics(
            button: true,
            label: '${values[index].$2}: ${values[index].$3}',
            onTap: values[index].$4,
            excludeSemantics: true,
            child: AppCard(
              key: ValueKey('stat-$index'),
              onTap: values[index].$4,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors[index].withValues(alpha: .12),
                      borderRadius: AppRadii.field,
                    ),
                    child: Icon(
                      values[index].$1,
                      size: AppSpacing.icon,
                      color: colors[index],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${values[index].$3}',
                    style: AppTextStyles.resolve(
                      context,
                      AppTextStyles.h3,
                    ).copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    values[index].$2,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.resolve(
                      context,
                      AppTextStyles.caption,
                    ).copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
          return Column(
            children: [
              for (var row = 0; row < values.length; row += columns) ...[
                if (row > 0) const SizedBox(height: AppSpacing.md),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var column = 0; column < columns; column++) ...[
                        if (column > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: row + column < values.length
                              ? card(row + column)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      );
    });
  }
}

```

## lib/features/home/presentation/widgets/home_quick_actions.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Three guarded shortcut actions with high-contrast gradient backgrounds.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.onCreate});
  final Future<void> Function() onCreate;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale =
          MediaQuery.textScalerOf(
            context,
          ).scale(AppTextStyles.button.fontSize!) /
          AppTextStyles.button.fontSize!;
      final values = [
        (
          'create-resume',
          'create_new',
          Icons.add,
          AppColors.primaryGradient,
          onCreate,
        ),
        (
          'import-resume',
          'import_resume',
          Icons.upload_file_outlined,
          AppColors.successGradient,
          () async {
            await Get.toNamed<void>(AppRoutes.importResume);
          },
        ),
        (
          'check-ats',
          'ats_checker',
          Icons.fact_check_outlined,
          AppColors.warmGradient,
          () async {
            await Get.toNamed<void>(AppRoutes.atsChecker);
          },
        ),
      ];
      Widget action(int index) => AppButton(
        key: ValueKey(values[index].$1),
        label: values[index].$2.tr,
        icon: values[index].$3,
        gradient: values[index].$4,
        iconOnTop: scale <= 1.3,
        size: AppButtonSize.sm,
        fullWidth: true,
        onPressed: values[index].$5,
      );
      if (scale > 1.3 || constraints.maxWidth < 300) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < values.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              action(i),
            ],
          ],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < values.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: action(i)),
            ],
          ],
        ),
      );
    },
  );
}

```

## lib/features/home/presentation/widgets/template_carousel.dart
```dart
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/template_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/template_model.dart';
import '../../../../shared_widgets/index.dart';

/// Responsive gradient template cards with accessible manual carousel controls.
class TemplateCarousel extends StatefulWidget {
  const TemplateCarousel({super.key});
  @override
  State<TemplateCarousel> createState() => _TemplateCarouselState();
}

class _TemplateCarouselState extends State<TemplateCarousel> {
  final _carousel = carousel.CarouselSliderController();
  int _index = 0;
  Color _color(TemplateModel template) {
    final hex = template.previewColor?.replaceFirst('#', '') ?? '';
    final value = hex.length == 6 ? int.tryParse(hex, radix: 16) : null;
    var color = value == null ? AppColors.primary : Color(0xff000000 | value);
    for (var i = 0; i < 20 && color.computeLuminance() > .18; i++) {
      color = Color.lerp(color, AppColors.darkBackground, .15)!;
    }
    return color;
  }

  IconData _icon(String id) => switch (id) {
    'classic' => Icons.article_outlined,
    'business' => Icons.business_center_outlined,
    'technical' => Icons.terminal,
    'ats' => Icons.fact_check_outlined,
    _ => Icons.auto_awesome_outlined,
  };
  Widget _card(BuildContext context, TemplateModel template) {
    final color = _color(template);
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: AppRadii.dialog,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [color, Color.lerp(color, AppColors.darkBackground, .45)!],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    _icon(template.id),
                    size: AppSpacing.xxxl,
                    color: AppColors.lightSurface,
                  ),
                ),
                if (template.id == 'ats') ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Flexible(
                    child: Text(
                      'ATS',
                      style: TextStyle(color: AppColors.lightSurface),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              template.localizedName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.h4,
              ).copyWith(color: AppColors.lightSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              template.localizedDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.bodySmall,
              ).copyWith(color: AppColors.lightSurface),
            ),
            const Spacer(),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: ValueKey('use-template-${template.id}'),
              label: 'use_template'.tr,
              fullWidth: true,
              onPressed: () async {
                await Get.toNamed<void>(
                  AppRoutes.resumeBuilder,
                  arguments: template.id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final templates = Get.find<TemplateController>().getFeaturedTemplates();
    if (templates.isEmpty) {
      return AppEmptyState(
        title: 'no_templates_available'.tr,
        actionLabel: 'browse_templates'.tr,
        onAction: () async {
          await Get.toNamed<void>(AppRoutes.templates);
        },
      );
    }
    final scale =
        MediaQuery.textScalerOf(
          context,
        ).scale(AppTextStyles.bodySmall.fontSize!) /
        AppTextStyles.bodySmall.fontSize!;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final active = _index.clamp(0, templates.length - 1);
    return Column(
      children: [
        carousel.CarouselSlider(
          carouselController: _carousel,
          options: carousel.CarouselOptions(
            height:
                AppSpacing.xxxl * 8 +
                (scale > 1 ? scale - 1 : 0) * AppSpacing.xxxl * 6,
            viewportFraction: Responsive.value<double>(
              context: context,
              mobile: .85,
              tablet: .5,
              desktop: .33,
            ),
            enlargeCenterPage: false,
            autoPlay:
                !reduced &&
                !MediaQuery.accessibleNavigationOf(context) &&
                scale < 1.5 &&
                TickerMode.of(context) &&
                templates.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 500),
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              if (mounted) setState(() => _index = index);
            },
          ),
          items: templates.map((template) => _card(context, template)).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            IconButton(
              tooltip: 'previous'.tr,
              onPressed: templates.length < 2
                  ? null
                  : () {
                      if (reduced) {
                        _carousel.jumpToPage(
                          (active - 1 + templates.length) % templates.length,
                        );
                      } else {
                        _carousel.previousPage(
                          duration: AppTheme.motionDuration,
                        );
                      }
                    },
              icon: const BackButtonIcon(),
            ),
            Text(
              'template_position'.trParams({
                'current': '${active + 1}',
                'total': '${templates.length}',
              }),
              style: AppTextStyles.resolve(context, AppTextStyles.caption),
            ),
            IconButton(
              tooltip: 'next'.tr,
              onPressed: templates.length < 2
                  ? null
                  : () {
                      if (reduced) {
                        _carousel.jumpToPage((active + 1) % templates.length);
                      } else {
                        _carousel.nextPage(duration: AppTheme.motionDuration);
                      }
                    },
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ],
    );
  });
}

```

## lib/features/home/presentation/widgets/recent_activity_card.dart
```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';

/// Saved-resume surface with a photo fallback, skill chips and explicit actions.
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.resume,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });
  final ResumeModel resume;
  final VoidCallback onEdit;
  final FutureOr<void> Function() onDelete, onFavorite;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = resume.fullName.trim().isEmpty
        ? 'untitled_resume'.tr
        : resume.fullName;
    final date = DateFormatter.relativeTime(
      resume.updatedAt ?? resume.createdAt,
      locale: Get.locale?.languageCode ?? 'en',
    );
    return LayoutBuilder(
      builder: (context, constraints) => AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onEdit,
          excludeFromSemantics: true,
          canRequestFocus: false,
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: constraints.hasBoundedHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAvatar(
                      name: name,
                      size: AppSpacing.touchTarget,
                      image: resume.profilePicture?.isNotEmpty == true
                          ? FileImage(File(resume.profilePicture!))
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Tooltip(
                        message: name,
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.resolve(
                            context,
                            AppTextStyles.label,
                          ).copyWith(color: scheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'last_saved'.trParams({'time': date}),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.caption,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
                if (resume.skills.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final skill in resume.skills.take(3))
                        AppChip(label: skill.name),
                    ],
                  ),
                ],
                if (constraints.hasBoundedHeight) const Spacer(),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  alignment: WrapAlignment.end,
                  children: [
                    IconButton(
                      key: ValueKey('edit-resume-${resume.id}'),
                      tooltip: 'edit_resume'.tr,
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      key: ValueKey('favorite-resume-${resume.id}'),
                      tooltip:
                          (resume.isFavorite
                                  ? 'remove_favorite'
                                  : 'add_favorite')
                              .tr,
                      onPressed: () async {
                        await onFavorite();
                      },
                      icon: Icon(
                        resume.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: resume.isFavorite
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      key: ValueKey('delete-resume-${resume.id}'),
                      tooltip: 'delete'.tr,
                      onPressed: () async {
                        await onDelete();
                      },
                      icon: Icon(Icons.delete_outline, color: scheme.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/features/home/presentation/widgets/marquee_header.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Resume tips retaining all messages with a static reduced-motion alternative.
class MarqueeHeader extends StatelessWidget {
  const MarqueeHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final tips = [
      'tip_action_verbs'.tr,
      'tip_tailor_resume'.tr,
      'tip_resume_length'.tr,
      'tip_relevant_skills'.tr,
      'tip_job_keywords'.tr,
    ];
    final text = tips.join('   •   ');
    final scheme = Theme.of(context).colorScheme;
    final style = AppTextStyles.resolve(
      context,
      AppTextStyles.bodySmall,
    ).copyWith(color: scheme.onSurfaceVariant);
    final staticTips =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context) ||
        MediaQuery.textScalerOf(
              context,
            ).scale(AppTextStyles.bodySmall.fontSize!) >
            AppTextStyles.h4.fontSize!;
    return AppCard(
      child: staticTips
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: scheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(tips.join('\n'), style: style),
              ],
            )
          : Semantics(
              label: text,
              excludeSemantics: true,
              child: SizedBox(
                height:
                    MediaQuery.textScalerOf(
                      context,
                    ).scale(AppTextStyles.bodySmall.fontSize!) +
                    AppSpacing.xl,
                child: Marquee(
                  text: text,
                  style: style,
                  velocity: 35,
                  blankSpace: AppSpacing.xxxl,
                  pauseAfterRound: const Duration(seconds: 2),
                  textDirection: Directionality.of(context),
                ),
              ),
            ),
    );
  }
}

```

## test/home/home_test.dart
```dart
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/home/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final entries = List.generate(
    7,
    (index) => ResumeModel(
      id: index + 1,
      fullName: 'User ${index + 1}',
      createdAt: DateTime(2026, 1, index + 1),
      isFavorite: index < 3,
      skills: [
        Skill(name: 'Flutter'),
        Skill(name: 'Communication'),
        Skill(name: 'SQL'),
      ],
    ),
  );
  int loads = 0;
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() {
    loads++;
    return entries.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    saves++;
    final saved = resume.copyWith(
      id: resume.id ?? 99,
      updatedAt: DateTime.now(),
    );
    final index = entries.indexWhere((entry) => entry.id == saved.id);
    if (index < 0) {
      entries.add(saved);
    } else {
      entries[index] = saved;
    }
    return saved.copyWith();
  }

  @override
  Future<void> deleteResume(int id) async {
    entries.removeWhere((entry) => entry.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host({
  bool dark = false,
  double scale = 1,
  bool reducedMotion = true,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Get.locale ?? const Locale('en', 'US'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reducedMotion,
    ),
    child: child!,
  ),
  home: const HomeScreen(),
  getPages: [
    GetPage(
      name: AppRoutes.atsChecker,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('ats-marker')),
    ),
    GetPage(
      name: AppRoutes.importResume,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('import-marker')),
    ),
    GetPage(
      name: AppRoutes.resumeBuilder,
      transition: Transition.noTransition,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
    GetPage(
      name: AppRoutes.templates,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('templates-marker')),
    ),
    GetPage(
      name: AppRoutes.favorites,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('favorites-marker')),
    ),
    GetPage(
      name: AppRoutes.settings,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('settings-marker')),
    ),
  ],
);

void size(WidgetTester tester, double width, [double height = 900]) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    if (target.hitTestable().evaluate().isNotEmpty) return;
    final viewport = tester.getRect(find.byKey(const ValueKey('home-scroll')));
    final exists = target.evaluate().isNotEmpty;
    final above = exists && tester.getCenter(target).dy < viewport.top;
    await tester.dragFrom(
      Offset(viewport.left + 6, viewport.center.dy),
      Offset(0, above ? 300 : -300),
    );
    await tester.pumpAndSettle();
  }
  throw StateError('Unable to reveal $target');
}

void main() {
  late _Repository repository;
  late ResumeController resumes;
  late TemplateController templates;
  void prepare() {
    resumes = Get.put(ResumeController(repository: repository));
    templates = Get.put(TemplateController());
  }

  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en', 'US');
    repository = _Repository();
  });
  tearDown(() {
    Get.reset();
  });

  testWidgets('Import action opens the import screen', (tester) async {
    prepare();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('import-resume'));
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('import-marker'), findsOneWidget);
  });

  testWidgets('ATS action opens the checker', (tester) async {
    prepare();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('check-ats'));
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('ats-marker'), findsOneWidget);
  });

  testWidgets(
    'Statistics reflect all seven resumes, five templates and three favorites',
    (tester) async {
      prepare();
      await tester.pumpWidget(host());
      for (final value in ['7', '5', '3']) {
        expect(
          find.descendant(
            of: find.byType(StatsCards),
            matching: find.text(value),
          ),
          findsOneWidget,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Home responds at mobile, tablet, desktop and large Arabic text sizes',
    (tester) async {
      prepare();
      size(tester, 320);
      for (final entry in <double, double>{
        320: 2,
        600: 2,
        1200: 2,
        1920: 1,
      }.entries) {
        tester.view.physicalSize = Size(entry.key, 900);
        Get.locale = const Locale('ar', 'SA');
        await tester.pumpWidget(host(dark: true, scale: entry.value));
        await tester.pump();
        final expected = entry.key < 600 ? 'recent-list' : 'recent-grid';
        await reveal(tester, find.byKey(ValueKey(expected)));
        expect(find.byKey(ValueKey(expected)), findsOneWidget);
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        Get.reset();
        Get.testMode = true;
        resumes = Get.put(ResumeController(repository: repository));
        templates = Get.put(TemplateController());
      }
    },
  );

  testWidgets(
    'Carousel fractions are 0.85, 0.5 and 0.33 and manual controls work',
    (tester) async {
      prepare();
      size(tester, 390);
      for (final entry in <double, double>{
        390: 0.85,
        800: 0.5,
        1440: 0.33,
      }.entries) {
        tester.view.physicalSize = Size(entry.key, 1000);
        await tester.pumpWidget(host());
        await reveal(tester, find.byType(carousel.CarouselSlider));
        final widget = tester.widget<carousel.CarouselSlider>(
          find.byType(carousel.CarouselSlider),
        );
        expect(widget.options.viewportFraction, entry.value);
        expect(widget.options.autoPlay, false);
        await reveal(tester, find.byTooltip('Next'));
        await tester.tap(find.byTooltip('Next'));
        await tester.pumpAndSettle();
        expect(find.text('2 of 5'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        Get.reset();
        Get.testMode = true;
        resumes = Get.put(ResumeController(repository: repository));
        templates = Get.put(TemplateController());
      }
    },
  );

  testWidgets(
    'View all displays older resumes instead of navigating to favorites',
    (tester) async {
      prepare();
      size(tester, 390);
      await tester.pumpWidget(host());
      expect(find.byKey(const ValueKey('recent-1')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('stat-0')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('recent-1')), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Create and use-template actions open the builder with the correct arguments',
    (tester) async {
      prepare();
      size(tester, 800, 1200);
      Object? argument;
      await tester.pumpWidget(
        host(
          capture: (value) {
            argument = value;
          },
        ),
      );
      await reveal(tester, find.byKey(const ValueKey('create-resume')));
      await tester.tap(find.byKey(const ValueKey('create-resume')));
      await tester.pumpAndSettle();
      expect(find.text('builder-marker'), findsOneWidget);
      expect(argument, isNull);
      Get.back<void>();
      await tester.pumpAndSettle();
      final use = find.byKey(const ValueKey('use-template-modern')).first;
      await reveal(tester, use);
      await tester.tap(use);
      await tester.pumpAndSettle();
      expect(argument, 'modern');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Favorite and edit actions update live counts and pass an independent resume',
    (tester) async {
      prepare();
      size(tester, 800, 1200);
      Object? argument;
      await tester.pumpWidget(
        host(
          capture: (value) {
            argument = value;
          },
        ),
      );
      final card = find.byKey(const ValueKey('recent-7'));
      await reveal(tester, card);
      final favorite = find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('favorite-resume-7')),
      );
      await reveal(tester, favorite);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.widget<RecentActivityCard>(card).resume.id, 7);
      expect(tester.widget<IconButton>(favorite).onPressed, isNotNull);
      await tester.tap(favorite);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        repository.saves,
        1,
        reason:
            'Favorite should save without navigating; route: ${Get.currentRoute}',
      );
      expect(resumes.getFavoriteResumes(), hasLength(4));
      final edit = find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('edit-resume-7')),
      );
      await reveal(tester, edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(argument, isA<ResumeModel>());
      final edited = argument as ResumeModel;
      expect(edited.id, 7);
      edited.fullName = 'Unsaved change';
      expect(
        resumes.resumes.firstWhere((resume) => resume.id == 7).fullName,
        'User 7',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Delete requires confirmation before removing a resume', (
    tester,
  ) async {
    prepare();
    size(tester, 800, 1200);
    await tester.pumpWidget(host());
    final card = find.byKey(const ValueKey('recent-7'));
    await reveal(tester, card);
    await reveal(
      tester,
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.pumpAndSettle();
    expect(resumes.resumes, hasLength(7));
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('Cancel')),
    );
    await tester.pumpAndSettle();
    expect(resumes.resumes, hasLength(7));
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(of: find.byType(Dialog), matching: find.text('Delete'))
          .last,
    );
    await tester.pump();
    expect(resumes.resumes, hasLength(6));
    expect(repository.entries.any((resume) => resume.id == 7), false);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Bottom navigation opens the selected destination', (
    tester,
  ) async {
    prepare();
    size(tester, 390);
    await tester.pumpWidget(host());
    final destination = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.favorite_outline),
    );
    await tester.tap(destination);
    await tester.pumpAndSettle();
    expect(find.text('favorites-marker'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Empty data and invalid template colors render without crashes', (
    tester,
  ) async {
    prepare();
    size(tester, 320);
    resumes.resumes.clear();
    templates.templates.assignAll([
      const TemplateModel(
        id: 'custom',
        name: 'Custom',
        nameAr: 'مخصص',
        description: 'Description',
        descriptionAr: 'وصف',
        type: 'classic',
        language: 'en',
        previewColor: 'invalid',
        isFeatured: true,
      ),
    ]);
    await tester.pumpWidget(host(scale: 3));
    await reveal(tester, find.text('No resumes found'));
    expect(find.text('No resumes found'), findsOneWidget);
    expect(tester.takeException(), isNull);
    templates.templates.clear();
    await tester.pump();
    expect(find.text('No templates are available'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

```

## test/home/redesign_dashboard_test.dart
```dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/home/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  _Repository(bool arabic)
    : entries = List.generate(
        3,
        (index) => ResumeModel(
          id: index + 1,
          fullName: arabic
              ? 'سيرة تجريبية ${index + 1}'
              : 'Demo Resume ${index + 1}',
          createdAt: DateTime(2026, 1, index + 1),
          isFavorite: index == 0,
          skills: [
            Skill(name: 'Flutter'),
            Skill(name: 'Dart'),
            Skill(name: 'Communication'),
          ],
          templateId: 'modern',
        ),
      );
  final List<ResumeModel> entries;
  @override
  List<ResumeModel> loadResumes() =>
      entries.map((entry) => entry.copyWith()).toList();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _prepare(bool arabic) {
  Get.testMode = true;
  Get.locale = Locale(arabic ? 'ar' : 'en');
  Get.put(ResumeController(repository: _Repository(arabic)));
  Get.put(TemplateController());
}

Widget _host({bool arabic = false, bool dark = false, double scale = 1}) =>
    GetMaterialApp(
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
      home: const RepaintBoundary(
        key: ValueKey('dashboard-preview'),
        child: HomeScreen(),
      ),
      getPages: [
        GetPage(
          name: AppRoutes.resumeBuilder,
          transition: Transition.noTransition,
          page: () => const Scaffold(body: Text('builder-marker')),
        ),
        GetPage(
          name: AppRoutes.templates,
          transition: Transition.noTransition,
          page: () => const Scaffold(body: Text('templates-marker')),
        ),
        GetPage(
          name: AppRoutes.favorites,
          transition: Transition.noTransition,
          page: () => const Scaffold(body: Text('favorites-marker')),
        ),
        GetPage(
          name: AppRoutes.settings,
          transition: Transition.noTransition,
          page: () => const Scaffold(body: Text('settings-marker')),
        ),
      ],
    );
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 90; i++) {
    if (finder.hitTestable().evaluate().isNotEmpty) return;
    final viewport = tester.getRect(find.byKey(const ValueKey('home-scroll')));
    final above =
        finder.evaluate().isNotEmpty &&
        tester.getCenter(finder).dy < viewport.top;
    await tester.dragFrom(
      Offset(viewport.left + AppSpacing.sm, viewport.center.dy),
      Offset(0, above ? 250 : -250),
    );
    await tester.pumpAndSettle();
  }
  throw StateError('Unable to reveal $finder');
}

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('dashboard-preview')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('deliveries/ui_redesign').create(recursive: true);
      await File(
        'deliveries/ui_redesign/batch_04_$name.png',
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
      final font = FontLoader(entry.key)..addFont(rootBundle.load(entry.value));
      await font.load();
    }
  });
  tearDown(Get.reset);
  test('quick-action gradients keep white labels readable', () {
    for (final gradient in [
      AppColors.primaryGradient,
      AppColors.successGradient,
      AppColors.warmGradient,
    ]) {
      for (final color in gradient.colors) {
        final a = AppColors.lightSurface.computeLuminance(),
            b = color.computeLuminance();
        expect(
          (math.max(a, b) + .05) / (math.min(a, b) + .05),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });
  testWidgets('rail destinations open the existing routes', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    _prepare(false);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    for (final entry in {
      'templates': 'templates-marker',
      'favorites': 'favorites-marker',
      'settings': 'settings-marker',
    }.entries) {
      final rail = find.byType(NavigationRail);
      expect(rail, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final tooltip = find.descendant(
        of: rail,
        matching: find.byTooltip(entry.key.tr),
      );
      await tester.tap(tooltip);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      Get.back<void>();
      await tester.pumpAndSettle();
    }
  });
  testWidgets(
    'floating create action opens builder without mutating saved resumes',
    (tester) async {
      _prepare(false);
      final resumes = Get.find<ResumeController>();
      final original = resumes.resumes.map((r) => r.copyWith()).toList();
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-create-fab')));
      await tester.pumpAndSettle();
      expect(find.text('builder-marker'), findsOneWidget);
      expect(resumes.resumes, original);
    },
  );
  testWidgets('header avatar opens settings', (tester) async {
    _prepare(false);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    final avatar = find.descendant(
      of: find.byType(HomeHeader),
      matching: find.bySemanticsLabel('settings'.tr),
    );
    await tester.tap(avatar);
    await tester.pumpAndSettle();
    expect(find.text('settings-marker'), findsOneWidget);
  });
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final dark in [false, true]) {
      for (final arabic in [false, true]) {
        testWidgets('dashboard fits $width $dark $arabic at scale 2', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, width == 1024 ? 480 : 900);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          _prepare(arabic);
          await tester.pumpWidget(_host(arabic: arabic, dark: dark, scale: 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            find.byType(width < 600 ? NavigationBar : NavigationRail),
            findsOneWidget,
          );
          await _reveal(tester, find.byKey(const ValueKey('check-ats')));
          expect(tester.takeException(), isNull);
          await _reveal(tester, find.byKey(const ValueKey('delete-resume-3')));
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
              ((width == 390 && dark == arabic) ||
                  (width == 1920 && !dark && !arabic))) {
            tester.view.physicalSize = Size(width, width == 390 ? 1800 : 1500);
            await tester.pumpWidget(_host(arabic: arabic, dark: dark));
            await tester.pumpAndSettle();
            await tester.drag(
              find.byKey(const ValueKey('home-scroll')),
              const Offset(0, 20000),
            );
            await tester.pumpAndSettle();
            await _capture(
              tester,
              width == 1920
                  ? 'desktop_light_en'
                  : dark
                  ? 'home_dark_ar'
                  : 'home_light_en',
            );
          }
        });
      }
    }
  }
}

```

