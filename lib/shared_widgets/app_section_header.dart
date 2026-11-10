import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';
import '../core/utils/responsive.dart';
import '../core/utils/app_snackbar.dart';
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
    this.inlineAction = false,
  }) : assert((actionLabel == null) == (onAction == null));
  final String title;
  final String? subtitle, actionLabel;
  final FutureOr<void> Function()? onAction;
  final IconData? actionIcon;
  final bool inlineAction;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scheme = Theme.of(context).colorScheme;
      final heading = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.xs,
            height: inlineAction ? 20 : AppSpacing.xxl,
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
                    style: AppTextStyles.resolve(context, AppTextStyles.h4)
                        .copyWith(
                          color: scheme.onSurface,
                          fontSize: inlineAction ? 16 : null,
                          fontWeight: inlineAction ? FontWeight.w700 : null,
                        ),
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
      if (inlineAction) {
        return Row(
          children: [
            Expanded(child: heading),
            const SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * .34),
              child: TextButton(
                onPressed: onAction == null
                    ? null
                    : () async {
                        try {
                          await onAction!();
                        } catch (_) {
                          if (context.mounted) {
                            AppSnackbar.error(context, 'action_failed'.tr);
                          }
                        }
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(48, 48),
                  textStyle: AppTextStyles.resolve(
                    context,
                    AppTextStyles.button,
                  ).copyWith(fontSize: 12),
                ),
                child: Text(actionLabel!, textAlign: TextAlign.center),
              ),
            ),
          ],
        );
      }
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
