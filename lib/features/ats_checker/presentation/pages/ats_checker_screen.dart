import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/ats_controller.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/ats_scorer.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/ats_score_gauge.dart';
import '../widgets/ats_issues_list.dart';
import '../widgets/ats_suggestions_card.dart';

/// Checks the current draft or a selected saved resume without mutating it.
class ATSCheckerScreen extends StatefulWidget {
  const ATSCheckerScreen({super.key});
  @override
  State<ATSCheckerScreen> createState() => _ATSCheckerScreenState();
}

class _ATSCheckerScreenState extends State<ATSCheckerScreen> {
  final _ats = Get.find<AtsController>();
  final _resumes = Get.find<ResumeController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ats.analyze();
    });
  }

  Future<void> _edit() async {
    await _ats.editResume();
    if (mounted) _ats.analyze();
  }

  Future<void> _choose() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.value<double>(
              context: dialogContext,
              mobile: 500,
              tablet: 600,
              desktop: 650,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ats_choose_resume'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_resumes.resumes.isEmpty) Text('no_resumes_found'.tr),
                      for (final resume in _resumes.getRecentResumes(
                        limit: _resumes.resumes.length,
                      ))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppButton(
                            key: ValueKey('ats-select-${resume.id}'),
                            label: resume.fullName.trim().isEmpty
                                ? 'untitled_resume'.tr
                                : resume.fullName,
                            fullWidth: true,
                            onPressed: () {
                              _resumes.currentResume.value = resume.copyWith();
                              _ats.analyze();
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'cancel'.tr,
                  variant: AppButtonVariant.text,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(
        title: Text('ats_checker'.tr),
        toolbarHeight:
            AppSpacing.touchTarget +
            AppSpacing.sm +
            math.max(0, scale - 1) * AppSpacing.xxl,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('ats-scroll'),
            padding: Responsive.pagePadding(context),
            child: Obx(() {
              final resume = _resumes.currentResume.value;
              final empty = resume == null || resume.fullName.trim().isEmpty;
              final result = _ats.result.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    key: const ValueKey('ats-choose-resume'),
                    label: 'ats_choose_resume'.tr,
                    icon: Icons.folder_open,
                    onPressed: _ats.isApplyingTemplate.value ? null : _choose,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('ats_guidance'.tr),
                  const SizedBox(height: AppSpacing.sm),
                  Text('ats_formatting_note'.tr),
                  if (resume != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      resume.fullName.trim().isEmpty
                          ? 'untitled_resume'.tr
                          : resume.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                  if (_ats.errorMessage.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _ats.errorMessage.value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  if (_ats.isAnalyzing.value)
                    AppLoading(message: 'ats_checking'.tr)
                  else if (!empty && result != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Builder(
                      builder: (context) {
                        final summary = AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AtsScoreGauge(score: result.overallScore),
                              const SizedBox(height: AppSpacing.xl),
                              for (final entry in result.sectionScores.entries)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.xs,
                                        children: [
                                          Text(
                                            'ats_section_${entry.key}'.tr,
                                            style: AppTextStyles.resolve(
                                              context,
                                              AppTextStyles.bodySmall,
                                            ),
                                          ),
                                          Text(
                                            '${entry.value}/${AtsScorer.sectionMaximums[entry.key]}',
                                            style: AppTextStyles.resolve(
                                              context,
                                              AppTextStyles.label,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      LinearProgressIndicator(
                                        key: ValueKey(
                                          'ats-section-progress-${entry.key}',
                                        ),
                                        value:
                                            (entry.value /
                                                    (AtsScorer
                                                            .sectionMaximums[entry
                                                            .key] ??
                                                        1))
                                                .clamp(0.0, 1.0),
                                        minHeight: AppSpacing.sm,
                                        borderRadius: AppRadii.chip,
                                        semanticsLabel:
                                            'ats_section_${entry.key}'.tr,
                                        semanticsValue:
                                            '${entry.value}/${AtsScorer.sectionMaximums[entry.key]}',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                        final issues = AtsIssuesList(
                          issues: result.issues,
                          onEdit: _edit,
                        );
                        if (Responsive.isTabletOrLarger(context)) {
                          return Row(
                            key: const ValueKey('ats-wide-layout'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: summary),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(flex: 2, child: issues),
                            ],
                          );
                        }
                        return Column(
                          key: const ValueKey('ats-mobile-layout'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            summary,
                            const SizedBox(height: AppSpacing.lg),
                            issues,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AtsSuggestionsCard(
                      suggestions: result.suggestions,
                      missingKeywords: result.missingKeywords,
                      onEdit: _edit,
                    ),
                  ],
                  if (empty)
                    AppEmptyState(
                      title: 'no_resume_to_check'.tr,
                      actionLabel: 'create_resume'.tr,
                      onAction: () async {
                        await Get.toNamed<void>(AppRoutes.resumeBuilder);
                        if (mounted) _ats.analyze();
                      },
                    ),
                  if (!empty) ...[
                    const SizedBox(height: AppSpacing.icon),
                    AppButton(
                      key: const ValueKey('ats-recheck'),
                      label: 'ats_recheck'.tr,
                      icon: Icons.refresh,
                      fullWidth: true,
                      onPressed: _ats.isApplyingTemplate.value
                          ? null
                          : () {
                              _ats.analyze();
                            },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: const ValueKey('ats-use-template'),
                      label: 'ats_use_template'.tr,
                      icon: Icons.description_outlined,
                      fullWidth: true,
                      isLoading: _ats.isApplyingTemplate.value,
                      onPressed: () async {
                        final saved = await _ats.useAtsTemplate();
                        if (saved && context.mounted) {
                          AppSnackbar.success(
                            context,
                            'ats_template_applied'.tr,
                          );
                        }
                      },
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
