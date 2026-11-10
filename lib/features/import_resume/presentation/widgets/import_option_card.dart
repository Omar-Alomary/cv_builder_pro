import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// File format card with recommendation or warning and a working picker action.
class ImportOptionCard extends StatelessWidget {
  const ImportOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    required this.onSelect,
    this.badgeLabel,
    this.recommended = false,
    this.warning = false,
  });
  final String title, description, actionLabel;
  final IconData icon;
  final Future<void> Function()? onSelect;
  final String? badgeLabel;
  final bool recommended, warning;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = recommended
        ? dark
              ? AppColors.secondaryLight
              : AppColors.successForeground
        : warning
        ? dark
              ? AppColors.accent
              : AppColors.warningForeground
        : scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, color: color, size: AppSpacing.xl),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.resolve(context, AppTextStyles.h4),
                      ),
                      if (badgeLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .12),
                            borderRadius: AppRadii.chip,
                          ),
                          child: Text(
                            badgeLabel!,
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.caption,
                            ).copyWith(color: color),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.bodySmall,
              ).copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: actionLabel,
              icon: Icons.upload_file_outlined,
              fullWidth: true,
              variant: recommended
                  ? AppButtonVariant.primary
                  : AppButtonVariant.secondary,
              gradient: recommended ? AppColors.successGradient : null,
              onPressed: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}
