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
