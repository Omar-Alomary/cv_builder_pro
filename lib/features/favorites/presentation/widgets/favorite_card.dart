import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../app/theme/index.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';

/// Saved favorite with profile fallback and accessible editing actions.
class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.resume,
    required this.onEdit,
    required this.onRemove,
  });
  final ResumeModel resume;
  final Future<void> Function() onEdit;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final name = resume.fullName.trim().isEmpty
        ? 'untitled_resume'.tr
        : resume.fullName;
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('swipe-favorite-${resume.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onRemove();
        // Persisted controller state removes the card; cancellation or failure
        // leaves it in place instead of optimistically hiding the resume.
        return false;
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppRadii.card,
        ),
        child: Icon(
          Icons.heart_broken_outlined,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: AppAvatar(
                    heroTag: resume.id == null
                        ? null
                        : 'cv-resume-${resume.id}',
                    name: name,
                    size: AppSpacing.xxxl,
                    image: resume.profilePicture?.isNotEmpty == true
                        ? FileImage(File(resume.profilePicture!))
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.resolve(context, AppTextStyles.h4),
                  ),
                ),
              ],
            ),
            if (resume.email.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                resume.email,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'last_saved'.trParams({
                'time': DateFormatter.relativeTime(
                  resume.updatedAt ?? resume.createdAt,
                  locale: Get.locale?.languageCode ?? 'en',
                ),
              }),
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.caption,
              ).copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (resume.skills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: resume.skills
                    .take(3)
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: ValueKey('edit-favorite-${resume.id}'),
              label: 'edit_resume'.tr,
              icon: Icons.edit_outlined,
              fullWidth: true,
              onPressed: onEdit,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              key: ValueKey('remove-favorite-${resume.id}'),
              label: 'remove_favorite'.tr,
              icon: Icons.favorite,
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
