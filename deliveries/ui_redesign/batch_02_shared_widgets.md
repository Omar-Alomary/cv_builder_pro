# UI/UX — Batch 2: Shared Widgets
طُبقت المكونات العشرة المطلوبة داخل shared_widgets، مع تحديث ملف التجميع وإضافة مقاسات مشتركة مسماة إلى AppSpacing. لم تتغير الخدمات أو المتحكمات أو المستودعات أو النماذج أو الاعتماديات. بقي ResponsiveBuilder كما هو.
AppTextField: يحتفظ بجميع معاملات الاستخدام السابقة، والتحقق والتنسيق والقيم الابتدائية وRTL/LTR. يضيف ظل التركيز وحاوية أيقونة ملوّنة ويملك FocusNode داخلياً عند الحاجة، مع احترام ملكية عقد التركيز الخارجية وتبديلها بأمان.
AppButton: gradient أساسي، outline ثانوي، danger، ghost، وأحجام sm/md/lg. تبقى filled/outlined/text متوافقة مع الاستدعاءات السابقة. أصغر هدف لمس 48px، والنص قابل للالتفاف، وتُمنع الضغوط المتكررة أثناء العمل غير المتزامن. توجد استجابة ضغط 0.98، مع إلغاء الحركة عند طلب تقليلها، وحالة تحميل ورسالة وصول واحدة.
AppCard: سطح وظل ناعم وزوايا 20، مع hover 1.02 وضغط 0.98 عند كونه تفاعلياً، وتفعيل بلوحة المفاتيح. AppChip: filled/outlined وأيقونة واختيار وحذف منفصلان. AppAvatar: حلقة متدرجة وحرف بديل ودعم خطأ الصورة وشارة كاميرا ذات هدف لمس مناسب.
AppEmptyState وAppSectionHeader: أيقونة 80 داخل دائرة ملوّنة وزر CTA، وعنوان قسم بخط جانبي اتجاهي. تتكيف النصوص والأفعال مع العرض الضيق وتكبير النص. AppSnackBar: نجاح وتحذير وخطأ ومعلومات مع أيقونة وزوايا 16 وتباين للنص. لم تُعدّل واجهة AppSnackbar الموجودة في core؛ المكوّن الجديد خاص بطبقة العرض، وتستخدمه أخطاء AppButton.
AppBottomSheet.show<T>: لوحة سفلية عامة قابلة للتمرير، بعنوان وأيقونة اختيارية ومقبض سحب وزر إغلاق، وتعيد نتيجة typed إلى المستدعي. تراعي مساحة لوحة المفاتيح والمنطقة الآمنة. لم يُستبدل أي حوار أعمال في هذه الدفعة؛ الدمج سيكون ضمن دفعة الحوارات.
AppLoading: Shimmer دون اعتماديات جديدة، مع إدارة دورة حياة الحركة وإيقافها عندما يُعطّل TickerMode. يبقى التقدم المحدد ونص الوصول مدعومين. تقليل الحركة يعرض مؤشراً ثابتاً. useAnimation=false يحتفظ بالمؤشر الدائري. ملف Lottie واعتماديته لم يُحذفا.
التحقق: 29 اختباراً جديداً، منها 20 حالة تجمع خمسة عروض 320/390/600/1024/1920 مع AR/EN وLight/Dark وتكبير النص 200%. اختبارات التفاعل تشمل تبديل FocusNode، الأزرار والتغذية الراجعة، لوحة المفاتيح، اختيار/حذف الشرائح، فشل الصورة والكاميرا، الرسائل، اللوحة السفلية مع لوحة المفاتيح، ودورة حياة Shimmer. اجتازت اختبارات التوافق السابقة للمكونات الـ11 أيضاً.
نتيجة المجموعة الكاملة: 309 اختبارات ناجحة (280 سابقة + 29 جديدة). التحليل الساكن lib وtest دون ملاحظات بعد إزالة استيراد زائد من ملف الاختبار. لم تُجر محاولة تشغيل جهاز في هذه الدفعة.
## عينات العرض
[فاتح / إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_02_light_en.png)
[داكن / عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_02_dark_ar.png)
العينات تعرض المكونات المشتركة بخطوط فعلية عند حجم النص العادي؛ اختبارات العرض تمت عند 200%. هذه ليست إعادة تصميم مكتملة لشاشة الرئيسية، التي تأتي في Batch 4.
## الملفات كاملة
1. lib/shared_widgets/app_text_field.dart
2. lib/shared_widgets/app_button.dart
3. lib/shared_widgets/app_card.dart
4. lib/shared_widgets/app_empty_state.dart
5. lib/shared_widgets/app_section_header.dart
6. lib/shared_widgets/app_chip.dart
7. lib/shared_widgets/app_avatar.dart
8. lib/shared_widgets/app_snack_bar.dart
9. lib/shared_widgets/app_bottom_sheet.dart
10. lib/shared_widgets/app_loading.dart
11. lib/shared_widgets/index.dart
12. lib/app/theme/app_spacing.dart
13. test/shared_widgets/redesign_components_test.dart

