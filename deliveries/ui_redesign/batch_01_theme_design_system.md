# UI/UX — Batch 1: Theme + Design System
طُبقت ملفات نظام التصميم الستة مع ملف تجميع داخل lib/app/theme/index.dart. لم تتغير الخدمات أو المستودعات أو المتحكمات أو النماذج أو الاعتماديات، ولم يُعدل lib/app/index.dart خارج نطاق الثيم.
الألوان: Indigo الأساسي #4F46E5 مع الداكن #4338CA والفاتح #818CF8، وTeal وAmber والألوان الدلالية المطلوبة، مع أسطح وحدود ونصوص مستقلة للوضعين. تستعمل التفاعلات في الوضع الداكن Indigo الفاتح لتحسين التباين. أضيفت درجات دلالية أغمق للنصوص على الأسطح الفاتحة بدلاً من استخدام ألوان النجاح والتحذير الفاتحة كنص صغير.
الخطوط: مقياس display/h1/h2/h3/h4/bodyLarge/body/bodySmall/label/caption/button. تستخدم الأنماط الافتراضية Poppins مع Cairo للحروف العربية. AppTextStyles.resolve يختار عائلة الخط بحسب لغة السياق، وAppTheme.forLocale يتيح ثيماً صريح اللغة للمكونات التالية؛ لم يُعدل متحكم اللغة. لا يتغير محتوى ملفات PDF أو قواعد ATS.
المقاسات: AppSpacing للمسافات وأهداف اللمس والحدود، AppRadii للزوايا، وAppShadows للظلال الناعمة والمتوسطة والكبيرة والملونة. الثيم يوحّد البطاقات والحقول والأزرار والحوارات والشرائح والتنقل والرسائل والمؤشرات، مع الإبقاء على AppTheme.light وAppTheme.dark وإضافة lightTheme وdarkTheme.
نطاق الدفعة: هذا هو أساس التصميم فقط. أزرار gradient المخصصة وحقول التركيز والمكونات المشتركة ستأتي في Batch 2، وإعادة بناء الشاشات ضمن دفعاتها. عينتا PNG تعرضان مكونات Material تحت الثيم الجديد وليستا ادعاءً باكتمال تصميم الرئيسية.
التحقق الجديد: فحص تباين النصوص والأزرار والأخطاء بنسبة لا تقل عن 4.5:1؛ 20 حالة عرض تجمع أحجام 320/390/600/1024/1920 مع Light/Dark وAR/EN وتكبير النص 200%؛ تحقق من هدف لمس لا يقل عن 48. المجموع 23 اختباراً جديداً. راجعت عينتي العرض بصرياً بخطوط فعلية وأيقونات Material عند حجم النص العادي.
تعديل الاختبار القديم الوحيد: الوصول إلى Carousel بالتمرير قبل قراءة خصائصه؛ النسب 0.85/0.5/0.33 وفحص التنقل بقيت كما هي. لم يُغير كود الرئيسية أو سلوكها.
## عينات التصميم
[فاتح / إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_01_light_en.png)
[داكن / عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_01_dark_ar.png)
## الملفات كاملة
1. lib/app/theme/app_colors.dart
2. lib/app/theme/app_shadows.dart
3. lib/app/theme/app_radii.dart
4. lib/app/theme/app_spacing.dart
5. lib/app/theme/app_text_styles.dart
6. lib/app/theme/app_theme.dart
7. lib/app/theme/index.dart
8. test/theme/design_system_test.dart
9. test/home/home_test.dart

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
    colors: [successForeground, secondary],
  );
  static const warmGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [warningForeground, accent],
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

## lib/app/theme/app_shadows.dart
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Elevation recipes for surfaces and restrained brand-colored emphasis.
abstract final class AppShadows {
  static const soft = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: AppSpacing.lg,
      offset: Offset(0, AppSpacing.xs),
    ),
  ];
  static const medium = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: AppSpacing.xl,
      offset: Offset(0, AppSpacing.sm),
    ),
  ];
  static const large = [
    BoxShadow(
      color: AppColors.shadowLarge,
      blurRadius: AppSpacing.xxxl,
      offset: Offset(0, AppSpacing.lg),
    ),
  ];
  static const dark = [
    BoxShadow(
      color: AppColors.darkShadow,
      blurRadius: AppSpacing.xl,
      offset: Offset(0, AppSpacing.sm),
    ),
  ];
  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: .18),
      blurRadius: AppSpacing.xl,
      offset: const Offset(0, AppSpacing.sm),
    ),
  ];
  static List<BoxShadow> forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : soft;
}

