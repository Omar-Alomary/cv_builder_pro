# UI/UX — Batch 7: Resume Builder + Steps
أعيد تصميم شاشة بناء السيرة وخطواتها داخل طبقة العرض. لم تتغير النماذج أو المتحكمات أو المستودع أو الخدمات أو قواعد التحقق أو الترجمات أو الاعتماديات.
مؤشر المراحل: دوائر مرقمة وروابط وعلامات تحقق للمراحل السابقة، مع إبقاء ChoiceChip ودلالات الاختيار الأصلية. تتحرك القائمة الأفقية لإظهار المرحلة الحالية عند تغيرها. حالة الحفظ الحقيقية انتقلت إلى شريط العنوان مع أيقونة، وتعرض المسودة الجديدة والتغييرات المنتظرة والحفظ التلقائي والحفظ الجاري وفق المتحكم القائم.
التنقل: AnimatedSwitcher للمراحل والأقسام الإضافية مع احترام تقليل الحركة، وأزرار سابقة بإطار وتالية متدرجة. بقي نموذج البيانات الشخصية مثبتاً في الشجرة حتى عند إخفائه، فلا يفقد حالة الحقول والتحقق عند الانتقال. بقيت مسارات المعاينة والحفظ عند الخروج وتصدير JSON كما هي.
البيانات الشخصية: AppAvatar دائري مع بديل الاسم أو الصورة، وأيقونة كاميرا وزر اختيار يتشاركان منع التكرار. أضيفت أيقونات الحقول واستخدمت مسافات النظام. تبقى أزواج الاسم/البريد والهاتف/العنوان في صفوف على التابلت وسطح المكتب. تظل الحقول المخفية حسب القالب محفوظة في النموذج.
التعليم والخبرة والدورات والشهادات واللغات والمشاريع والإنجازات: ResumeEntryCard موحد بسطح وظل وأيقونة القسم وأزرار تعديل وحذف. أضيف ResumeReorderableList بمقابض سحب ظاهرة وإجراءات إعادة الترتيب الدلالية الأصلية في Flutter. يغير السحب ترتيب قائمة المسودة ويبلغ المتحكم بالتحديث، فتستخدم آلية الحفظ القائمة الترتيب الجديد؛ لا يوجد مسار تخزين جديد. بقيت نوافذ التحرير المنفصلة والتحقق والإلغاء دون تغيير.
المهارات: نموذج ببطاقة، Slider بخمس درجات، مؤشر LinearProgressIndicator متدرج، وشارات ملونة للمستوى مع قيمة نصية حتى لا يعتمد المعنى على اللون. بقي منع التكرار والإضافة والتحرير والحذف والتحقق من المسودة كما هو. الاهتمامات تستخدم عنوان القسم الموحد وبطاقات الإدخالات الجديدة مع الحفاظ على الاقتراحات والاختيار ومنع التكرار.
التحقق: flutter analyze دون ملاحظات، وجميع اختبارات المشروع الـ472 ناجحة، ومنها اختبارات البناء السابقة الـ57. أضيفت 29 حالة تشغيل عادية: 20 حالة تمر بجميع المراحل والأقسام الإضافية عند عروض 320/390/600/1024/1920 مع اللغتين والوضعين وتكبير النص 200%، و7 حالات تتحقق من حفظ إعادة ترتيب الأقسام وعدم تعديل نسخة المصدر قبل الحفظ، وحالة سحب فعلي بحركة مؤشر متدرجة، وحالة تنقل مع تفعيل الحركة للحفاظ على نص النموذج. يستخدم اختبار جميع الأقسام إعداد ATS لإظهار كل الأقسام؛ لم تتغير إعدادات القوالب الإنتاجية. ارتفاع 480 عند عرض 1024 يغطي الوضع الأفقي. تضاف 4 حالات التقاط صور فقط عند تفعيل WRITE_UI_PREVIEWS، وتولد 8 صور بخطوط التطبيق الفعلية. لم يُكرر التشغيل على جهاز فعلي في هذه الدفعة.
## المعاينات
[personal — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_personal_light_en_390.png)
[personal — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_personal_light_en_1920.png)
[personal — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_personal_dark_ar_390.png)
[personal — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_personal_dark_ar_1920.png)
[skills — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_skills_light_en_390.png)
[skills — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_skills_light_en_1920.png)
[skills — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_skills_dark_ar_390.png)
[skills — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_07_skills_dark_ar_1920.png)
## الملفات كاملة
1. lib/features/resume_builder/presentation/pages/resume_builder_screen.dart
2. lib/features/resume_builder/presentation/steps/achievements_step.dart
3. lib/features/resume_builder/presentation/steps/additional_info_step.dart
4. lib/features/resume_builder/presentation/steps/certificates_step.dart
5. lib/features/resume_builder/presentation/steps/courses_step.dart
6. lib/features/resume_builder/presentation/steps/education_step.dart
7. lib/features/resume_builder/presentation/steps/experience_step.dart
8. lib/features/resume_builder/presentation/steps/interests_step.dart
9. lib/features/resume_builder/presentation/steps/languages_step.dart
10. lib/features/resume_builder/presentation/steps/personal_info_step.dart
11. lib/features/resume_builder/presentation/steps/projects_step.dart
12. lib/features/resume_builder/presentation/steps/skills_step.dart
13. lib/features/resume_builder/presentation/widgets/step_indicator.dart
14. lib/features/resume_builder/presentation/widgets/navigation_buttons.dart
15. lib/features/resume_builder/presentation/widgets/resume_entry_card.dart
16. lib/features/resume_builder/presentation/widgets/resume_reorderable_list.dart
17. lib/features/resume_builder/presentation/widgets/skill_level_indicator.dart
18. lib/features/resume_builder/index.dart
19. test/resume_builder/redesign_builder_test.dart

