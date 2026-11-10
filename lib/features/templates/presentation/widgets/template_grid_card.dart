import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../data/models/template_model.dart';
import '../../../../shared_widgets/index.dart';
import 'template_mini_preview.dart';

/// Document preview card with a larger inspection sheet before selection.
class TemplateGridCard extends StatelessWidget {
  const TemplateGridCard({
    super.key,
    required this.template,
    required this.onSelect,
  });
  final TemplateModel template;
  final Future<void> Function() onSelect;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .65)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('preview-template-${template.id}'),
              onTap: () =>
                  TemplateMiniPreview.show(context, template, onSelect),
              child: Container(
                width: double.infinity,
                color: scheme.surfaceContainerLow,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: TemplateMiniPreview(
                  templateId: template.id,
                  previewImage: template.previewImage,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  template.localizedName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.resolve(context, AppTextStyles.label),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  template.localizedDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.caption,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: AppRadii.chip,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        template.type == 'ats'
                            ? 'ATS'
                            : 'template_category_${template.type}'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.resolve(
                          context,
                          AppTextStyles.caption,
                        ).copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  key: ValueKey('select-template-${template.id}'),
                  label: 'use_template'.tr,
                  fullWidth: true,
                  size: AppButtonSize.sm,
                  onPressed: onSelect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
