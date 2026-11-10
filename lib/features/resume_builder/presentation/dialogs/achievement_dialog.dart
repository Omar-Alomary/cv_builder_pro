import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/achievement.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits all achievement fields, including imported custom categories.
class AchievementDialog extends StatefulWidget {
  const AchievementDialog({super.key, this.achievement});
  final Achievement? achievement;
  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.achievement?.name ?? '',
  );
  late final _description = TextEditingController(
    text: widget.achievement?.description ?? '',
  );
  late final _date = TextEditingController(
    text: widget.achievement?.date ?? '',
  );
  late final _organization = TextEditingController(
    text: widget.achievement?.organization ?? '',
  );
  late final _category = TextEditingController(
    text: widget.achievement?.category ?? '',
  );
  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Achievement(
        name: _name.text.trim(),
        description: _description.text.trim(),
        date: DateFormatter.monthYear(
          DateFormatter.parseMonthYear(_date.text)!,
        ),
        organization: _optional(_organization.text),
        category: _optional(_category.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.emoji_events_outlined,
    title: (widget.achievement == null ? 'add_achievement' : 'edit_achievement')
        .tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('achievement-name'),
            controller: _name,
            label: 'achievement_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'achievement_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-category'),
            controller: _category,
            label: 'category'.tr,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-organization'),
            controller: _organization,
            label: 'organization'.tr,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-date'),
            controller: _date,
            label: 'date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-description'),
            controller: _description,
            label: 'description'.tr,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            validator: (value) =>
                Validators.validateRequired(value, 'description'.tr),
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [
      _name,
      _description,
      _date,
      _organization,
      _category,
    ]) {
      control.dispose();
    }
    super.dispose();
  }
}
