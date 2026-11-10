# Part 2 — الدفعة الحادية والعشرون: المشاريع والإنجازات والاهتمامات
طُبقت الملفات التالية في المشروع. المشاريع: إضافة وتعديل وحذف وإلغاء، التحقق من ترتيب تواريخ MM/YYYY وتطبيع الأرقام العربية، مشروع مستمر، وصف وتقنيات قابلة للتحرير (كل تقنية في سطر مستقل؛ الفواصل داخل الاسم محفوظة). الإنجازات: الاسم والوصف والتاريخ والجهة والتصنيف المخصّص دون إسقاط حقول عند التعديل. الاهتمامات: اقتراحات مترجمة مع حفظ القيم المتوافقة مع JSON، إضافة اهتمام مخصّص ومنع التكرار وتعديل وإلغاء وحذف.
اختُبرت العربية والوضع الليلي وتكبير النص إلى الضعف عند 320×900 و800×400 و1920×900، وحدود عرض الحوارات 500/600/650. اختبارات الدفعة 12 اختباراً. الكود المفصول والاختبارات اجتازا التحليل الساكن دون ملاحظات. ما زال فصل المعاينة والتخصيص وقوالب PDF الأربعة المتبقية مطلوباً في الدفعات التالية؛ لم يُختبر تشغيل فعلي على جهاز في هذه الدفعة.
## الملفات
1. lib/features/resume_builder/presentation/steps/projects_step.dart
2. lib/features/resume_builder/presentation/steps/achievements_step.dart
3. lib/features/resume_builder/presentation/steps/interests_step.dart
4. lib/features/resume_builder/presentation/dialogs/project_dialog.dart
5. lib/features/resume_builder/presentation/dialogs/achievement_dialog.dart
6. lib/features/resume_builder/presentation/steps/additional_info_step.dart
7. lib/features/resume_builder/index.dart
8. lib/translations/en_us.dart
9. lib/translations/ar_sa.dart
10. lib/legacy_app.dart
11. test/resume_builder/projects_achievements_interests_test.dart

## lib/features/resume_builder/presentation/steps/projects_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/project.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/project_dialog.dart';
import '../widgets/resume_entry_card.dart';

/// Project list supporting isolated dialog edits and reactive CRUD updates.
class ProjectsStep extends StatefulWidget {
  const ProjectsStep({super.key});
  @override
  State<ProjectsStep> createState() => _ProjectsStepState();
}

