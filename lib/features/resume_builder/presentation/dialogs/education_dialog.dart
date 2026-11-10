import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/education.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits all education fields without changing the source until confirmed.
class EducationDialog extends StatefulWidget {
  const EducationDialog({super.key, this.education});
  final Education? education;
  @override
  State<EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<EducationDialog> {
  final _form = GlobalKey<FormState>();
  late final _degree = TextEditingController(
    text: widget.education?.degree ?? '',
  );
  late final _institution = TextEditingController(
    text: widget.education?.institution ?? '',
  );
  late final _year = TextEditingController(text: widget.education?.year ?? '');
  late final _grade = TextEditingController(
    text: widget.education?.grade ?? '',
  );
  late final _description = TextEditingController(
    text: widget.education?.description ?? '',
  );
  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Education(
        degree: _degree.text.trim(),
        institution: _institution.text.trim(),
        year: DateFormatter.normalizeDigits(_year.text.trim()),
        grade: _optional(_grade.text),
        description: _optional(_description.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.school_outlined,
    title: (widget.education == null ? 'add_education' : 'edit_education').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('education-degree'),
            controller: _degree,
            label: 'degree'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'degree'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-institution'),
            controller: _institution,
            label: 'institution'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'institution'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-year'),
            controller: _year,
            label: 'graduation_year'.tr,
            hint: 'YYYY',
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            validator: Validators.validateYear,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-grade'),
            controller: _grade,
            label: 'grade'.tr,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-description'),
            controller: _description,
            label: 'description'.tr,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [
      _degree,
      _institution,
      _year,
      _grade,
      _description,
    ]) {
      control.dispose();
    }
    super.dispose();
  }
}
