import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/experience.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Validates chronological month/year dates and preserves current employment.
class ExperienceDialog extends StatefulWidget {
  const ExperienceDialog({super.key, this.experience});
  final Experience? experience;
  @override
  State<ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<ExperienceDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.experience?.jobTitle ?? '',
  );
  late final _company = TextEditingController(
    text: widget.experience?.company ?? '',
  );
  late final _start = TextEditingController(
    text: widget.experience?.startDate ?? '',
  );
  late final _end = TextEditingController(
    text: widget.experience?.endDate ?? '',
  );
  late final _description = TextEditingController(
    text: widget.experience?.description ?? '',
  );
  late bool _current = widget.experience?.isCurrent ?? false;
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Experience(
        jobTitle: _title.text.trim(),
        company: _company.text.trim(),
        startDate: DateFormatter.monthYear(
          DateFormatter.parseMonthYear(_start.text)!,
        ),
        endDate: _current
            ? null
            : DateFormatter.monthYear(DateFormatter.parseMonthYear(_end.text)!),
        isCurrent: _current,
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.work_outline,
    title:
        (widget.experience == null ? 'add_experience' : 'edit_experience').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('experience-title'),
            controller: _title,
            label: 'job_title'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'job_title'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('experience-company'),
            controller: _company,
            label: 'company'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'company'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('experience-start'),
            controller: _start,
            label: 'start_date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            key: const ValueKey('experience-current'),
            contentPadding: EdgeInsets.zero,
            title: Text('current_job'.tr),
            value: _current,
            onChanged: (value) => setState(() => _current = value ?? false),
          ),
          if (!_current) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              key: const ValueKey('experience-end'),
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
            key: const ValueKey('experience-description'),
            controller: _description,
            label: 'description'.tr,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_title, _company, _start, _end, _description]) {
      control.dispose();
    }
    super.dispose();
  }
}
