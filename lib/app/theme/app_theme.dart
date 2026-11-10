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