```

## lib/app/theme/app_radii.dart
```dart
import 'package:flutter/material.dart';

/// Reusable corner radii for fields, cards, dialogs and pill controls.
abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 999;
  static const field = BorderRadius.all(Radius.circular(sm));
  static const card = BorderRadius.all(Radius.circular(lg));
  static const dialog = BorderRadius.all(Radius.circular(xl));
  static const chip = BorderRadius.all(Radius.circular(pill));
}

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
}

```

## lib/app/theme/app_text_styles.dart
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Type scale with Poppins for Latin text and Cairo for Arabic glyphs.
abstract final class AppTextStyles {
  static const fontFamily = 'Poppins';
  static const arabicFontFamily = 'Cairo';
  static const fontFallback = [arabicFontFamily];
  static const display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const h3 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static const h4 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static String familyFor(Locale locale) =>
      locale.languageCode == 'ar' ? arabicFontFamily : fontFamily;
  static TextStyle resolve(BuildContext context, TextStyle style) =>
      style.copyWith(
        fontFamily: familyFor(Localizations.localeOf(context)),
        fontFamilyFallback: const [fontFamily, arabicFontFamily],
      );
  static TextTheme textTheme(Brightness brightness, {Locale? locale}) {
    final theme = TextTheme(
      displayLarge: display,
      displayMedium: h1,
      displaySmall: h2,
      headlineLarge: h1,
      headlineMedium: h2,
      headlineSmall: h3,
      titleLarge: h4,
      titleMedium: body.copyWith(fontWeight: FontWeight.w600),
      titleSmall: label,
      bodyLarge: bodyLarge,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: button,
      labelMedium: label,
      labelSmall: caption,
    );
    return theme.apply(
      fontFamily: locale == null ? fontFamily : familyFor(locale),
      fontFamilyFallback: const [fontFamily, arabicFontFamily],
      bodyColor: AppColors.text(brightness),
      displayColor: AppColors.text(brightness),
    );
  }
}

```

