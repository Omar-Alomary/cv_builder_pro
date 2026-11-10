import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/language.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits language proficiency while retaining imported custom levels.
class ResumeLanguageDialog extends StatefulWidget {
  const ResumeLanguageDialog({super.key, this.language});
  final Language? language;
  static const levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Fluent',
    'Native',
  ];
  static String levelLabel(String level) => levels.contains(level)
      ? 'builder_language_${level.toLowerCase()}'.tr
      : level;
  @override
  State<ResumeLanguageDialog> createState() => _ResumeLanguageDialogState();
}

class _ResumeLanguageDialogState extends State<ResumeLanguageDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.language?.name ?? '');
  late String _level = widget.language?.level ?? 'Intermediate';
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(Language(name: _name.text.trim(), level: _level));
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.translate,
    title: (widget.language == null ? 'add_language' : 'edit_language').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            key: const ValueKey('language-name'),
            controller: _name,
            label: 'language_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'language_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('proficiency_level'.tr),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final level in {...ResumeLanguageDialog.levels, _level})
                ChoiceChip(
                  key: ValueKey('language-level-$level'),
                  label: Text(ResumeLanguageDialog.levelLabel(level)),
                  selected: _level == level,
                  onSelected: (_) => setState(() => _level = level),
                ),
            ],
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }
}