class _ProjectsStepState extends State<ProjectsStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null || (index != null && index >= target.projects.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Project>(
        context: context,
        builder: (_) => ProjectDialog(
          project: index == null ? null : target.projects[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.projects.add(result);
      } else if (index < target.projects.length) {
        target.projects[index] = result;
      }
      _resumes.currentResume.refresh();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final target = _resumes.currentResume.value;
    final entries = target?.projects ?? <Project>[];
    return ListView(
      key: const PageStorageKey('projects-scroll'),
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          key: const ValueKey('add-projects'),
          label: 'add_project'.tr,
          icon: Icons.code,
          fullWidth: true,
          onPressed: _edit,
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          AppEmptyState(title: 'no_projects_added'.tr, icon: Icons.code),
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            entryKey: 'project-$index',
            title: entries[index].name,
            details: [
              entries[index].description,
              '${entries[index].startDate} — ${entries[index].isCurrent ? 'builder_present'.tr : entries[index].endDate ?? ''}',
              entries[index].technologies.join(', '),
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.projects.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}

```

## lib/features/resume_builder/presentation/steps/achievements_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/achievement.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/achievement_dialog.dart';
import '../widgets/resume_entry_card.dart';

/// Achievement list supporting isolated dialog edits and reactive CRUD updates.
class AchievementsStep extends StatefulWidget {
  const AchievementsStep({super.key});
  @override
  State<AchievementsStep> createState() => _AchievementsStepState();
}

class _AchievementsStepState extends State<AchievementsStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null ||
        (index != null && index >= target.achievements.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Achievement>(
        context: context,
        builder: (_) => AchievementDialog(
          achievement: index == null ? null : target.achievements[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.achievements.add(result);
      } else if (index < target.achievements.length) {
        target.achievements[index] = result;
      }
      _resumes.currentResume.refresh();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final target = _resumes.currentResume.value;
    final entries = target?.achievements ?? <Achievement>[];
    return ListView(
      key: const PageStorageKey('achievements-scroll'),
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          key: const ValueKey('add-achievements'),
          label: 'add_achievement'.tr,
          icon: Icons.emoji_events_outlined,
          fullWidth: true,
          onPressed: _edit,
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          AppEmptyState(
            title: 'no_achievements_added'.tr,
            icon: Icons.emoji_events_outlined,
          ),
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            entryKey: 'achievement-$index',
            title: entries[index].name,
            details: [
              entries[index].description,
              entries[index].date,
              entries[index].organization ?? '',
              entries[index].category ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.achievements.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}

```

## lib/features/resume_builder/presentation/steps/interests_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/ats_scorer.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_entry_card.dart';

/// Manages translated suggestions and arbitrary interests without duplicates.
class InterestsStep extends StatefulWidget {
  const InterestsStep({super.key});
  static const suggestions = [
    'Reading',
    'Travel',
    'Music',
    'Sports',
    'Photography',
    'Coding',
    'Art',
    'Gaming',
    'Cooking',
    'Yoga',
    'Chess',
    'Volunteering',
    'Writing',
    'Dancing',
  ];
  @override
  State<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<InterestsStep> {
  final _resumes = Get.find<ResumeController>();
  final _name = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  int? _editing;
  ResumeModel? _editingResume;
  void _reset() {
    _name.clear();
    _form.currentState?.reset();
    setState(() {
      _editing = null;
      _editingResume = null;
    });
  }

  String _normalize(String text) => AtsScorer.normalize(text);
  String _label(String value) => InterestsStep.suggestions.contains(value)
      ? 'builder_interest_${value.toLowerCase()}'.tr
      : value;
  void _add() {
    final target = _resumes.currentResume.value;
    if (target == null || !_form.currentState!.validate()) return;
    final values = [...?target.interests];
    if (_editing != null) {
      if (!identical(target, _editingResume) || _editing! >= values.length) {
        return;
      }
      values[_editing!] = _name.text.trim();
    } else {
      values.add(_name.text.trim());
    }
    target.interests = values;
    _reset();
    _resumes.currentResume.refresh();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final target = _resumes.currentResume.value;
    final interests = target?.interests ?? <String>[];
    return ListView(
      controller: _scroll,
      key: const PageStorageKey('interests-scroll'),
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _form,
          child: AppTextField(
            key: const ValueKey('interest-name'),
            controller: _name,
            label: 'builder_interest_name'.tr,
            autovalidateMode: AutovalidateMode.disabled,
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'builder_interest_required'.tr;
              for (var i = 0; i < interests.length; i++) {
                if (i != _editing &&
                    _normalize(interests[i]) == _normalize(name)) {
                  return 'builder_interest_duplicate'.tr;
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          key: const ValueKey('add-interest'),
          label: (_editing == null ? 'builder_add_interest' : 'save').tr,
          icon: Icons.add,
          fullWidth: true,
          onPressed: _add,
        ),
        if (_editing != null)
          AppButton(
            key: const ValueKey('cancel-interest'),
            label: 'cancel'.tr,
            variant: AppButtonVariant.text,
            fullWidth: true,
            onPressed: _reset,
          ),
        const SizedBox(height: 20),
        Text('builder_interest_suggestions'.tr),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in InterestsStep.suggestions)
              FilterChip(
                key: ValueKey('interest-suggestion-$suggestion'),
                label: Text(_label(suggestion)),
                selected: interests.any(
                  (entry) => _normalize(entry) == _normalize(suggestion),
                ),
                onSelected: (selected) {
                  if (target == null) return;
                  target.interests = selected
                      ? [...interests, suggestion]
                      : interests
                            .where(
                              (entry) =>
                                  _normalize(entry) != _normalize(suggestion),
                            )
                            .toList();
                  _resumes.currentResume.refresh();
                  _reset();
                },
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (interests.isEmpty)
          AppEmptyState(
            title: 'builder_no_interests'.tr,
            icon: Icons.favorite_outline,
          ),
        for (var index = 0; index < interests.length; index++)
          ResumeEntryCard(
            entryKey: 'interest-$index',
            title: _label(interests[index]),
            details: const [],
            onEdit: () {
              _name.text = interests[index];
              setState(() {
                _editing = index;
                _editingResume = target;
              });
              if (_scroll.hasClients) _scroll.jumpTo(0);
            },
            onDelete: () {
              target!.interests = [...interests]..removeAt(index);
              _resumes.currentResume.refresh();
              _reset();
            },
          ),
      ],
    );
  });
  @override
  void dispose() {
    _name.dispose();
    _scroll.dispose();
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/dialogs/project_dialog.dart
```dart
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
          const SizedBox(height: 16),
          AppTextField(
            key: const ValueKey('project-start'),
            controller: _start,
            label: 'start_date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            key: const ValueKey('project-current'),
            contentPadding: EdgeInsets.zero,
            title: Text('current_project'.tr),
            value: _current,
            onChanged: (value) => setState(() => _current = value ?? false),
          ),
          if (!_current) ...[
            const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          AppTextField(
            key: const ValueKey('project-description'),
            controller: _description,
            label: 'description'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'description'.tr),
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
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

```

## lib/features/resume_builder/presentation/dialogs/achievement_dialog.dart
```dart
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
          const SizedBox(height: 16),
          AppTextField(
            key: const ValueKey('achievement-category'),
            controller: _category,
            label: 'category'.tr,
          ),
          const SizedBox(height: 16),
          AppTextField(
            key: const ValueKey('achievement-organization'),
            controller: _organization,
            label: 'organization'.tr,
          ),
          const SizedBox(height: 16),
          AppTextField(
            key: const ValueKey('achievement-date'),
            controller: _date,
            label: 'date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: 16),
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

```

## lib/features/resume_builder/presentation/steps/additional_info_step.dart
```dart
import 'interests_step.dart';
import 'achievements_step.dart';
import 'projects_step.dart';
import 'languages_step.dart';
import 'certificates_step.dart';
import 'courses_step.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/template_fields.dart';
import '../../../../shared_widgets/index.dart';

/// Controlled additional sections with direct selection and reversible navigation.
class AdditionalInfoStep extends StatelessWidget {
  const AdditionalInfoStep({
    super.key,
    required this.fields,
    required this.selectedIndex,
    required this.onSelected,
  });
  final TemplateFields fields;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static List<String> sectionKeys(TemplateFields fields) => [
    if (fields.showCourses) 'courses',
    if (fields.showCertificates) 'certificates',
    if (fields.showLanguages) 'languages',
    if (fields.showProjects) 'projects',
    if (fields.showAchievements) 'achievements',
    if (fields.showInterests) 'interests',
  ];
  @override
  Widget build(BuildContext context) {
    final sections = sectionKeys(fields);
    if (sections.isEmpty) {
      return AppEmptyState(title: 'no_additional_sections'.tr);
    }
    final selected = selectedIndex.clamp(0, sections.length - 1);
    final child = switch (sections[selected]) {
      'courses' => const CoursesStep(),
      'certificates' => const CertificatesStep(),
      'languages' => const LanguagesStep(),
      'projects' => const ProjectsStep(),
      'achievements' => const AchievementsStep(),
      _ => const InterestsStep(),
    };
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              for (var index = 0; index < sections.length; index++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    key: ValueKey('additional-${sections[index]}'),
                    selected: selected == index,
                    label: Text(sections[index].tr),
                    onSelected: (_) => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
        Text(
          'builder_section_position'.trParams({
            'current': '${selected + 1}',
            'total': '${sections.length}',
          }),
        ),
        Expanded(
          child: KeyedSubtree(key: ValueKey(sections[selected]), child: child),
        ),
      ],
    );
  }
}

```

## lib/features/resume_builder/index.dart
```dart
export 'presentation/widgets/resume_json_export_button.dart';
export 'presentation/templates/base_pdf_template.dart';
export 'presentation/templates/ats_pdf_template.dart';
export 'presentation/pages/resume_builder_screen.dart';
export 'presentation/steps/personal_info_step.dart';
export 'presentation/steps/additional_info_step.dart';
export 'presentation/widgets/step_indicator.dart';
export 'presentation/widgets/navigation_buttons.dart';
export 'presentation/steps/education_step.dart';
export 'presentation/steps/experience_step.dart';
export 'presentation/steps/skills_step.dart';
export 'presentation/dialogs/education_dialog.dart';
export 'presentation/dialogs/experience_dialog.dart';
export 'presentation/widgets/resume_form_dialog.dart';
export 'presentation/widgets/resume_entry_card.dart';
export 'presentation/steps/courses_step.dart';
export 'presentation/steps/certificates_step.dart';
export 'presentation/steps/languages_step.dart';
export 'presentation/dialogs/course_dialog.dart';
export 'presentation/dialogs/certificate_dialog.dart';
export 'presentation/dialogs/language_dialog.dart';
export 'presentation/steps/projects_step.dart';
export 'presentation/steps/achievements_step.dart';
export 'presentation/steps/interests_step.dart';
export 'presentation/dialogs/project_dialog.dart';
export 'presentation/dialogs/achievement_dialog.dart';

```

## lib/translations/en_us.dart
```dart
/// English interface messages.
const Map<String, String> enUs = {
  'home': 'Home',
  'templates': 'Templates',
  'favorites': 'Favorites',
  'settings': 'Settings',
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'next': 'Next',
  'previous': 'Previous',
  'finish': 'Finish',
  'preview': 'Preview',
  'view_all': 'View All',
  'success': 'Success',
  'resume_saved': 'Resume saved successfully',
  'resume_deleted': 'Resume deleted successfully',
  'no_resumes_found': 'No resumes found',
  'no_favorites': 'No favorites yet',
  'browse_templates': 'Browse Templates',
  'create_new': 'Create New',
  'recent_activity': 'Recent Activity',
  'featured_templates': 'Featured Templates',
  'use_template': 'Use Template',
  'personal_info': 'Personal Information',
  'education': 'Education',
  'experience': 'Experience',
  'skills': 'Skills',
  'full_name': 'Full Name',
  'email': 'Email',
  'phone': 'Phone',
  'address': 'Address',
  'summary': 'Professional Summary',
  'degree': 'Degree',
  'institution': 'Institution',
  'graduation_year': 'Graduation Year',
  'grade': 'Grade',
  'add_education': 'Add Education',
  'edit_education': 'Edit Education',
  'no_education_added': 'No education added',
  'degree_required': 'Degree is required',
  'institution_required': 'Institution is required',
  'year_required': 'Graduation year is required',
  'job_title': 'Job Title',
  'company': 'Company',
  'start_date': 'Start Date',
  'end_date': 'End Date',
  'current_job': 'Current Job',
  'description': 'Description',
  'add_experience': 'Add Experience',
  'edit_experience': 'Edit Experience',
  'no_experience_added': 'No experience added',
  'job_title_required': 'Job title is required',
  'company_required': 'Company is required',
  'start_date_required': 'Start date is required',
  'skill_name': 'Skill Name',
  'skill_level': 'Skill Level',
  'add_skill': 'Add Skill',
  'no_skills_added': 'No skills added',
  'language': 'Language',
  'change_app_language': 'Change app language',
  'dark_mode': 'Dark Mode',
  'switch_theme': 'Switch between light and dark theme',
  'contact_us': 'Contact Us',
  'share_app': 'Share App',
  'email_required': 'Email is required',
  'invalid_email': 'Please enter a valid email',
  'phone_required': 'Phone number is required',
  'invalid_phone': 'Please enter a valid phone number',
  'is_required': 'is required',
  'create_resume': 'Create Resume',
  'edit_resume': 'Edit Resume',
  'customize_resume': 'Customize Resume',
  'apply_changes': 'Apply Changes',
  'customization_saved': 'Customization saved successfully',
  'failed_to_generate_preview': 'Failed to generate preview',
  'failed_to_export': 'Failed to export PDF',
  'choose_color': 'Choose Color',
  'preview_updated': 'Preview updated successfully',
  'update_preview': 'Update Preview',
  'courses': 'Courses',
  'certificates': 'Certificates',
  'languages': 'Languages',
  'add_course': 'Add Course',
  'add_certificate': 'Add Certificate',
  'add_language': 'Add Language',
  'course_name': 'Course Name',
  'certificate_name': 'Certificate Name',
  'language_name': 'Language Name',
  'provider': 'Provider',
  'organization': 'Organization',
  'proficiency_level': 'Proficiency Level',
  'no_courses_added': 'No courses added',
  'no_certificates_added': 'No certificates added',
  'no_languages_added': 'No languages added',
  'course_name_required': 'Course name is required',
  'provider_required': 'Provider is required',
  'certificate_name_required': 'Certificate name is required',
  'organization_required': 'Organization is required',
  'language_name_required': 'Language name is required',
  'additional_info': 'Additional Info',
  'projects': 'Projects',
  'achievements': 'Achievements',
  'interests': 'Interests',
  'project_name': 'Project Name',
  'achievement': 'Achievement',
  'no_projects_added': 'No projects added',
  'no_achievements_added': 'No achievements added',
  'no_additional_sections': 'No additional sections available',
  'your_selected_interests': 'Your Selected Interests:',
  'select_interests': 'Select Your Interests',
  'linkedin': 'LinkedIn',
  'github': 'GitHub',
  'website': 'Website',
  'portfolio': 'Portfolio',
  'profile_image_updated': 'Profile image updated successfully',
  'clear_cache': 'Clear Cache',
  'clear_cache_description': 'Remove temporary files and free up space',
  'clear_cache_confirmation': 'Are you sure you want to clear cache?',
  'cache_cleared': 'Cache cleared successfully',
  'cache_clear_failed': 'Failed to clear cache',
  'data': 'Data',
  'about': 'About',
  'app_version': 'App Version',
  'version_1_0_0': 'Version 1.0.0',
  'exit_app': 'Exit App',
  'exit_confirmation': 'Are you sure you want to exit?',
  'exit': 'Exit',
  'yes': 'Yes',
  'no': 'No',
  'logged_out': 'Logged out',
  'come_back_soon': 'We hope to see you again soon!',
  'logout_confirmation': 'Are you sure you want to logout?',
  'professional_resume_builder': 'Professional Resume Builder',
  'appearance': 'Appearance',
  'data_management': 'Data Management',
  'support': 'Support',
  'get_help_support': 'Get help and support',
  'rate_app': 'Rate App',
  'rate_us_on_store': 'Rate us on the store',
  'share_with_friends': 'Share with friends',
  'cannot_open_email': 'Cannot open email client',
  'select_language': 'Select Language',
  'add_project': 'Add Project',
  'edit_project': 'Edit Project',
  'current_project': 'Current Project',
  'technologies_used': 'Technologies Used',
  'add_technology': 'Add Technology',
  'project_name_required': 'Project name is required',
  'description_required': 'Description is required',
  'achievement_name': 'Achievement Name',
  'achievement_name_required': 'Achievement name is required',
  'category': 'Category',
  'date_required': 'Date is required',
  'add_achievement': 'Add Achievement',
  'edit_achievement': 'Edit Achievement',
  'cache_cleared_completely': 'Cache cleared completely',
  'clear_all_data': 'Clear All Data',
  'clear_all_data_confirmation':
      'This will delete ALL your resumes and settings. This action cannot be undone. Are you sure?',
  'clear_all': 'Clear All',
  'all_data_cleared': 'All data cleared successfully',
  'clear_all_data_failed': 'Failed to clear all data',
  'close': 'Close',
  'date': 'Date',
  'year': 'Year',
  'error': 'Error',
  'retry': 'Retry',
  'featured': 'Featured',
  'logout': 'Log out',
  'my_skills': 'My skills',
  'resumes': 'Resumes',
  'edit_certificate': 'Edit certificate',
  'edit_course': 'Edit course',
  'edit_language': 'Edit language',
  'app_name': 'CV Builder Pro',
  'search_templates': 'Search templates',
  'search': 'Search',
  'no_search_results': 'No matching results',
  'search_hint': 'Search by name or description',
  'total_resumes': 'Total resumes',
  'favorite_resumes': 'Favorite resumes',
  'available_templates': 'Available templates',
  'saving': 'Saving…',
  'auto_saved': 'Saved automatically',
  'last_saved': 'Last saved: @time',
  'save_failed': 'Could not save your changes. Try again.',
  'loading': 'Loading…',
  'please_wait': 'Please wait',
  'storage_error':
      'Storage operation failed. Check device storage and try again.',
  'startup_error':
      'Local storage could not be opened. Close and reopen the app. If the problem persists, check storage space and app permissions.',
  'field_required': '@field is required',
  'invalid_url': 'Enter a full http(s) URL',
  'invalid_date': 'Use a valid MM/YYYY date',
  'invalid_date_range': 'The end date must not precede the start date',
  'choose_image': 'Choose image',
  'remove_image': 'Remove image',
  'delete_resume_confirmation': 'Delete this resume?',
  'select_resume': 'Select a resume',
  'export_json': 'Export JSON',
  'export_pdf': 'Export PDF',
  'share_json': 'Share JSON',
  'share_pdf': 'Share PDF',
  'print_pdf': 'Print PDF',
  'import_json': 'Import JSON',
  'import_pdf': 'Import PDF',
  'import_txt': 'Import TXT',
  'recommended': 'Recommended',
  'choose_file': 'Choose file',
  'paste_json': 'Paste JSON',
  'paste_json_hint': 'Paste the complete resume JSON here',
  'json_import_description':
      'Restores all fields from a compatible resume JSON file.',
  'pdf_import_description':
      'Attempts to extract text from supported text-based PDF files. Scanned PDFs require OCR.',
  'txt_import_description':
      'Extracts recognizable contact details and text for review.',
  'import_success': 'Resume imported successfully',
  'import_failed': 'Could not import this file. Check its format and contents.',
  'import_cancelled': 'No file selected',
  'unsupported_file': 'This file type is not supported',
  'file_too_large': 'The file exceeds the 10 MB import limit',
  'invalid_json': 'The JSON structure or field types are invalid',
  'pdf_import_unsupported':
      'Text could not be extracted from this PDF. Try JSON or TXT.',
  'review_before_save':
      'Review and correct the imported information before saving.',
  'save_and_edit': 'Save and edit',
  'export_success': 'Export completed',
  'export_failed': 'Could not export the resume',
  'export_cancelled': 'Export cancelled',
  'export_quality': 'Export quality',
  'quality_standard': 'Standard',
  'quality_high': 'High',
  'customization': 'Customization',
  'font_family': 'Font',
  'font_size': 'Font size',
  'primary_color': 'Primary color',
  'secondary_color': 'Secondary color',
  'ats_checker': 'ATS checker',
  'ats_score': 'ATS score',
  'ats_score_out_of': '@score out of 100',
  'ats_recheck': 'Check again',
  'ats_use_template': 'Use ATS template',
  'ats_edit_resume': 'Go to edit',
  'ats_issues': 'Issues',
  'ats_suggestions': 'Suggestions',
  'ats_missing_keywords': 'Missing keywords',
  'ats_no_issues': 'No issues found by these checks',
  'ats_no_resume': 'Select or create a resume to start the check',
  'ats_checking': 'Analyzing resume…',
  'ats_guidance':
      'This is a rule-based guide, not a guarantee of acceptance by recruiting systems.',
  'ats_formatting_note':
      'Formatting checks use the configured template, not a parsed exported PDF.',
  'ats_template_applied': 'ATS template saved',
  'ats_section_contact': 'Contact',
  'ats_section_summary': 'Summary',
  'ats_section_experience': 'Experience',
  'ats_section_education': 'Education',
  'ats_section_skills': 'Skills',
  'ats_section_keywords': 'Keywords',
  'ats_section_formatting': 'Formatting',
  'ats_severity_critical': 'Critical',
  'ats_severity_warning': 'Warning',
  'ats_severity_info': 'Information',
  'ats_keyword_teamwork': 'teamwork',
  'ats_keyword_leadership': 'leadership',
  'ats_keyword_communication': 'communication',
  'ats_keyword_problem_solving': 'problem-solving',
  'time_just_now': 'Just now',
  'time_ago': '@count @unit ago',
  'time_in': 'In @count @unit',
  'time_minute': 'minute',
  'time_minutes': 'minutes',
  'time_hour': 'hour',
  'time_hours': 'hours',
  'time_day': 'day',
  'time_days': 'days',
  'ats_issue_name': 'The resume has no name.',
  'ats_fix_name': 'Add your full name.',
  'ats_issue_email': 'Email is missing or invalid.',
  'ats_fix_email': 'Add a valid email address.',
  'ats_issue_phone': 'Phone is missing or invalid.',
  'ats_fix_phone': 'Add a valid phone number.',
  'ats_issue_linkedin': 'A valid LinkedIn URL is missing.',
  'ats_fix_linkedin': 'Add your full LinkedIn profile URL.',
  'ats_issue_website': 'A website or portfolio URL is missing.',
  'ats_fix_website': 'Add a relevant website or portfolio URL.',
  'ats_issue_summary_missing': 'Professional summary is missing.',
  'ats_fix_summary_missing': 'Write a concise professional summary.',
  'ats_issue_summary_length': 'Summary length is outside 50–300 characters.',
  'ats_fix_summary_length': 'Keep the summary between 50 and 300 characters.',
  'ats_issue_summary_keywords': 'The summary lacks recognized job keywords.',
  'ats_fix_summary_keywords': 'Include relevant skills in the summary.',
  'ats_issue_experience_missing':
      'No complete work experience entry was found.',
  'ats_fix_experience_missing':
      'Add relevant work, internship or volunteer experience.',
  'ats_issue_experience_actions':
      'Experience descriptions lack recognized action verbs.',
  'ats_fix_experience_actions':
      'Describe achievements with verbs such as developed or led.',
  'ats_issue_experience_dates':
      'Experience dates are missing, invalid or in the future.',
  'ats_fix_experience_dates':
      'Use MM/YYYY dates and mark ongoing positions as current.',
  'ats_issue_education_missing':
      'Education is missing a degree or institution.',
  'ats_fix_education_missing': 'Add your degree and institution.',
  'ats_issue_education_year': 'A valid graduation year is missing.',
  'ats_fix_education_year':
      'Add a four-digit graduation or expected graduation year.',
  'ats_issue_skills_minimum': 'Fewer than five distinct skills were found.',
  'ats_fix_skills_minimum': 'Add at least five relevant distinct skills.',
  'ats_issue_skills_count': 'Fewer than ten distinct skills were found.',
  'ats_fix_skills_count':
      'Add more relevant skills where supported by your experience.',
  'ats_issue_skills_diversity':
      'A mix of recognized technical and interpersonal skills was not found.',
  'ats_fix_skills_diversity':
      'Include both technical and interpersonal skills you actually use.',
  'ats_issue_keywords_missing':
      'Common transferable skill keywords were not found.',
  'ats_fix_keywords_missing':
      'Mention relevant teamwork, leadership, communication or problem-solving experience.',
  'ats_issue_placeholders': 'Placeholder text requiring review was found.',
  'ats_fix_placeholders':
      'Replace placeholder text with your own verified information.',
  'ats_issue_photo': 'The configured output includes a photo.',
  'ats_fix_photo': 'Use the ATS template to omit the photo from the output.',
  'ats_issue_font': 'The selected font is not in the simple-font list.',
  'ats_fix_font': 'Choose Cairo or Poppins, or use the ATS template.',
  'ats_issue_columns':
      'A single-column layout is not confirmed for this configuration.',
  'ats_fix_columns': 'Use the single-column ATS template.',
  'ats_select_resume': 'Select or create a resume before analyzing.',
  'ats_analysis_failed':
      'The resume could not be analyzed. Check its data and try again.',
  'ats_save_failed': 'The ATS template could not be saved.',
  'ats_apply_failed': 'The ATS template could not be applied.',
  'action_failed': 'The action could not be completed. Try again.',
  'splash_tagline': 'Create your professional resume',
  'splash_preparing': 'Getting ready…',
  'language_selection_title': 'Choose your language',
  'language_selection_subtitle':
      'Select your preferred language. You can change it later in settings.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'United States',
  'country_sa': 'Saudi Arabia',
  'select_english': 'Select English',
  'select_arabic': 'Select Arabic',
  'switch_to_english': 'Use the app in English',
  'switch_to_arabic': 'Use the app in Arabic',
  'home_welcome': 'Welcome back!',
  'home_empty_description': 'Start by creating your first professional resume.',
  'home_templates_description': 'Choose from our professional designs.',
  'home_recent_description': 'Your latest saved resumes and changes.',
  'show_recent': 'Show recent',
  'untitled_resume': 'Untitled resume',
  'no_templates_available': 'No templates are available',
  'template_position': '@current of @total',
  'add_favorite': 'Add to favorites',
  'remove_favorite': 'Remove from favorites',
  'tip_action_verbs': 'Use action verbs to describe your achievements.',
  'tip_tailor_resume': 'Tailor your resume for each job application.',
  'tip_resume_length': 'Keep your resume concise and relevant.',
  'tip_relevant_skills': 'Highlight your most relevant skills and experience.',
  'tip_job_keywords': 'Use relevant keywords from the job description.',
  'clear_template_search': 'Clear search',
  'reset_template_filters': 'Reset filters',
  'template_category_all': 'All',
  'template_category_ats': 'ATS',
  'template_category_business': 'Business',
  'template_category_classic': 'Classic',
  'template_category_modern': 'Modern',
  'template_category_technical': 'Technical',
  'favorite_remove_confirmation':
      'Remove "@name" from favorites? The resume will remain saved.',
  'favorites_empty_description':
      'Add your saved resumes to favorites to find them here.',
  'favorites_empty_title': 'No favorites yet',
  'search_favorites': 'Search favorites',
  'change_profile_image': 'Change profile photo',
  'profile_image_failed':
      'Could not select or save the profile photo. Please try again.',
  'settings_data_description':
      'Delete all saved resumes, favorites, profile and preferences.',
  'settings_exit_confirmation':
      'Exit the app and clear the current draft and profile photo preference? Saved resumes will remain.',
  'share_app_message': 'Create professional resumes with CV Builder Pro.',
  'import_discard': 'Discard preview',
  'import_edit_json': 'Editable resume JSON',
  'import_empty': 'The file contains no text.',
  'import_extension_mismatch':
      'The selected file does not match the requested format.',
  'import_invalid_json':
      'Invalid resume JSON. Use an object with fullName as text and correctly typed resume fields.',
  'import_invalid_pdf': 'This PDF is damaged or unsupported.',
  'import_json_description':
      'Preserves every resume section. Select a UTF-8 or UTF-16 JSON file, up to 10 MB.',
  'import_json_title': 'JSON — recommended',
  'import_loading': 'Reading and checking your resume…',
  'import_name_required': 'Enter a full name before saving.',
  'import_paste_json': 'Or paste resume JSON',
  'import_pdf_description':
      'Supports simple ASCII text PDFs, including Flate streams. Scans, encrypted PDFs and encoded fonts are unsupported. Review the extracted content.',
  'import_pdf_encrypted': 'Password-protected PDF files cannot be imported.',
  'import_pdf_font_unsupported':
      'This PDF uses unsupported font encoding. Import JSON or copy its text to a UTF-8 TXT file.',
  'import_pdf_no_text':
      'No supported PDF text was found. Scanned PDFs require OCR; use JSON or TXT instead.',
  'import_pdf_title': 'PDF — basic text only',
  'import_preview': 'Preview import',
  'import_preview_description':
      'Edit any field in the full JSON below, then save a new copy and continue editing. Foreign IDs, favorites and image paths are reset.',
  'import_preview_empty': 'Your import preview appears here',
  'import_preview_empty_description':
      'Choose a file or paste JSON. Nothing is saved until you confirm.',
  'import_read_failed':
      'Could not read the file. Check access permissions and try again.',
  'import_resume': 'Import resume',
  'import_save_edit': 'Save and continue editing',
  'import_section_counts':
      'Education: @education • Experience: @experience • Skills: @skills',
  'import_select_file': 'Select @format file',
  'import_text_encoding': 'Save the text file using UTF-8 or UTF-16 encoding.',
  'import_too_large':
      'The file is larger than 10 MB or its decompressed content exceeds the safe limit.',
  'import_txt_description':
      'Extracts name, email, phone, links and comma-separated skills. Keeps the complete text in Summary for manual review.',
  'import_txt_title': 'TXT',
  'import_unsupported': 'Choose a JSON, PDF or TXT file.',
  'export_json_description':
      'Save or share a complete JSON copy, including all sections and customization. You can import it again later. Photo paths are references, not embedded images.',
  'export_json_extension': 'Choose a filename ending in .json.',
  'export_json_invalid':
      'The resume contains data that cannot be exported as JSON.',
  'export_json_save': 'Save JSON file',
  'export_json_save_failed':
      'Could not save JSON. Check the selected location and available space.',
  'export_json_saved': 'JSON file saved successfully.',
  'export_json_share': 'Share JSON file',
  'export_json_share_failed':
      'Could not share JSON. Check that a sharing application is available.',
  'export_json_shared': 'JSON file sent to the share panel.',
  'export_json_too_large':
      'This JSON exceeds the 10 MB import limit. Reduce its content before exporting.',
  'export_no_resume': 'Open or create a resume before exporting.',
  'ats_choose_resume': 'Choose a saved resume',
  'builder_fix_personal':
      'Check your name, email, phone and any profile links before continuing.',
  'builder_new_draft': 'New draft',
  'builder_remove_photo': 'Remove photo',
  'builder_save_close': 'Save and close',
  'builder_saved': 'Saved',
  'builder_section_position': 'Section @current of @total',
  'builder_unsaved': 'Changes waiting to be saved',
  'builder_entry_changed':
      'The resume changed while editing. Cancel this edit and select the entry again.',
  'builder_future_date': 'The date cannot be later than the current month.',
  'builder_invalid_year':
      'Enter a four-digit year from 1900 to ten years from now.',
  'builder_present': 'Present',
  'builder_skill_duplicate': 'This skill is already listed.',
  'builder_skill_level_1': 'Beginner',
  'builder_skill_level_2': 'Basic',
  'builder_skill_level_3': 'Intermediate',
  'builder_skill_level_4': 'Advanced',
  'builder_skill_level_5': 'Expert',
  'builder_skill_required': 'Enter a skill name.',
  'builder_certificate_url': 'Certificate URL (optional)',
  'builder_credential_id': 'Credential ID (optional)',
  'builder_language_beginner': 'Beginner',
  'builder_language_intermediate': 'Intermediate',
  'builder_language_advanced': 'Advanced',
  'builder_language_fluent': 'Fluent',
  'builder_language_native': 'Native',
  'builder_technology_lines': 'One technology per line.',
  'builder_interest_name': 'Interest',
  'builder_interest_required': 'Enter an interest.',
  'builder_interest_duplicate': 'This interest is already added.',
  'builder_add_interest': 'Add interest',
  'builder_interest_suggestions': 'Suggested interests',
  'builder_no_interests': 'No interests added',
  'builder_interest_reading': 'Reading',
  'builder_interest_travel': 'Travel',
  'builder_interest_music': 'Music',
  'builder_interest_sports': 'Sports',
  'builder_interest_photography': 'Photography',
  'builder_interest_coding': 'Coding',
  'builder_interest_art': 'Art',
  'builder_interest_gaming': 'Gaming',
  'builder_interest_cooking': 'Cooking',
  'builder_interest_yoga': 'Yoga',
  'builder_interest_chess': 'Chess',
  'builder_interest_volunteering': 'Volunteering',
  'builder_interest_writing': 'Writing',
  'builder_interest_dancing': 'Dancing',
};

```

## lib/translations/ar_sa.dart
```dart
/// Arabic interface messages.
const Map<String, String> arSa = {
  'home': 'الرئيسية',
  'templates': 'القوالب',
  'favorites': 'المفضلة',
  'settings': 'الإعدادات',
  'save': 'حفظ',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'edit': 'تعديل',
  'next': 'التالي',
  'previous': 'السابق',
  'finish': 'إنهاء',
  'preview': 'معاينة',
  'view_all': 'عرض الكل',
  'success': 'نجاح',
  'resume_saved': 'تم حفظ السيرة الذاتية بنجاح',
  'resume_deleted': 'تم حذف السيرة الذاتية بنجاح',
  'no_resumes_found': 'لا توجد سير ذاتية',
  'no_favorites': 'لا توجد مفضلات بعد',
  'browse_templates': 'تصفح جميع القوالب',
  'create_new': 'إنشاء سيرة جديدة',
  'recent_activity': 'النشاطات الأخيرة',
  'featured_templates': 'قوالب مميزة',
  'use_template': 'استخدم القالب',
  'personal_info': 'المعلومات الشخصية',
  'education': 'التعليم',
  'experience': 'الخبرات',
  'skills': 'المهارات',
  'full_name': 'الاسم الكامل',
  'email': 'البريد الإلكتروني',
  'phone': 'رقم الهاتف',
  'address': 'العنوان',
  'summary': 'الملخص المهني',
  'degree': 'الشهادة',
  'institution': 'المؤسسة التعليمية',
  'graduation_year': 'سنة التخرج',
  'grade': 'التقدير',
  'add_education': 'إضافة تعليم',
  'edit_education': 'تعديل التعليم',
  'no_education_added': 'لم تتم إضافة تعليم',
  'degree_required': 'الشهادة مطلوبة',
  'institution_required': 'المؤسسة التعليمية مطلوبة',
  'year_required': 'سنة التخرج مطلوبة',
  'job_title': 'المسمى الوظيفي',
  'company': 'الشركة',
  'start_date': 'تاريخ البدء',
  'end_date': 'تاريخ الانتهاء',
  'current_job': 'وظيفة حالية',
  'description': 'الوصف',
  'add_experience': 'إضافة خبرة',
  'edit_experience': 'تعديل الخبرة',
  'no_experience_added': 'لم تتم إضافة خبرات',
  'job_title_required': 'المسمى الوظيفي مطلوب',
  'company_required': 'الشركة مطلوبة',
  'start_date_required': 'تاريخ البدء مطلوب',
  'skill_name': 'اسم المهارة',
  'skill_level': 'المستوى',
  'add_skill': 'إضافة مهارة',
  'no_skills_added': 'لم تتم إضافة مهارات',
  'language': 'اللغة',
  'change_app_language': 'تغيير لغة التطبيق',
  'dark_mode': 'الوضع الليلي',
  'switch_theme': 'التبديل بين الوضع الليلي والنهاري',
  'contact_us': 'اتصل بنا',
  'share_app': 'مشاركة التطبيق',
  'email_required': 'البريد الإلكتروني مطلوب',
  'invalid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
  'phone_required': 'رقم الهاتف مطلوب',
  'invalid_phone': 'الرجاء إدخال رقم هاتف صحيح',
  'is_required': 'مطلوب',
  'create_resume': 'إنشاء سيرة ذاتية',
  'edit_resume': 'تعديل السيرة الذاتية',
  'customize_resume': 'تخصيص السيرة الذاتية',
  'apply_changes': 'تطبيق التغييرات',
  'customization_saved': 'تم حفظ التخصيص بنجاح',
  'failed_to_generate_preview': 'فشل في إنشاء المعاينة',
  'failed_to_export': 'فشل في تصدير PDF',
  'choose_color': 'اختر اللون',
  'preview_updated': 'تم تحديث المعاينة بنجاح',
  'update_preview': 'تحديث المعاينة',
  'courses': 'الدورات التدريبية',
  'certificates': 'الشهادات',
  'languages': 'اللغات',
  'add_course': 'إضافة دورة',
  'add_certificate': 'إضافة شهادة',
  'add_language': 'إضافة لغة',
  'course_name': 'اسم الدورة',
  'certificate_name': 'اسم الشهادة',
  'language_name': 'اسم اللغة',
  'provider': 'مقدم الدورة',
  'organization': 'الجهة المانحة',
  'proficiency_level': 'مستوى الإتقان',
  'no_courses_added': 'لم تتم إضافة دورات',
  'no_certificates_added': 'لم تتم إضافة شهادات',
  'no_languages_added': 'لم تتم إضافة لغات',
  'course_name_required': 'اسم الدورة مطلوب',
  'provider_required': 'مقدم الدورة مطلوب',
  'certificate_name_required': 'اسم الشهادة مطلوب',
  'organization_required': 'الجهة المانحة مطلوبة',
  'language_name_required': 'اسم اللغة مطلوب',
  'additional_info': 'معلومات إضافية',
  'projects': 'المشاريع',
  'achievements': 'الإنجازات',
  'interests': 'الاهتمامات',
  'project_name': 'اسم المشروع',
  'achievement': 'الإنجاز',
  'no_projects_added': 'لم تتم إضافة مشاريع',
  'no_achievements_added': 'لم تتم إضافة إنجازات',
  'no_additional_sections': 'لا توجد أقسام إضافية',
  'your_selected_interests': 'اهتماماتك المختارة:',
  'select_interests': 'اختر اهتماماتك',
  'linkedin': 'لينكد إن',
  'github': 'جيت هاب',
  'website': 'الموقع الإلكتروني',
  'portfolio': 'ملف الأعمال',
  'profile_image_updated': 'تم تحديث صورة الملف الشخصي بنجاح',
  'clear_cache': 'مسح الكاش',
  'clear_cache_description': 'إزالة الملفات المؤقتة وتحرير المساحة',
  'clear_cache_confirmation': 'هل أنت متأكد من مسح الكاش؟',
  'cache_cleared': 'تم مسح الكاش بنجاح',
  'cache_clear_failed': 'فشل في مسح الكاش',
  'data': 'البيانات',
  'about': 'حول التطبيق',
  'app_version': 'إصدار التطبيق',
  'version_1_0_0': 'الإصدار 1.0.0',
  'exit_app': 'الخروج من التطبيق',
  'exit_confirmation': 'هل أنت متأكد من الخروج من التطبيق؟',
  'exit': 'خروج',
  'yes': 'نعم',
  'no': 'لا',
  'logged_out': 'تم تسجيل الخروج',
  'come_back_soon': 'نتمنى رؤيتك مرة أخرى قريباً!',
  'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
  'professional_resume_builder': 'منشئ السير الذاتية الاحترافي',
  'appearance': 'المظهر',
  'data_management': 'إدارة البيانات',
  'support': 'الدعم',
  'get_help_support': 'احصل على المساعدة والدعم',
  'rate_app': 'تقييم التطبيق',
  'rate_us_on_store': 'قيمنا في المتجر',
  'share_with_friends': 'شارك مع الأصدقاء',
  'cannot_open_email': 'لا يمكن فتح بريد إلكتروني',
  'select_language': 'اختر لغتك المفضلة',
  'add_project': 'إضافة مشروع',
  'edit_project': 'تعديل مشروع',
  'current_project': 'مشروع حالي',
  'technologies_used': 'التقنيات المستخدمة',
  'add_technology': 'إضافة تقنية',
  'project_name_required': 'اسم المشروع مطلوب',
  'description_required': 'الوصف مطلوب',
  'achievement_name': 'اسم الإنجاز',
  'achievement_name_required': 'اسم الإنجاز مطلوب',
  'category': 'التصنيف',
  'date_required': 'التاريخ مطلوب',
  'add_achievement': 'إضافة إنجاز',
  'edit_achievement': 'تعديل إنجاز',
  'cache_cleared_completely': 'تم مسح الكاش بالكامل',
  'clear_all_data': 'مسح جميع البيانات',
  'clear_all_data_confirmation':
      'سيؤدي هذا إلى حذف جميع سيرك الذاتية وإعداداتك. هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟',
  'clear_all': 'مسح الكل',
  'all_data_cleared': 'تم مسح جميع البيانات بنجاح',
  'clear_all_data_failed': 'فشل في مسح جميع البيانات',
  'close': 'إغلاق',
  'date': 'التاريخ',
  'year': 'السنة',
  'error': 'خطأ',
  'retry': 'إعادة المحاولة',
  'featured': 'مميز',
  'logout': 'تسجيل الخروج',
  'my_skills': 'مهاراتي',
  'resumes': 'السير الذاتية',
  'edit_certificate': 'تعديل الشهادة',
  'edit_course': 'تعديل الدورة',
  'edit_language': 'تعديل اللغة',
  'app_name': 'CV Builder Pro',
  'search_templates': 'البحث في القوالب',
  'search': 'بحث',
  'no_search_results': 'لا توجد نتائج مطابقة',
  'search_hint': 'ابحث بالاسم أو الوصف',
  'total_resumes': 'إجمالي السير',
  'favorite_resumes': 'السير المفضلة',
  'available_templates': 'القوالب المتاحة',
  'saving': 'جارٍ الحفظ…',
  'auto_saved': 'تم الحفظ تلقائياً',
  'last_saved': 'آخر حفظ: @time',
  'save_failed': 'تعذر حفظ التغييرات. أعد المحاولة.',
  'loading': 'جارٍ التحميل…',
  'please_wait': 'يرجى الانتظار',
  'storage_error': 'تعذرت عملية التخزين. تحقق من مساحة الجهاز وأعد المحاولة.',
  'startup_error':
      'تعذر فتح التخزين المحلي. أغلق التطبيق ثم أعد تشغيله. إذا استمرت المشكلة، تحقق من مساحة التخزين وصلاحيات التطبيق.',
  'field_required': '@field مطلوب',
  'invalid_url': 'أدخل رابطاً كاملاً يبدأ بـ http أو https',
  'invalid_date': 'استخدم تاريخاً صالحاً بصيغة MM/YYYY',
  'invalid_date_range': 'يجب ألا يسبق تاريخ الانتهاء تاريخ البدء',
  'choose_image': 'اختيار صورة',
  'remove_image': 'إزالة الصورة',
  'delete_resume_confirmation': 'هل تريد حذف هذه السيرة؟',
  'select_resume': 'اختر سيرة ذاتية',
  'export_json': 'تصدير JSON',
  'export_pdf': 'تصدير PDF',
  'share_json': 'مشاركة JSON',
  'share_pdf': 'مشاركة PDF',
  'print_pdf': 'طباعة PDF',
  'import_json': 'استيراد JSON',
  'import_pdf': 'استيراد PDF',
  'import_txt': 'استيراد TXT',
  'recommended': 'موصى به',
  'choose_file': 'اختيار ملف',
  'paste_json': 'لصق JSON',
  'paste_json_hint': 'الصق بيانات السيرة بصيغة JSON هنا',
  'json_import_description': 'يستعيد جميع الحقول من ملف JSON متوافق للسيرة.',
  'pdf_import_description':
      'يحاول استخراج النص من ملفات PDF النصية المدعومة. الملفات الممسوحة ضوئياً تحتاج إلى OCR.',
  'txt_import_description':
      'يستخرج بيانات الاتصال والنصوص التي يمكن التعرف عليها لمراجعتها.',
  'import_success': 'تم استيراد السيرة بنجاح',
  'import_failed': 'تعذر استيراد الملف. تحقق من صيغته ومحتواه.',
  'import_cancelled': 'لم يتم اختيار ملف',
  'unsupported_file': 'نوع الملف غير مدعوم',
  'file_too_large': 'يتجاوز الملف حد الاستيراد البالغ 10 ميجابايت',
  'invalid_json': 'بنية JSON أو أنواع الحقول غير صالحة',
  'pdf_import_unsupported':
      'تعذر استخراج النص من ملف PDF هذا. جرّب JSON أو TXT.',
  'review_before_save': 'راجع المعلومات المستوردة وصححها قبل الحفظ.',
  'save_and_edit': 'حفظ وتعديل',
  'export_success': 'اكتمل التصدير',
  'export_failed': 'تعذر تصدير السيرة',
  'export_cancelled': 'تم إلغاء التصدير',
  'export_quality': 'جودة التصدير',
  'quality_standard': 'قياسية',
  'quality_high': 'عالية',
  'customization': 'التخصيص',
  'font_family': 'الخط',
  'font_size': 'حجم الخط',
  'primary_color': 'اللون الرئيسي',
  'secondary_color': 'اللون الثانوي',
  'ats_checker': 'فحص ATS',
  'ats_score': 'نتيجة ATS',
  'ats_score_out_of': '@score من 100',
  'ats_recheck': 'إعادة الفحص',
  'ats_use_template': 'استخدام قالب ATS',
  'ats_edit_resume': 'انتقل للتعديل',
  'ats_issues': 'الملاحظات',
  'ats_suggestions': 'الاقتراحات',
  'ats_missing_keywords': 'الكلمات المفتاحية المفقودة',
  'ats_no_issues': 'لم تُكتشف ملاحظات وفق هذه القواعد',
  'ats_no_resume': 'اختر سيرة أو أنشئ سيرة لبدء الفحص',
  'ats_checking': 'جارٍ تحليل السيرة…',
  'ats_guidance':
      'هذا تقييم إرشادي قائم على قواعد، ولا يضمن القبول لدى أنظمة التوظيف.',
  'ats_formatting_note':
      'يعتمد فحص التنسيق على إعداد القالب، وليس على تحليل ملف PDF مصدّر.',
  'ats_template_applied': 'تم حفظ قالب ATS',
  'ats_section_contact': 'بيانات الاتصال',
  'ats_section_summary': 'الملخص المهني',
  'ats_section_experience': 'الخبرة',
  'ats_section_education': 'التعليم',
  'ats_section_skills': 'المهارات',
  'ats_section_keywords': 'الكلمات المفتاحية',
  'ats_section_formatting': 'التنسيق',
  'ats_severity_critical': 'حرجة',
  'ats_severity_warning': 'تنبيه',
  'ats_severity_info': 'معلومة',
  'ats_keyword_teamwork': 'العمل الجماعي',
  'ats_keyword_leadership': 'القيادة',
  'ats_keyword_communication': 'التواصل',
  'ats_keyword_problem_solving': 'حل المشكلات',
  'time_just_now': 'الآن',
  'time_ago': 'منذ @count @unit',
  'time_in': 'خلال @count @unit',
  'time_minute': 'دقيقة',
  'time_minutes': 'دقيقة',
  'time_hour': 'ساعة',
  'time_hours': 'ساعة',
  'time_day': 'يوم',
  'time_days': 'يوم',
  'ats_issue_name': 'السيرة لا تحتوي على اسم.',
  'ats_fix_name': 'أضف اسمك الكامل.',
  'ats_issue_email': 'البريد الإلكتروني مفقود أو غير صالح.',
  'ats_fix_email': 'أضف بريداً إلكترونياً صالحاً.',
  'ats_issue_phone': 'رقم الهاتف مفقود أو غير صالح.',
  'ats_fix_phone': 'أضف رقم هاتف صالحاً.',
  'ats_issue_linkedin': 'رابط LinkedIn صالح مفقود.',
  'ats_fix_linkedin': 'أضف رابط ملفك الكامل في LinkedIn.',
  'ats_issue_website': 'رابط الموقع أو معرض الأعمال مفقود.',
  'ats_fix_website': 'أضف رابط موقع أو معرض أعمال مناسب.',
  'ats_issue_summary_missing': 'الملخص المهني مفقود.',
  'ats_fix_summary_missing': 'اكتب ملخصاً مهنياً موجزاً.',
  'ats_issue_summary_length': 'طول الملخص خارج نطاق 50–300 حرف.',
  'ats_fix_summary_length': 'اجعل الملخص بين 50 و300 حرف.',
  'ats_issue_summary_keywords': 'الملخص يفتقر إلى كلمات وظيفية معروفة.',
  'ats_fix_summary_keywords': 'اذكر المهارات المرتبطة بالوظيفة في الملخص.',
  'ats_issue_experience_missing': 'لا توجد خبرة بمسمى وظيفي وشركة.',
  'ats_fix_experience_missing': 'أضف خبرة عمل أو تدريب أو تطوع مناسبة.',
  'ats_issue_experience_actions': 'أوصاف الخبرة تفتقر إلى أفعال إنجاز معروفة.',
  'ats_fix_experience_actions': 'صف إنجازاتك بأفعال مثل طورت أو قدت.',
  'ats_issue_experience_dates':
      'تواريخ الخبرة مفقودة أو غير مرتبة أو مستقبلية.',
  'ats_fix_experience_dates': 'استخدم MM/YYYY وحدد الوظائف المستمرة كعمل حالي.',
  'ats_issue_education_missing': 'التعليم يفتقر إلى المؤهل أو المؤسسة.',
  'ats_fix_education_missing': 'أضف المؤهل والمؤسسة التعليمية.',
  'ats_issue_education_year': 'سنة تخرج صالحة مفقودة.',
  'ats_fix_education_year': 'أضف سنة التخرج أو التخرج المتوقع بأربعة أرقام.',
  'ats_issue_skills_minimum': 'عدد المهارات المختلفة أقل من خمس.',
  'ats_fix_skills_minimum': 'أضف خمس مهارات مختلفة مرتبطة بالوظيفة على الأقل.',
  'ats_issue_skills_count': 'عدد المهارات المختلفة أقل من عشر.',
  'ats_fix_skills_count': 'أضف مهارات مناسبة إضافية تدعمها خبرتك.',
  'ats_issue_skills_diversity':
      'لم يظهر مزيج من المهارات التقنية والشخصية المعروفة.',
  'ats_fix_skills_diversity': 'اذكر مهارات تقنية وشخصية تستخدمها فعلياً.',
  'ats_issue_keywords_missing': 'لم تظهر كلمات المهارات العامة المعروفة.',
  'ats_fix_keywords_missing':
      'اذكر خبرة مناسبة في العمل الجماعي أو القيادة أو التواصل أو حل المشكلات.',
  'ats_issue_placeholders': 'ظهر نص تجريبي يحتاج إلى مراجعة.',
  'ats_fix_placeholders': 'استبدل النصوص التجريبية بمعلوماتك الصحيحة.',
  'ats_issue_photo': 'الإخراج المحدد يتضمن صورة.',
  'ats_fix_photo': 'استخدم قالب ATS لاستبعاد الصورة من الإخراج.',
  'ats_issue_font': 'الخط المحدد خارج قائمة الخطوط البسيطة.',
  'ats_fix_font': 'اختر Cairo أو Poppins أو استخدم قالب ATS.',
  'ats_issue_columns': 'لم يُعتمد تخطيط بعمود واحد لهذا الإعداد.',
  'ats_fix_columns': 'استخدم قالب ATS ذي العمود الواحد.',
  'ats_select_resume': 'اختر سيرة أو أنشئ سيرة قبل الفحص.',
  'ats_analysis_failed': 'تعذر تحليل السيرة. راجع بياناتها وأعد المحاولة.',
  'ats_save_failed': 'تعذر حفظ قالب ATS.',
  'ats_apply_failed': 'تعذر تطبيق قالب ATS.',
  'action_failed': 'تعذر إكمال العملية. أعد المحاولة.',
  'splash_tagline': 'أنشئ سيرتك الذاتية الاحترافية',
  'splash_preparing': 'جارٍ التجهيز…',
  'language_selection_title': 'اختر لغتك',
  'language_selection_subtitle':
      'اختر اللغة التي تفضلها. يمكنك تغييرها لاحقاً من الإعدادات.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'الولايات المتحدة',
  'country_sa': 'السعودية',
  'select_english': 'اختيار الإنجليزية',
  'select_arabic': 'اختيار العربية',
  'switch_to_english': 'استخدم التطبيق باللغة الإنجليزية',
  'switch_to_arabic': 'استخدم التطبيق باللغة العربية',
  'home_welcome': 'مرحباً بك!',
  'home_empty_description': 'ابدأ بإنشاء أول سيرة ذاتية احترافية لك.',
  'home_templates_description': 'اختر من تصاميمنا الاحترافية.',
  'home_recent_description': 'آخر السير الذاتية المحفوظة والتغييرات.',
  'show_recent': 'عرض الأحدث',
  'untitled_resume': 'سيرة بدون اسم',
  'no_templates_available': 'لا توجد قوالب متاحة',
  'template_position': '@current من @total',
  'add_favorite': 'إضافة إلى المفضلة',
  'remove_favorite': 'إزالة من المفضلة',
  'tip_action_verbs': 'استخدم أفعالاً قوية لوصف إنجازاتك.',
  'tip_tailor_resume': 'خصص سيرتك الذاتية لكل وظيفة تتقدم لها.',
  'tip_resume_length': 'اجعل سيرتك الذاتية موجزة ومرتبطة بالوظيفة.',
  'tip_relevant_skills': 'ركز على المهارات والخبرات الأكثر صلة بالوظيفة.',
  'tip_job_keywords': 'استخدم الكلمات المفتاحية المناسبة من وصف الوظيفة.',
  'clear_template_search': 'مسح البحث',
  'reset_template_filters': 'إعادة ضبط الفلاتر',
  'template_category_all': 'الكل',
  'template_category_ats': 'ATS',
  'template_category_business': 'أعمال',
  'template_category_classic': 'كلاسيكي',
  'template_category_modern': 'عصري',
  'template_category_technical': 'تقني',
  'favorite_remove_confirmation':
      'هل تريد إزالة «@name» من المفضلة؟ ستبقى السيرة محفوظة.',
  'favorites_empty_description': 'أضف سيرك المحفوظة إلى المفضلة لتظهر هنا.',
  'favorites_empty_title': 'لا توجد مفضلات بعد',
  'search_favorites': 'البحث في المفضلة',
  'change_profile_image': 'تغيير الصورة الشخصية',
  'profile_image_failed': 'تعذر اختيار الصورة الشخصية أو حفظها. حاول مرة أخرى.',
  'settings_data_description':
      'حذف جميع السير المحفوظة والمفضلة والصورة الشخصية والتفضيلات.',
  'settings_exit_confirmation':
      'هل تريد الخروج ومسح المسودة الحالية وتفضيل الصورة الشخصية؟ ستبقى السير المحفوظة.',
  'share_app_message': 'أنشئ سيراً ذاتية احترافية باستخدام CV Builder Pro.',
  'import_discard': 'تجاهل المعاينة',
  'import_edit_json': 'JSON السيرة القابل للتعديل',
  'import_empty': 'لا يحتوي الملف على نص.',
  'import_extension_mismatch': 'لا يطابق الملف المختار التنسيق المطلوب.',
  'import_invalid_json':
      'JSON السيرة غير صالح. استخدم كائناً يحتوي fullName كنص وحقول السيرة بأنواع صحيحة.',
  'import_invalid_pdf': 'ملف PDF تالف أو غير مدعوم.',
  'import_json_description':
      'يحفظ جميع أقسام السيرة. اختر ملف JSON بترميز UTF-8 أو UTF-16، بحد أقصى 10 ميغابايت.',
  'import_json_title': 'JSON — موصى به',
  'import_loading': 'جارٍ قراءة السيرة والتحقق منها…',
  'import_name_required': 'أدخل الاسم الكامل قبل الحفظ.',
  'import_paste_json': 'أو الصق JSON السيرة',
  'import_pdf_description':
      'يدعم ملفات PDF النصية البسيطة بأحرف ASCII، ومنها تدفقات Flate. لا يدعم الصور أو التشفير أو الخطوط المرمّزة. راجع المحتوى المستخرج.',
  'import_pdf_encrypted': 'لا يمكن استيراد PDF المحمي بكلمة مرور.',
  'import_pdf_font_unsupported':
      'يستخدم PDF ترميز خطوط غير مدعوم. استورد JSON أو انسخ نصه إلى ملف TXT بترميز UTF-8.',
  'import_pdf_no_text':
      'لم يُعثر على نص PDF مدعوم. الملفات المصوّرة تحتاج OCR؛ استخدم JSON أو TXT بدلاً منها.',
  'import_pdf_title': 'PDF — نص بسيط فقط',
  'import_preview': 'معاينة الاستيراد',
  'import_preview_description':
      'عدّل أي حقل في JSON الكامل أدناه، ثم احفظ نسخة جديدة وأكمل التعديل. يُعاد ضبط المعرّف والمفضلة ومسار الصورة المستوردة.',
  'import_preview_empty': 'ستظهر معاينة الاستيراد هنا',
  'import_preview_empty_description':
      'اختر ملفاً أو الصق JSON. لن تُحفظ بيانات قبل تأكيدك.',
  'import_read_failed':
      'تعذرت قراءة الملف. تحقق من صلاحية الوصول وحاول مرة أخرى.',
  'import_resume': 'استيراد سيرة',
  'import_save_edit': 'حفظ ومتابعة التعديل',
  'import_section_counts':
      'التعليم: @education • الخبرة: @experience • المهارات: @skills',
  'import_select_file': 'اختيار ملف @format',
  'import_text_encoding': 'احفظ الملف النصي بترميز UTF-8 أو UTF-16.',
  'import_too_large':
      'يتجاوز الملف 10 ميغابايت أو يتجاوز محتواه بعد فك الضغط الحد الآمن.',
  'import_txt_description':
      'يستخرج الاسم والبريد والهاتف والروابط والمهارات المفصولة بفواصل، ويحفظ النص الكامل في الملخص للمراجعة اليدوية.',
  'import_txt_title': 'TXT',
  'import_unsupported': 'اختر ملف JSON أو PDF أو TXT.',
  'export_json_description':
      'احفظ أو شارك نسخة JSON كاملة تشمل الأقسام والتخصيص، ويمكن استيرادها لاحقاً. مسار الصورة مرجع محلي وليس صورة مضمّنة.',
  'export_json_extension': 'اختر اسم ملف ينتهي بالامتداد .json.',
  'export_json_invalid': 'تحتوي السيرة على بيانات لا يمكن تصديرها بصيغة JSON.',
  'export_json_save': 'حفظ ملف JSON',
  'export_json_save_failed':
      'تعذر حفظ JSON. تحقق من موقع الحفظ والمساحة المتاحة.',
  'export_json_saved': 'تم حفظ ملف JSON بنجاح.',
  'export_json_share': 'مشاركة ملف JSON',
  'export_json_share_failed': 'تعذرت مشاركة JSON. تحقق من توفر تطبيق للمشاركة.',
  'export_json_shared': 'تم تمرير ملف JSON إلى نافذة المشاركة.',
  'export_json_too_large':
      'يتجاوز JSON حد الاستيراد البالغ 10 ميغابايت. قلّل المحتوى قبل التصدير.',
  'export_no_resume': 'افتح سيرة أو أنشئ واحدة قبل التصدير.',
  'ats_choose_resume': 'اختيار سيرة محفوظة',
  'builder_fix_personal':
      'تحقق من الاسم والبريد والهاتف وروابط الحسابات قبل المتابعة.',
  'builder_new_draft': 'مسودة جديدة',
  'builder_remove_photo': 'إزالة الصورة',
  'builder_save_close': 'حفظ وإغلاق',
  'builder_saved': 'تم الحفظ',
  'builder_section_position': 'القسم @current من @total',
  'builder_unsaved': 'تعديلات بانتظار الحفظ',
  'builder_entry_changed':
      'تغيرت السيرة أثناء التعديل. ألغِ التعديل واختر العنصر مجدداً.',
  'builder_future_date': 'لا يمكن أن يكون التاريخ بعد الشهر الحالي.',
  'builder_invalid_year':
      'أدخل سنة من أربعة أرقام بين 1900 وعشر سنوات من الآن.',
  'builder_present': 'حتى الآن',
  'builder_skill_duplicate': 'هذه المهارة موجودة بالفعل.',
  'builder_skill_level_1': 'مبتدئ',
  'builder_skill_level_2': 'أساسي',
  'builder_skill_level_3': 'متوسط',
  'builder_skill_level_4': 'متقدم',
  'builder_skill_level_5': 'خبير',
  'builder_skill_required': 'أدخل اسم المهارة.',
  'builder_certificate_url': 'رابط الشهادة (اختياري)',
  'builder_credential_id': 'معرّف الاعتماد (اختياري)',
  'builder_language_beginner': 'مبتدئ',
  'builder_language_intermediate': 'متوسط',
  'builder_language_advanced': 'متقدم',
  'builder_language_fluent': 'طليق',
  'builder_language_native': 'لغة أم',
  'builder_technology_lines': 'أدخل كل تقنية في سطر مستقل.',
  'builder_interest_name': 'الاهتمام',
  'builder_interest_required': 'أدخل اهتماماً.',
  'builder_interest_duplicate': 'هذا الاهتمام مضاف بالفعل.',
  'builder_add_interest': 'إضافة اهتمام',
  'builder_interest_suggestions': 'اهتمامات مقترحة',
  'builder_no_interests': 'لم تضف اهتمامات بعد',
  'builder_interest_reading': 'القراءة',
  'builder_interest_travel': 'السفر',
  'builder_interest_music': 'الموسيقى',
  'builder_interest_sports': 'الرياضة',
  'builder_interest_photography': 'التصوير',
  'builder_interest_coding': 'البرمجة',
  'builder_interest_art': 'الفن',
  'builder_interest_gaming': 'الألعاب',
  'builder_interest_cooking': 'الطبخ',
  'builder_interest_yoga': 'اليوغا',
  'builder_interest_chess': 'الشطرنج',
  'builder_interest_volunteering': 'التطوع',
  'builder_interest_writing': 'الكتابة',
  'builder_interest_dancing': 'الرقص',
};

```

## lib/legacy_app.dart
```dart
//10
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'data/index.dart';
import 'controllers/index.dart';
import 'features/resume_builder/presentation/widgets/resume_json_export_button.dart';
import 'app/routes/app_routes.dart';
import 'core/services/pdf_service.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ==================== MODELS ====================

// ==================== VALIDATORS ====================

// ==================== WIDGETS ====================

// ==================== RESUME BUILDER SCREENS ====================
// Helper Widgets
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TemplateController templateController = Get.find<TemplateController>();

  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.grey;
  String _fontFamily = 'Poppins';
  double _fontSize = 12;
  bool _showCustomization = false;
  Uint8List? _cachedPDF;
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _loadCustomization();
    _generatePDFAndCache();
  }

  void _loadCustomization() {
    if (resumeController.currentResume.value?.templateId == 'ats') {
      _primaryColor = Colors.black;
      _secondaryColor = Colors.black;
      _fontFamily = 'Cairo';
      _fontSize = 11;
      _showCustomization = false;
      return;
    }
    final customization = resumeController.currentResume.value?.customization;
    if (customization != null) {
      _primaryColor = Color(customization['primaryColor'] ?? Colors.blue.value);
      _secondaryColor = Color(
        customization['secondaryColor'] ?? Colors.grey.value,
      );
      _fontFamily = customization['fontFamily'] ?? 'Poppins';
      _fontSize = customization['fontSize'] ?? 12.0;
    }
  }

  Future<void> _generatePDFAndCache() async {
    setState(() => _isGeneratingPDF = true);
    try {
      _cachedPDF = await _generatePDF();
    } catch (e) {
      print('Error generating PDF: $e');
      _cachedPDF = null;
    } finally {
      if (mounted) setState(() => _isGeneratingPDF = false);
    }
  }

  Future<Uint8List> _generatePDF() async {
    final resume = resumeController.currentResume.value!;
    if (resume.templateId == 'ats') {
      return PdfService().generateAts(
        resume,
        locale: Get.locale?.languageCode ?? 'en',
      );
    }
    final isArabic = Get.locale?.languageCode == 'ar';
    final pdf = pw.Document();

    // Load fonts
    pw.Font? headerFont;
    pw.Font? bodyFont;
    try {
      final headerFontData = await rootBundle.load(
        'assets/fonts/SukarBlack.ttf',
      );
      headerFont = pw.Font.ttf(headerFontData);
      final bodyFontData = await rootBundle.load(
        'assets/fonts/Cairo-Regular.ttf',
      );
      bodyFont = pw.Font.ttf(bodyFontData);
    } catch (e) {
      print('Font loading error: $e');
    }

    final textDirection = isArabic
        ? pw.TextDirection.rtl
        : pw.TextDirection.ltr;

    final titles = {
      'summary': isArabic ? 'الملخص المهني' : 'Professional Summary',
      'education': isArabic ? 'التعليم' : 'Education',
      'experience': isArabic ? 'الخبرات العملية' : 'Work Experience',
      'skills': isArabic ? 'المهارات' : 'Skills',
      'courses': isArabic ? 'الدورات التدريبية' : 'Courses',
      'certificates': isArabic ? 'الشهادات' : 'Certificates',
      'languages': isArabic ? 'اللغات' : 'Languages',
      'projects': isArabic ? 'المشاريع' : 'Projects',
      'achievements': isArabic ? 'الإنجازات' : 'Achievements',
      'interests': isArabic ? 'الاهتمامات' : 'Interests',
      'present': isArabic ? 'حالياً' : 'Present',
      'grade': isArabic ? 'التقدير' : 'Grade',
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          List<pw.Widget> widgets = [];

          // Header
          widgets.add(
            _buildHeader(
              resume,
              titles,
              textDirection,
              isArabic,
              headerFont,
              bodyFont,
            ),
          );
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(pw.Divider(color: PdfColor.fromInt(_primaryColor.value)));

          // Summary
          if (resume.summary != null && resume.summary!.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(titles['summary']!, headerFont, textDirection),
            );
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              pw.Text(
                resume.summary!,
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
            );
          }

          // Education
          if (resume.education.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['education']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var edu in resume.education) {
              widgets.add(
                _buildEducationItem(
                  edu,
                  titles,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Experience
          if (resume.experience.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['experience']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var exp in resume.experience) {
              widgets.add(
                _buildExperienceItem(
                  exp,
                  titles,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Skills
          if (resume.skills.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(titles['skills']!, headerFont, textDirection),
            );
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              _buildSkillsSection(
                resume.skills,
                textDirection,
                isArabic,
                bodyFont,
              ),
            );
          }

          // Courses
          if (resume.courses.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(titles['courses']!, headerFont, textDirection),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var course in resume.courses) {
              widgets.add(
                _buildCourseItem(
                  course,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Certificates
          if (resume.certificates.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['certificates']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var cert in resume.certificates) {
              widgets.add(
                _buildCertificateItem(
                  cert,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Languages
          if (resume.languages.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['languages']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var lang in resume.languages) {
              widgets.add(
                _buildLanguageItem(
                  lang,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }
          // Projects Section with full details
          if (resume.projects.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['projects']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var project in resume.projects) {
              widgets.add(
                _buildProjectItem(
                  project,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Achievements Section with full details
          if (resume.achievements.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['achievements']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var achievement in resume.achievements) {
              widgets.add(
                _buildAchievementItem(
                  achievement,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Interests
          if (resume.interests != null && resume.interests!.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['interests']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              _buildInterestsSection(
                resume.interests!,
                textDirection,
                bodyFont,
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    ResumeModel resume,
    Map<String, String> titles,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (resume.profilePicture != null &&
            File(resume.profilePicture!).existsSync())
          pw.Container(
            width: 80,
            height: 80,
            margin: const pw.EdgeInsets.only(right: 16),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              image: pw.DecorationImage(
                image: pw.MemoryImage(
                  File(resume.profilePicture!).readAsBytesSync(),
                ),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: isArabic
                ? pw.CrossAxisAlignment.end
                : pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                resume.fullName.isEmpty
                    ? (isArabic ? 'الاسم الكامل' : 'Full Name')
                    : resume.fullName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(_primaryColor.value),
                  font: headerFont,
                ),
                textDirection: textDirection,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${titles['email']}: ${resume.email.isEmpty ? 'email@example.com' : resume.email}',
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
              pw.Text(
                '${titles['phone']}: ${resume.phone.isEmpty ? '+1234567890' : resume.phone}',
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
              if (resume.address != null && resume.address!.isNotEmpty)
                pw.Text(
                  '${titles['address']}: ${resume.address!}',
                  style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                  textDirection: textDirection,
                ),
              if (resume.linkedin != null && resume.linkedin!.isNotEmpty)
                pw.Text(
                  '${titles['linkedin']}: ${resume.linkedin!}',
                  style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                  textDirection: textDirection,
                ),
              if (resume.github != null && resume.github!.isNotEmpty)
                pw.Text(
                  '${titles['github']}: ${resume.github!}',
                  style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                  textDirection: textDirection,
                ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(
    String title,
    pw.Font? headerFont,
    pw.TextDirection textDirection,
  ) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(_primaryColor.value),
        font: headerFont,
      ),
      textDirection: textDirection,
    );
  }

  pw.Widget _buildEducationItem(
    Education edu,
    Map<String, String> titles,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            edu.degree.isEmpty ? (isArabic ? 'الشهادة' : 'Degree') : edu.degree,
            style: pw.TextStyle(
              fontSize: _fontSize + 2,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            edu.institution.isEmpty
                ? (isArabic ? 'المؤسسة' : 'Institution')
                : edu.institution,
            style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            edu.year.isEmpty ? (isArabic ? 'السنة' : 'Year') : edu.year,
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
          if (edu.grade != null && edu.grade!.isNotEmpty)
            pw.Text(
              '${titles['grade']}: ${edu.grade}',
              style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
              textDirection: textDirection,
            ),
        ],
      ),
    );
  }

  pw.Widget _buildExperienceItem(
    Experience exp,
    Map<String, String> titles,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exp.jobTitle.isEmpty
                ? (isArabic ? 'المسمى الوظيفي' : 'Job Title')
                : exp.jobTitle,
            style: pw.TextStyle(
              fontSize: _fontSize + 2,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            exp.company.isEmpty
                ? (isArabic ? 'الشركة' : 'Company')
                : exp.company,
            style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            '${exp.startDate.isEmpty ? (isArabic ? 'تاريخ البدء' : 'Start Date') : exp.startDate} - ${exp.isCurrent ? titles['present'] : (exp.endDate?.isEmpty ?? true ? (isArabic ? 'تاريخ الانتهاء' : 'End Date') : exp.endDate)}',
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
          if (exp.description != null && exp.description!.isNotEmpty)
            pw.Text(
              exp.description!,
              style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
              textDirection: textDirection,
            ),
        ],
      ),
    );
  }

  pw.Widget _buildSkillsSection(
    List<Skill> skills,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? bodyFont,
  ) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: skills.map((skill) {
        String levelText = '';
        switch (skill.level) {
          case 1:
            levelText = isArabic ? 'مبتدئ' : 'Beginner';
            break;
          case 2:
            levelText = isArabic ? 'أساسي' : 'Basic';
            break;
          case 3:
            levelText = isArabic ? 'متوسط' : 'Intermediate';
            break;
          case 4:
            levelText = isArabic ? 'متقدم' : 'Advanced';
            break;
          case 5:
            levelText = isArabic ? 'خبير' : 'Expert';
            break;
        }
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(_primaryColor.value),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            '${skill.name} ${levelText.isNotEmpty ? '($levelText)' : ''}',
            style: pw.TextStyle(
              fontSize: _fontSize,
              color: PdfColors.white,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildCourseItem(
    Course course,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            course.name.isEmpty
                ? (isArabic ? 'اسم الدورة' : 'Course Name')
                : course.name,
            style: pw.TextStyle(
              fontSize: _fontSize,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            course.provider.isEmpty
                ? (isArabic ? 'مقدم الدورة' : 'Provider')
                : course.provider,
            style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            course.year.isEmpty ? (isArabic ? 'السنة' : 'Year') : course.year,
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCertificateItem(
    Certificate cert,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cert.name.isEmpty
                ? (isArabic ? 'اسم الشهادة' : 'Certificate Name')
                : cert.name,
            style: pw.TextStyle(
              fontSize: _fontSize,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            cert.organization.isEmpty
                ? (isArabic ? 'الجهة المانحة' : 'Organization')
                : cert.organization,
            style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            cert.year.isEmpty ? (isArabic ? 'السنة' : 'Year') : cert.year,
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLanguageItem(
    Language lang,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    String levelDisplay = '';
    switch (lang.level) {
      case 'Beginner':
        levelDisplay = isArabic ? 'مبتدئ' : 'Beginner';
        break;
      case 'Intermediate':
        levelDisplay = isArabic ? 'متوسط' : 'Intermediate';
        break;
      case 'Advanced':
        levelDisplay = isArabic ? 'متقدم' : 'Advanced';
        break;
      case 'Fluent':
        levelDisplay = isArabic ? 'طليق' : 'Fluent';
        break;
      case 'Native':
        levelDisplay = isArabic ? 'لغة أم' : 'Native';
        break;
      default:
        levelDisplay = lang.level;
    }
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              lang.name.isEmpty ? (isArabic ? 'لغة' : 'Language') : lang.name,
              style: pw.TextStyle(
                fontSize: _fontSize,
                fontWeight: pw.FontWeight.bold,
                font: headerFont,
              ),
              textDirection: textDirection,
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(_primaryColor.value),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              levelDisplay,
              style: pw.TextStyle(
                fontSize: _fontSize - 2,
                color: PdfColors.white,
                font: bodyFont,
              ),
              textDirection: textDirection,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectItem(
    Project project,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          // Project Name
          pw.Row(
            children: [
              // pw.Icon(
              //   pw.IconData(0xe3c9),
              //   size: 12,
              //   color: PdfColor.fromInt(_primaryColor.value),
              // ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  project.name,
                  style: pw.TextStyle(
                    fontSize: _fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                    font: headerFont,
                  ),
                  textDirection: textDirection,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // Date Range
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Text(
              '${project.startDate} - ${project.isCurrent ? (isArabic ? 'حالياً' : 'Present') : project.endDate ?? ''}',
              style: pw.TextStyle(
                fontSize: _fontSize - 1,
                color: PdfColors.grey600,
                font: bodyFont,
              ),
              textDirection: textDirection,
            ),
          ),
          pw.SizedBox(height: 4),

          // Description
          if (project.description.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                project.description,
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
            ),

          // Technologies
          if (project.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Wrap(
                spacing: 4,
                runSpacing: 4,
                children: project.technologies
                    .map(
                      (tech) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(_primaryColor.value),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          tech,
                          style: pw.TextStyle(
                            fontSize: _fontSize - 2,
                            color: PdfColors.white,
                            font: bodyFont,
                          ),
                          textDirection: textDirection,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildAchievementItem(
    Achievement achievement,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          // Achievement Name with Icon
          pw.Row(
            children: [
              // pw.Icon(
              //   pw.IconData(0xe8b5),
              //   size: 12,
              //   color: PdfColor.fromInt(_primaryColor.value),
              // ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  achievement.name,
                  style: pw.TextStyle(
                    fontSize: _fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                    font: headerFont,
                  ),
                  textDirection: textDirection,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // Date
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Text(
              achievement.date,
              style: pw.TextStyle(
                fontSize: _fontSize - 1,
                color: PdfColors.grey600,
                font: bodyFont,
              ),
              textDirection: textDirection,
            ),
          ),

          // Organization
          if (achievement.organization != null &&
              achievement.organization!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                achievement.organization!,
                style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
                textDirection: textDirection,
              ),
            ),

          // Category
          if (achievement.category != null && achievement.category!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(_primaryColor.value),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  achievement.category!,
                  style: pw.TextStyle(
                    fontSize: _fontSize - 2,
                    color: PdfColors.white,
                    font: bodyFont,
                  ),
                  textDirection: textDirection,
                ),
              ),
            ),

          // Description
          if (achievement.description.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                achievement.description,
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildInterestsSection(
    List<String> interests,
    pw.TextDirection textDirection,
    pw.Font? bodyFont,
  ) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: interests.map((interest) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(_primaryColor.value),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            interest,
            style: pw.TextStyle(
              fontSize: _fontSize,
              color: PdfColors.white,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveCustomization() async {
    final resume = resumeController.currentResume.value;
    if (resume != null) {
      resume.customization = {
        'primaryColor': _primaryColor.value,
        'secondaryColor': _secondaryColor.value,
        'fontFamily': _fontFamily,
        'fontSize': _fontSize,
      };
      resumeController.currentResume.value = resume;
      resumeController.currentResume.refresh();
      final saved = await resumeController.saveResume(resume);
      if (!saved || !mounted) return;
      await _generatePDFAndCache();
      Get.snackbar(
        'success'.tr,
        'customization_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _exportPDF() async {
    try {
      final pdfBytes = await _generatePDF();
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Check out my resume!');
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_export'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'preview'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('preview-check-ats'),
            tooltip: 'ats_checker'.tr,
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () async {
              await Get.toNamed<void>(AppRoutes.atsChecker);
              if (!mounted) return;
              _loadCustomization();
              await _generatePDFAndCache();
            },
          ),
          ResumeJsonExportButton(
            key: const ValueKey('preview-export-json'),
            resume: () => resumeController.currentResume.value?.copyWith(
              customization: {
                ...?resumeController.currentResume.value?.customization,
                'primaryColor': _primaryColor.toARGB32(),
                'secondaryColor': _secondaryColor.toARGB32(),
                'fontFamily': _fontFamily,
                'fontSize': _fontSize,
              },
            ),
          ),
          if (resumeController.currentResume.value?.templateId != 'ats')
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  _showCustomization ? Icons.preview : Icons.edit,
                  color: _showCustomization ? Colors.green : null,
                ),
                onPressed: () =>
                    setState(() => _showCustomization = !_showCustomization),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportPDF,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          if (_showCustomization)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveCustomization,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
        ],
      ),
      body: _showCustomization
          ? _buildCustomizationPanel()
          : _buildPDFPreview(),
    );
  }

  Widget _buildPDFPreview() {
    if (_isGeneratingPDF) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating preview...'),
          ],
        ),
      );
    }
    if (_cachedPDF == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('failed_to_generate_preview'.tr),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _generatePDFAndCache();
                setState(() {});
              },
              child: Text('retry'.tr),
            ),
          ],
        ),
      );
    }
    return PdfPreview(
      build: (format) async => _cachedPDF!,
      allowPrinting: true,
      allowSharing: true,
      previewPageMargin: const EdgeInsets.all(8),
      initialPageFormat: PdfPageFormat.a4,
    );
  }

  Widget _buildCustomizationPanel() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.color_lens),
                const SizedBox(width: 8),
                Text(
                  'customize_resume'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildColorCard(),
                const SizedBox(height: 16),
                _buildFontFamilyCard(),
                const SizedBox(height: 16),
                _buildFontSizeCard(),
                const SizedBox(height: 16),
                _buildLivePreviewCard(),
                const SizedBox(height: 16),
                _buildUpdateButton(),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildColorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Primary Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildColorOption(
                    Colors.blue,
                    () => setState(() => _primaryColor = Colors.blue),
                  ),
                  _buildColorOption(
                    Colors.green,
                    () => setState(() => _primaryColor = Colors.green),
                  ),
                  _buildColorOption(
                    Colors.red,
                    () => setState(() => _primaryColor = Colors.red),
                  ),
                  _buildColorOption(
                    Colors.purple,
                    () => setState(() => _primaryColor = Colors.purple),
                  ),
                  _buildColorOption(
                    Colors.orange,
                    () => setState(() => _primaryColor = Colors.orange),
                  ),
                  _buildColorOption(
                    Colors.teal,
                    () => setState(() => _primaryColor = Colors.teal),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _showCustomColorPicker(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.colorize,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontFamilyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Family',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFontOption('Poppins', 'Modern'),
                const SizedBox(width: 12),
                _buildFontOption('Cairo', 'Arabic'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.format_size),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 8,
                    max: 16,
                    divisions: 8,
                    label: '${_fontSize.toInt()}',
                    onChanged: (value) => setState(() => _fontSize = value),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_fontSize.toInt()}',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Card(
      color: _primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: _primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Live Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resumeController.currentResume.value!.fullName.isEmpty
                        ? 'Your Name'
                        : resumeController.currentResume.value!.fullName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sample text with $_fontFamily font',
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 4, color: _primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await _generatePDFAndCache();
          setState(() => _showCustomization = false);
          Get.snackbar(
            'success'.tr,
            'preview_updated'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        icon: const Icon(Icons.refresh),
        label: Text('update_preview'.tr),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showCustomization = false),
              icon: const Icon(Icons.close),
              label: Text('cancel'.tr),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _saveCustomization();
                setState(() => _showCustomization = false);
              },
              icon: const Icon(Icons.check),
              label: Text(
                'apply_changes'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, VoidCallback onTap) {
    final isSelected = _primaryColor == color;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFontOption(String fontFamily, String displayName) {
    final isSelected = _fontFamily == fontFamily;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _fontFamily = fontFamily),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? _primaryColor.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: fontFamily,
                  color: isSelected ? _primaryColor : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? _primaryColor : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('choose_color'.tr),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _primaryColor,
            onColorChanged: (color) => setState(() => _primaryColor = color),
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }
}

// ==================== MAIN ====================

```

## test/resume_builder/projects_achievements_interests_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare() {
  final resumes = Get.put(ResumeController(repository: _Repository()));
  resumes.currentResume.value = ResumeModel(fullName: 'Draft');
  return resumes;
}

Widget _host(Widget child, {double scale = 1, bool arabic = false}) =>
    GetMaterialApp(
      locale: Locale(arabic ? 'ar' : 'en'),
      translations: AppTranslations(),
      theme: arabic ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: child,
            ),
          ),
        ),
      ),
    );
Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);
Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String value) async {
  final target = _field(key);
  await tester.ensureVisible(target);
  await tester.enterText(target, value);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  testWidgets('project validates range, edits all fields and cancels safely', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const ProjectsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-projects');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects, isEmpty);
    await _type(tester, 'project-title', 'App');
    await _type(tester, 'project-start', '٠٢/٢٠٢٤');
    await _type(tester, 'project-end', '01/2024');
    await _type(tester, 'project-description', 'Built app');
    await _type(tester, 'project-technologies', 'Dart\nFlutter, Web');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects, isEmpty);
    await _type(tester, 'project-end', '03/2024');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects.single.startDate, '02/2024');
    expect(r.projects.single.technologies, ['Dart', 'Flutter, Web']);
    await _tap(tester, 'edit-project-0');
    await _type(tester, 'project-title', 'Discard');
    final cancel = find.widgetWithText(TextButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(r.projects.single.name, 'App');
    await _tap(tester, 'edit-project-0');
    await _tap(tester, 'project-current');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects.single.isCurrent, isTrue);
    expect(r.projects.single.endDate, isNull);
    expect(r.projects.single.technologies, ['Dart', 'Flutter, Web']);
    await _tap(tester, 'delete-project-0');
    expect(r.projects, isEmpty);
  });
  testWidgets('achievement preserves custom category and organization', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const AchievementsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-achievements');
    await _type(tester, 'achievement-name', 'Award');
    await _type(tester, 'achievement-description', 'Won award');
    await _type(tester, 'achievement-date', '٠١/٢٠٢٤');
    await _type(tester, 'achievement-category', 'Custom imported');
    await _type(tester, 'achievement-organization', 'University');
    await _tap(tester, 'save-resume-entry');
    expect(r.achievements.single.date, '01/2024');
    await _tap(tester, 'edit-achievement-0');
    await _type(tester, 'achievement-name', 'Updated');
    await _tap(tester, 'save-resume-entry');
    expect(r.achievements.single.category, 'Custom imported');
    expect(r.achievements.single.organization, 'University');
    expect(r.achievements.single.name, 'Updated');
    await _tap(tester, 'delete-achievement-0');
    expect(r.achievements, isEmpty);
  });
  testWidgets('interests add, deduplicate, edit, cancel, toggle and remove', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const InterestsStep()));
    await tester.pumpAndSettle();
    await _type(tester, 'interest-name', 'Reading');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Reading']);
    await _type(tester, 'interest-name', ' reading ');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Reading']);
    await _tap(tester, 'edit-interest-0');
    await _type(tester, 'interest-name', 'Custom hobby');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'edit-interest-0');
    await _type(tester, 'interest-name', 'Discard');
    await _tap(tester, 'cancel-interest');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'interest-suggestion-Reading');
    expect(r.interests, ['Custom hobby', 'Reading']);
    await _tap(tester, 'interest-suggestion-Reading');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'delete-interest-0');
    expect(r.interests, isEmpty);
  });
  for (final width in [320.0, 800.0, 1920.0]) {
    for (final kind in ['projects', 'achievements', 'interests']) {
      testWidgets('$kind Arabic scaled text at $width', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final r = _prepare().currentResume.value!;
        r.projects.add(
          Project(
            name: 'مشروع طويل في تطوير التطبيقات',
            description: 'تطوير حلول تقنية متقدمة ومتنوعة',
            startDate: '01/2024',
            isCurrent: true,
            technologies: ['Flutter', 'Dart'],
          ),
        );
        r.achievements.add(
          Achievement(
            name: 'إنجاز طويل في تطوير البرمجيات',
            description: 'وصف تفصيلي للإنجاز',
            date: '01/2024',
            category: 'تصنيف مخصص',
          ),
        );
        r.interests = ['اهتمام مخصص طويل في تطوير البرمجيات'];
        await tester.pumpWidget(
          _host(
            switch (kind) {
              'projects' => const ProjectsStep(),
              'achievements' => const AchievementsStep(),
              _ => const InterestsStep(),
            },
            scale: 2,
            arabic: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (kind != 'interests') {
          await _tap(tester, 'add-$kind');
          expect(tester.takeException(), isNull);
          final surface = find.byKey(
            const ValueKey('resume-form-dialog-surface'),
          );
          expect(
            tester.getSize(surface).width,
            lessThanOrEqualTo(
              width < 600
                  ? 500
                  : width < 1200
                  ? 600
                  : 650,
            ),
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('save-resume-entry')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        } else {
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('edit-interest-0')),
            300,
            scrollable: find.byType(Scrollable).first,
          );
          await _tap(tester, 'edit-interest-0');
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}

```



التحقق النهائي: نجحت جميع اختبارات المشروع وعددها 220 اختباراً، منها 12 اختباراً جديداً لهذه الدفعة. تبقى 27 ملاحظة غير مانعة في ملف المعاينة القديم، دون أخطاء تحليل.
