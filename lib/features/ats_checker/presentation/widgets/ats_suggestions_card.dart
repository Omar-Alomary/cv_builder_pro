import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../../../../app/theme/index.dart';

/// Improvement checklist and missing keyword labels from the current analysis.
class AtsSuggestionsCard extends StatelessWidget {
  const AtsSuggestionsCard({
    super.key,
    required this.suggestions,
    required this.missingKeywords,
    required this.onEdit,
  });
  final List<String> suggestions;
  final List<String> missingKeywords;
  final Future<void> Function() onEdit;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: 'ats_suggestions'.tr),
          if (suggestions.isEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('ats_no_issues'.tr),
          ],
          for (final suggestion in suggestions)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text('• $suggestion'),
            ),
          if (missingKeywords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.icon),
            Text(
              'ats_missing_keywords'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: missingKeywords
                  .map((word) => Chip(label: Text(word)))
                  .toList(),
            ),
          ],
          if (suggestions.isNotEmpty || missingKeywords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'ats_edit_resume'.tr,
              fullWidth: true,
              onPressed: onEdit,
            ),
          ],
        ],
      ),
    ),
  );
}
