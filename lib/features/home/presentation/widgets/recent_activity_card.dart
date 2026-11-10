import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';

/// Compact horizontal resume tile retaining edit, favorite and delete actions.
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.resume,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });
  final ResumeModel resume;
  final VoidCallback onEdit;
  final FutureOr<void> Function() onDelete, onFavorite;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = resume.fullName.trim().isEmpty
        ? 'untitled_resume'.tr
        : resume.fullName;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppAvatar(
                  name: name,
                  heroTag: resume.id == null ? null : 'cv-resume-${resume.id}',
                  size: AppSpacing.xxl,
                  image: resume.profilePicture?.isNotEmpty == true
                      ? FileImage(File(resume.profilePicture!))
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.resolve(context, AppTextStyles.label),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              DateFormatter.relativeTime(
                resume.updatedAt ?? resume.createdAt,
                locale: Get.locale?.languageCode ?? 'en',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.caption,
              ).copyWith(color: scheme.onSurfaceVariant),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  key: ValueKey('edit-resume-${resume.id}'),
                  tooltip: 'edit'.tr,
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: AppSpacing.icon,
                    color: scheme.primary,
                  ),
                ),
                IconButton(
                  key: ValueKey('change-template-resume-${resume.id}'),
                  tooltip: 'change_template'.tr,
                  onPressed: () => ResumeTemplatePicker.show(context, resume),
                  icon: Icon(
                    Icons.palette_outlined,
                    size: AppSpacing.icon,
                    color: scheme.primary,
                  ),
                ),
                IconButton(
                  key: ValueKey('favorite-resume-${resume.id}'),
                  tooltip: 'favorites'.tr,
                  onPressed: () async {
                    await onFavorite();
                  },
                  icon: Icon(
                    resume.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: AppSpacing.icon,
                    color: scheme.primary,
                  ),
                ),
                IconButton(
                  key: ValueKey('delete-resume-${resume.id}'),
                  tooltip: 'delete'.tr,
                  onPressed: () async {
                    await onDelete();
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    size: AppSpacing.icon,
                    color: scheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
