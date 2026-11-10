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
