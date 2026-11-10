import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/ats_scorer.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../data/models/skill.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/skill_level_indicator.dart';
import '../../../../app/theme/index.dart';

/// Adds and edits distinct skills with localized, accessible five-level ratings.
class SkillsStep extends StatefulWidget {
  const SkillsStep({super.key});
  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  final _resumes = Get.find<ResumeController>();
  final _name = TextEditingController();
  final _scroll = ScrollController();
  var _form = GlobalKey<FormState>();
  int _level = 3;
  int? _editing;
  ResumeModel? _editingResume;
  String? _error;
  void _reset() {
    _name.clear();
    setState(() {
      _form = GlobalKey<FormState>();
      _level = 3;
      _editing = null;
      _editingResume = null;
      _error = null;
    });
  }

  String? _validate(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'builder_skill_required'.tr;
    final skills = _resumes.currentResume.value?.skills ?? [];
    for (var index = 0; index < skills.length; index++) {
      if (index != _editing &&
          AtsScorer.normalize(skills[index].name) ==
              AtsScorer.normalize(name)) {
        return 'builder_skill_duplicate'.tr;
      }
    }
    return null;
  }

  void _save() {
    final target = _resumes.currentResume.value;
    if (target == null) return;
    if (_editing != null &&
        (!identical(target, _editingResume) ||
            _editing! >= target.skills.length)) {
      setState(() => _error = 'builder_entry_changed');
      return;
    }
    if (!_form.currentState!.validate()) return;
    final skill = Skill(name: _name.text.trim(), level: _level);
    if (_editing == null) {
      target.skills.add(skill);
    } else {
      target.skills[_editing!] = skill;
    }
    _resumes.currentResume.refresh();
    _reset();
  }

  void _edit(int index) {
    final target = _resumes.currentResume.value;
    if (target == null || index < 0 || index >= target.skills.length) return;
    final skill = target.skills[index];
    _name.text = skill.name;
    setState(() {
      _form = GlobalKey<FormState>();
      _editing = index;
      _editingResume = target;
      _level = skill.level.clamp(1, 5);
      _error = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Color _levelColor(int level) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (level.clamp(1, 5)) {
      1 => dark ? AppColors.errorLight : AppColors.errorForeground,
      2 => dark ? AppColors.accent : AppColors.warningForeground,
      3 => dark ? AppColors.primaryLight : AppColors.infoForeground,
      4 => Theme.of(context).colorScheme.primary,
      _ => dark ? AppColors.secondaryLight : AppColors.successForeground,
    };
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final target = _resumes.currentResume.value;
    final skills = target?.skills ?? <Skill>[];
    return SingleChildScrollView(
      controller: _scroll,
      key: const PageStorageKey('skills-scroll'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      key: const ValueKey('skill-name'),
                      controller: _name,
                      label: 'skill_name'.tr,
                      validator: _validate,
                      autovalidateMode: AutovalidateMode.disabled,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '${'skill_level'.tr}: ${'builder_skill_level_$_level'.tr} ($_level/5)',
                    ),
                    Slider(
                      key: const ValueKey('skill-level'),
                      value: _level.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: 'builder_skill_level_$_level'.tr,
                      semanticFormatterCallback: (value) =>
                          'builder_skill_level_${value.round()}'.tr,
                      onChanged: (value) =>
                          setState(() => _level = value.round()),
                    ),
                    SkillLevelIndicator(name: 'skill_level'.tr, level: _level),
                    const SizedBox(height: AppSpacing.lg),
                    if (_error != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!.tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    AppButton(
                      key: const ValueKey('save-skill'),
                      label: (_editing == null ? 'add_skill' : 'save').tr,
                      icon: _editing == null ? Icons.add : Icons.save_outlined,
                      fullWidth: true,
                      onPressed: _save,
                    ),
                    if (_editing != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        key: const ValueKey('cancel-skill-edit'),
                        label: 'cancel'.tr,
                        variant: AppButtonVariant.text,
                        fullWidth: true,
                        onPressed: _reset,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (skills.isEmpty)
            AppEmptyState(
              title: 'no_skills_added'.tr,
              icon: Icons.psychology_outlined,
            ),
          for (var index = 0; index < skills.length; index++)
            ResumeEntryCard(
              entryKey: 'skill-$index',
              title: skills[index].name,
              details: [
                '${'builder_skill_level_${skills[index].level.clamp(1, 5)}'.tr} (${skills[index].level}/5)',
              ],
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(
                      '${skills[index].level}/5',
                      style: AppTextStyles.resolve(
                        context,
                        AppTextStyles.label,
                      ).copyWith(color: _levelColor(skills[index].level)),
                    ),
                    avatar: Icon(
                      Icons.bolt_outlined,
                      size: AppSpacing.icon,
                      color: _levelColor(skills[index].level),
                    ),
                    backgroundColor: _levelColor(
                      skills[index].level,
                    ).withValues(alpha: .12),
                    side: BorderSide(color: _levelColor(skills[index].level)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SkillLevelIndicator(
                    name: skills[index].name,
                    level: skills[index].level,
                  ),
                ],
              ),
              onEdit: () => _edit(index),
              onDelete: () {
                target!.skills.removeAt(index);
                _resumes.currentResume.refresh();
                _reset();
              },
            ),
        ],
      ),
    );
  });
  @override
  void dispose() {
    _name.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
