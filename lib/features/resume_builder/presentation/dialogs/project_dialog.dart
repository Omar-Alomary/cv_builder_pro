import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/project.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits project dates, current status, description and technologies in isolation.
class ProjectDialog extends StatefulWidget {
  const ProjectDialog({super.key, this.project});
  final Project? project;
  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.project?.name ?? '');
  late final _technologies = TextEditingController(
    text: widget.project?.technologies.join('\n') ?? '',
  );
  late final _start = TextEditingController(
    text: widget.project?.startDate ?? '',
  );
  late final _end = TextEditingController(text: widget.project?.endDate ?? '');
  late final _description = TextEditingController(
    text: widget.project?.description ?? '',
  );
  late bool _current = widget.project?.isCurrent ?? false;
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Project(
        name: _title.text.trim(),
        technologies: _technologies.text
            .split('\n')
            .map((v) => v.trim())
            .where((v) => v.isNotEmpty)
            .toList(),
        startDate: DateFormatter.monthYear(
          DateFormatter.parseMonthYear(_start.text)!,
        ),
        endDate: _current
            ? null
            : DateFormatter.monthYear(DateFormatter.parseMonthYear(_end.text)!),
        isCurrent: _current,
        description: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.code,
    title: (widget.project == null ? 'add_project' : 'edit_project').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('project-title'),
            controller: _title,
            label: 'project_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'project_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('project-start'),
            controller: _start,
            label: 'start_date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            key: const ValueKey('project-current'),
            contentPadding: EdgeInsets.zero,
            title: Text('current_project'.tr),
            value: _current,
            onChanged: (value) => setState(() => _current = value ?? false),
          ),
          if (!_current) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              key: const ValueKey('project-end'),
              controller: _end,
              label: 'end_date'.tr,
              hint: 'MM/YYYY',
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.datetime,
              validator: (value) =>
                  Validators.validateEndDate(value, startDate: _start.text),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('project-description'),
            controller: _description,
            label: 'description'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'description'.tr),
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('project-technologies'),
            controller: _technologies,
            label: 'technologies_used'.tr,
            helperText: 'builder_technology_lines'.tr,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_title, _technologies, _start, _end, _description]) {
      control.dispose();
    }
    super.dispose();
  }
}