## lib/shared_widgets/app_text_field.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme/index.dart';

/// Native form behavior with an owned-or-external focus node and branded focus.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue, hint, helperText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged, onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final Widget? prefixIcon, suffixIcon;
  final int? maxLines, maxLength;
  final bool enabled, readOnly, obscureText;
  final TextDirection? textDirection;
  final AutovalidateMode autovalidateMode;
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.textDirection,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : assert(controller == null || initialValue == null),
       assert(!obscureText || maxLines == 1);
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _internalFocus = FocusNode();
  FocusNode get _focus => widget.focusNode ?? _internalFocus;
  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocus).removeListener(_changed);
      _focus.addListener(_changed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondaryStyle = AppTextStyles.resolve(
      context,
      AppTextStyles.bodySmall,
    ).copyWith(color: scheme.onSurfaceVariant);
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppTheme.motionDuration,
      decoration: BoxDecoration(
        borderRadius: AppRadii.field,
        boxShadow: _focus.hasFocus && widget.enabled
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: .12),
                  blurRadius: AppSpacing.lg,
                ),
              ]
            : const [],
      ),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: _focus,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textDirection: widget.textDirection,
        inputFormatters: widget.inputFormatters,
        autofillHints: widget.autofillHints,
        autovalidateMode: widget.autovalidateMode,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        style: AppTextStyles.resolve(
          context,
          AppTextStyles.body,
        ).copyWith(color: scheme.onSurface),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          labelStyle: secondaryStyle,
          hintStyle: secondaryStyle,
          helperStyle: secondaryStyle,
          errorStyle: secondaryStyle.copyWith(color: scheme.error),
          helperMaxLines: 4,
          errorMaxLines: 4,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadii.xs),
                      ),
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        size: AppSpacing.icon,
                        color: scheme.primary,
                      ),
                      child: widget.prefixIcon!,
                    ),
                  ),
                ),
          suffixIcon: widget.suffixIcon,
          alignLabelWithHint: widget.maxLines != 1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focus.removeListener(_changed);
    _internalFocus.dispose();
    super.dispose();
  }
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
    final content = Row(
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
          gradient: primary && !disabled ? AppColors.primaryGradient : null,
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

## lib/shared_widgets/app_card.dart
```dart
import 'package:flutter/material.dart';
import '../app/theme/index.dart';

/// Surface card with restrained shadows, focus feedback and optional activation.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.semanticsLabel,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;
  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hover = false, _pressed = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = widget.onTap != null;
    return Semantics(
      button: interactive,
      label: widget.semanticsLabel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: interactive && !MediaQuery.disableAnimationsOf(context)
              ? _pressed
                    ? 0.98
                    : _hover
                    ? 1.02
                    : 1
              : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppTheme.motionDuration,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadii.card,
              boxShadow: AppShadows.forBrightness(theme.brightness),
            ),
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: AppRadii.card,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: AppRadii.card,
                onHighlightChanged: (value) => setState(() => _pressed = value),
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/shared_widgets/app_empty_state.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app/theme/index.dart';
import 'app_button.dart';

/// Scrollable empty state with a tinted illustration and optional primary CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.description_outlined,
    this.actionLabel,
    this.onAction,
  }) : assert((actionLabel == null) == (onAction == null));
  final String title;
  final String? description, actionLabel;
  final IconData icon;
  final FutureOr<void> Function()? onAction;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.emptyMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                  ),
                  child: Icon(
                    icon,
                    size: AppSpacing.emptyIcon,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.h4,
                  ).copyWith(color: scheme.onSurface),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.bodySmall,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

```

## lib/shared_widgets/app_section_header.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app/theme/index.dart';
import '../core/utils/responsive.dart';
import 'app_button.dart';

/// Wrapping section heading with a directional accent and optional action.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  }) : assert((actionLabel == null) == (onAction == null));
  final String title;
  final String? subtitle, actionLabel;
  final FutureOr<void> Function()? onAction;
  final IconData? actionIcon;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scheme = Theme.of(context).colorScheme;
      final heading = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.xs,
            height: AppSpacing.xxl,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: AppRadii.chip,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppTextStyles.resolve(
                      context,
                      AppTextStyles.h4,
                    ).copyWith(color: scheme.onSurface),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.resolve(
                      context,
                      AppTextStyles.bodySmall,
                    ).copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
      if (actionLabel == null) return heading;
      final action = AppButton(
        label: actionLabel!,
        onPressed: onAction,
        icon: actionIcon,
        variant: AppButtonVariant.ghost,
      );
      if (constraints.maxWidth >= Responsive.mobileBreakpoint) {
        return Row(
          children: [
            Expanded(flex: 2, child: heading),
            const SizedBox(width: AppSpacing.lg),
            Flexible(child: action),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading,
          const SizedBox(height: AppSpacing.sm),
          Align(alignment: AlignmentDirectional.centerEnd, child: action),
        ],
      );
    },
  );
}

