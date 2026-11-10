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
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final inline =
                constraints.maxWidth >= 240 &&
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDestructive
                              ? scheme.errorContainer
                              : scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Icon(icon, color: foreground, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                                  fontSize: 14,
                                  color: isDestructive
                                      ? scheme.error
                                      : scheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle,
                            style:
                                AppTextStyles.resolve(
                                  context,
                                  AppTextStyles.bodySmall,
                                ).copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
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
                  const SizedBox(height: 8),
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