## lib/features/resume_builder/presentation/pages/resume_builder_screen.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/index.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../steps/personal_info_step.dart';
import '../steps/additional_info_step.dart';
import '../steps/education_step.dart';
import '../steps/experience_step.dart';
import '../steps/skills_step.dart';
import '../widgets/step_indicator.dart';
import '../widgets/navigation_buttons.dart';
import '../widgets/resume_json_export_button.dart';

/// Responsive editor with independent drafts and guarded save/navigation flows.
class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});
  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _resumes = Get.find<ResumeController>();
  final _templates = Get.find<TemplateController>();
  final _personal = GlobalKey<PersonalInfoStepState>();
  late final ResumeModel _initial;
  int _step = 0;
  int _additional = 0;
  bool _busy = false;
  bool _allowPop = false;
  bool _personalInvalid = false;

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    final draft = argument is ResumeModel
        ? argument.copyWith()
        : ResumeModel(
            templateId:
                argument is String &&
                    AppConstants.templateIds.contains(argument)
                ? argument
                : AppConstants.defaultTemplateId,
          );
    _initial = draft.copyWith();
    _resumes.stopAutoSave();
    _resumes.currentResume.value = draft;
    _resumes.isEditing.value = draft.id != null;
    _resumes.lastSavedAt.value = null;
    _resumes.lastSaveWasAutomatic.value = false;
    _resumes.startAutoSave();
  }

  bool _dirty(ResumeModel draft) {
    for (final saved in _resumes.resumes) {
      if (draft.id != null && saved.id == draft.id) return saved != draft;
    }
    return draft != _initial;
  }

  bool _validatePersonal() {
    final valid = _personal.currentState?.validate() ?? false;
    setState(() {
      _personalInvalid = !valid;
      if (!valid) _step = 0;
    });
    return valid;
  }

  Future<void> _leave({bool forceSave = false}) async {
    if (_busy || !Navigator.of(context).canPop()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    _resumes.stopAutoSave();
    try {
      final draft = _resumes.currentResume.value!;
      if ((forceSave || _dirty(draft)) && !await _resumes.saveResume(draft)) {
        _resumes.startAutoSave();
        return;
      }
      if (!mounted) return;
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
      _resumes.startAutoSave();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _preview({bool saveFirst = false}) async {
    if (_busy || (saveFirst && !_validatePersonal())) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    _resumes.stopAutoSave();
    try {
      if (saveFirst &&
          !await _resumes.saveResume(_resumes.currentResume.value!)) {
        return;
      }
      if (mounted) await Get.toNamed<void>(AppRoutes.preview);
    } finally {
      if (mounted) {
        _resumes.startAutoSave();
        setState(() => _busy = false);
      }
    }
  }

  void _select(int step) {
    if (_busy || (step != 0 && _step == 0 && !_validatePersonal())) return;
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
  }

  void _previous() {
    if (_busy) return;
    setState(() {
      if (_step == 4 && _additional > 0) {
        _additional--;
      } else if (_step > 0) {
        _step--;
      }
    });
  }

  Future<void> _next(int totalSteps, int additionalCount) async {
    if (_busy || (_step == 0 && !_validatePersonal())) return;
    FocusScope.of(context).unfocus();
    if (_step < totalSteps - 1) {
      setState(() => _step++);
    } else if (_step == 4 && _additional < additionalCount - 1) {
      setState(() => _additional++);
    } else {
      await _preview(saveFirst: true);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final draft = _resumes.currentResume.value!;
    final fields = _templates.getFieldsForTemplate(draft.templateId);
    final sections = AdditionalInfoStep.sectionKeys(fields);
    final labels = [
      'personal_info'.tr,
      'education'.tr,
      'experience'.tr,
      'skills'.tr,
      if (sections.isNotEmpty) 'additional_info'.tr,
    ];
    final step = _step.clamp(0, labels.length - 1);
    final additional = _additional
        .clamp(0, math.max(0, sections.length - 1))
        .toInt();
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final dirty = _dirty(draft);
    final status = _resumes.isSaving.value
        ? 'saving'
        : dirty
        ? 'builder_unsaved'
        : _resumes.lastSaveWasAutomatic.value &&
              _resumes.lastSavedAt.value == draft.updatedAt
        ? 'auto_saved'
        : draft.id != null
        ? 'builder_saved'
        : 'builder_new_draft';
    final header = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepIndicator(
            labels: labels,
            currentStep: step,
            onSelected: _busy ? null : _select,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_personalInvalid)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  'builder_fix_personal'.tr,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    );
    final content = IgnorePointer(
      ignoring: _busy,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: step != 0,
            child: PersonalInfoStep(key: _personal),
          ),
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppTheme.motionDuration,
            layoutBuilder: (current, previous) =>
                Stack(fit: StackFit.expand, children: [...previous, ?current]),
            child: KeyedSubtree(
              key: ValueKey('builder-content-$step'),
              child: switch (step) {
                1 => const EducationStep(),
                2 => const ExperienceStep(),
                3 => const SkillsStep(),
                4 when sections.isNotEmpty => AdditionalInfoStep(
                  fields: fields,
                  selectedIndex: additional,
                  onSelected: (index) => setState(() => _additional = index),
                ),
                _ => const SizedBox(),
              },
            ),
          ),
        ],
      ),
    );
    final navigation = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NavigationButtons(
        canGoBack: step > 0,
        isLastStep:
            step == labels.length - 1 &&
            (step != 4 || additional == sections.length - 1),
        busy: _busy,
        onPrevious: _previous,
        onNext: () => _next(labels.length, sections.length),
      ),
    );
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _resumes.isEditing.value ? 'edit_resume'.tr : 'create_resume'.tr,
          ),
          toolbarHeight:
              AppSpacing.touchTarget +
              AppSpacing.sm +
              math.max(0, scale - 1) * AppSpacing.xxl,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              AppSpacing.xl + AppSpacing.lg * scale,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Icon(
                      _resumes.isSaving.value
                          ? Icons.sync
                          : dirty
                          ? Icons.edit_note
                          : Icons.cloud_done_outlined,
                      size: AppSpacing.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        status.tr,
                        key: const ValueKey('builder-save-status'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.resolve(
                              context,
                              AppTextStyles.caption,
                            ).copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          leading: BackButton(onPressed: _busy ? null : _leave),
          actions: [
            ResumeJsonExportButton(
              key: const ValueKey('builder-export-json'),
              resume: () => _resumes.currentResume.value,
            ),
            IconButton(
              key: const ValueKey('builder-preview'),
              tooltip: 'preview'.tr,
              icon: const Icon(Icons.visibility_outlined),
              onPressed: _busy ? null : _preview,
            ),
            IconButton(
              key: const ValueKey('builder-save-close'),
              tooltip: 'builder_save_close'.tr,
              icon: const Icon(Icons.save_outlined),
              onPressed: _busy ? null : () => _leave(forceSave: true),
            ),
          ],
        ),
        body: SafeArea(
          child: Responsive.maxWidth(
            width: 900,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxHeight < 600) {
                  return SingleChildScrollView(
                    key: const ValueKey('builder-compact-scroll'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        SizedBox(
                          height: math.max(280, constraints.maxHeight * .65),
                          child: content,
                        ),
                        navigation,
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    Expanded(child: content),
                    navigation,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  });
  @override
  void dispose() {
    _resumes.stopAutoSave();
    super.dispose();
  }
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
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

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
    return ResumeReorderableList(
      key: const PageStorageKey('achievements-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-achievements'),
            label: 'add_achievement'.tr,
            icon: Icons.emoji_events_outlined,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_achievements_added'.tr,
              icon: Icons.emoji_events_outlined,
            ),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
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

## lib/features/resume_builder/presentation/steps/additional_info_step.dart
```dart
import '../../../../app/theme/index.dart';
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
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              for (var index = 0; index < sections.length; index++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
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
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppTheme.motionDuration,
            layoutBuilder: (current, previous) =>
                Stack(fit: StackFit.expand, children: [...previous, ?current]),
            child: KeyedSubtree(
              key: ValueKey(sections[selected]),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

```

## lib/features/resume_builder/presentation/steps/certificates_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/certificate.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/certificate_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Certificate list supporting isolated dialog edits and reactive CRUD updates.
class CertificatesStep extends StatefulWidget {
  const CertificatesStep({super.key});
  @override
  State<CertificatesStep> createState() => _CertificatesStepState();
}

class _CertificatesStepState extends State<CertificatesStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null ||
        (index != null && index >= target.certificates.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Certificate>(
        context: context,
        builder: (_) => CertificateDialog(
          certificate: index == null ? null : target.certificates[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.certificates.add(result);
      } else if (index < target.certificates.length) {
        target.certificates[index] = result;
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
    final entries = target?.certificates ?? <Certificate>[];
    return ResumeReorderableList(
      key: const PageStorageKey('certificates-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-certificates'),
            label: 'add_certificate'.tr,
            icon: Icons.verified_outlined,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_certificates_added'.tr,
              icon: Icons.verified_outlined,
            ),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
            entryKey: 'certificate-$index',
            title: entries[index].name,
            details: [
              entries[index].organization,
              entries[index].year,
              entries[index].credentialId ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.certificates.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}

```

## lib/features/resume_builder/presentation/steps/courses_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/course.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/course_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Course list supporting isolated dialog edits and reactive CRUD updates.
class CoursesStep extends StatefulWidget {
  const CoursesStep({super.key});
  @override
  State<CoursesStep> createState() => _CoursesStepState();
}

class _CoursesStepState extends State<CoursesStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null || (index != null && index >= target.courses.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Course>(
        context: context,
        builder: (_) =>
            CourseDialog(course: index == null ? null : target.courses[index]),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.courses.add(result);
      } else if (index < target.courses.length) {
        target.courses[index] = result;
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
    final entries = target?.courses ?? <Course>[];
    return ResumeReorderableList(
      key: const PageStorageKey('courses-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-courses'),
            label: 'add_course'.tr,
            icon: Icons.menu_book_outlined,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_courses_added'.tr,
              icon: Icons.menu_book_outlined,
            ),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
            entryKey: 'course-$index',
            title: entries[index].name,
            details: [
              entries[index].provider,
              entries[index].year,
              entries[index].certificateUrl ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.courses.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}

```

## lib/features/resume_builder/presentation/steps/education_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/education.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/education_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Education list supporting isolated dialog edits and reactive CRUD updates.
class EducationStep extends StatefulWidget {
  const EducationStep({super.key});
  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null || (index != null && index >= target.education.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Education>(
        context: context,
        builder: (_) => EducationDialog(
          education: index == null ? null : target.education[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.education.add(result);
      } else if (index < target.education.length) {
        target.education[index] = result;
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
    final entries = target?.education ?? <Education>[];
    return ResumeReorderableList(
      key: const PageStorageKey('education-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-education'),
            label: 'add_education'.tr,
            icon: Icons.school_outlined,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_education_added'.tr,
              icon: Icons.school_outlined,
            ),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
            entryKey: 'education-$index',
            title: entries[index].degree,
            details: [
              entries[index].institution,
              entries[index].year,
              if (entries[index].grade?.isNotEmpty ?? false)
                '${'grade'.tr}: ${entries[index].grade}',
              entries[index].description ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.education.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}

```

## lib/features/resume_builder/presentation/steps/experience_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/experience.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/experience_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Work history list with localized current employment and complete descriptions.
class ExperienceStep extends StatefulWidget {
  const ExperienceStep({super.key});
  @override
  State<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends State<ExperienceStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null ||
        (index != null && index >= target.experience.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Experience>(
        context: context,
        builder: (_) => ExperienceDialog(
          experience: index == null ? null : target.experience[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.experience.add(result);
      } else if (index < target.experience.length) {
        target.experience[index] = result;
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
    final entries = target?.experience ?? <Experience>[];
    return ResumeReorderableList(
      key: const PageStorageKey('experience-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-experience'),
            label: 'add_experience'.tr,
            icon: Icons.work_outline,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_experience_added'.tr,
              icon: Icons.work_outline,
            ),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
            entryKey: 'experience-$index',
            title: entries[index].jobTitle,
            details: [
              entries[index].company,
              '${entries[index].startDate} - ${entries[index].isCurrent ? 'builder_present'.tr : entries[index].endDate ?? ''}',
              entries[index].description ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.experience.removeAt(index);
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
import '../../../../app/theme/index.dart';
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
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.icon),
        AppSectionHeader(title: 'builder_interest_suggestions'.tr),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
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
        const SizedBox(height: AppSpacing.icon),
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

## lib/features/resume_builder/presentation/steps/languages_step.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/language.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/language_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Language list supporting isolated dialog edits and reactive CRUD updates.
class LanguagesStep extends StatefulWidget {
  const LanguagesStep({super.key});
  @override
  State<LanguagesStep> createState() => _LanguagesStepState();
}

class _LanguagesStepState extends State<LanguagesStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null || (index != null && index >= target.languages.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Language>(
        context: context,
        builder: (_) => ResumeLanguageDialog(
          language: index == null ? null : target.languages[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.languages.add(result);
      } else if (index < target.languages.length) {
        target.languages[index] = result;
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
    final entries = target?.languages ?? <Language>[];
    return ResumeReorderableList(
      key: const PageStorageKey('languages-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-languages'),
            label: 'add_language'.tr,
            icon: Icons.translate,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_languages_added'.tr,
              icon: Icons.translate,
            ),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
            entryKey: 'language-$index',
            title: entries[index].name,
            details: [ResumeLanguageDialog.levelLabel(entries[index].level)],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.languages.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}

```

## lib/features/resume_builder/presentation/steps/personal_info_step.dart
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/index.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared_widgets/index.dart';

/// Responsive personal information form preserving hidden template fields.
class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key, this.imageService});
  final SettingsService? imageService;
  @override
  State<PersonalInfoStep> createState() => PersonalInfoStepState();
}

/// Form state exposing validation to the editor's navigation controls.
class PersonalInfoStepState extends State<PersonalInfoStep> {
  final _form = GlobalKey<FormState>();
  bool _picking = false;
  final _resumes = Get.find<ResumeController>();
  final _controls = <String, TextEditingController>{};
  @override
  void initState() {
    super.initState();
    final json = _resumes.currentResume.value!.toJson();
    for (final field in [
      'fullName',
      'email',
      'phone',
      'address',
      'summary',
      'linkedin',
      'github',
      'website',
      'portfolio',
    ]) {
      _controls[field] = TextEditingController(
        text: json[field] as String? ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant PersonalInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final json = _resumes.currentResume.value!.toJson();
    for (final entry in _controls.entries) {
      final value = json[entry.key] as String? ?? '';
      if (entry.value.text != value) entry.value.text = value;
    }
  }

  bool validate() => _form.currentState?.validate() ?? false;
  void _update(String field, String value) {
    final resume = _resumes.currentResume.value!;
    final nullable = value.isEmpty ? null : value;
    switch (field) {
      case 'fullName':
        resume.fullName = value;
      case 'email':
        resume.email = value;
      case 'phone':
        resume.phone = value;
      case 'address':
        resume.address = nullable;
      case 'summary':
        resume.summary = nullable;
      case 'linkedin':
        resume.linkedin = nullable;
      case 'github':
        resume.github = nullable;
      case 'website':
        resume.website = nullable;
      case 'portfolio':
        resume.portfolio = nullable;
    }
    _resumes.currentResume.refresh();
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final path = await (widget.imageService ?? SettingsService())
          .pickProfileImage();
      if (path == null || !mounted) return;
      _resumes.currentResume.value!.profilePicture = path;
      _resumes.currentResume.refresh();
      setState(() {});
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'profile_image_failed'.tr);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Widget _field(
    String field,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool ltr = false,
    int lines = 1,
  }) => AppTextField(
    key: ValueKey('personal-$field'),
    controller: _controls[field],
    label: label.tr,
    prefixIcon: Icon(switch (field) {
      'fullName' => Icons.person_outline,
      'email' => Icons.alternate_email,
      'phone' => Icons.phone_outlined,
      'address' => Icons.location_on_outlined,
      'summary' => Icons.notes_outlined,
      _ => Icons.link,
    }),
    validator: validator,
    keyboardType: keyboard,
    textDirection: ltr ? TextDirection.ltr : null,
    maxLines: lines,
    onChanged: (value) => _update(field, value),
  );
  Widget _pair(Widget first, Widget? second) {
    if (second == null) return first;
    if (Responsive.isTabletOrLarger(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: second),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        first,
        const SizedBox(height: AppSpacing.lg),
        second,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resume = _resumes.currentResume.value!;
    final fields = Get.find<TemplateController>().getFieldsForTemplate(
      resume.templateId,
    );
    return SingleChildScrollView(
      key: const PageStorageKey('personal-scroll'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fields.showProfilePicture) ...[
              Center(
                child: AppAvatar(
                  name: resume.fullName,
                  size: AppSpacing.avatar + AppSpacing.xl,
                  image: resume.profilePicture?.isNotEmpty == true
                      ? FileImage(File(resume.profilePicture!))
                      : null,
                  onCameraPressed: _picking ? null : _pickImage,
                  semanticsLabel: 'change_profile_image'.tr,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                key: const ValueKey('personal-pick-image'),
                label: 'change_profile_image'.tr,
                icon: Icons.camera_alt_outlined,
                onPressed: _pickImage,
                isLoading: _picking,
                fullWidth: true,
              ),
              if (resume.profilePicture != null)
                AppButton(
                  label: 'builder_remove_photo'.tr,
                  variant: AppButtonVariant.text,
                  onPressed: () {
                    resume.profilePicture = null;
                    _resumes.currentResume.refresh();
                    setState(() {});
                  },
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
            _pair(
              _field(
                'fullName',
                'full_name',
                validator: (value) =>
                    Validators.validateRequired(value, 'full_name'.tr),
              ),
              _field(
                'email',
                'email',
                validator: Validators.validateEmail,
                keyboard: TextInputType.emailAddress,
                ltr: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _pair(
              _field(
                'phone',
                'phone',
                validator: Validators.validatePhone,
                keyboard: TextInputType.phone,
                ltr: true,
              ),
              fields.showAddress ? _field('address', 'address') : null,
            ),
            for (final entry in {
              'linkedin': fields.showLinkedin,
              'github': fields.showGithub,
              'website': fields.showWebsite,
              'portfolio': fields.showPortfolio,
            }.entries)
              if (entry.value) ...[
                const SizedBox(height: AppSpacing.lg),
                _field(
                  entry.key,
                  entry.key,
                  validator: Validators.validateUrl,
                  keyboard: TextInputType.url,
                  ltr: true,
                ),
              ],
            if (fields.showSummary) ...[
              const SizedBox(height: AppSpacing.lg),
              _field(
                'summary',
                'summary',
                lines: 5,
                keyboard: TextInputType.multiline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final control in _controls.values) {
      control.dispose();
    }
    super.dispose();
  }
}

```

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
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

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
    return ResumeReorderableList(
      key: const PageStorageKey('projects-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-projects'),
            label: 'add_project'.tr,
            icon: Icons.code,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(title: 'no_projects_added'.tr, icon: Icons.code),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
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

## lib/features/resume_builder/presentation/steps/skills_step.dart
```dart
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
    final target = _resumes.currentResume.value!;
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

```

## lib/features/resume_builder/presentation/widgets/step_indicator.dart
```dart
import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Numbered stages with completion checks, connectors and native selection.
class StepIndicator extends StatefulWidget {
  const StepIndicator({
    super.key,
    required this.labels,
    required this.currentStep,
    required this.onSelected,
  });
  final List<String> labels;
  final int currentStep;
  final ValueChanged<int>? onSelected;
  @override
  State<StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator> {
  final _scroll = ScrollController();
  final _targets = <GlobalKey>[];
  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_scroll.hasClients ||
          widget.currentStep >= _targets.length) {
        return;
      }
      final target = _targets[widget.currentStep].currentContext
          ?.findRenderObject();
      if (target == null) return;
      _scroll.position.ensureVisible(
        target,
        alignment: .5,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppTheme.motionDuration,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(covariant StepIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.labels.length != widget.labels.length) {
      _reveal();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    final currentStep = widget.currentStep;
    final onSelected = widget.onSelected;
    while (_targets.length < labels.length) {
      _targets.add(GlobalKey());
    }
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            KeyedSubtree(
              key: _targets[index],
              child: ChoiceChip(
                key: ValueKey('builder-step-$index'),
                selected: currentStep == index,
                showCheckmark: false,
                side: BorderSide.none,
                backgroundColor: AppColors.transparent,
                selectedColor: AppColors.transparent,
                padding: const EdgeInsets.all(AppSpacing.xs),
                label: SizedBox(
                  width: AppSpacing.xxxl * 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppSpacing.touchTarget,
                        height: AppSpacing.touchTarget,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: index <= currentStep
                              ? AppColors.primaryGradient
                              : null,
                          color: index > currentStep
                              ? scheme.primaryContainer
                              : null,
                          border: Border.all(
                            color: index <= currentStep
                                ? scheme.primary
                                : scheme.outlineVariant,
                          ),
                        ),
                        child: index < currentStep
                            ? const Icon(
                                Icons.check,
                                color: AppColors.lightSurface,
                                size: AppSpacing.xl,
                              )
                            : Text(
                                '${index + 1}',
                                textScaler: TextScaler.noScaling,
                                style: AppTextStyles.h4.copyWith(
                                  color: index == currentStep
                                      ? AppColors.lightSurface
                                      : scheme.primary,
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.resolve(
                              context,
                              AppTextStyles.caption,
                            ).copyWith(
                              color: index == currentStep
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                onSelected: onSelected == null
                    ? null
                    : (_) => onSelected(index),
              ),
            ),
            if (index < labels.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.focusStroke,
                  color: index < currentStep
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

```

## lib/features/resume_builder/presentation/widgets/navigation_buttons.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../../../../app/theme/index.dart';

/// Editor navigation that stacks actions when width or text scale requires it.
class NavigationButtons extends StatelessWidget {
  const NavigationButtons({
    super.key,
    required this.canGoBack,
    required this.isLastStep,
    required this.onPrevious,
    required this.onNext,
    this.busy = false,
  });
  final bool canGoBack;
  final bool isLastStep;
  final bool busy;
  final VoidCallback onPrevious;
  final Future<void> Function() onNext;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final previous = AppButton(
        key: const ValueKey('builder-previous'),
        label: 'previous'.tr,
        icon: Icons.arrow_back,
        fullWidth: true,
        variant: AppButtonVariant.secondary,
        onPressed: busy ? null : onPrevious,
      );
      final next = AppButton(
        key: const ValueKey('builder-next'),
        label: (isLastStep ? 'finish' : 'next').tr,
        icon: isLastStep ? Icons.check : Icons.arrow_forward,
        fullWidth: true,
        onPressed: busy ? null : onNext,
      );
      if (!canGoBack) return next;
      if (constraints.maxWidth < 400 ||
          MediaQuery.textScalerOf(context).scale(14) > 21) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            previous,
            const SizedBox(height: AppSpacing.sm),
            next,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: previous),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 2, child: next),
        ],
      );
    },
  );
}

```

## lib/features/resume_builder/presentation/widgets/resume_entry_card.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Surface entry with tinted section icon and separate edit/delete controls.
class ResumeEntryCard extends StatelessWidget {
  const ResumeEntryCard({
    super.key,
    required this.title,
    required this.details,
    required this.onEdit,
    required this.onDelete,
    required this.entryKey,
    this.footer,
  });
  final String title, entryKey;
  final List<String> details;
  final VoidCallback onEdit, onDelete;
  final Widget? footer;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (entryKey.split('-').first) {
      'education' => Icons.school_outlined,
      'experience' => Icons.work_outline,
      'course' => Icons.menu_book_outlined,
      'certificate' => Icons.verified_outlined,
      'language' => Icons.translate,
      'project' => Icons.code,
      'achievement' => Icons.emoji_events_outlined,
      'skill' => Icons.psychology_outlined,
      _ => Icons.favorite_outline,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    icon,
                    color: scheme.primary,
                    size: AppSpacing.icon,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.resolve(context, AppTextStyles.h4),
                  ),
                ),
              ],
            ),
            for (final detail in details.where(
              (value) => value.trim().isNotEmpty,
            ))
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  detail,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.bodySmall,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.md),
              footer!,
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              children: [
                IconButton(
                  key: ValueKey('edit-$entryKey'),
                  tooltip: 'edit'.tr,
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: scheme.primary),
                ),
                IconButton(
                  key: ValueKey('delete-$entryKey'),
                  tooltip: 'delete'.tr,
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

```

## lib/features/resume_builder/presentation/widgets/resume_reorderable_list.dart
```dart
import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Shared reorderable presentation retaining native drag and semantic actions.
class ResumeReorderableList extends StatelessWidget {
  const ResumeReorderableList({
    super.key,
    required this.header,
    required this.children,
    required this.onReorder,
  });
  final Widget header;
  final List<Widget> children;
  final ReorderCallback onReorder;
  @override
  Widget build(BuildContext context) => ReorderableListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    header: header,
    onReorder: onReorder,
    proxyDecorator: (child, index, animation) => Material(
      color: AppColors.transparent,
      elevation: AppSpacing.sm,
      borderRadius: AppRadii.card,
      child: child,
    ),
    buildDefaultDragHandles: false,
    children: [
      for (var index = 0; index < children.length; index++)
        Row(
          key: children[index].key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[index]),
            ReorderableDragStartListener(
              index: index,
              child: SizedBox.square(
                dimension: AppSpacing.touchTarget,
                child: Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
    ],
  );
}

```

## lib/features/resume_builder/presentation/widgets/skill_level_indicator.dart
```dart
import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Gradient skill level with native progress semantics and a stable text value.
class SkillLevelIndicator extends StatelessWidget {
  const SkillLevelIndicator({
    super.key,
    required this.name,
    required this.level,
  });
  final String name;
  final int level;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: AppRadii.chip,
      child: ColoredBox(
        color: scheme.primaryContainer,
        child: ShaderMask(
          shaderCallback: (bounds) => AppColors.coolGradient.createShader(
            bounds,
            textDirection: Directionality.of(context),
          ),
          blendMode: BlendMode.srcIn,
          child: LinearProgressIndicator(
            minHeight: AppSpacing.sm,
            value: level.clamp(1, 5) / 5,
            color: AppColors.lightSurface,
            backgroundColor: AppColors.transparent,
            semanticsLabel: name,
            semanticsValue: '$level/5',
          ),
        ),
      ),
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
export 'presentation/templates/modern_pdf_template.dart';
export 'presentation/templates/classic_pdf_template.dart';
export 'presentation/templates/business_pdf_template.dart';
export 'presentation/templates/technical_pdf_template.dart';
export 'presentation/templates/pdf_template_options.dart';
export 'presentation/pages/preview_screen.dart';
export 'presentation/widgets/customization_panel.dart';
export 'presentation/widgets/pdf_preview_view.dart';
export 'presentation/widgets/resume_reorderable_list.dart';
export 'presentation/widgets/skill_level_indicator.dart';

```

## test/resume_builder/redesign_builder_test.dart
```dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

ResumeModel _seed() => ResumeModel(
  id: 1,
  fullName: 'Alex Morgan',
  email: 'alex@example.com',
  phone: '+15551234567',
  summary: 'Flutter developer building accessible mobile applications.',
  education: List.generate(
    2,
    (i) => Education(
      degree: 'Degree $i',
      institution: 'University',
      year: '2020',
      description: 'Computer science and software engineering.',
    ),
  ),
  experience: List.generate(
    2,
    (i) => Experience(
      jobTitle: 'Developer $i',
      company: 'Studio',
      startDate: '01/2021',
      isCurrent: true,
      description: 'Developed accessible mobile applications.',
    ),
  ),
  courses: List.generate(
    2,
    (i) => Course(name: 'Course $i', provider: 'Academy', year: '2022'),
  ),
  certificates: List.generate(
    2,
    (i) => Certificate(
      name: 'Certificate $i',
      organization: 'Academy',
      year: '2023',
    ),
  ),
  languages: List.generate(
    2,
    (i) => Language(name: 'Language $i', level: 'advanced'),
  ),
  projects: List.generate(
    2,
    (i) => Project(
      name: 'Project $i',
      description: 'Accessible application',
      startDate: '01/2024',
      isCurrent: true,
      technologies: ['Flutter', 'Dart'],
    ),
  ),
  achievements: List.generate(
    2,
    (i) => Achievement(
      name: 'Achievement $i',
      description: 'Delivered a successful product',
      date: '01/2025',
    ),
  ),
  skills: [
    Skill(name: 'Flutter', level: 5),
    Skill(name: 'Communication', level: 3),
  ],
  interests: ['Reading', 'Coding'],
);

class _Repository implements ResumeRepository {
  ResumeModel saved = _seed();
  @override
  List<ResumeModel> loadResumes() => [saved.copyWith()];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    saved = resume.copyWith(id: 1, updatedAt: DateTime.now());
    return saved.copyWith();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare(_Repository repository) {
  final controller = Get.put(ResumeController(repository: repository));
  Get.put(TemplateController());
  controller.currentResume.value = repository.saved.copyWith();
  return controller;
}

Widget _host(
  Widget child, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
  bool motion = false,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: !motion,
    ),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('builder-capture-boundary'),
    child: child,
  ),
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('builder-capture-boundary')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_07_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget _section(String name) => switch (name) {
  'education' => const EducationStep(),
  'experience' => const ExperienceStep(),
  'courses' => const CoursesStep(),
  'certificates' => const CertificatesStep(),
  'languages' => const LanguagesStep(),
  'projects' => const ProjectsStep(),
  _ => const AchievementsStep(),
};
void main() {
  setUpAll(() async {
    for (final entry in {
      'Poppins': 'assets/fonts/Poppins-Regular.ttf',
      'Cairo': 'assets/fonts/Cairo-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });
  tearDown(Get.reset);
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final arabic in [false, true]) {
      for (final dark in [false, true]) {
        testWidgets('all builder stages $width ar=$arabic dark=$dark scale2', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, width == 1024 ? 480 : 1200);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          _prepare(_Repository());
          // Exercise all optional sections using the ATS field configuration.

          await tester.pumpWidget(
            _host(
              const ResumeBuilderScreen(),
              arabic: arabic,
              dark: dark,
              scale: 2,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Get.find<ResumeController>().currentResume.value = _seed().copyWith(
            templateId: 'ats',
          );
          await tester.pumpAndSettle();
          // Keep validation tied to actual form edits as in the existing tests.
          for (final entry in {
            'fullName': 'Alex Morgan',
            'email': 'alex@example.com',
            'phone': '+15551234567',
          }.entries) {
            final field = find.descendant(
              of: find.byKey(ValueKey('personal-${entry.key}')),
              matching: find.byType(TextFormField),
            );
            await tester.ensureVisible(field);
            await tester.enterText(field, entry.value);
            await tester.pumpAndSettle();
          }
          for (var step = 1; step < 5; step++) {
            await _tap(tester, find.byKey(ValueKey('builder-step-$step')));
            expect(tester.takeException(), isNull);
            if (step == 4) {
              for (final name in [
                'courses',
                'certificates',
                'languages',
                'projects',
                'achievements',
                'interests',
              ]) {
                await _tap(tester, find.byKey(ValueKey('additional-$name')));
                expect(tester.takeException(), isNull);
              }
            }
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        });
      }
    }
  }
  for (final section in [
    'education',
    'experience',
    'courses',
    'certificates',
    'languages',
    'projects',
    'achievements',
  ]) {
    testWidgets('$section reorder survives saving and preserves source copy', (
      tester,
    ) async {
      final repository = _Repository();
      final controller = _prepare(repository);
      await tester.pumpWidget(_host(Scaffold(body: _section(section))));
      await tester.pumpAndSettle();
      final before = controller.currentResume.value!.toJson()[section] as List;
      final first = before.first;
      tester
          .widget<ReorderableListView>(find.byType(ReorderableListView))
          .onReorder(0, 2);
      await tester.pumpAndSettle();
      expect(
        (controller.currentResume.value!.toJson()[section] as List).last,
        first,
      );
      expect((repository.saved.toJson()[section] as List).first, first);
      await controller.saveResume(controller.currentResume.value!);
      expect((repository.saved.toJson()[section] as List).last, first);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('education accepts an actual long-press reorder gesture', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _prepare(_Repository());
    final first = controller.currentResume.value!.education.first;
    await tester.pumpWidget(_host(const Scaffold(body: EducationStep())));
    await tester.pumpAndSettle();
    final cards = find.byType(ResumeEntryCard);
    final point = tester.getCenter(
      find.byType(ReorderableDragStartListener).first,
    );
    final destination =
        tester.getBottomRight(cards.last) - const Offset(100, 10);
    final gesture = await tester.startGesture(point);
    await tester.pump(const Duration(milliseconds: 700));
    for (var segment = 1; segment <= 30; segment++) {
      await gesture.moveTo(Offset.lerp(point, destination, segment / 30)!);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.currentResume.value!.education.last, same(first));
  });
  testWidgets('step animations retain personal form edits', (tester) async {
    _prepare(_Repository());
    await tester.pumpWidget(_host(const ResumeBuilderScreen(), motion: true));
    await tester.pumpAndSettle();
    for (final entry in {
      'fullName': 'Alex Morgan',
      'email': 'alex@example.com',
      'phone': '+15551234567',
    }.entries) {
      final field = find.descendant(
        of: find.byKey(ValueKey('personal-${entry.key}')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
      await tester.pumpAndSettle();
    }
    await _tap(tester, find.byKey(const ValueKey('builder-step-1')));
    await _tap(tester, find.byKey(const ValueKey('builder-step-0')));
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('personal-fullName')),
              matching: find.byType(TextFormField),
            ),
          )
          .controller!
          .text,
      'Alex Morgan',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  if (const bool.fromEnvironment('WRITE_UI_PREVIEWS')) {
    for (final dark in [false, true]) {
      for (final width in [390.0, 1920.0]) {
        testWidgets('capture builder and skills $width dark=$dark', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final controller = _prepare(_Repository());
          await tester.pumpWidget(
            _host(const ResumeBuilderScreen(), arabic: dark, dark: dark),
          );
          await tester.pumpAndSettle();
          await _capture(
            tester,
            'personal_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
          );
          controller.currentResume.value = _seed();
          await tester.pumpAndSettle();
          await _tap(tester, find.byKey(const ValueKey('builder-step-3')));
          await _capture(
            tester,
            'skills_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        });
      }
    }
  }
}

```