```

## lib/shared_widgets/app_chip.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';

/// Filled or bordered appearance for reusable labels and selectable chips.
enum AppChipVariant { filled, outlined }

/// Native keyboard-accessible chip supporting selection, actions and removal.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.selected = false,
    this.variant = AppChipVariant.filled,
  }) : assert(onSelected == null || onPressed == null);
  final String label;
  final IconData? icon;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onPressed, onDeleted;
  final bool selected;
  final AppChipVariant variant;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputChip(
      label: Text(
        label,
        style: AppTextStyles.resolve(context, AppTextStyles.label),
      ),
      avatar: icon == null
          ? null
          : Icon(icon, size: AppSpacing.icon, color: scheme.primary),
      selected: selected,
      showCheckmark: icon == null,
      onSelected: onSelected,
      onPressed: onPressed,
      onDeleted: onDeleted,
      deleteButtonTooltipMessage: 'delete'.tr,
      backgroundColor: variant == AppChipVariant.filled
          ? scheme.primaryContainer
          : scheme.surface,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(
        color: variant == AppChipVariant.outlined
            ? scheme.outline
            : AppColors.transparent,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.chip),
    );
  }
}

```

## lib/shared_widgets/app_avatar.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';

/// Ring avatar with a readable initial, image-error fallback and camera action.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.name,
    this.image,
    this.size = AppSpacing.avatar,
    this.onTap,
    this.onCameraPressed,
    this.semanticsLabel,
  }) : assert(size > 0);
  final String? name, semanticsLabel;
  final ImageProvider<Object>? image;
  final double size;
  final VoidCallback? onTap, onCameraPressed;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = name?.trim() ?? '';
    final fallback = text.isEmpty
        ? null
        : String.fromCharCode(text.runes.first).toUpperCase();
    Widget initial() => ColoredBox(
      color: scheme.primaryContainer,
      child: Center(
        child: fallback == null
            ? Icon(Icons.person_outline, color: scheme.primary, size: size * .4)
            : Text(
                fallback,
                textScaler: TextScaler.noScaling,
                style: AppTextStyles.h3.copyWith(
                  fontSize: size * .36,
                  color: scheme.primary,
                ),
              ),
      ),
    );
    final dimension = math.max(
      size,
      onTap != null || onCameraPressed != null
          ? AppSpacing.touchTarget
          : AppSpacing.none,
    );
    return SizedBox.square(
      dimension: dimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Semantics(
            label: semanticsLabel ?? (text.isEmpty ? 'personal_info'.tr : text),
            image: true,
            button: onTap != null,
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(AppSpacing.focusStroke),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Material(
                color: scheme.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: ClipOval(
                      child: ExcludeSemantics(
                        child: image == null
                            ? initial()
                            : Image(
                                image: image!,
                                width: size,
                                height: size,
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, stackTrace) =>
                                    initial(),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (onCameraPressed != null)
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: IconButton(
                tooltip: 'change_profile_image'.tr,
              alignment: AlignmentDirectional.bottomEnd,
              padding: EdgeInsets.zero,
                onPressed: onCameraPressed,
                icon: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.lightSurface,
                    size: AppSpacing.icon,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

```

## lib/shared_widgets/app_snack_bar.dart
```dart
import 'package:flutter/material.dart';
import '../app/theme/index.dart';

/// Floating semantic feedback without changing the service-layer snackbar API.
abstract final class AppSnackBar {
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success, Icons.check_circle_outline);
  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error, Icons.error_outline);
  static void warning(BuildContext context, String message) =>
      _show(context, message, AppColors.warning, Icons.warning_amber_rounded);
  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.info, Icons.info_outline);
  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.dark
        ? color
        : color == AppColors.success
        ? AppColors.successForeground
        : color == AppColors.warning
        ? AppColors.warningForeground
        : color == AppColors.info
        ? AppColors.infoForeground
        : AppColors.errorForeground;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
          side: BorderSide(color: color.withValues(alpha: .5)),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppSpacing.none,
        duration: const Duration(seconds: 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: AppRadii.field,
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.xl),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.resolve(
                  context,
                  AppTextStyles.bodySmall,
                ).copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

## lib/shared_widgets/app_bottom_sheet.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';
import '../core/utils/responsive.dart';

/// Keyboard-aware modal sheet with a drag handle and a scrollable content area.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });
  final String title;
  final Widget child;
  final IconData? icon;
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder builder,
    IconData? icon,
    bool isDismissible = true,
    bool enableDrag = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: false,
    constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth / 2),
    builder: (sheetContext) =>
        AppBottomSheet(title: title, icon: icon, child: builder(sheetContext)),
  );
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final available = math.max(
      AppSpacing.none,
      media.size.height - media.viewInsets.bottom - media.padding.top,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: available * .9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                child: Container(
                  width: AppSpacing.xxxl,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: scheme.outline,
                    borderRadius: AppRadii.chip,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.lg,
                  end: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: AppTextStyles.resolve(
                            context,
                            AppTextStyles.h4,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'close'.tr,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

## lib/shared_widgets/app_loading.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';

/// Accessible loading feedback with shimmer, determinate progress and reduced motion.
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.progress,
    this.useAnimation = true,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));
  final String? message;
  final double? progress;
  final bool useAnimation;
  @override
  Widget build(BuildContext context) {
    final label = message ?? 'loading'.tr;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final scheme = Theme.of(context).colorScheme;
    final Widget indicator;
    if (progress != null) {
      indicator = CircularProgressIndicator(value: progress);
    } else if (reduced) {
      indicator = Icon(
        Icons.hourglass_empty,
        size: AppSpacing.xxxl,
        color: scheme.primary,
      );
    } else if (useAnimation) {
      indicator = const _LoadingShimmer();
    } else {
      indicator = const CircularProgressIndicator();
    }
    return Semantics(
      liveRegion: true,
      label: label,
      value: progress == null ? null : '${(progress! * 100).round()}%',
      excludeSemantics: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.loadingMaxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                indicator,
                const SizedBox(height: AppSpacing.lg),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.bodySmall,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();
  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context) && !MediaQuery.disableAnimationsOf(context)) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget line(double factor) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: factor,
        child: Container(
          height: AppSpacing.md,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadii.field,
          ),
        ),
      ),
    );
    return SizedBox(
      width: AppSpacing.loadingMaxWidth,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-3 + _controller.value * 4, 0),
            end: Alignment(-1 + _controller.value * 4, 0),
            colors: [
              scheme.surfaceContainerHighest,
              scheme.surface,
              scheme.surfaceContainerHighest,
            ],
          ).createShader(bounds),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            line(1),
            const SizedBox(height: AppSpacing.md),
            line(.72),
            const SizedBox(height: AppSpacing.md),
            line(.88),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

```

## lib/app/theme/app_spacing.dart
```dart
/// Shared spacing, stroke and touch-target dimensions for presentation widgets.
abstract final class AppSpacing {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double stroke = 1;
  static const double focusStroke = 2;
  static const double icon = 20;
  static const double touchTarget = 48;
  static const double avatar = 72;
  static const double emptyIcon = 80;
  static const double emptyMaxWidth = 480;
  static const double loadingMaxWidth = 320;
}

```

## test/shared_widgets/redesign_components_test.dart
```dart
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

```

