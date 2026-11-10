import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/course.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits every course field in isolation until the user saves.
class CourseDialog extends StatefulWidget {
  const CourseDialog({super.key, this.course});
  final Course? course;
  @override
  State<CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<CourseDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.course?.name ?? '');
  late final _provider = TextEditingController(
    text: widget.course?.provider ?? '',
  );
  late final _year = TextEditingController(text: widget.course?.year ?? '');
  late final _certificateUrl = TextEditingController(
    text: widget.course?.certificateUrl ?? '',
  );
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Course(
        name: _name.text.trim(),
        provider: _provider.text.trim(),
        year: DateFormatter.normalizeDigits(_year.text.trim()),
        certificateUrl: (_certificateUrl.text.trim().isEmpty
            ? null
            : _certificateUrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.menu_book_outlined,
    title: (widget.course == null ? 'add_course' : 'edit_course').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('course-name'),
            controller: _name,
            label: 'course_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'course_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('course-provider'),
            controller: _provider,
            label: 'provider'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'provider'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('course-year'),
            controller: _year,
            label: 'year'.tr,
            validator: Validators.validateYear,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            hint: 'YYYY',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('course-certificateUrl'),
            controller: _certificateUrl,
            label: 'builder_certificate_url'.tr,
            validator: Validators.validateUrl,
            keyboardType: TextInputType.url,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_name, _provider, _year, _certificateUrl]) {
      control.dispose();
    }
    super.dispose();
  }
}
