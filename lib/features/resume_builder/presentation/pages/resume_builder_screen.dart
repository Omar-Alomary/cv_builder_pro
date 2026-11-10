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
import '../../../../shared_widgets/index.dart';
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
  bool _draftReady = false;

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
    // Previous routes still observe this controller while navigation builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Rx ignores equal copies; detach the previous editing session first.
      _resumes.currentResume.value = null;
      _resumes.currentResume.value = draft;
      _resumes.isEditing.value = draft.id != null;
      _resumes.lastSavedAt.value = null;
      _resumes.lastSaveWasAutomatic.value = false;
      _resumes.startAutoSave();
      setState(() => _draftReady = true);
    });
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
    final draft = _resumes.currentResume.value;
    final empty = draft == null || draft.fullName.trim().isEmpty;
    if (forceSave && empty) {
      AppSnackbar.warning(context, 'resume_is_empty'.tr);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    _resumes.stopAutoSave();
    try {
      if (draft != null &&
          !empty &&
          (forceSave || _dirty(draft)) &&
          !await _resumes.saveResume(draft)) {
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
    final draft = _resumes.currentResume.value;
    if (draft == null || draft.fullName.trim().isEmpty) {
      AppSnackbar.warning(context, 'resume_is_empty'.tr);
      return;
    }
    if (_busy || (saveFirst && !_validatePersonal())) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    _resumes.stopAutoSave();
    try {
      if (saveFirst && !await _resumes.saveResume(draft)) {
        return;
      }
      if (mounted) await Get.toNamed<void>(AppRoutes.preview);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
    } finally {
      if (mounted) {
        _resumes.startAutoSave();
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _showTemplatePickerDialog() async {
    if (_busy) return;
    final draft = _resumes.currentResume.value;
    if (draft == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    _resumes.stopAutoSave();
    try {
      await ResumeTemplatePicker.show(context, draft);
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
  Widget build(BuildContext context) {
    if (!_draftReady) {
      return const Scaffold(body: SafeArea(child: AppLoading()));
    }
    return Obx(() {
      final draft = _resumes.currentResume.value;
      if (draft == null) {
        return Scaffold(
          appBar: AppBar(title: Text('create_resume'.tr)),
          body: SafeArea(
            child: AppEmptyState(
              title: 'resume_is_empty'.tr,
              actionLabel: 'create_resume'.tr,
              onAction: () => Get.offNamed<void>(AppRoutes.resumeBuilder),
            ),
          ),
        );
      }
      final empty = draft.fullName.trim().isEmpty;
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
            Row(
              children: [
                AppTemplateIcon(
                  templateId: draft.templateId,
                  size: AppSpacing.xl,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _templates
                            .getTemplateById(draft.templateId)
                            ?.localizedName ??
                        draft.templateId,
                    style: AppTextStyles.resolve(context, AppTextStyles.caption)
                        .copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, ?current],
              ),
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
      final compactToolbar = Responsive.isMobile(context) || scale > 1.3;
      final toolbarActions = [
        IconButton(
          key: const ValueKey('builder-change-template'),
          tooltip: 'change_template'.tr,
          icon: const Icon(Icons.palette_outlined),
          onPressed: _busy ? null : _showTemplatePickerDialog,
        ),
        ResumeJsonExportButton(
          key: const ValueKey('builder-export-json'),
          resume: () => _resumes.currentResume.value,
        ),
        IconButton(
          key: const ValueKey('builder-preview'),
          tooltip: 'preview'.tr,
          icon: const Icon(Icons.visibility_outlined),
          onPressed: _busy || empty ? null : _preview,
        ),
        IconButton(
          key: const ValueKey('builder-save-close'),
          tooltip: 'builder_save_close'.tr,
          icon: const Icon(Icons.save_outlined),
          onPressed: _busy || empty ? null : () => _leave(forceSave: true),
        ),
      ];
      return PopScope(
        canPop: _allowPop,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _leave();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _resumes.isEditing.value ? 'edit_resume'.tr : 'create_resume'.tr,
              key: const ValueKey('builder-title'),
              maxLines: 2,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.h4,
              ).copyWith(fontSize: 18),
            ),
            toolbarHeight:
                AppSpacing.touchTarget +
                AppSpacing.sm +
                math.max(0, scale - 1) * AppSpacing.xxxl,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                AppSpacing.xl +
                    AppSpacing.lg * scale +
                    (compactToolbar ? AppSpacing.touchTarget : 0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (compactToolbar)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: toolbarActions,
                      ),
                    ),
                  Padding(
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
                ],
              ),
            ),
            leading: BackButton(onPressed: _busy ? null : _leave),
            actions: compactToolbar ? null : toolbarActions,
          ),
          body: SafeArea(
            child: Responsive.maxWidth(
              width: 900,
              child: Column(
                children: [
                  Expanded(
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
                                  height: math.max(
                                    280,
                                    constraints.maxHeight * .65,
                                  ),
                                  child: content,
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            header,
                            Expanded(child: content),
                          ],
                        );
                      },
                    ),
                  ),
                  navigation,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _resumes.stopAutoSave();
    super.dispose();
  }
}
