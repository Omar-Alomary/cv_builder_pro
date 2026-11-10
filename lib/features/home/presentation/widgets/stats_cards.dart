import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../controllers/template_controller.dart';

/// Compact live totals without background cards or shadows.
class StatsCards extends StatelessWidget {
  const StatsCards({super.key, required this.onViewResumes});
  final VoidCallback onViewResumes;
  @override
  Widget build(BuildContext context) {
    final resumes = Get.find<ResumeController>(),
        templates = Get.find<TemplateController>();
    return Obx(
      () => Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xs,
        children: [
          for (final entry in [
            (
              Icons.description_outlined,
              'resumes'.tr,
              resumes.resumes.length,
              onViewResumes,
            ),
            (
              Icons.grid_view_outlined,
              'templates'.tr,
              templates.templates.length,
              () => Get.toNamed<void>(AppRoutes.templates),
            ),
            (
              Icons.favorite_outline,
              'favorites'.tr,
              resumes.getFavoriteResumes().length,
              () => Get.toNamed<void>(AppRoutes.favorites),
            ),
          ].indexed)
            TextButton(
              key: ValueKey('stat-${entry.$1}'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                padding: EdgeInsets.zero,
              ),
              onPressed: entry.$2.$4,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                children: [
                  Icon(entry.$2.$1, size: AppSpacing.lg),
                  Text(
                    '${entry.$2.$3}',
                    style: AppTextStyles.resolve(
                      context,
                      AppTextStyles.caption,
                    ),
                  ),
                  Text(
                    entry.$2.$2,
                    style: AppTextStyles.resolve(
                      context,
                      AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
