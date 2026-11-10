import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/ats_score_model.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Findings sorted by severity, each with a direct editing action.
class AtsIssuesList extends StatelessWidget {
  const AtsIssuesList({super.key, required this.issues, required this.onEdit});
  final List<AtsIssue> issues;
  final Future<void> Function() onEdit;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color severityColor(String severity) => switch (severity) {
      'critical' => scheme.error,
      'warning' =>
        Theme.of(context).brightness == Brightness.dark
            ? AppColors.accent
            : AppColors.warningForeground,
      _ => scheme.primary,
    };
    final sorted = [
      for (final severity in AtsIssue.severities)
        ...issues.where((issue) => issue.severity == severity),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: 'ats_issues'.tr),
        const SizedBox(height: AppSpacing.md),
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('ats_no_issues'.tr),
          ),
        for (var index = 0; index < sorted.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              key: ValueKey('ats-issue-$index'),
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Icon(
                          sorted[index].severity == 'critical'
                              ? Icons.error_outline
                              : sorted[index].severity == 'warning'
                              ? Icons.warning_amber_outlined
                              : Icons.info_outline,
                          color: severityColor(sorted[index].severity),
                        ),
                        Text(
                          'ats_severity_${sorted[index].severity}'.tr,
                          style: TextStyle(
                            color: severityColor(sorted[index].severity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('ats_section_${sorted[index].category}'.tr),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(sorted[index].description),
                    const SizedBox(height: AppSpacing.sm),
                    Text(sorted[index].suggestion),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: ValueKey('ats-edit-issue-$index'),
                      label: 'ats_edit_resume'.tr,
                      icon: Icons.edit_outlined,
                      fullWidth: true,
                      variant: AppButtonVariant.secondary,
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
