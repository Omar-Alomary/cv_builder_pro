import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/resume_import_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/index.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Editable full-schema JSON preview that validates before saving a new resume.
class ImportPreviewWidget extends StatefulWidget {
  const ImportPreviewWidget({
    super.key,
    required this.resume,
    required this.onSave,
    required this.onDiscard,
  });
  final ResumeModel resume;
  final Future<void> Function(ResumeModel) onSave;
  final VoidCallback onDiscard;
  @override
  State<ImportPreviewWidget> createState() => _ImportPreviewWidgetState();
}

class _ImportPreviewWidgetState extends State<ImportPreviewWidget> {
  late final _json = TextEditingController(
    text: ResumeJson.encode(widget.resume),
  );
  @override
  void dispose() {
    _json.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: 'import_preview'.tr,
            subtitle: 'import_preview_description'.tr,
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppAvatar(
              name: widget.resume.fullName,
              size: AppSpacing.xxxl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.resume.fullName.isEmpty
                ? 'untitled_resume'.tr
                : widget.resume.fullName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.resume.email.isNotEmpty)
            Text(widget.resume.email, textDirection: TextDirection.ltr),
          Text(
            'import_section_counts'.trParams({
              'education': '${widget.resume.education.length}',
              'experience': '${widget.resume.experience.length}',
              'skills': '${widget.resume.skills.length}',
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('import-preview-json'),
            controller: _json,
            label: 'import_edit_json'.tr,
            maxLines: 16,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const ValueKey('save-imported-resume'),
            label: 'import_save_edit'.tr,
            icon: Icons.save_outlined,
            fullWidth: true,
            onPressed: () async {
              try {
                final resume = ResumeImportService().fromJsonText(_json.text);
                if (resume.fullName.trim().isEmpty) {
                  AppSnackbar.warning(context, 'import_name_required'.tr);
                  return;
                }
                await widget.onSave(resume);
              } on ImportException catch (error) {
                if (context.mounted) {
                  AppSnackbar.error(context, error.messageKey.tr);
                }
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'import_discard'.tr,
            onPressed: widget.onDiscard,
            fullWidth: true,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    ),
  );
}
