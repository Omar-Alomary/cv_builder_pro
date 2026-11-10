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
