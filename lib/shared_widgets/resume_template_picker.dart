import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resume_controller.dart';
import '../controllers/template_controller.dart';
import '../core/utils/app_snackbar.dart';
import '../data/models/resume_model.dart';
import '../features/templates/presentation/widgets/template_mini_preview.dart';
import 'app_bottom_sheet.dart';

/// Shared template chooser preserving every field and committing only on success.
abstract final class ResumeTemplatePicker {
  static bool _open = false;

  static Future<bool> show(BuildContext context, ResumeModel resume) async {
    if (_open) return false;
    _open = true;
    try {
      final id = await AppBottomSheet.show<String>(
        context: context,
        title: 'change_template'.tr,
        icon: Icons.palette_outlined,
        builder: (sheetContext) => LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 360 ? 2 : 3;
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final templates = Get.find<TemplateController>().templates;
            return GridView.builder(
              key: const ValueKey('change-template-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: templates.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 190 + (scale - 1).clamp(0, 4) * 100,
              ),
              itemBuilder: (context, index) {
                final template = templates[index];
                final selected = template.id == resume.templateId;
                final scheme = Theme.of(context).colorScheme;
                return Semantics(
                  selected: selected,
                  button: true,
                  child: Material(
                    color: scheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: selected
                            ? scheme.primary
                            : scheme.outlineVariant,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: ValueKey('change-template-${template.id}'),
                      onTap: () => Navigator.of(sheetContext).pop(template.id),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                TemplateMiniPreview(
                                  templateId: template.id,
                                  previewImage: template.previewImage,
                                ),
                                if (selected)
                                  Align(
                                    alignment: AlignmentDirectional.topEnd,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: scheme.primary,
                                        semanticLabel: 'current_template'.tr,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${template.localizedName}\n${template.language == 'ar' ? 'العربية' : 'English'}',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
      if (id == null || id == resume.templateId) return false;
      final controller = Get.find<ResumeController>();
      final changed = resume.copyWith(templateId: id);
      if (!await controller.saveResume(changed)) return false;
      if (identical(controller.currentResume.value, resume) ||
          (resume.id != null &&
              controller.currentResume.value?.id == resume.id)) {
        controller.currentResume.value = changed;
      }
      if (context.mounted) AppSnackbar.success(context, 'template_changed'.tr);
      return true;
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, 'action_failed'.tr);
      return false;
    } finally {
      _open = false;
    }
  }
}