## lib/app/theme/app_theme.dart
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Material 3 themes retaining the existing light/dark entry points.
abstract final class AppTheme {
  static const motionDuration = Duration(milliseconds: 200);
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);
  static ThemeData forLocale(Brightness brightness, Locale locale) =>
      _build(brightness, locale: locale);

  static ThemeData _build(Brightness brightness, {Locale? locale}) {
    final dark = brightness == Brightness.dark;
    final surface = AppColors.surface(brightness);
    final background = AppColors.background(brightness);
    final text = AppColors.text(brightness);
    final muted = AppColors.textSecondary(brightness);
    final outline = AppColors.border(brightness);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: dark ? AppColors.primaryLight : AppColors.primary,
          onPrimary: dark ? AppColors.darkBackground : AppColors.lightSurface,
          primaryContainer: dark ? AppColors.darkTint : AppColors.lightTint,
          onPrimaryContainer: dark ? AppColors.darkText : AppColors.primaryDark,
          secondary: dark ? AppColors.secondaryLight : AppColors.secondary,
          onSecondary: AppColors.lightText,
          tertiary: AppColors.accent,
          onTertiary: AppColors.lightText,
          surface: surface,
          onSurface: text,
          onSurfaceVariant: muted,
          surfaceContainerLowest: background,
          surfaceContainerLow: surface,
          surfaceContainer: surface,
          surfaceContainerHigh: dark
              ? AppColors.darkBorder
              : AppColors.lightTint,
          surfaceContainerHighest: dark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          outline: outline,
          outlineVariant: outline,
          error: dark ? AppColors.errorLight : AppColors.errorForeground,
          onError: dark ? AppColors.darkBackground : AppColors.lightSurface,
          errorContainer: dark
              ? AppColors.darkErrorContainer
              : AppColors.lightErrorContainer,
          onErrorContainer: dark
              ? AppColors.darkText
              : AppColors.errorForeground,
          surfaceTint: AppColors.transparent,
        );
    final typography = AppTextStyles.textTheme(brightness, locale: locale);
    final border = OutlineInputBorder(
      borderRadius: AppRadii.field,
      borderSide: BorderSide(color: outline, width: AppSpacing.stroke),
    );
    final buttonShape = RoundedRectangleBorder(borderRadius: AppRadii.field);
    const buttonPadding = EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    );
    final filledStyle = ElevatedButton.styleFrom(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      disabledBackgroundColor: outline.withValues(alpha: .4),
      disabledForegroundColor: muted,
      minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
      elevation: AppSpacing.none,
      shadowColor: AppColors.transparent,
      padding: buttonPadding,
      shape: buttonShape,
      textStyle: typography.labelLarge,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: scheme.primary,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      cardColor: surface,
      dividerColor: outline,
      shadowColor: dark ? AppColors.darkShadow : AppColors.shadow,
      disabledColor: muted.withValues(alpha: .5),
      fontFamily: locale == null
          ? AppTextStyles.fontFamily
          : AppTextStyles.familyFor(locale),
      fontFamilyFallback: const [
        AppTextStyles.fontFamily,
        AppTextStyles.arabicFontFamily,
      ],
      textTheme: typography,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,
      hoverColor: scheme.primary.withValues(alpha: .06),
      focusColor: scheme.primary.withValues(alpha: .12),
      highlightColor: scheme.primary.withValues(alpha: .08),
      appBarTheme: AppBarTheme(
        elevation: AppSpacing.none,
        scrolledUnderElevation: AppSpacing.none,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: AppColors.transparent,
        titleTextStyle: typography.titleLarge,
        iconTheme: IconThemeData(color: text, size: AppSpacing.xl),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: AppSpacing.none,
        margin: const EdgeInsets.all(AppSpacing.none),
        surfaceTintColor: AppColors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: outline.withValues(alpha: .65)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: border,
        enabledBorder: border,
        disabledBorder: border.copyWith(
          borderSide: BorderSide(color: outline.withValues(alpha: .5)),
        ),
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: scheme.primary,
            width: AppSpacing.focusStroke,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(
            color: scheme.error,
            width: AppSpacing.focusStroke,
          ),
        ),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        labelStyle: typography.bodySmall?.copyWith(color: muted),
        hintStyle: typography.bodySmall?.copyWith(color: muted),
        helperStyle: typography.bodySmall?.copyWith(color: muted),
        errorStyle: typography.bodySmall?.copyWith(color: scheme.error),
        errorMaxLines: 4,
        prefixIconColor: scheme.primary,
        suffixIconColor: muted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: filledStyle),
      filledButtonTheme: FilledButtonThemeData(style: filledStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: typography.labelLarge,
          minimumSize: const Size(
            AppSpacing.touchTarget,
            AppSpacing.touchTarget,
          ),
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: scheme.primary, width: AppSpacing.stroke),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: typography.labelLarge,
          minimumSize: const Size(
            AppSpacing.touchTarget,
            AppSpacing.touchTarget,
          ),
          padding: buttonPadding,
          shape: buttonShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(
            AppSpacing.touchTarget,
            AppSpacing.touchTarget,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.field),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: scheme.primaryContainer,
        disabledColor: outline.withValues(alpha: .4),
        labelStyle: typography.labelMedium?.copyWith(color: text),
        secondaryLabelStyle: typography.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        checkmarkColor: scheme.primary,
        deleteIconColor: muted,
        side: BorderSide(color: outline),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.chip),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.dialog),
        titleTextStyle: typography.titleLarge,
        contentTextStyle: typography.bodyMedium,
        actionsPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        showDragHandle: true,
        dragHandleColor: outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppColors.lightSurface : AppColors.darkSurface,
        contentTextStyle: typography.bodySmall?.copyWith(
          color: dark ? AppColors.lightText : AppColors.darkText,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        elevation: AppSpacing.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => typography.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : muted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        useIndicator: true,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: typography.labelMedium?.copyWith(
          color: scheme.primary,
        ),
        unselectedLabelTextStyle: typography.labelMedium?.copyWith(
          color: muted,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        textColor: text,
        titleTextStyle: typography.bodyMedium,
        subtitleTextStyle: typography.bodySmall?.copyWith(color: muted),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.field),
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: AppSpacing.stroke,
        space: AppSpacing.xl,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: scheme.primaryContainer,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primaryContainer,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: .12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: typography.labelSmall?.copyWith(
          color: scheme.onPrimary,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(AppRadii.pill),
        thumbColor: WidgetStatePropertyAll(outline),
        thickness: const WidgetStatePropertyAll(AppSpacing.xs),
      ),
    );
  }
}

```

## lib/app/theme/index.dart
```dart
export 'app_colors.dart';
export 'app_radii.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_text_styles.dart';
export 'app_theme.dart';

```

## test/theme/design_system_test.dart
```dart
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
    size(tester, 800);
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


التحقق النهائي: flutter analyze دون ملاحظات. نجحت جميع اختبارات المشروع وعددها 280 (257 سابقة + 23 جديدة). لم تُجر محاولة تشغيل جهاز جديد في هذه الدفعة؛ عوائق بيئة التشغيل الموثقة في Part 3 السابق لم تُغيّر.
